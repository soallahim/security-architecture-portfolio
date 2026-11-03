# 08 — Security Assessment Findings

## Assessment scope

This review evaluates the implemented Azure-to-local hybrid test path, network enforcement, and Azure Firewall-to-Splunk telemetry. It distinguishes confirmed laboratory observations from design risks. A denied flow is not, by itself, proof of an exploitable vulnerability.

## Test observations and disposition

| ID | Observation | Security implication | Action / disposition | Supporting evidence |
|---|---|---|---|---|
| AZ-F-01 | A temporary NSG rule was used during validation and subsequently removed | Temporary test rules require cleanup and verification; no unintended long-term retention was established | Temporary rule removed; Network Watcher IP flow verification returned **Deny** for the evaluated path | AZ-04; [NSG screenshot](./evidence/EV-AZURE-03-NSG-Deny.png) |
| AZ-F-02 | Authorized TCP/5432 traffic reached the local HTTP test listener in 3/3 checks | Required connectivity can coexist with selected deny policies | Recorded as a positive network reachability result; not database authentication assurance | AZ-01; [Firewall logs](./evidence/EV-AZURE-01-Firewall-Logs.png) |
| AZ-F-03 | Denied TCP/4444 events were received by Splunk and the SEC-001 scheduled detection triggered | Demonstrates visibility and detection for the tested denied traffic | Recorded as a validated detection path; repeated alert executions are not independent incidents | AZ-02, AZ-03, AZ-05; [Firewall logs](./evidence/EV-AZURE-01-Firewall-Logs.png), [SEC-001](./evidence/EV-AZURE-02-SEC001-Triggered.png) |

## Assessment interpretation

**Classification:** AZ-F-01 is a test-cleanup verification observation, not a confirmed vulnerability. AZ-F-02 and AZ-F-03 are positive assurance observations, not security defects.


**Observed test cleanup:** AZ-F-01 records the removal of a temporary test exception and a subsequent NSG decision check. It is not presented as an exploited vulnerability or a production security incident.

**Architecture assurance:** Network enforcement and monitoring are supported for specific test paths only. The validation does not establish complete policy coverage, all possible lateral-movement paths, or production readiness.

## Related documents

[Requirements](01-business-security-requirements.md) · [Risk Assessment](02-threat-model-risk-assessment.md) · [Architecture](03-target-security-architecture.md) · [Validation](07-security-validation-evidence.md) · [Evidence Register](evidence/README.md)
