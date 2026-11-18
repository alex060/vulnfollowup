-- =====================================================================
-- VulnFollowUp - queries.sql (T03, lleva Pablo)
-- Consultas para filtros, dashboard e informe de proveedores.
-- Los parametros usan la sintaxis :nombre (valen en @Query nativas de Spring
-- Data y como variables de psql: \set severity '''CRITICA''' / \set minScore NULL).
-- Los CAST evitan el error "could not determine data type of parameter"
-- de PostgreSQL cuando un filtro opcional llega como NULL.
-- =====================================================================

-- ---------------------------------------------------------------------
-- Q1. Listado de vulnerabilidades con filtros opcionales, orden y pagina
--     (GET /api/vulnerabilities). Un filtro en NULL no se aplica.
--     El filtro por activo usa EXISTS para no duplicar filas cuando una
--     vulnerabilidad afecta a varios activos.
--     Parametros: severity, status, assetId, responsible, minScore, maxScore,
--                 size (maximo por pagina), offset (= pagina * size)
-- ---------------------------------------------------------------------
SELECT v.id, v.title, v.status, c.score, c.severity,
       v.responsible, v.target_date, v.version
FROM vulnerabilities v
JOIN cvss_assessments c ON c.vulnerability_id = v.id
WHERE (CAST(:severity    AS VARCHAR) IS NULL OR c.severity    = CAST(:severity    AS VARCHAR))
  AND (CAST(:status      AS VARCHAR) IS NULL OR v.status      = CAST(:status      AS VARCHAR))
  AND (CAST(:responsible AS VARCHAR) IS NULL OR v.responsible = CAST(:responsible AS VARCHAR))
  AND (CAST(:minScore    AS NUMERIC) IS NULL OR c.score      >= CAST(:minScore    AS NUMERIC))
  AND (CAST(:maxScore    AS NUMERIC) IS NULL OR c.score      <= CAST(:maxScore    AS NUMERIC))
  AND (CAST(:assetId     AS BIGINT)  IS NULL OR EXISTS (
         SELECT 1 FROM vulnerability_assets va
         WHERE va.vulnerability_id = v.id AND va.asset_id = CAST(:assetId AS BIGINT)))
ORDER BY c.score DESC, v.id
LIMIT :size OFFSET :offset;
-- (Si minScore > maxScore, la API debe responder 400 antes de llegar aqui.)

-- ---------------------------------------------------------------------
-- Q2. Detalle de una vulnerabilidad con CVSS y activos afectados
--     (GET /api/vulnerabilities/{id}). Parametro: id
-- ---------------------------------------------------------------------
SELECT v.id, v.title, v.description, v.refs, v.detected_at, v.status,
       v.responsible, v.target_date, v.version,
       c.cvss_version, c.vector, c.score, c.severity,
       (SELECT string_agg(a.id || ':' || a.name, ' | ' ORDER BY a.id)
          FROM vulnerability_assets va JOIN assets a ON a.id = va.asset_id
         WHERE va.vulnerability_id = v.id) AS affected_assets
FROM vulnerabilities v
LEFT JOIN cvss_assessments c ON c.vulnerability_id = v.id
WHERE v.id = :id;

-- Comentarios y evidencias de una vulnerabilidad. Parametro: id
SELECT cm.created_at, u.username AS author, cm.text, cm.evidence
FROM comments cm JOIN users u ON u.id = cm.author_id
WHERE cm.vulnerability_id = :id
ORDER BY cm.created_at;

-- Auditoria de una vulnerabilidad. Parametro: id
SELECT ae.performed_at, u.username AS performed_by, ae.action, ae.old_value, ae.new_value
FROM audit_events ae JOIN users u ON u.id = ae.performed_by
WHERE ae.entity_type = 'VULNERABILITY' AND ae.entity_id = :id
ORDER BY ae.performed_at;

-- ---------------------------------------------------------------------
-- Q3. Dashboard (GET /api/dashboard/summary). Incluye categorias con 0.
-- ---------------------------------------------------------------------
-- Totales
SELECT (SELECT count(*) FROM assets WHERE status = 'ACTIVO') AS total_assets,
       (SELECT count(*) FROM vulnerabilities)                AS total_vulnerabilities;

-- Por severidad
SELECT s.severity, count(c.id) AS total
FROM (VALUES ('CRITICA'), ('ALTA'), ('MEDIA'), ('BAJA'), ('INFORMATIVA')) AS s(severity)
LEFT JOIN cvss_assessments c ON c.severity = s.severity
GROUP BY s.severity
ORDER BY array_position(ARRAY['CRITICA','ALTA','MEDIA','BAJA','INFORMATIVA'], s.severity);

-- Por estado
SELECT s.status, count(v.id) AS total
FROM (VALUES ('ABIERTA'), ('PENDIENTE_REMEDIACION'), ('RESUELTA'), ('CERRADA')) AS s(status)
LEFT JOIN vulnerabilities v ON v.status = s.status
GROUP BY s.status
ORDER BY array_position(ARRAY['ABIERTA','PENDIENTE_REMEDIACION','RESUELTA','CERRADA'], s.status);

-- ---------------------------------------------------------------------
-- Q4. Informe de proveedor (GET /api/providers/{id}/report). Parametro: providerId
--     "Pendiente" = ABIERTA o PENDIENTE_REMEDIACION (una RESUELTA ya no cuenta).
--     COUNT(DISTINCT ...) evita contar dos veces una vulnerabilidad que afecta
--     a varios activos del mismo proveedor.
-- ---------------------------------------------------------------------
SELECT p.id AS provider_id, p.name,
       count(DISTINCT a.id)                                      AS total_assets,
       count(DISTINCT v.id)                                      AS pending_vulnerabilities,
       count(DISTINCT v.id) FILTER (WHERE c.severity = 'CRITICA') AS critical_vulnerabilities
FROM providers p
LEFT JOIN assets a                ON a.provider_id = p.id AND a.status = 'ACTIVO'
LEFT JOIN vulnerability_assets va ON va.asset_id = a.id
LEFT JOIN vulnerabilities v       ON v.id = va.vulnerability_id
                                 AND v.status IN ('ABIERTA', 'PENDIENTE_REMEDIACION')
LEFT JOIN cvss_assessments c      ON c.vulnerability_id = v.id
WHERE p.id = :providerId
GROUP BY p.id, p.name;

-- Detalle de pendientes del proveedor: cada vulnerabilidad UNA vez, con sus activos.
SELECT v.id, v.title, v.status, c.severity, c.score, v.target_date,
       string_agg(DISTINCT a.name, ', ' ORDER BY a.name) AS affected_assets_of_provider
FROM assets a
JOIN vulnerability_assets va ON va.asset_id = a.id
JOIN vulnerabilities v       ON v.id = va.vulnerability_id
JOIN cvss_assessments c      ON c.vulnerability_id = v.id
WHERE a.provider_id = :providerId AND a.status = 'ACTIVO'
  AND v.status IN ('ABIERTA', 'PENDIENTE_REMEDIACION')
GROUP BY v.id, v.title, v.status, c.severity, c.score, v.target_date
ORDER BY c.score DESC, v.id;

-- Demostracion de la "pregunta clave" (si una vulnerabilidad afecta a dos
-- activos del mismo proveedor, cuenta una): comparar ambos recuentos.
SELECT p.name,
       count(*)             AS filas_sin_distinct,   -- INFLADO
       count(DISTINCT v.id) AS vulnerabilidades_reales
FROM providers p
JOIN assets a                ON a.provider_id = p.id
JOIN vulnerability_assets va ON va.asset_id = a.id
JOIN vulnerabilities v       ON v.id = va.vulnerability_id
WHERE v.status IN ('ABIERTA', 'PENDIENTE_REMEDIACION')
GROUP BY p.name
ORDER BY p.name;

-- ---------------------------------------------------------------------
-- Q5. BORRADOR para T12 (regla de riesgo; la decide quien lleva T12):
--     "En riesgo" = proveedor de criticidad ALTA con alguna vulnerabilidad
--     CRITICA ABIERTA/PENDIENTE; "Revision pendiente" = ultima revision de
--     hace mas de 12 meses (plazo supuesto: no fijado en la guia).
--     Combinadas con "y" para En riesgo; las dos marcas son independientes.
-- ---------------------------------------------------------------------
SELECT p.id, p.name, p.criticality,
       (p.criticality = 'ALTA' AND count(DISTINCT v.id) FILTER (WHERE c.severity = 'CRITICA') > 0) AS en_riesgo,
       (p.last_review IS NULL OR p.last_review < CURRENT_DATE - INTERVAL '12 months')             AS revision_pendiente
FROM providers p
LEFT JOIN assets a                ON a.provider_id = p.id AND a.status = 'ACTIVO'
LEFT JOIN vulnerability_assets va ON va.asset_id = a.id
LEFT JOIN vulnerabilities v       ON v.id = va.vulnerability_id
                                 AND v.status IN ('ABIERTA', 'PENDIENTE_REMEDIACION')
LEFT JOIN cvss_assessments c      ON c.vulnerability_id = v.id
GROUP BY p.id, p.name, p.criticality, p.last_review
ORDER BY p.id;
