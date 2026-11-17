# Especificación del Contrato Inicial de la API REST (T01)

* **Versión:** 1.0.0 (Borrador inicial acordado por Alex para T01)
* **Base URL:** `http://localhost:8080/api`
* **Formato de intercambio:** `application/json;charset=UTF-8`

---

## 1. Códigos de Estado HTTP Estándar

* `200 OK`: Consulta o actualización realizada correctamente.
* `201 Created`: Recurso creado con éxito (devuelve el objeto creado con su ID generado).
* `400 Bad Request`: Error de validación en los datos de entrada (campos obligatorios vacíos, score fuera de rango 0-10, etc.).
* `401 Unauthorized`: No se ha enviado credencial o las credenciales son incorrectas.
* `403 Forbidden`: El usuario autenticado no tiene permisos para esta acción (ej. `VIEWER` intentando crear un activo).
* `404 Not Found`: El recurso solicitado no existe (ID inexistente).
* `409 Conflict`: Conflicto de concurrencia optimista (versión desactualizada) o clave única duplicada.

---

## 2. Endpoints y Payloads de Datos

### 2.1. Comprobación de Salud (Público)
* **Endpoint:** `GET /api/health` o `GET /hola`
* **Acceso:** Público (sin autenticación).
* **Respuesta (`200 OK`):**
```json
{
  "status": "UP",
  "service": "VulnFollowUp API",
  "timestamp": "2026-11-15T16:00:00Z"
}
```

---

### 2.2. Autenticación (`POST /api/auth/login`)
* **Acceso:** Público.
* **Request Body:**
```json
{
  "username": "analyst",
  "password": "Analyst123!"
}
```
* **Respuesta (`200 OK`):**
```json
{
  "username": "analyst",
  "role": "ANALYST",
  "token": "token-temporal-o-basic-auth",
  "authenticated": true
}
```

---

### 2.3. Gestión de Activos (`/api/assets`)

#### `GET /api/assets`
* **Acceso:** `ADMIN`, `ANALYST`, `VIEWER`.
* **Respuesta (`200 OK`):**
```json
[
  {
    "id": 1,
    "nombre": "API de pagos",
    "tipo": "SERVICIO_WEB",
    "responsable": "Equipo Pasarela",
    "entorno": "PRODUCCION",
    "estado": "ACTIVO",
    "providerId": 1,
    "providerNombre": "HostingSur"
  }
]
```

#### `POST /api/assets`
* **Acceso:** `ADMIN`, `ANALYST`.
* **Request Body:**
```json
{
  "nombre": "Servidor de Base de Datos Principal",
  "tipo": "INFRAESTRUCTURA",
  "responsable": "Equipo DBA",
  "entorno": "PRODUCCION",
  "providerId": 1
}
```
* **Respuesta (`201 Created`):** Devuelve el objeto creado con su `id` asignado.

---

### 2.4. Gestión de Vulnerabilidades (`/api/vulnerabilities`)

#### `GET /api/vulnerabilities`
* **Acceso:** `ADMIN`, `ANALYST`, `VIEWER`.
* **Filtros opcionales por query params:** `?severidad=CRITICA&estado=ABIERTA&assetId=1`
* **Respuesta (`200 OK`):**
```json
[
  {
    "id": "VFU-0001",
    "titulo": "Inyección SQL en endpoint de autenticación",
    "descripcion": "Fallo de sanitización que permite bypass de login.",
    "estado": "ABIERTA",
    "score": 9.8,
    "severidad": "CRITICA",
    "responsable": "Alex",
    "fechaObjetivo": "2026-12-01",
    "version": 0,
    "activosAfectados": [
      { "id": 1, "nombre": "API de pagos" }
    ]
  }
]
```

#### `POST /api/vulnerabilities`
* **Acceso:** `ADMIN`, `ANALYST`.
* **Request Body:**
```json
{
  "id": "VFU-0001",
  "titulo": "Inyección SQL en endpoint de autenticación",
  "descripcion": "Fallo de sanitización que permite bypass de login.",
  "cvssVersion": "3.1",
  "cvssVector": "CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H",
  "score": 9.8,
  "severidad": "CRITICA",
  "assetIds": [1]
}
```
* **Respuesta (`201 Created`):** Devuelve el registro creado con estado `ABIERTA` por defecto.

#### `PATCH /api/vulnerabilities/{id}/status`
* **Acceso:** `ADMIN`, `ANALYST`.
* **Propósito:** Cambio de fase en el flujo de remediación con evidencia y control de versión optimista.
* **Request Body:**
```json
{
  "nuevoEstado": "RESUELTA",
  "responsable": "Alex",
  "fechaObjetivo": "2026-12-01",
  "evidencia": "Se parametrizó la consulta con PreparedStatement en Commit #a1b2c3d.",
  "versionActual": 0
}
```
* **Respuesta (`200 OK`):** Devuelve el objeto actualizado con `version: 1`.
* **Respuesta (`409 Conflict`):** Si `versionActual` no coincide con la versión en base de datos.

---

### 2.5. Gestión de Proveedores TIC (`/api/providers`)

#### `GET /api/providers`
* **Acceso:** `ADMIN`, `ANALYST`, `VIEWER`.
* **Respuesta (`200 OK`):**
```json
[
  {
    "id": 1,
    "nombre": "HostingSur",
    "servicio": "Hosting Cloud e Infraestructura",
    "criticidad": "ALTA",
    "contratoReferencia": "CONT-2026-091",
    "contacto": "soporte@hostingsur.ejemplo.es",
    "ultimaRevision": "2026-10-15"
  }
]
```

#### `GET /api/providers/{id}/report`
* **Acceso:** `ADMIN`, `ANALYST`, `VIEWER`.
* **Propósito:** Resumen de riesgos DORA del proveedor sin duplicar conteos si una vulnerabilidad afecta a múltiples activos del mismo proveedor.
* **Respuesta (`200 OK`):**
```json
{
  "providerId": 1,
  "nombre": "HostingSur",
  "totalActivos": 3,
  "totalVulnerabilidadesPendientes": 1,
  "vulnerabilidadesCriticas": 1,
  "nivelRiesgoCalculado": "ALTO"
}
```

---

### 2.6. Resumen de Dashboard (`GET /api/dashboard/summary`)
* **Acceso:** `ADMIN`, `ANALYST`, `VIEWER`.
* **Respuesta (`200 OK`):**
```json
{
  "totalActivos": 12,
  "totalVulnerabilidades": 25,
  "porSeveridad": {
    "CRITICA": 4,
    "ALTA": 8,
    "MEDIA": 10,
    "BAJA": 3
  },
  "porEstado": {
    "ABIERTA": 5,
    "PENDIENTE_REMEDIACION": 12,
    "RESUELTA": 6,
    "CERRADA": 2
  }
}
```
