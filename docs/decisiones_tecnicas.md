# Decisiones Técnicas y Alcance Inicial (T01)

* **Proyecto:** VulnFollowUp (Proyecto Intermodular 2º DAM - 2026/2027)
* **Responsable de la propuesta (Lleva):** Alex
* **Revisión técnica (Revisa):** Adri
* **Demostración y comprensión (Demuestra):** Pablo
* **Fecha:** 15 de noviembre de 2026 (Revisión técnica de Adri: 17 de noviembre de 2026)
* **Estado:** Entregada por Alex y Revisada por Adri (aprobada con cambio a PostgreSQL). Pendiente de demostración oral por Pablo.

---

## 1. Stack Tecnológico y Versiones Comunes

Para evitar incompatibilidades entre los equipos de desarrollo y asegurar que todo compile tanto en local como en la entrega final, se fija el siguiente stack:

| Componente | Tecnología | Versión acordada | Justificación / Notas |
| :--- | :--- | :--- | :--- |
| **Backend API** | Java + Spring Boot | Java 21 LTS (compatible con JDK 24 en local) / Spring Boot 3.3.x | Se usa el Maven Wrapper (`./mvnw`) para unificar dependencias sin depender de la instalación global. |
| **Starters Spring** | Web, Security, Data JPA, Validation | Spring Boot Starters estándar | Evita conflictos de logging manual; validaciones con anotaciones `@NotNull`, `@Size`, etc. |
| **Base de Datos** | PostgreSQL (Docker o local) | PostgreSQL 16 LTS (puerto host `5432:5432`) | Decisión revisada por Adri: la guía oficial del proyecto toma PostgreSQL como referencia directa (apartados 5 y 16, doc [R6]). Además de ofrecer un soporte transaccional y niveles de aislamiento más estrictos para los requisitos de concurrencia y rollback (T08/T10), el equipo está mucho más habituado a su manejo y herramientas de clase, lo que nos dará mayor agilidad y evitará fricciones innecesarias con dialectos o tipos de datos. |
| **Web / Desktop** | React + TypeScript + Vite | React 18 / Node 20 LTS o 24 local | Permite tipado estricto con interfaces compartidas con los DTOs del backend. |
| **Móvil** | Android nativo (Kotlin) | Android SDK 34 (Android 14) / Room / Compose | Conexión HTTP al backend común y persistencia local para modo offline. |
| **Distribución Web** | Docker + Nginx | Imagen Nginx Alpine | Servirá la SPA compilada (`dist`) en producción. |

---

## 2. Decisión sobre el Estándar CVSS

* **Decisión acordada:** Se implementará **CVSS v3.1 Base Metrics**.
* **Justificación:** El enunciado permite elegir entre CVSS v3.1 y v4.0. Implementar ambas o saltar a la 4.0 añade una complejidad innecesaria en la fórmula matemática en esta primera fase. Con CVSS 3.1 cubrimos al 100% el requisito del módulo de seguridad. Además, tal y como valida Adri en la revisión, al ser una versión previa ya asentada disponemos de abundante documentación oficial, calculadoras contrastadas y muchos más vectores reales verificados en FIRST/NVD para validar nuestros casos de prueba sin margen de error.
* **Métricas Base a registrar:**
  * Attack Vector (AV): `NETWORK`, `ADJACENT`, `LOCAL`, `PHYSICAL`.
  * Attack Complexity (AC): `LOW`, `HIGH`.
  * Privileges Required (PR): `NONE`, `LOW`, `HIGH`.
  * User Interaction (UI): `NONE`, `REQUIRED`.
  * Scope (S): `UNCHANGED`, `CHANGED`.
  * Confidentiality (C): `NONE`, `LOW`, `HIGH`.
  * Integrity (I): `NONE`, `LOW`, `HIGH`.
  * Availability (A): `NONE`, `LOW`, `HIGH`.
* **Formato de almacenamiento:**
  * Vector CVSS: `VARCHAR(100)` (ej. `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`).
  * Score numérico: `DECIMAL(3,1)` (rango de 0.0 a 10.0).
  * Severidades según rango oficial NVD/FIRST:
    * `INFORMATIVA`: 0.0
    * `BAJA`: 0.1 - 3.9
    * `MEDIA`: 4.0 - 6.9
    * `ALTA`: 7.0 - 8.9
    * `CRITICA`: 9.0 - 10.0

---

## 3. Autenticación y Control de Accesos (RBAC)

* **Protocolo:** Autenticación HTTP (`httpBasic` o Bearer token) sobre HTTPS / HTTP local.
* **Protección de credenciales:** Contraseñas nunca en texto plano; almacenamiento mediante hash **BCrypt** con salt automático generado por Spring Security.
* **Modelo de identidades separado:** La tabla `users` (`app_user`) gestiona credenciales y roles; es totalmente independiente de los activos y responsables del negocio.
* **Matriz de permisos por rol:**

| Operación / Endpoint | ADMIN | ANALYST | VIEWER |
| :--- | :---: | :---: | :---: |
| Consultar dashboard, activos y vulnerabilidades | Sí | Sí | Sí |
| Crear y editar activos (`/api/assets`) | Sí | Sí | No |
| Crear vulnerabilidades y valorar CVSS (`/api/vulnerabilities`) | Sí | Sí | No |
| Cambiar estado de remediación y subir evidencias | Sí | Sí | No |
| Gestión completa de proveedores TIC (`/api/providers`) | Sí | No | No |
| Importación masiva de vulnerabilidades (JSON) | Sí | Sí | No |
| Ejecución de proceso externo de informes batch | Sí | No | No |

---

## 4. Ciclo de Vida de Vulnerabilidades y Reglas de Negocio

Los estados internos en base de datos se gestionarán mediante un enumerado estricto en mayúsculas:
1. `ABIERTA`: Estado inicial al registrar el hallazgo.
2. `PENDIENTE_REMEDIACION`: Se le asigna un responsable y una fecha objetivo de resolución.
3. `RESUELTA`: El responsable aporta una evidencia textual o técnica de la mitigación.
4. `CERRADA`: Validación final por parte de un analista o administrador.

* **Regla de concurrencia (para T10):** Se utilizará control de concurrencia optimista (`@Version` en JPA / columna `version INT`) para evitar que dos analistas sobreescriban cambios simultáneos sin advertencia.

---

## 5. Puerto y Variables de Entorno

* **Puerto API Backend:** `8080` (Base URL: `http://localhost:8080/api`).
* **Puerto Base de Datos:** `5432` (estándar de PostgreSQL en Docker o servicio local).
* **Puerto Frontend Vite:** `5173`.
* **Configuración:** Se incluirá un archivo `backend/src/main/resources/application.properties.example` con variables documentadas para que cada compañero clone y configure su conexión local sin subir credenciales privadas a Git.

---

## 6. Consultas Pendientes para los Profesores

1. **Informes en DI (Desarrollo de Interfaces):** Aclarar si la exportación en PDF es obligatoria para la entrega ordinaria o si basta con exportación CSV y dashboard gráfico interactivo (el enunciado tiene una discrepancia entre la pág. 11 y la pág. 23).
2. **Evaluación de Inglés:** Confirmar si la parte oral consiste en el vídeo explicativo de 3-5 minutos o si habrá ronda de preguntas en inglés durante la defensa final presencial.
