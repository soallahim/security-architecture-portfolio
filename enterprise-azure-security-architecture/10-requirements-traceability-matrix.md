# 10 — Requirements Traceability Matrix

## Traceability method

This matrix uses the **original requirement identifiers** from [01 — Business and Security Requirements](01-business-security-requirements.md). It separates tested outcomes, configuration observations, and requirements that cannot be declared verified from the available evidence. Original design-stage tests (NET/VPN/ROUTE/GOV) are **not automatically equivalent** to the later AZ-01–AZ-05 laboratory validation identifiers.

| Requirement | Security objective | Architecture decision / control | Recorded validation | Current assurance status |
|---|---|---|---|---|
| SEC-01 | Separate application and database security zones | Subnet segregation, routing, NSG and Azure Firewall | Route-association screenshots in evidence register; no complete independent zone isolation test in AZ-01–05 | **Partially evidenced** |
| SEC-02 | Least-privilege application-to-service communication | Azure Firewall Policy and network restrictions | AZ-01: 3/3 TCP/5432 HTTP-listener connections; AZ-02: denied TCP/4444 events | **Partially validated** — selected flows only; original TCP/22 negative test not established |
| SEC-03 | Block unsolicited database-to-application initiation | Bidirectional routing and restrictive network rules | No directly corresponding AZ-01–05 reverse-initiation test | **Not validated by current AZ tests** |
| SEC-04 | Enforce intended central firewall inspection | UDR, Azure Firewall, hybrid routing | Effective-route screenshots and Azure Firewall events; no complete symmetric packet-path proof | **Partially evidenced** |
| SEC-05 | Secure hybrid VPN without local inbound exposure | WireGuard, restrictive routing, OPNsense | Hybrid connectivity observed; route screenshots available | **Partially evidenced** — peer/key security and all forwarding paths not independently tested |
| SEC-06 | Restrict management access | Source-restricted management rules, host/NSG controls | Management-blocking screenshots present; their test context requires separate attribution | **Evidence available; coverage not fully established** |
| SEC-07 | Defense in depth | Azure Firewall, NSG and host restrictions | AZ-04: Network Watcher returned Deny after temporary-rule removal | **Partially validated** — NSG decision only |
| SEC-08 | Record and investigate policy decisions | Firewall diagnostics, Event Hubs, Splunk and SEC-001 | AZ-02, AZ-03, AZ-05 | **Validated for observed pipeline and alert** |
| SEC-09 | Protect secrets and published evidence | Least-privilege ingestion role, storage transport controls, publication review | Owner confirmed screenshot sensitive-data review; configuration observations recorded | **Partially evidenced** — no full repository secret-scan claim |
| SEC-10 | Maintain safe teardown and cost governance | Inventory, cost checks, cleanup plan | Historical plan documented; no confirmed final resource/billing reconciliation | **Not validated** |

## Verified evidence references

| Validation | Observed result | Screenshot |
|---|---|---|
| AZ-01 | 3/3 TCP/5432 connections to local HTTP test listener | [Azure Firewall logs](evidence/EV-AZURE-01-Firewall-Logs.png) |
| AZ-02 | Denied TCP/4444 events ingested in Splunk | [Azure Firewall logs](evidence/EV-AZURE-01-Firewall-Logs.png) |
| AZ-03 | SEC-001 scheduled alert triggered | [SEC-001 screenshot](evidence/EV-AZURE-02-SEC001-Triggered.png) |
| AZ-04 | Network Watcher IP flow verification returned Deny | [NSG screenshot](evidence/EV-AZURE-03-NSG-Deny.png) |
| AZ-05 | Azure Firewall diagnostics observed through Event Hubs in Splunk | [Firewall logs](evidence/EV-AZURE-01-Firewall-Logs.png) |

## Assurance interpretation

**The five AZ tests directly support selected aspects of SEC-02, SEC-04, SEC-07 and SEC-08.** SEC-05 has supporting hybrid-connectivity context but no complete VPN-security validation. The other requirements have configuration observations, ancillary screenshot material, or no confirmed matching test. This is a qualitative mapping, not a numerical compliance score. An original requirement should not be marked fully met merely because one associated test passed.

The TCP/5432 target was a temporary HTTP listener, not PostgreSQL. NSG IP flow verification is a rule-decision check, not end-to-end packet proof. Multiple scheduled alert executions are not independent incidents. Images remain in the [15-image evidence register](evidence/README.md), with all files retained.

## Related documents

[Original Requirements](01-business-security-requirements.md) · [Risk Register](02-threat-model-risk-assessment.md) · [ADRs](04-architecture-decision-records.md) · [Validation](07-security-validation-evidence.md) · [Security Assurance](13-security-assurance-report.md)
