-- =====================================================================
-- VulnFollowUp - schema.sql (T03, lleva Pablo)
-- PostgreSQL 16. Crea las tablas, claves, restricciones e indices.
--
-- ATENCION: el bloque DROP del principio borra TODO. Esta pensado para la
-- base de desarrollo/demo (reinicializable). No lo ejecutes en una base con
-- datos que quieras conservar.
--
-- Convenciones: tablas y columnas en ingles (snake_case); los CODIGOS de
-- estado, severidad, etc. en MAYUSCULAS en espanol, como fija
-- docs/decisiones_tecnicas.md. Los JSON de la API usan los nombres del
-- contrato (docs/api/README.md); el mapeo lo hacen las entidades/DTO.
-- =====================================================================

DROP TABLE IF EXISTS jobs, audit_events, comments, cvss_assessments,
    vulnerability_assets, vulnerabilities, assets, providers, users, roles CASCADE;

-- ---------------------------------------------------------------------
-- Roles y usuarios (identidades separadas de los activos y responsables)
-- ---------------------------------------------------------------------
CREATE TABLE roles (
    id    SMALLINT    PRIMARY KEY,
    name  VARCHAR(20) NOT NULL UNIQUE,
    CONSTRAINT ck_roles_name CHECK (name IN ('ADMIN', 'ANALYST', 'VIEWER'))
);

CREATE TABLE users (
    id             BIGSERIAL    PRIMARY KEY,
    username       VARCHAR(50)  NOT NULL UNIQUE,
    password_hash  VARCHAR(100) NOT NULL,          -- BCrypt, nunca texto plano
    role_id        SMALLINT     NOT NULL REFERENCES roles (id),
    active         BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at     TIMESTAMPTZ  NOT NULL DEFAULT now(),
    CONSTRAINT ck_users_username CHECK (length(trim(username)) >= 3)
);

-- ---------------------------------------------------------------------
-- Proveedores TIC y activos (un proveedor por activo; proveedor opcional)
-- ---------------------------------------------------------------------
CREATE TABLE providers (
    id                   BIGSERIAL    PRIMARY KEY,
    name                 VARCHAR(100) NOT NULL UNIQUE,
    service              VARCHAR(150) NOT NULL,
    criticality          VARCHAR(10)  NOT NULL,
    contract_reference   VARCHAR(50),
    contact              VARCHAR(150),
    last_review          DATE,
    active               BOOLEAN      NOT NULL DEFAULT TRUE,
    CONSTRAINT ck_providers_criticality CHECK (criticality IN ('BAJA', 'MEDIA', 'ALTA'))
);

CREATE TABLE assets (
    id           BIGSERIAL    PRIMARY KEY,
    name         VARCHAR(120) NOT NULL,
    type         VARCHAR(30)  NOT NULL,
    responsible  VARCHAR(100) NOT NULL,
    environment  VARCHAR(20)  NOT NULL,
    status       VARCHAR(10)  NOT NULL DEFAULT 'ACTIVO',
    provider_id  BIGINT       REFERENCES providers (id) ON DELETE RESTRICT,
    created_at   TIMESTAMPTZ  NOT NULL DEFAULT now(),
    CONSTRAINT ck_assets_type CHECK (type IN
        ('SERVICIO_WEB', 'INFRAESTRUCTURA', 'APLICACION', 'BASE_DATOS', 'ESTACION_TRABAJO', 'RED')),
    CONSTRAINT ck_assets_environment CHECK (environment IN ('PRODUCCION', 'PREPRODUCCION', 'DESARROLLO')),
    CONSTRAINT ck_assets_status CHECK (status IN ('ACTIVO', 'INACTIVO')),
    CONSTRAINT uq_assets_name_env UNIQUE (name, environment)
);

-- ---------------------------------------------------------------------
-- Vulnerabilidades
--  * id: identificador interno VFU-0001 (o un CVE si se importa uno real)
--  * version: control de concurrencia optimista (T10): +1 en cada cambio
--  * Para salir de ABIERTA hacen falta responsable y fecha objetivo
-- ---------------------------------------------------------------------
CREATE TABLE vulnerabilities (
    id            VARCHAR(20)  PRIMARY KEY,
    title         VARCHAR(200) NOT NULL,
    description   TEXT,
    refs          TEXT,                                -- referencias (URLs, avisos)
    detected_at   DATE         NOT NULL DEFAULT CURRENT_DATE,
    status        VARCHAR(25)  NOT NULL DEFAULT 'ABIERTA',
    responsible   VARCHAR(100),
    target_date   DATE,
    version       INTEGER      NOT NULL DEFAULT 0,
    created_at    TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at    TIMESTAMPTZ  NOT NULL DEFAULT now(),
    CONSTRAINT ck_vuln_id CHECK (id ~ '^(VFU-[0-9]{4,}|CVE-[0-9]{4}-[0-9]{4,})$'),
    CONSTRAINT ck_vuln_status CHECK (status IN
        ('ABIERTA', 'PENDIENTE_REMEDIACION', 'RESUELTA', 'CERRADA')),
    CONSTRAINT ck_vuln_owner_when_not_open CHECK
        (status = 'ABIERTA' OR (responsible IS NOT NULL AND target_date IS NOT NULL)),
    CONSTRAINT ck_vuln_version CHECK (version >= 0)
);

-- Relacion N:M: una vulnerabilidad afecta a varios activos y viceversa.
-- La pareja no puede repetirse (clave primaria compuesta).
CREATE TABLE vulnerability_assets (
    vulnerability_id  VARCHAR(20) NOT NULL REFERENCES vulnerabilities (id) ON DELETE CASCADE,
    asset_id          BIGINT      NOT NULL REFERENCES assets (id) ON DELETE RESTRICT,
    PRIMARY KEY (vulnerability_id, asset_id)
);

-- Valoracion CVSS actual (una por vulnerabilidad). Solo CVSS 3.1 Base (T01).
-- La severidad debe ser coherente con el score segun los rangos NVD/FIRST.
CREATE TABLE cvss_assessments (
    id                BIGSERIAL    PRIMARY KEY,
    vulnerability_id  VARCHAR(20)  NOT NULL UNIQUE REFERENCES vulnerabilities (id) ON DELETE CASCADE,
    cvss_version      VARCHAR(5)   NOT NULL DEFAULT '3.1',
    vector            VARCHAR(100) NOT NULL,
    score             NUMERIC(3,1) NOT NULL,
    severity          VARCHAR(12)  NOT NULL,
    assessed_at       TIMESTAMPTZ  NOT NULL DEFAULT now(),
    assessed_by       BIGINT       NOT NULL REFERENCES users (id),
    CONSTRAINT ck_cvss_version CHECK (cvss_version = '3.1'),
    CONSTRAINT ck_cvss_vector CHECK (vector ~
        '^CVSS:3\.1/AV:[NALP]/AC:[LH]/PR:[NLH]/UI:[NR]/S:[UC]/C:[NLH]/I:[NLH]/A:[NLH]$'),
    CONSTRAINT ck_cvss_score_range CHECK (score >= 0 AND score <= 10),
    CONSTRAINT ck_cvss_severity CHECK (
           (score = 0               AND severity = 'INFORMATIVA')
        OR (score > 0 AND score < 4  AND severity = 'BAJA')
        OR (score >= 4 AND score < 7 AND severity = 'MEDIA')
        OR (score >= 7 AND score < 9 AND severity = 'ALTA')
        OR (score >= 9               AND severity = 'CRITICA'))
);

-- ---------------------------------------------------------------------
-- Comentarios con evidencia y auditoria
-- ---------------------------------------------------------------------
CREATE TABLE comments (
    id                BIGSERIAL    PRIMARY KEY,
    vulnerability_id  VARCHAR(20)  NOT NULL REFERENCES vulnerabilities (id) ON DELETE CASCADE,
    author_id         BIGINT       NOT NULL REFERENCES users (id),
    created_at        TIMESTAMPTZ  NOT NULL DEFAULT now(),
    text              TEXT         NOT NULL,
    evidence          TEXT,
    CONSTRAINT ck_comments_text CHECK (length(trim(text)) > 0)
);

-- Auditoria generica: sin clave foranea a la entidad para que el historial
-- sobreviva aunque se desactive o se retire lo auditado.
CREATE TABLE audit_events (
    id            BIGSERIAL    PRIMARY KEY,
    entity_type   VARCHAR(20)  NOT NULL,
    entity_id     VARCHAR(50)  NOT NULL,
    action        VARCHAR(30)  NOT NULL,       -- CREATE, UPDATE, STATUS_CHANGE, IMPORT...
    old_value     TEXT,
    new_value     TEXT,
    performed_by  BIGINT       NOT NULL REFERENCES users (id),
    performed_at  TIMESTAMPTZ  NOT NULL DEFAULT now(),
    CONSTRAINT ck_audit_entity CHECK (entity_type IN
        ('VULNERABILITY', 'ASSET', 'PROVIDER', 'USER', 'IMPORT'))
);

-- Seguimiento de importaciones e informes (compartida por T08 y T11).
CREATE TABLE jobs (
    id                 BIGSERIAL    PRIMARY KEY,
    type               VARCHAR(10)  NOT NULL,
    status             VARCHAR(10)  NOT NULL DEFAULT 'PENDING',
    created_by         BIGINT       NOT NULL REFERENCES users (id),
    created_at         TIMESTAMPTZ  NOT NULL DEFAULT now(),
    finished_at        TIMESTAMPTZ,
    records_processed  INTEGER      NOT NULL DEFAULT 0,
    message            TEXT,
    CONSTRAINT ck_jobs_type CHECK (type IN ('IMPORT', 'REPORT')),
    CONSTRAINT ck_jobs_status CHECK (status IN ('PENDING', 'RUNNING', 'COMPLETED', 'FAILED')),
    CONSTRAINT ck_jobs_records CHECK (records_processed >= 0)
);

-- ---------------------------------------------------------------------
-- Indices (filtros del listado, dashboard e informe de proveedor)
-- ---------------------------------------------------------------------
CREATE INDEX ix_assets_provider        ON assets (provider_id);
CREATE INDEX ix_vuln_status            ON vulnerabilities (status);
CREATE INDEX ix_vuln_responsible       ON vulnerabilities (responsible);
CREATE INDEX ix_va_asset               ON vulnerability_assets (asset_id);
CREATE INDEX ix_cvss_severity_score    ON cvss_assessments (severity, score);
CREATE INDEX ix_comments_vuln          ON comments (vulnerability_id, created_at);
CREATE INDEX ix_audit_entity           ON audit_events (entity_type, entity_id, performed_at);
