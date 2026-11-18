# Diagrama entidad-relación (T03)

Se ve dibujado en GitHub, en VS Code (extensión Mermaid) o pegándolo en <https://mermaid.live>.

```mermaid
erDiagram
    ROLES ||--o{ USERS : "tiene"
    PROVIDERS |o--o{ ASSETS : "presta (opcional)"
    VULNERABILITIES ||--o{ VULNERABILITY_ASSETS : "afecta"
    ASSETS ||--o{ VULNERABILITY_ASSETS : "es afectado"
    VULNERABILITIES ||--o| CVSS_ASSESSMENTS : "valoracion actual"
    VULNERABILITIES ||--o{ COMMENTS : "tiene"
    USERS ||--o{ COMMENTS : "escribe"
    USERS ||--o{ CVSS_ASSESSMENTS : "valora"
    USERS ||--o{ AUDIT_EVENTS : "realiza"
    USERS ||--o{ JOBS : "lanza"

    ROLES {
        smallint id PK
        varchar name "ADMIN, ANALYST, VIEWER"
    }
    USERS {
        bigint id PK
        varchar username UK
        varchar password_hash "BCrypt"
        smallint role_id FK
        boolean active
    }
    PROVIDERS {
        bigint id PK
        varchar name UK
        varchar service
        varchar criticality "BAJA, MEDIA, ALTA"
        varchar contract_reference
        varchar contact
        date last_review
    }
    ASSETS {
        bigint id PK
        varchar name "UK con environment"
        varchar type
        varchar responsible
        varchar environment
        varchar status "ACTIVO, INACTIVO"
        bigint provider_id FK "puede ser nulo"
    }
    VULNERABILITIES {
        varchar id PK "VFU-0001"
        varchar title
        text description
        varchar status "4 estados"
        varchar responsible
        date target_date
        int version "concurrencia optimista"
    }
    VULNERABILITY_ASSETS {
        varchar vulnerability_id PK,FK
        bigint asset_id PK,FK
    }
    CVSS_ASSESSMENTS {
        bigint id PK
        varchar vulnerability_id FK,UK
        varchar cvss_version "3.1"
        varchar vector
        numeric score "DECIMAL(3,1)"
        varchar severity
        bigint assessed_by FK
    }
    COMMENTS {
        bigint id PK
        varchar vulnerability_id FK
        bigint author_id FK
        text text
        text evidence
    }
    AUDIT_EVENTS {
        bigint id PK
        varchar entity_type
        varchar entity_id "sin FK a proposito"
        varchar action
        text old_value
        text new_value
        bigint performed_by FK
    }
    JOBS {
        bigint id PK
        varchar type "IMPORT, REPORT"
        varchar status
        bigint created_by FK
        int records_processed
    }
```

## Estados de una vulnerabilidad

`ABIERTA` → `PENDIENTE_REMEDIACION` (exige responsable y fecha objetivo) → `RESUELTA` (exige evidencia: comentario) → `CERRADA`.
La base de datos garantiza que fuera de `ABIERTA` haya responsable y fecha. Las **transiciones permitidas** y la evidencia las valida la API (T09).

## Dónde se guarda cada dato del ejemplo VFU-0001

| Dato | Tabla y columna |
| --- | --- |
| Identificador, título, descripción, fecha de detección | `vulnerabilities.id / title / description / detected_at` |
| Estado, responsable, fecha objetivo, versión de edición | `vulnerabilities.status / responsible / target_date / version` |
| Afecta a "API de pagos" y "Servidor de Base de Datos Principal" | dos filas en `vulnerability_assets` (VFU-0001 con activo 1 y con activo 2) |
| Vector, puntuación 9,8 y severidad Crítica | `cvss_assessments.vector / score / severity` |
| Quién la valoró | `cvss_assessments.assessed_by` → `users` |
| Proveedor HostingSur de esos activos | `assets.provider_id` → `providers` |
| Comentarios y evidencias | `comments.text / evidence` |
| Quién cambió el estado y cuándo | `audit_events` |
