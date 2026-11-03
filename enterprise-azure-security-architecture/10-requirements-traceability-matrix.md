# 10 — Requirements Traceability Matrix

## Method

**Business objective → security requirement → architecture response → control → test → evidence.** This matrix links verified outcomes to the existing planning-stage requirements; it does not rewrite the original requirement IDs.

| Objective | Architecture response | Control / decision | Validation | Evidence | Assurance conclusion |
|---|---|---|---|---|---|
| Preserve required application connectivity | Hybrid WireGuard routing with scoped Azure Firewall policy | Selected allowed network path | AZ-01 | EV-01 | TCP/5432 HTTP listener reachable in 3/3 tests |
| Restrict unapproved network traffic | Azure Firewall Policy and NSG restrictions | Denied TCP/4444 path; private-network outbound NSG policy | AZ-02, AZ-04 | EV-01, EV-03 | Denied event observed; NSG rule evaluation returned Deny |
| Centralize security telemetry | Azure Firewall diagnostics → Event Hubs → Splunk Enterprise | Firewall diagnostic categories and Event Hub receiver role | AZ-05 | EV-01 | Firewall telemetry observed in Splunk |
| Detect repeated denied connections | Splunk scheduled correlation alert SEC-001 | Scheduled alert on indexed firewall events | AZ-03 | EV-02 | Triggered alert observed on 3 November 2026 |
| Restrict log-ingestion privileges | Event Hub-scoped Azure Event Hubs Data Receiver | Least-privilege service principal assignment | Configuration review | See implementation documentation | Scope recorded; not a penetration test of identity boundaries |
| Protect checkpoint storage transport | HTTPS-only, TLS 1.2, anonymous blob access disabled | Storage security configuration | Configuration review | See implementation documentation | Configuration recorded; not an end-to-end storage attack test |

## Evidence status

EV-01–EV-03 are reserved screenshot references in the evidence register. They become **published screenshot evidence only after the images are uploaded and reviewed**. Test outcomes described here reflect previously recorded laboratory observations, not tests rerun during this documentation update.

## Assurance rule

A successful connection does not prove application authentication. A blocked flow does not prove every other path is blocked. A triggered alert does not establish a unique security incident.

[Requirements](01-business-security-requirements.md) · [Risk Assessment](02-threat-model-risk-assessment.md) · [Decisions](04-architecture-decision-records.md) · [Validation](07-security-validation-evidence.md)
