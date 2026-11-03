# 10 — Requirements Traceability Matrix

## Method

**Business objective → security requirement → architecture response → control → test → evidence.** This matrix links verified outcomes to the existing planning-stage requirements; it does not rewrite the original requirement IDs.

| Original requirement / objective | Architecture response | Control / decision | Validation | Evidence | Assurance conclusion |
|---|---|---|---|---|---|
| BUS-02 / SEC-02 — Preserve required application connectivity | Hybrid WireGuard routing with scoped Azure Firewall policy | Selected allowed network path | AZ-01 | [Azure Firewall logs](./evidence/EV-AZURE-01-Firewall-Logs.png) | TCP/5432 HTTP listener reachable in 3/3 tests |
| SEC-02, SEC-07 — Restrict unapproved network traffic | Azure Firewall Policy and NSG restrictions | Denied TCP/4444 path; private-network outbound NSG policy | AZ-02, AZ-04 | [Azure Firewall logs](./evidence/EV-AZURE-01-Firewall-Logs.png), [NSG decision](./evidence/EV-AZURE-03-NSG-Deny.png) | Denied event observed; NSG rule evaluation returned Deny |
| BUS-04 / SEC-08 — Centralize security telemetry | Azure Firewall diagnostics → Event Hubs → Splunk Enterprise | Firewall diagnostic categories and Event Hub receiver role | AZ-05 | [Azure Firewall logs](./evidence/EV-AZURE-01-Firewall-Logs.png) | Firewall telemetry observed in Splunk |
| SEC-08 — Detect repeated denied connections | Splunk scheduled correlation alert SEC-001 | Scheduled alert on indexed firewall events | AZ-03 | [SEC-001 alert](./evidence/EV-AZURE-02-SEC001-Triggered.png) | Triggered alert observed on 3 November 2026 |
| SEC-08, SEC-09 — Restrict log-ingestion privileges | Event Hub-scoped Azure Event Hubs Data Receiver | Least-privilege service principal assignment | Configuration review | See implementation documentation | Scope recorded; not a penetration test of identity boundaries |
| SEC-09 — Protect checkpoint storage transport | HTTPS-only, TLS 1.2, anonymous blob access disabled | Storage security configuration | Configuration review | See implementation documentation | Configuration recorded; not an end-to-end storage attack test |

## Evidence status

All 15 screenshots are uploaded and indexed. The repository owner has confirmed their sensitive-data review; evidence relevance and attribution remain separate checks. Test outcomes described here reflect previously recorded laboratory observations, not tests rerun during this documentation update.

## Assurance rule

A successful connection does not prove application authentication. A blocked flow does not prove every other path is blocked. A triggered alert does not establish a unique security incident.

[Requirements](01-business-security-requirements.md) · [Risk Assessment](02-threat-model-risk-assessment.md) · [Decisions](04-architecture-decision-records.md) · [Validation](07-security-validation-evidence.md)
