# Base de datos (T03) — esquema, datos de prueba y consultas

| Archivo | Para qué sirve |
| --- | --- |
| `schema.sql` | Crea tablas, claves, restricciones e índices. **Empieza borrando todo** (base de desarrollo/demo). |
| `seed_data.sql` | Datos sintéticos: 3 usuarios (hash BCrypt), 4 proveedores, 8 activos, 8 vulnerabilidades con CVSS 3.1, comentarios y auditoría. |
| `queries.sql` | Consultas de filtros, dashboard e informe de proveedores (parámetros `:nombre`). |
| `tests.sql` | Pruebas automáticas: lo inválido debe rechazarse y lo válido aceptarse. No deja cambios. |
| `ER_diagrama.md` | Diagrama entidad-relación y dónde se guarda cada dato de VFU-0001. |

## Cómo ejecutarlo en una base vacía (PostgreSQL 16, desde la raíz del repo)

```powershell
psql -U postgres -c "CREATE DATABASE vulnfollowup_db;"
psql -U postgres -d vulnfollowup_db -v ON_ERROR_STOP=1 -f database/schema.sql
psql -U postgres -d vulnfollowup_db -v ON_ERROR_STOP=1 -f database/seed_data.sql
psql -U postgres -d vulnfollowup_db -f database/tests.sql
```

`tests.sql` debe mostrar solo líneas `OK`. Cuentas de prueba (solo desarrollo): `admin / Admin123!`, `analyst / Analyst123!`, `viewer / Viewer123!`.
Para repetir desde cero basta con volver a ejecutar `schema.sql` y `seed_data.sql`.

## Decisiones del modelo (para la revisión de Alex)

- **Tablas y columnas en inglés; códigos en español en mayúsculas** (`PENDIENTE_REMEDIACION`, `CRITICA`...), como en `docs/decisiones_tecnicas.md`. Los JSON del contrato usan otros nombres (`nombre`, `tipo`...): lo resuelven las entidades/DTO.
- **N:M** entre vulnerabilidades y activos con tabla intermedia y clave primaria compuesta, así la pareja no se repite.
- **Un proveedor por activo (opcional)** y **una valoración CVSS actual por vulnerabilidad** (`UNIQUE`), como propone la guía. Si se quiere historial de valoraciones o varios proveedores por activo, habría que ampliar el modelo.
- **La base valida lo básico:** formato del identificador, vector CVSS 3.1, score 0–10 y severidad coherente con el score, estados permitidos, responsable y fecha al salir de `ABIERTA`. Las transiciones y la evidencia las valida la API (T09). Esto da una segunda barrera, no sustituye a la validación de T07.
- **CVSS solo 3.1** a nivel de BD (`cvss_version = '3.1'`). Si el equipo decide admitir 4.0, hay que cambiar esa restricción y el patrón del vector.
- **Sin borrado en cascada de lo importante:** no se puede borrar un proveedor con activos ni un activo con vulnerabilidades; los activos se desactivan (`INACTIVO`) para conservar el historial.
- **`audit_events` sin clave foránea a la entidad**, a propósito, para que el historial sobreviva.
- **`jobs` ya está creada** (la comparten T08 y T11), así no hay que decidir quién la crea primero.
- **`vulnerabilities.version`** queda lista para el control de concurrencia (T10): sumar 1 en cada cambio.
- **Dashboard:** `GET /api/dashboard/summary` sigue sin dueño en el tablero; las consultas ya están en `queries.sql` (Q3).
- **Regla de riesgo del proveedor (Q5):** es solo un borrador para T12; el plazo de "revisión vencida" (12 meses) es una suposición mía, la guía no lo fija.

## Importante para el backend

`application.properties` tiene `spring.jpa.hibernate.ddl-auto=update`: Hibernate crearía o modificaría tablas por su cuenta y chocaría con `schema.sql`. Con estos scripts conviene `validate` o `none` (acordarlo con Adri).

## Cómo se probó

Los cuatro scripts se ejecutaron en una base vacía con PostgreSQL 16.2: `tests.sql` da 31 pruebas OK y 0 fallos, y las consultas de `queries.sql` se probaron con y sin filtros. Falta repetirlo en vuestro PostgreSQL de Windows (lo hace Adri según el flujo de la T03).
