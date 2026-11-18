### Ficha T03: Tablas y datos de prueba (borrador)
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
* **Aportación de revisión (pendiente de Alex):** Alex prueba una relación inválida y una asociación duplicada en su equipo y deja su aportación aquí.
* **Evidencia:** carpeta `database/`; `tests.sql` ejecutado en PostgreSQL 16.2 (31 OK, 0 FALLO).
* **Demostración (pendiente de Adri):** Adri crea la base siguiendo `database/README.md` y señala dónde se guarda cada dato de VFU-0001 (tabla en `ER_diagrama.md`).
* **Tiempo real:** Pablo: ___ min.
* **Estado y siguiente paso:** Entregada (pendiente de revisión de Alex). La T04 (Alex) y la T05 (Adri) pueden usar este esquema cuando Alex lo dé por revisado. La T03 no se cierra hasta que la T01 y la T02 estén terminadas.
