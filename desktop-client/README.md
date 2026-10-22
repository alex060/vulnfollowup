# Desktop / SPA Web Client (DI)

This module contains the primary administrative and analytical interface for `ADMIN` and `ANALYST` users.

## Requirements (Desarrollo de Interfaces)
- **Architecture**: Modern component-based framework (React, Angular, Vue, or Ionic).
- **Accessibility**: Strict compliance with WCAG 2.1 AA standards (color contrast, keyboard focus, ARIA semantics).
- **Dashboard**: Interactive data visualizations and charts displaying vulnerabilities by severity and status.
- **Reporting**: Exportable summaries in CSV / PDF format.
- **Packaging & Deployment**:
  - Desktop native wrapper (Electron Forge or Tauri) OR
  - Dockerized production SPA with an optimized Nginx container (`docker-compose.yml`).
