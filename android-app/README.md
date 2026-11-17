# Mobile Application (PMDM)

This module contains the native Android client for VulnFollowUp.

## Requirements (Programación Multimedia y Dispositivos Móviles)
- **Features**:
  - Secure authentication against the backend API.
  - Vulnerability list, filtering, and detailed inspection (CVSS vector, score, severity, references).
  - Quick update actions for `ANALYST` profile (state transition or assignee updates).
- **Network & State Handling**:
  - Clear UI states: loading spinner, error feedback, empty states.
- **Offline Resilience**:
  - Local caching layer using **Room** or **Jetpack DataStore** to enable offline inspection of the latest vulnerability dataset.
- **Testing**:
  - Emulator and physical device testing plan.


## Instrucciones de arranque local (T02)

1. Abrir Android Studio y seleccionar la carpeta `android-app/`.
2. Esperar la sincronización de Gradle (`Gradle Sync`).
3. Seleccionar un emulador Android (API 26+) o dispositivo físico con depuración USB habilitada.
4. Ejecutar con **Run 'app'** (`Shift + F10`).
5. La pantalla inicial mostrará el mensaje básico con Jetpack Compose.
