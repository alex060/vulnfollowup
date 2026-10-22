# Backend Service (PSP + AD + SGE)

This module contains the central REST API service for VulnFollowUp.

## Technical Responsibilities
- **Acceso a Datos (AD)**:
  - Database persistence layer (JPA / Hibernate / JDBC).
  - Transactional integrity and rollback handling on batch imports.
  - Advanced querying and filtering (severity, state, asset, assignee, score range).
- **Programación de Servicios y Procesos (PSP)**:
  - REST API endpoints and authentication (JWT token or session-based).
  - Background async tasks using `ExecutorService` (JSON import & reports).
  - Concurrency control: protected shared resource with demonstrable race condition fix (synchronized, locks, atomic classes, or DB optimistic locking).
  - External process execution using `ProcessBuilder` (e.g., CSV/HTML report generation or maintenance script).
  - Secure logging without sensitive data leakage.
- **Sistemas de Gestión Empresarial (SGE)**:
  - ICT Provider entity management under DORA compliance.
  - Business rules for critical providers and pending vulnerability alerts.
