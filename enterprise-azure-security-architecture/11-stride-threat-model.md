# 11 — STRIDE Threat Model

## System under assessment

The assessed system includes an Azure application workload, routed WireGuard connectivity to local laboratory segments, Azure Firewall and NSG enforcement, Event Hubs telemetry transport, and Splunk Enterprise detection. The STRIDE scenarios below are **architectural threat hypotheses**, not observed compromises.

| STRIDE | Threat scenario | Trust boundary | Architecture response | Validation coverage |
|---|---|---|---|---|
| Spoofing | Unauthorized identity attempts to consume security events | Event Hubs → Splunk | Event Hub-scoped Data Receiver role for the ingestion principal | Configuration recorded; adversarial identity test not claimed |
| Tampering | A policy exception permits traffic beyond intended scope | Workload → network controls | Restricted policy and review of temporary NSG test rule | Temporary exception removed; AZ-04 |
| Repudiation | Denied network activity lacks centrally searchable records | Azure Firewall → Event Hubs → Splunk | Centralized firewall diagnostics and indexed telemetry | AZ-02, AZ-05 |
| Information disclosure | Broader-than-needed network reachability exposes local services | Azure ↔ local network | Destination/port-specific enforcement | Selected allow/deny flows AZ-01, AZ-02 |
| Denial of service | Disruption of telemetry pipeline reduces monitoring visibility | Event Hubs → Splunk | Separation of event transport and SIEM consumption; operational monitoring needed | Event ingestion observed; resilience test not claimed |
| Elevation of privilege | Over-scoped ingestion identity or administrative path | Azure IAM / local management | Receiver-only Event Hub role and controlled management routing | Role scope recorded; privilege escalation not tested |

## Prioritization

Highest attention in this lab is given to **unauthorized cross-boundary traffic**, **unintended policy exceptions**, and **loss of detection visibility**, because these directly affect the architecture objectives. This is a qualitative design prioritization, not a quantified production risk score.

## Relationship to the risk register

The planning-stage risk register in [02](02-threat-model-risk-assessment.md) provides the initial risk framing. This document organizes the threat scenarios by STRIDE and points to the specific tests where evidence exists. Neither document substitutes for an enterprise penetration test.

[Architecture](03-target-security-architecture.md) · [Traffic Matrix](09-security-traffic-flow-matrix.md) · [Assurance](13-security-assurance-report.md)
