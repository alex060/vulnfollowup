-- =====================================================================
-- VulnFollowUp - tests.sql (T03)
-- Ejecutar DESPUES de schema.sql y seed_data.sql:
--   psql -U postgres -d vulnfollowup_db -f tests.sql
-- Cada prueba imprime OK o FALLO. No deja datos modificados (todo se deshace).
-- Las pruebas "rechazar" son las que pide la guia: relacion invalida y
-- asociacion duplicada deben rechazarse (mas otras restricciones).
-- =====================================================================
\set ON_ERROR_STOP off
\pset tuples_only on

-- Intenta ejecutar una sentencia; OK si la base la rechaza, FALLO si la acepta.
CREATE FUNCTION pg_temp.expect_reject(label text, stmt text) RETURNS void AS $$
BEGIN
    EXECUTE stmt;
    RAISE EXCEPTION 'ACEPTADO';
EXCEPTION WHEN OTHERS THEN
    IF SQLERRM = 'ACEPTADO' THEN
        RAISE NOTICE 'FALLO | % -> se acepto y debia rechazarse', label;
    ELSE
        RAISE NOTICE 'OK    | % -> rechazado: %', label, left(SQLERRM, 90);
    END IF;
END $$ LANGUAGE plpgsql;

-- Ejecuta sentencias que DEBEN funcionar; OK si no dan error. Siempre se deshacen.
CREATE FUNCTION pg_temp.expect_accept(label text, stmts text[]) RETURNS void AS $$
DECLARE s text;
BEGIN
    FOREACH s IN ARRAY stmts LOOP EXECUTE s; END LOOP;
    RAISE EXCEPTION 'ACEPTADO';
EXCEPTION WHEN OTHERS THEN
    IF SQLERRM = 'ACEPTADO' THEN
        RAISE NOTICE 'OK    | % -> aceptado correctamente', label;
    ELSE
        RAISE NOTICE 'FALLO | % -> debia aceptarse y dio: %', label, left(SQLERRM, 90);
    END IF;
END $$ LANGUAGE plpgsql;

-- Compara el resultado de una consulta (texto) con lo esperado.
CREATE FUNCTION pg_temp.expect_value(label text, query text, expected text) RETURNS void AS $$
DECLARE got text;
BEGIN
    EXECUTE query INTO got;
    IF got IS NOT DISTINCT FROM expected THEN
        RAISE NOTICE 'OK    | % -> %', label, got;
    ELSE
        RAISE NOTICE 'FALLO | % -> esperado %, obtenido %', label, expected, got;
    END IF;
END $$ LANGUAGE plpgsql;

-- ---- Relaciones (lo que revisa Alex) ----
SELECT pg_temp.expect_reject('Relacion invalida: activo inexistente',
  $q$INSERT INTO vulnerability_assets VALUES ('VFU-0001', 999)$q$);
SELECT pg_temp.expect_reject('Relacion invalida: vulnerabilidad inexistente',
  $q$INSERT INTO vulnerability_assets VALUES ('VFU-9999', 1)$q$);
SELECT pg_temp.expect_reject('Asociacion duplicada (VFU-0001, activo 1)',
  $q$INSERT INTO vulnerability_assets VALUES ('VFU-0001', 1)$q$);
SELECT pg_temp.expect_reject('Activo con proveedor inexistente',
  $q$INSERT INTO assets (name, type, responsible, environment, provider_id)
     VALUES ('X', 'APLICACION', 'Equipo X', 'PRODUCCION', 999)$q$);
SELECT pg_temp.expect_reject('Borrar proveedor que tiene activos',
  $q$DELETE FROM providers WHERE id = 1$q$);
SELECT pg_temp.expect_reject('Borrar activo con vulnerabilidades asociadas',
  $q$DELETE FROM assets WHERE id = 1$q$);

-- ---- Unicidad ----
SELECT pg_temp.expect_reject('Usuario duplicado',
  $q$INSERT INTO users (username, password_hash, role_id) VALUES ('analyst', 'x', 2)$q$);
SELECT pg_temp.expect_reject('Activo duplicado (mismo nombre y entorno)',
  $q$INSERT INTO assets (name, type, responsible, environment)
     VALUES ('API de pagos', 'SERVICIO_WEB', 'Equipo X', 'PRODUCCION')$q$);
SELECT pg_temp.expect_reject('Segunda valoracion CVSS para la misma vulnerabilidad',
  $q$INSERT INTO cvss_assessments (vulnerability_id, vector, score, severity, assessed_by)
     VALUES ('VFU-0001', 'CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:L/I:N/A:N', 5.3, 'MEDIA', 2)$q$);
SELECT pg_temp.expect_reject('Rol inexistente',
  $q$INSERT INTO roles VALUES (9, 'SUPERUSER')$q$);

-- ---- Vulnerabilidades y estados ----
SELECT pg_temp.expect_reject('Identificador con formato invalido',
  $q$INSERT INTO vulnerabilities (id, title) VALUES ('ABC', 'x')$q$);
SELECT pg_temp.expect_reject('Estado inexistente',
  $q$UPDATE vulnerabilities SET status = 'EN_PROCESO' WHERE id = 'VFU-0002'$q$);
SELECT pg_temp.expect_reject('Pasar a PENDIENTE sin responsable ni fecha',
  $q$UPDATE vulnerabilities SET status = 'PENDIENTE_REMEDIACION' WHERE id = 'VFU-0001'$q$);
SELECT pg_temp.expect_reject('Version negativa',
  $q$UPDATE vulnerabilities SET version = -1 WHERE id = 'VFU-0001'$q$);
SELECT pg_temp.expect_reject('Comentario vacio',
  $q$INSERT INTO comments (vulnerability_id, author_id, text) VALUES ('VFU-0001', 2, '   ')$q$);

-- ---- CVSS ----
SELECT pg_temp.expect_reject('CVSS: vector mal formado',
  $q$UPDATE cvss_assessments SET vector = 'AV:N/AC:L' WHERE vulnerability_id = 'VFU-0001'$q$);
SELECT pg_temp.expect_reject('CVSS: version 4.0 (no soportada en esta fase)',
  $q$UPDATE cvss_assessments SET cvss_version = '4.0' WHERE vulnerability_id = 'VFU-0001'$q$);
SELECT pg_temp.expect_reject('CVSS: score mayor de 10',
  $q$UPDATE cvss_assessments SET score = 10.5 WHERE vulnerability_id = 'VFU-0001'$q$);
SELECT pg_temp.expect_reject('CVSS: score negativo',
  $q$UPDATE cvss_assessments SET score = -1 WHERE vulnerability_id = 'VFU-0001'$q$);
SELECT pg_temp.expect_reject('CVSS: severidad incoherente con el score (9,8 como BAJA)',
  $q$UPDATE cvss_assessments SET severity = 'BAJA' WHERE vulnerability_id = 'VFU-0001'$q$);

-- ---- Casos que deben funcionar y resultados esperados ----
SELECT pg_temp.expect_value('Vulnerabilidades cargadas', 'SELECT count(*) FROM vulnerabilities', '8');
SELECT pg_temp.expect_value('Asociaciones cargadas',     'SELECT count(*) FROM vulnerability_assets', '11');
SELECT pg_temp.expect_value('Cuentas de prueba (admin, analyst, viewer)', 'SELECT count(*) FROM users', '3');
SELECT pg_temp.expect_value('Hashes BCrypt (ninguna clave en texto plano)',
  $q$SELECT count(*) FROM users WHERE password_hash NOT LIKE '$2a$%'$q$, '0');
SELECT pg_temp.expect_value('VFU-0001 afecta a 2 activos',
  $q$SELECT count(*) FROM vulnerability_assets WHERE vulnerability_id = 'VFU-0001'$q$, '2');
SELECT pg_temp.expect_value('HostingSur: filas del join (inflado)',
  $q$SELECT count(*) FROM providers p JOIN assets a ON a.provider_id=p.id
     JOIN vulnerability_assets va ON va.asset_id=a.id JOIN vulnerabilities v ON v.id=va.vulnerability_id
     WHERE p.id=1 AND v.status IN ('ABIERTA','PENDIENTE_REMEDIACION')$q$, '4');
SELECT pg_temp.expect_value('HostingSur: pendientes sin duplicar (VFU-0001, 0002, 0007)',
  $q$SELECT count(DISTINCT v.id) FROM providers p JOIN assets a ON a.provider_id=p.id
     JOIN vulnerability_assets va ON va.asset_id=a.id JOIN vulnerabilities v ON v.id=va.vulnerability_id
     WHERE p.id=1 AND v.status IN ('ABIERTA','PENDIENTE_REMEDIACION')$q$, '3');

-- ---- Operaciones validas (se deshacen al terminar cada prueba) ----
SELECT pg_temp.expect_accept('Alta de activo nuevo (la secuencia continua tras los datos de prueba)',
  ARRAY[$q$INSERT INTO assets (name, type, responsible, environment)
           VALUES ('Activo nuevo', 'RED', 'Equipo Redes', 'PRODUCCION')$q$]);
SELECT pg_temp.expect_accept('Alta de vulnerabilidad + valoracion CVSS + activo afectado',
  ARRAY[$q$INSERT INTO vulnerabilities (id, title) VALUES ('VFU-0009', 'Prueba')$q$,
        $q$INSERT INTO cvss_assessments (vulnerability_id, vector, score, severity, assessed_by)
           VALUES ('VFU-0009', 'CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H', 9.8, 'CRITICA', 2)$q$,
        $q$INSERT INTO vulnerability_assets VALUES ('VFU-0009', 1)$q$]);
SELECT pg_temp.expect_accept('Cambio de estado valido: ABIERTA -> PENDIENTE con responsable y fecha, version +1',
  ARRAY[$q$UPDATE vulnerabilities SET status = 'PENDIENTE_REMEDIACION', responsible = 'Equipo Pasarela',
           target_date = '2026-12-31', version = version + 1 WHERE id = 'VFU-0005'$q$]);
SELECT pg_temp.expect_accept('Desactivar un activo en lugar de borrarlo',
  ARRAY[$q$UPDATE assets SET status = 'INACTIVO' WHERE id = 6$q$]);
