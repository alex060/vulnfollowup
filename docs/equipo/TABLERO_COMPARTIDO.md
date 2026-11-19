# Tablero compartido de Alex, Adri y Pablo

Este es el reparto inicial propuesto, no un registro de trabajo ya realizado. Todo empieza en **Pendiente**. Cambiad responsables si las horas reales quedan desequilibradas, manteniendo una revisión y una demostración por alguien distinto del autor.

**Lleva:** construye y explica. **Revisa:** comprueba y aporta una prueba, corrección o mejora. **Demuestra:** ejecuta y explica sin que el autor le dicte los pasos. Todos tienen que entender el objetivo, el recorrido de datos y las pruebas.

Estados sugeridos: Pendiente > En curso > En revisión > Por explicar > Terminada. Un bloqueo se anota con la dependencia que falta. No marcar Terminada porque solo funcione en el equipo del autor.

## Tareas técnicas

| Tarea | Lleva | Revisa | Demuestra | Hace falta antes | Estado |
| --- | --- | --- | --- | --- | --- |
| T01. Alcance, tecnologías y contrato inicial | Alex | Adri | Pablo | Leer el enunciado juntos | Entregada y revisada |
| T02. Proyectos y arranque | Adri | Pablo | Alex | T01 | Entregada por Adri (en revisión) |
| T03. Tablas y datos de prueba | Pablo | Alex | Adri | T01-T02 | Revisada |
| T04. Login y permisos | Alex | Pablo | Adri | T03 | Pendiente |
| T05. API de activos | Adri | Alex | Pablo | T03-T04 | Pendiente |
| T06. API de vulnerabilidades y relaciones | Pablo | Adri | Alex | T05 | Pendiente |
| T07. Validación CVSS | Alex | Adri | Pablo | T06 | Pendiente |
| T08. Importación y rollback | Adri | Pablo | Alex | T03, T06-T07 | Pendiente |
| T09. Remediación y auditoría | Pablo | Alex | Adri | T06-T07 | Pendiente |
| T10. Concurrencia y protección | Alex | Pablo | Adri | T09 | Pendiente |
| T11. Tarea y proceso de informe | Adri | Alex | Pablo | Consulta de pendientes y permisos | Pendiente |
| T12. Proveedores, regla e informe | Pablo | Adri | Alex | Modelo T03 y API básica T04-T06 | Pendiente |
| T13. Web: login, formularios y detalle | Alex | Adri | Pablo | Contrato T04-T09; bocetos antes | Pendiente |
| T14. Web: filtros, dashboard y exportación | Adri | Pablo | Alex | Consultas API y T13 | Pendiente |
| T15. Android: login, lista, filtros y detalle | Pablo | Alex | Adri | Contrato T04-T07; conexión mínima tras T06 | Pendiente |
| T16. Android: cambios y caché | Alex | Pablo | Adri | T09, T15 y control de versión | Pendiente |
| T17. Distribución web y APK | Adri | Alex | Pablo | T13-T16 | Pendiente |
| T18. Pruebas integradas | Pablo | Adri | Alex | Repetir pruebas desde cada tarea; cierre tras T17 | Pendiente |

Cada persona lidera seis tareas, revisa seis y demuestra seis. La cantidad de tareas no mide su dificultad: anotad horas y ajustad. Una primera lectura real desde web y móvil se hace tras T06 para detectar problemas pronto, sin esperar a terminar todas las pantallas.

## Trabajos transversales

| Trabajo | Lleva | Revisa | Demuestra o defiende | Estado |
| --- | --- | --- | --- | --- |
| Inglés escrito: README, API, glosario y resumen | Alex | Adri | Pablo | Pendiente |
| Inglés oral: vídeo, guion y defensa | Adri | Pablo | Alex | Pendiente |
| IPE: negocio, costes, plan y actas | Pablo | Alex | Adri | Pendiente |
| Digitalización | Alex | Pablo | Adri | Pendiente |
| Sostenibilidad y mediciones | Adri | Alex | Pablo | Pendiente |
| Memoria común y declaración de IA | Pablo | Adri | Alex | Pendiente |

Los tres participan en vídeo y defensa, revisan sus contribuciones y actualizan sus portfolios. Quien lleva la memoria coordina, no redacta a ciegas todo lo de los otros.

## Ficha que copiáis para cada tarea

- Identificador y objetivo: qué comportamiento tiene que funcionar.
- Lleva / revisa / demuestra: nombres de los tres.
- Dependencias: qué datos o funciones deben existir antes.
- Pasos pequeños: lo que vais a realizar en esta sesión.
- Comprobación normal y de error: cómo sabréis que funciona.
- Aportación de revisión: prueba, corrección o mejora realizada.
- Evidencia: ruta de la prueba, captura o documento.
- Explicación compartida: qué dudas surgieron y qué falta entender.
- Tiempo real: construcción, revisión y explicación, por persona.
- Estado y siguiente paso.

## Requisitos para cerrar una tarea

- [ ] Se ha probado el caso correcto y un error relevante.
- [ ] El revisor ha comprobado el trabajo y dejado una aportación.
- [ ] El demostrador puede ejecutarlo siguiendo instrucciones.
- [ ] Los tres explican objetivo, recorrido, decisión y prueba.
- [ ] La evidencia y las instrucciones están guardadas.
- [ ] Se ha actualizado la matriz de conocimiento sin inventar avances.

## Rutina compartida

Al empezar: cinco minutos para decir qué hizo cada uno, qué hará y qué necesita. Al terminar una tarea: explicación breve, revisión y demostración por otro. Ajustar la duración a la dificultad; dividir tareas demasiado grandes.

Antes de entregar: ensayo con intercambio de presentadores y preguntas individuales mezcladas. Ninguno responde por otro antes de que termine su explicación.

---

## Fichas de tareas realizadas

### Ficha T01: Alcance, tecnologías y contrato inicial
* **Identificador y objetivo:** Definir stack unificado, versiones, estándar CVSS (3.1 Base), roles RBAC y contrato JSON inicial de la API REST para desbloquear T02 y T03.
* **Lleva / Revisa / Demuestra:** Alex / Adri / Pablo.
* **Dependencias:** Lectura de requisitos de `Proyecto_Intermodular_2DAM_VulnFollowUp (1).pdf` y `docs/GUIA_REALIZACION_VULNFOLLOWUP.md`.
* **Pasos realizados:**
  1. Redactado documento de stack, puertos y reglas en `docs/decisiones_tecnicas.md`.
  2. Acordado CVSS v3.1 Base y descarte de CVSS 4.0 en fase inicial.
  3. Matriz RBAC definida para `ADMIN`, `ANALYST` y `VIEWER`.
  4. Redactado el contrato completo de endpoints y DTOs en `docs/api/README.md`.
* **Comprobación normal y de error:**
  - Caso normal: El contrato describe los flujos principales (salud, login, activos, vulnerabilidades, remediación con versión y proveedores).
  - Caso error: Se contemplan códigos 400 (validación), 401 (sin credenciales), 403 (falta de permisos), 404 y 409 (conflicto de concurrencia optimista).
* **Aportación de revisión (Adri):** Revisión completada y aprobada con una corrección técnica: adopción definitiva de **PostgreSQL** en lugar de MySQL. Justificación: es la base recomendada por la guía del proyecto y la que el equipo domina con mayor soltura de clase, lo que nos evitará tropiezos con tipos de datos o dialectos y permitirá avanzar mucho más rápido; además, encaja de forma nativa con los requisitos de transacciones, rollback y niveles de concurrencia de la guía (T08/T10). Asimismo, se ratifica la elección de **CVSS 3.1 Base** frente a la versión 4.0 al tratarse de un estándar más maduro y contrastado, con mayor volumen de documentación, calculadoras y vectores oficiales de FIRST para verificar las pruebas.
* **Evidencia:** Archivos `docs/decisiones_tecnicas.md` y `docs/api/README.md`.
* **Explicación compartida (pendiente de Pablo):** Demostración y resumen del recorrido de datos para el cierre definitivo de T01.
* **Tiempo real:** Alex: 45 min (análisis, redacción y contrato) | Adri: 20 min (revisión de contrato, ajuste de base de datos a PostgreSQL y validación de CVSS 3.1).
* **Estado y siguiente paso:** Entregada y revisada. Siguiente paso: Adri inicia la creación de proyectos y arranque en T02.



### Ficha T02: Crear proyectos y hacer que arranquen
* **Identificador y objetivo:** Crear los proyectos base en `backend/`, `desktop-client/` y `android-app/`, verificando que compilan, arrancan y se comunican con su entorno local.
* **Lleva / Revisa / Demuestra:** Adri / Pablo / Alex.
* **Dependencias:** T01 entregada y revisada.
* **Pasos realizados:**
  1. **Backend (Spring Boot):** Generado en `backend/` con Java 21 LTS (Spring Boot 4.1.2), Maven Wrapper (`mvnw`), dependencias de Web, Data JPA, PostgreSQL y Validation. Creado el endpoint de salud `HealthController` (`GET /api/health`).
  2. **Configuración BD:** Preparado `application.properties.example` para PostgreSQL en puerto 5432.
  3. **Frontend Web (React + Vite):** Generado en `desktop-client/` con React 18, TypeScript, ESLint y Vite. Verificado el arranque en caliente con `npm run dev` en puerto 5173.
  4. **App Móvil (Android):** Creado en `android-app/` mediante Android Studio con plantilla *Empty Activity*, Kotlin y Jetpack Compose, listo para compilar y ejecutar en emulador.
  5. **Documentación:** Actualizados los `README.md` de cada subproyecto con instrucciones paso a paso para arranque limpio.
* **Comprobación normal y de error:**
  - Caso normal: Backend compila sin errores (`BUILD SUCCESS`), responde `GET /api/health` con JSON `{"status": "UP"}`. Web arranca en `http://localhost:5173/`. Android compila y sincroniza Gradle correctamente.
  - Caso error: La falta de archivo de configuración de base de datos se previene mediante `application.properties.example` para evitar fugas de credenciales en Git.
* **Aportación de revisión (pendiente de Pablo):** Pablo comprueba versiones, dependencias y pasos de arranque en copia limpia.
* **Evidencia:** Repositorio con los tres proyectos funcionales y capturas de arranque web (`Vite ready`), backend (`HealthController`) y Android Studio (`MainActivity.kt`).
* **Demostración (pendiente de Alex):** Alex arranca los servicios siguiendo las instrucciones de Adri.
* **Tiempo real:** Adri: 60 min (generación de proyectos, pruebas de compilación y documentación).
* **Estado y siguiente paso:** Entregada por Adri. Siguiente paso: Pablo revisa y Alex demuestra. Pablo puede empezar T03 (Diseño de base de datos).

---

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

