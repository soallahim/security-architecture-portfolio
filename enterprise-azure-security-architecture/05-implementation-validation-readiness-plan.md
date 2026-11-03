# 05 — Implementation and Validation Readiness Plan

**Document purpose:** Record the original readiness approach, the **actual executed validation outcomes**, and the remaining assurance gaps. Historical test identifiers are retained but not incorrectly converted to passing results.

## 1. Delivery approach

The original work sequence covered local OPNsense/Splunk readiness, WireGuard preparation, Azure network controls, diagnostic ingestion, positive and negative traffic tests, evidence capture and cost/teardown planning. The subsequent lab execution produced the recorded AZ-01–AZ-05 outcomes.

**Environment:** Azure Japan East; VNet `10.50.0.0/16`; application VM `10.50.10.4`; Azure Firewall `10.50.0.4`; local HTTP test listener `192.168.20.10:5432`.

## 2. Implementation workstreams

| Workstream | Architecture outcome | Evidence status |
|---|---|---|
| Local network segmentation | OPNsense and local routes used for the hybrid lab | Routing/management screenshots retained; full segmentation assertions separately assessed |
| WireGuard hybrid link | Azure-to-local connectivity demonstrated | Positive connection test and route screenshots |
| Azure network controls | Azure Firewall Policy and NSG restrictions applied | Denied events and Network Watcher rule decision |
| Firewall diagnostic transport | Azure Firewall diagnostics sent through Event Hubs | Events observed in Splunk |
| SIEM onboarding | Splunk Enterprise ingested firewall telemetry in `azure_security` | Azure/Splunk screenshots |
| Detection engineering | Scheduled SEC-001 repeated-denial alert | Trigger observed 3 November 2026 |
| Governance | Cost/cleanup planning recorded | Project resource group deletion confirmed; final billing not independently evidenced |

## 3. Executed validation register

| ID | Assertion | Actual observation | Interpretation | Primary screenshot |
|---|---|---|---|---|
| AZ-01 | Selected Azure-to-local service reachable | 3/3 TCP/5432 connections to temporary HTTP listener succeeded | TCP reachability only | [Firewall logs](evidence/EV-AZURE-01-Firewall-Logs.png) |
| AZ-02 | Unauthorized test traffic denied and logged | TCP/4444 denied events appeared in Splunk | Selected policy decision and event visibility | [Firewall logs](evidence/EV-AZURE-01-Firewall-Logs.png) |
| AZ-03 | Scheduled repeated-deny detection executes | SEC-001 triggered | Alert execution; multiple triggers are not separate incidents | [SEC-001 alert](evidence/EV-AZURE-02-SEC001-Triggered.png) |
| AZ-04 | Restrictive NSG rule applies after test cleanup | Network Watcher returned Deny | Rule evaluation, not packet capture | [NSG decision](evidence/EV-AZURE-03-NSG-Deny.png) |
| AZ-05 | Firewall events reach centralized SIEM | Azure Firewall diagnostics indexed via Event Hubs | Observed telemetry path, not resilience assurance | [Firewall logs](evidence/EV-AZURE-01-Firewall-Logs.png) |

## 4. Original planned tests: reconciliation

The original design contract is preserved for traceability, but an AZ-series result is **not** substituted for a different test objective.

| Original test | Original assertion | Current evidence disposition |
|---|---|---|
| NET-01 | APP → DB TCP/5432 allowed | AZ-01 supports reachability to a temporary **HTTP listener**, not database behavior |
| NET-02 | APP → DB TCP/22 denied | **Not established** by AZ-02, which used TCP/4444 |
| NET-03 | DB → APP new session denied | **Not established** by current AZ tests |
| VPN-01 | OPNsense-initiated WireGuard handshake | Working hybrid link and routing evidence; exact handshake assertion not independently revalidated here |
| VPN-02 | Authorized local admin → APP SSH allowed | Not established by current AZ tests |
| VPN-03 | Unauthorized local admin → DB SSH denied | Management screenshots retained; not mapped to a complete AZ test |
| ROUTE-01 | No bypass/asymmetric return on tested paths | Effective-route evidence exists; exhaustive path proof not established |
| LOG-01 | Azure Firewall events searchable in Splunk | AZ-05 supports the observed event-ingestion assertion |
| GOV-01 | Cost, secrets and teardown verified | Owner screenshot privacy review confirmed; resource-group deletion and subscription inventory confirmed; billing and full secret scan not established |

## 5. Test acceptance and evidence integrity

**Pass is assertion-specific:** AZ-01 is a TCP connection test, AZ-04 is a Network Watcher NSG decision, AZ-03 is a scheduled alert trigger. A log screenshot does not prove application authentication; a triggered alert does not establish an investigated incident.

**Evidence register:** All 15 screenshots remain in [evidence/](evidence/README.md), with filenames unchanged. The repository owner confirmed sensitive-data review. Relevance and test attribution are documented separately.

## 6. Findings and corrective action

A temporary NSG rule used for validation was removed; Network Watcher subsequently returned Deny under `Deny-Private-Networks-Outbound`. This is a **test cleanup and verification observation**, not proof of an exploited vulnerability or a long-lived insecure configuration.

## 7. Governance and acceptance

**Accepted for portfolio demonstration:** Hybrid connectivity for the selected test service, denied-event visibility, Event Hub/Splunk ingestion, SEC-001 detection execution, and the NSG rule decision.

**Not claimed:** Production deployment approval, full network segmentation, authenticated database service, high availability, complete management test coverage, verified final cloud costs; project resource-group deletion is confirmed.

## 8. Next assurance work, if the lab is ever reactivated

Additional work would require explicit approval and cost review: original TCP/22 and reverse-direction tests; bidirectional route inspection; management-source positive/negative tests; peer and identity misuse checks; ingestion failure recovery; and billing reconciliation. These are **future test recommendations**, not completed tasks.

[Requirements](01-business-security-requirements.md) · [Architecture](03-target-security-architecture.md) · [Findings](08-security-assessment-findings.md) · [Validation](07-security-validation-evidence.md) · [Assurance](13-security-assurance-report.md).
