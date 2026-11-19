### Ficha T03: Tablas y datos de prueba
* **Identificador y objetivo:** Diseñar el modelo de datos y crear el esquema SQL, datos de prueba y consultas, con restricciones que rechacen datos inválidos.
* **Lleva / Revisa / Demuestra:** Pablo / Alex / Adri.
* **Dependencias:** T01 revisada; T02 entregada (PostgreSQL conecta).
* **Pasos realizados:**
  1. Diagrama entidad-relación en `database/ER_diagrama.md`.
  2. `database/schema.sql`: 10 tablas, claves, restricciones e índices.
  3. `database/seed_data.sql`: usuarios con BCrypt, proveedores, activos, 8 vulnerabilidades con CVSS 3.1, comentarios y auditoría.
  4. `database/queries.sql`: filtros con paginación, detalle, dashboard e informe de proveedor sin duplicados.
  5. `database/tests.sql`: 31 pruebas automáticas.
* **Comprobación normal y de error:**
  - Normal: carga completa en base vacía; alta de activo, de vulnerabilidad con CVSS y cambio de estado válido.
  - Error: relación con activo inexistente, asociación duplicada, usuario duplicado, vector mal formado, score fuera de rango, severidad incoherente, pasar a PENDIENTE sin responsable. Todos rechazados.
* **Aportación de revisión (Alex):**
  - **Verificación de integridad relacional (N:M y FKs):** Comprobado en `database/schema.sql` y `database/tests.sql` que la tabla intermedia `vulnerability_assets`:
    1. Rechaza la inserción de una relación con un activo inexistente (error de clave foránea en `asset_id REFERENCES assets(id)`).
    2. Rechaza la inserción de una vulnerabilidad inexistente (error de clave foránea en `vulnerability_id REFERENCES vulnerabilities(id)`).
    3. Impide asociaciones duplicadas mediante la clave primaria compuesta `PRIMARY KEY (vulnerability_id, asset_id)` (lanzando violación de clave única si se reinserta el par `('VFU-0001', 1)`).
    4. En `assets`, la FK `provider_id REFERENCES providers(id) ON DELETE RESTRICT` rechaza proveedores inexistentes y bloquea el borrado de proveedores en uso.
  - **Observación constructiva de cara a T04 y T10:**
    1. Se confirma que el campo `version INTEGER NOT NULL DEFAULT 0` con restricción `CHECK (version >= 0)` en `vulnerabilities` encaja a la perfección con la anotación `@Version` de Spring Data JPA para el control de concurrencia optimista que implementaremos en la tarea T10.
    2. Los estados (`ABIERTA`, `PENDIENTE_REMEDIACION`, `RESUELTA`, `CERRADA`), roles y estructuras de tablas encajan al 100% con los DTOs y endpoints acordados en el contrato de la API (`docs/api/README.md`) y las decisiones técnicas de T01.
    3. La estructura de `users` y `roles` con `password_hash VARCHAR(100)` deja la base completamente preparada para enganchar directamente el `UserDetailsService` y `BCryptPasswordEncoder` en mi siguiente tarea: **T04 (Login y permisos)**.
* **Evidencia:** Carpeta `database/`; scripts `schema.sql`, `seed_data.sql`, `queries.sql` y `tests.sql` (31 pruebas automatizadas de validación y rechazo).
* **Demostración (pendiente de Adri):** Adri crea la base siguiendo `database/README.md` y señala dónde se guarda cada dato de VFU-0001 (tabla en `ER_diagrama.md`).
* **Tiempo real:** Pablo: 90 min (diseño DDL, seed data, queries y pruebas) | Alex: 25 min (revisión de integridad relacional, compatibilidad JPA/API y validación de tests).
* **Estado y siguiente paso:** Revisada por Alex (pendiente de demostración de Adri). Siguiente paso: Adri ejecuta la demostración en T03 y Alex ya puede avanzar en paralelo con T04 (Login y permisos con Spring Security).
