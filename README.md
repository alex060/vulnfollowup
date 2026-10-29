# VulnFollowUp

[![Project](https://img.shields.io/badge/Project-Intermodular%202º%20DAM-blue.svg)](#)
[![Regulation](https://img.shields.io/badge/Compliance-EU%20DORA%202022%2F2554-green.svg)](#)
[![CVSS](https://img.shields.io/badge/Standard-CVSS%20v3.1%20%2F%20v4.0-orange.svg)](#)

> **VulnFollowUp** is an internal, defensive platform for tracking, evaluating, and prioritizing technological vulnerabilities and ICT third-party provider risks. Developed as part of the 2nd Year Higher Technical Certificate in Multiplatform Application Development (CFGS DAM) at Nebrija FP.

---

## 1. Project Overview & Context

In compliance with **Regulation (EU) 2022/2554 (DORA)** on digital operational resilience for the financial sector, financial entities and their ICT service providers must demonstrate strict control over technological risks, critical asset mapping, third-party dependencies, and vulnerability remediation workflows.

**VulnFollowUp** provides:
- Centralized tracking of technical assets and ICT providers.
- Standardized vulnerability evaluation using **CVSS Base v3.1 / v4.0** metrics.
- End-to-end remediation lifecycle: `ABIERTA` $\rightarrow$ `PENDIENTE DE REMEDIACIÓN` $\rightarrow$ `RESUELTA` $\rightarrow$ `CERRADA`.
- Provider risk assessments and critical vulnerability reports.
- Real-time client dashboard and cross-platform access (Desktop/Web & Android Mobile App).

> **Responsible Use Notice**: VulnFollowUp is strictly a defensive management and auditing tool. It does not perform active network scanning, vulnerability exploitation, or penetration testing. All records utilize synthetic or publicly available CVE data.

---

## 2. System Architecture

The solution follows a multi-tier, client-server architecture powered by a unified REST API:

```
┌─────────────────────────┐
│       Android App       │ (PMDM - Mobile Tracking & Offline Cache)
└───────────┬─────────────┘
            │  HTTP/JSON
┌───────────┴─────────────┐
│ Desktop / SPA Web App   │ (DI - Admin & Analyst Management Dashboard)
└───────────┬─────────────┘
            │  HTTP/JSON
            ▼
┌─────────────────────────┐
│     VulnFollowUp API    │ (PSP + AD + SGE - Business Logic, Auth, Concurrency, DORA)
│    (Spring Boot / Java) │
└───────┬─────────┬───────┘
        │         │ ProcessBuilder
        │         ▼
        │   ┌─────────────────────────┐
        │   │ Child Reporting Process │ (External automated reports / maintenance)
        │   └─────────────────────────┘
        │ JPA / JDBC
        ▼
┌─────────────────────────┐
│   Relational Database   │ (MySQL / PostgreSQL / H2)
└─────────────────────────┘
```

---

## 3. Repository Structure

```text
vulnfollowup/
├── backend/            # REST API service, concurrency & ICT provider logic (PSP + AD + SGE)
├── desktop-client/     # Desktop / SPA Web client (DI)
├── android-app/        # Mobile application (PMDM)
├── database/           # Relational schema DDL, initial seed scripts & queries
├── data/               # Initial JSON/CSV datasets (assets, vulnerabilities, providers)
├── docs/
│   ├── api/            # REST API documentation and Postman/OpenAPI specs (EN)
│   ├── english/        # Technical bilingual glossary, executive summary & video script
│   ├── ipe/            # Lean Canvas, financial budget, Gantt & meeting minutes
│   ├── sge/            # ICT Provider BPMN workflow diagram & business rules
│   ├── digitalizacion/ # Digital transformation analysis & data flow diagrams
│   └── sostenibilidad/ # Sustainability audit (SDGs), efficiency benchmarks & best practices
├── README.md           # Master documentation (EN)
└── .gitignore          # Version control ignore definitions
```

---

## 4. Test Users & Role-Based Access Control (RBAC)

The platform enforces three distinct user profiles:

| Username | Password | Role | Permissions |
| :--- | :--- | :--- | :--- |
| `admin` | `Admin123!` | **ADMIN** | Full system access: user management, ICT provider management, system configuration, all reports. |
| `analyst` | `Analyst123!` | **ANALYST** | Asset registration, vulnerability reporting, CVSS scoring, remediation lifecycle updates, limited mobile updates. |
| `viewer` | `Viewer123!` | **VIEWER** | Read-only access: dashboard inspection, filtered vulnerability review, executive summaries. |

---

## 5. Getting Started & Installation

### Prerequisites
- **Java JDK**: 17 or 21+
- **Node.js**: v18+ (for Web/Desktop client)
- **Android Studio**: Iguana / Jellyfish or newer (Android SDK 34+)
- **Database**: MySQL 8.0 / PostgreSQL 15+ / Embedded H2

### Step 1: Clone the repository
```bash
git clone <REPOSITORY_URL>
cd vulnfollowup
```

### Step 2: Database Setup
1. Navigate to `database/`.
2. Run `schema.sql` followed by `data_initial.sql`.

### Step 3: Launch Backend
```bash
cd backend
./mvnw spring-boot:run
```
*API default base URL: `http://localhost:8080/api`*

### Step 4: Launch Frontend Client
```bash
cd ../desktop-client
npm install
npm run dev
```

### Step 5: Android App Setup
1. Open `android-app/` in Android Studio.
2. Sync Gradle dependencies.
3. Update API base URL in configuration to point to backend host IP.
4. Run on Android Emulator or physical device.

---

## 6. Team Members & Contributions

- **Member 1**: [Name / GitHub Profile] - *Role / Modules*
- **Member 2**: [Name / GitHub Profile] - *Role / Modules*
- **Member 3**: [Name / GitHub Profile] - *Role / Modules*

---

## 7. License & Academic Attribution
Developed for the Intermodular Project at **Instituto Nebrija de Formación Profesional**, Academic Year 2026-2027.

## 8. Project Guide & Shared Team Workflow

The Spanish step-by-step guide explains the requirements, implementation order, checks, and shared learning workflow for **Alex, Adri, and Pablo**:

- [Step-by-step guide (PDF)](output/pdf/Guia_realizacion_VulnFollowUp.pdf)
- [Editable guide (Markdown)](docs/GUIA_REALIZACION_VULNFOLLOWUP.md)
- [Shared task board](docs/equipo/TABLERO_COMPARTIDO.md)
- [Shared knowledge checklist](docs/equipo/CONOCIMIENTO.md)

Start by reading sections 1-4 together. Each technical task has a rotating lead, reviewer, and demonstrator. The task board and knowledge checklist start as pending; they describe planned work, not completed implementation.
