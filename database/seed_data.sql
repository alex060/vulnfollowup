-- =====================================================================
-- VulnFollowUp - seed_data.sql (T03, lleva Pablo)
-- Datos de prueba SINTETICOS. Ejecutar despues de schema.sql, en base vacia.
-- Las vulnerabilidades VFU-xxxx son inventadas, no son CVE reales.
-- Cuentas de prueba (solo desarrollo; contrasenas en texto aqui y BCrypt en BD):
--   admin / Admin123!      analyst / Analyst123!      viewer / Viewer123!
-- Los scores CVSS 3.1 estan calculados con la formula oficial; conviene
-- contrastarlos con la calculadora de FIRST (tarea T07/T08).
-- =====================================================================

BEGIN;

INSERT INTO roles (id, name) VALUES (1, 'ADMIN'), (2, 'ANALYST'), (3, 'VIEWER');

INSERT INTO users (id, username, password_hash, role_id) VALUES
 (1, 'admin',   '$2a$10$X4IMwHV5z/iA5h5v/7XKC.L98Ucr0odPKw7lHqiTgJmQfCRUv9zpy', 1),
 (2, 'analyst', '$2a$10$IZB.QHpjcVd9z0bmSB/a0Oqnnv.7PJV.g3WxDHKJ9/XkBIFguQ7m2', 2),
 (3, 'viewer',  '$2a$10$LunJ8Kn11fUgpG2UWSLlEefof8aO6U05YMKfL/d.JV5ykpQIOzVhy', 3);

-- Proveedores ficticios. PagoSeguro tiene la revision vencida; SoporteLocal no tiene activos.
INSERT INTO providers (id, name, service, criticality, contract_reference, contact, last_review) VALUES
 (1, 'HostingSur',   'Hosting Cloud e Infraestructura', 'ALTA',  'CONT-2026-091', 'soporte@hostingsur.ejemplo.es',  '2026-10-15'),
 (2, 'PagoSeguro',   'Pasarela de pagos',               'ALTA',  'CONT-2025-044', 'contacto@pagoseguro.ejemplo.es', '2025-09-01'),
 (3, 'CorreoNube',   'Correo corporativo SaaS',         'MEDIA', 'CONT-2026-017', 'ayuda@correonube.ejemplo.es',    '2026-06-20'),
 (4, 'SoporteLocal', 'Mantenimiento de puestos',        'BAJA',  'CONT-2026-120', 'tecnico@soportelocal.ejemplo.es','2026-09-10');

INSERT INTO assets (id, name, type, responsible, environment, status, provider_id) VALUES
 (1, 'API de pagos',                         'SERVICIO_WEB',     'Equipo Pasarela', 'PRODUCCION', 'ACTIVO',   1),
 (2, 'Servidor de Base de Datos Principal',  'INFRAESTRUCTURA',  'Equipo DBA',      'PRODUCCION', 'ACTIVO',   1),
 (3, 'Pasarela de cobros',                   'SERVICIO_WEB',     'Equipo Pasarela', 'PRODUCCION', 'ACTIVO',   2),
 (4, 'Portal de clientes',                   'APLICACION',       'Equipo Web',      'PRODUCCION', 'ACTIVO',   1),
 (5, 'Correo corporativo',                   'APLICACION',       'Equipo Sistemas', 'PRODUCCION', 'ACTIVO',   3),
 (6, 'Portatil de administracion',           'ESTACION_TRABAJO', 'Equipo Sistemas', 'PRODUCCION', 'ACTIVO',   NULL),
 (7, 'Portal de clientes (pruebas)',         'APLICACION',       'Equipo Web',      'DESARROLLO', 'ACTIVO',   1),
 (8, 'Servidor antiguo de ficheros',         'INFRAESTRUCTURA',  'Equipo Sistemas', 'PRODUCCION', 'INACTIVO', NULL);

-- Vulnerabilidades: una por estado y varias severidades.
-- version = numero de cambios guardados (control de concurrencia optimista).
INSERT INTO vulnerabilities (id, title, description, refs, detected_at, status, responsible, target_date, version) VALUES
 ('VFU-0001', 'Inyeccion SQL en endpoint de autenticacion',
  'Fallo de sanitizacion que permite saltarse el login.',
  'Informe interno de pruebas 2026-11', '2026-11-02', 'ABIERTA', NULL, NULL, 0),
 ('VFU-0002', 'Exposicion de datos en el listado de clientes',
  'El listado devuelve campos que el rol no deberia ver.',
  'Informe interno de pruebas 2026-10', '2026-10-20', 'PENDIENTE_REMEDIACION', 'Equipo Web', '2026-12-15', 1),
 ('VFU-0003', 'XSS reflejado en el buscador del portal',
  'El texto buscado se muestra sin escapar.',
  'Informe interno de pruebas 2026-10', '2026-10-05', 'RESUELTA', 'Equipo Web', '2026-11-20', 2),
 ('VFU-0004', 'Escalada local de privilegios en el servidor de BD',
  'Un usuario local con pocos permisos puede ejecutar como administrador.',
  'Aviso del proveedor, septiembre 2026', '2026-09-12', 'CERRADA', 'Equipo DBA', '2026-10-10', 3),
 ('VFU-0005', 'Configuracion TLS debil en la pasarela de cobros',
  'Se aceptan conexiones con parametros de cifrado inadecuados.',
  'Aviso del proveedor, noviembre 2026', '2026-11-10', 'ABIERTA', NULL, NULL, 0),
 ('VFU-0006', 'Fuga de informacion en logs del portatil de administracion',
  'Los registros locales incluyen datos de sesion.',
  NULL, '2026-11-05', 'ABIERTA', NULL, NULL, 0),
 ('VFU-0007', 'Ejecucion remota de codigo en el flujo de cobro',
  'Una entrada manipulada ejecuta codigo en pasarela y API de pagos.',
  'Informe interno de pruebas 2026-11', '2026-11-12', 'PENDIENTE_REMEDIACION', 'Equipo Pasarela', '2026-11-25', 1),
 ('VFU-0008', 'Observacion informativa: cabeceras HTTP mejorables',
  'Sin impacto directo; recomendacion de endurecimiento.',
  NULL, '2026-11-01', 'ABIERTA', NULL, NULL, 0);

-- Relacion N:M. VFU-0001 y VFU-0003 afectan a dos activos del MISMO proveedor
-- (HostingSur); VFU-0007 afecta a activos de DOS proveedores distintos.
INSERT INTO vulnerability_assets (vulnerability_id, asset_id) VALUES
 ('VFU-0001', 1), ('VFU-0001', 2),
 ('VFU-0002', 4),
 ('VFU-0003', 4), ('VFU-0003', 7),
 ('VFU-0004', 2),
 ('VFU-0005', 3),
 ('VFU-0006', 6),
 ('VFU-0007', 3), ('VFU-0007', 1),
 ('VFU-0008', 5);

INSERT INTO cvss_assessments (vulnerability_id, cvss_version, vector, score, severity, assessed_by) VALUES
 ('VFU-0001', '3.1', 'CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H',  9.8, 'CRITICA',     2),
 ('VFU-0002', '3.1', 'CVSS:3.1/AV:N/AC:L/PR:L/UI:N/S:U/C:H/I:N/A:N',  6.5, 'MEDIA',       2),
 ('VFU-0003', '3.1', 'CVSS:3.1/AV:N/AC:L/PR:N/UI:R/S:C/C:L/I:L/A:N',  6.1, 'MEDIA',       2),
 ('VFU-0004', '3.1', 'CVSS:3.1/AV:L/AC:L/PR:L/UI:N/S:U/C:H/I:H/A:H',  7.8, 'ALTA',        2),
 ('VFU-0005', '3.1', 'CVSS:3.1/AV:N/AC:H/PR:N/UI:N/S:U/C:H/I:H/A:H',  8.1, 'ALTA',        2),
 ('VFU-0006', '3.1', 'CVSS:3.1/AV:L/AC:H/PR:L/UI:R/S:U/C:L/I:N/A:N',  2.2, 'BAJA',        2),
 ('VFU-0007', '3.1', 'CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:C/C:H/I:H/A:H', 10.0, 'CRITICA',     2),
 ('VFU-0008', '3.1', 'CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:N/I:N/A:N',  0.0, 'INFORMATIVA', 2);

INSERT INTO comments (vulnerability_id, author_id, created_at, text, evidence) VALUES
 ('VFU-0002', 2, '2026-10-22 09:30+01', 'Se asigna al Equipo Web; se revisara la consulta del listado.', NULL),
 ('VFU-0003', 2, '2026-11-09 12:10+01', 'Correccion aplicada: se escapan las entradas del buscador.',
  'Prueba repetida en el entorno de pruebas del portal (activo 7): el ataque ya no funciona.'),
 ('VFU-0004', 2, '2026-10-08 17:45+01', 'Parche del proveedor instalado en el servidor.',
  'Version del parche anotada en el acta de mantenimiento.'),
 ('VFU-0004', 1, '2026-10-12 10:00+01', 'Validado por administracion; se cierra el seguimiento.', NULL),
 ('VFU-0007', 2, '2026-11-13 08:55+01', 'Prioridad maxima: afecta a dos proveedores.', NULL);

-- Auditoria: historial de cambios de estado (coherente con version y estado actual).
INSERT INTO audit_events (entity_type, entity_id, action, old_value, new_value, performed_by, performed_at) VALUES
 ('VULNERABILITY', 'VFU-0002', 'STATUS_CHANGE', 'ABIERTA', 'PENDIENTE_REMEDIACION', 2, '2026-10-22 09:30+01'),
 ('VULNERABILITY', 'VFU-0003', 'STATUS_CHANGE', 'ABIERTA', 'PENDIENTE_REMEDIACION', 2, '2026-10-06 11:00+01'),
 ('VULNERABILITY', 'VFU-0003', 'STATUS_CHANGE', 'PENDIENTE_REMEDIACION', 'RESUELTA', 2, '2026-11-09 12:10+01'),
 ('VULNERABILITY', 'VFU-0004', 'STATUS_CHANGE', 'ABIERTA', 'PENDIENTE_REMEDIACION', 2, '2026-09-13 09:00+01'),
 ('VULNERABILITY', 'VFU-0004', 'STATUS_CHANGE', 'PENDIENTE_REMEDIACION', 'RESUELTA', 2, '2026-10-08 17:45+01'),
 ('VULNERABILITY', 'VFU-0004', 'STATUS_CHANGE', 'RESUELTA', 'CERRADA', 1, '2026-10-12 10:00+01'),
 ('VULNERABILITY', 'VFU-0007', 'STATUS_CHANGE', 'ABIERTA', 'PENDIENTE_REMEDIACION', 2, '2026-11-13 08:55+01');

-- Las filas con id explicito no avanzan las secuencias: se ajustan para que
-- las altas nuevas (POST) no choquen con estos ids.
SELECT setval(pg_get_serial_sequence('users', 'id'),            (SELECT max(id) FROM users));
SELECT setval(pg_get_serial_sequence('providers', 'id'),        (SELECT max(id) FROM providers));
SELECT setval(pg_get_serial_sequence('assets', 'id'),           (SELECT max(id) FROM assets));
SELECT setval(pg_get_serial_sequence('cvss_assessments', 'id'), (SELECT max(id) FROM cvss_assessments));
SELECT setval(pg_get_serial_sequence('comments', 'id'),         (SELECT max(id) FROM comments));
SELECT setval(pg_get_serial_sequence('audit_events', 'id'),     (SELECT max(id) FROM audit_events));

COMMIT;
