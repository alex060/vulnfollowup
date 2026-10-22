# Seed & Import Datasets

This folder stores initial dataset files used for onboarding and batch import testing:
- `vulnerabilities_seed.json`: Minimum 20 synthetic or documented public CVE vulnerability records.
  - Required fields: ID/CVE, title, description, affected asset(s), CVSS version (3.1 or 4.0), CVSS vector string, base score, qualitative severity, initial state.
- `vulnerabilities_invalid.json`: Test file with intentional errors (e.g., mismatching version vs. vector, negative score) to demonstrate transaction rollback.
- `assets.json` / `assets.csv`: Initial assets (Payment API, App Server, DB, etc.).
- `providers.json` / `providers.csv`: Test ICT service providers (e.g., cloud hosting, payment gateways).
