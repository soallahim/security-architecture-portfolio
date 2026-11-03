# 01 — Business and Security Requirements

**Document status:** Current-state architecture requirements review | **Assessment date:** 3 November 2026 | **Environment:** Educational hybrid laboratory, Azure Japan East.

## 1. Business case and architecture objectives

The project evaluates how a small organization could establish controlled Azure-to-local connectivity while retaining network policy enforcement, security-event visibility, and reviewable architectural evidence. It demonstrates selected design controls, **not** a production-ready enterprise deployment.

**Primary objectives:** (1) permit explicitly required hybrid service traffic, (2) restrict unauthorized cross-boundary access, (3) centralize Azure Firewall decisions in Splunk, (4) produce a detectable security signal, and (5) document decisions, trade-offs, tests and evidence without exposing operational source files.

## 2. System boundary

| Zone / component | Function | Trust consideration |
|---|---|---|
| Azure VNet `10.50.0.0/16` (Japan East) | Cloud application and security infrastructure | Workload traffic is not automatically trusted |
| Azure application VM `10.50.10.4` | Test workload / flow initiator | Requires scoped routes and service permissions |
| Azure Firewall `10.50.0.4` | Network policy enforcement and diagnostic events | Policy effectiveness must be tied to specific flows |
| WireGuard gateway and OPNsense | Hybrid tunnel and local routing | Tunnel establishment does not authorize all traffic |
| Local HTTP test listener `192.168.20.10:5432` | Temporary connectivity test endpoint | **Not PostgreSQL**; no database authentication tested |
| Azure Event Hubs and Splunk Enterprise | Telemetry transport, search and scheduled detection | Event availability and consumer privilege boundaries |

**Evidence scope:** Five recorded AZ tests (AZ-01–AZ-05) and 15 retained screenshots. Not every image proves a distinct Azure security control. See [validation](07-security-validation-evidence.md) and [evidence index](evidence/README.md).

## 3. Business requirements and disposition

| ID | Requirement | Current evidence-informed disposition |
|---|---|---|
| BUS-01 | Explicit hybrid application trust boundaries | Architecture documented; only selected routes/flows validated |
| BUS-02 | Restrict unnecessary lateral movement | TCP/5432 allow and TCP/4444 deny observed; no exhaustive isolation claim |
| BUS-03 | Limited local administration under CGNAT | WireGuard connectivity established; full management allow/deny test coverage not confirmed by AZ tests |
| BUS-04 | Searchable Azure network security telemetry | Azure Firewall events indexed in Splunk and SEC-001 triggered |
| BUS-05 | Financially bounded, reproducible exercise | Original cost and teardown planning recorded; final cost/cleanup reconciliation not evidenced |
| BUS-06 | Honest, reviewable architecture case study | Requirements, decisions, results and evidence linked; untested claims distinguished |

## 4. Security requirements and assurance status

| ID | Requirement | Observed control / validation | Status |
|---|---|---|---|
| SEC-01 | Isolate APP and DB into distinct security zones | Route/segmentation screenshots; full independent APP/DB isolation test not established | Partially evidenced |
| SEC-02 | Least-privilege APP-to-service access | AZ-01 permitted TCP/5432 to HTTP listener; AZ-02 denied TCP/4444 | Partially validated; original TCP/22 test not confirmed |
| SEC-03 | Block unsolicited DB-to-APP sessions | No corresponding reverse-direction AZ test | Not validated |
| SEC-04 | Enforce intended inspection path | UDR/effective-route evidence and Azure Firewall events | Partially evidenced; no universal path assurance |
| SEC-05 | Secure hybrid VPN and local ingress | WireGuard used; routing evidence available | Partially evidenced; peer security not independently tested |
| SEC-06 | Restrict administrative access | Management-blocking screenshots available; source and scenario attribution not fully established | Partially evidenced |
| SEC-07 | Layered network restrictions | AZ-04 Network Watcher NSG decision returned Deny | Partially validated |
| SEC-08 | Record and investigate policy decisions | AZ-02, AZ-03, AZ-05: events ingested and scheduled alert triggered | Validated for observed event/detection path |
| SEC-09 | Protect secrets and published evidence | Repository owner confirmed screenshot sensitive-data review; receiver-scope and storage configuration recorded | Partially evidenced; no full secret scan claimed |
| SEC-10 | Preserve budget and teardown safeguards | Deletion of project resource group confirmed via Azure CLI; subscription resource list showed only two Network Watchers. Final billing reconciliation pending | Partially validated — resource cleanup confirmed |

**Acceptance rule:** A successful test satisfies only its stated assertion. Neither a TCP connection nor an NSG decision establishes comprehensive segmentation or application authorization.

## 5. Authorized traffic and telemetry intent

| Flow | Intent | Recorded observation |
|---|---|---|
| Azure APP → local test listener, TCP/5432 | Permit a specific required service | AZ-01: 3/3 connections succeeded |
| Selected Azure → local destination, TCP/4444 | Deny unapproved test traffic | AZ-02: denied events observed in Splunk |
| Selected private-network outbound NSG flow | Apply restrictive NSG policy | AZ-04: Network Watcher returned Deny after temporary rule removal |
| Azure Firewall → Event Hubs → Splunk | Centralize firewall events | AZ-05: events ingested in `azure_security` |
| Indexed denied events → SEC-001 | Trigger repeated-denial detection | AZ-03: scheduled alert triggered |

The full [traffic flow matrix](09-security-traffic-flow-matrix.md) separates enforcement points from telemetry channels.

## 6. Original test contract versus executed tests

The initial plan defined NET-01/02/03, VPN-01/02/03, ROUTE-01, LOG-01 and GOV-01. **These historical identifiers must not be silently marked passed** because the later AZ-01–AZ-05 tests cover different assertions. For example, the original NET-02 expected a TCP/22 deny, whereas AZ-02 recorded denied TCP/4444. The original NET-03 reverse-direction test is not proven by the recorded AZ series.

## 7. Architectural acceptance and evidence

**Accepted for portfolio demonstration:** Selected hybrid reachability, denied-event visibility, centralized Azure Firewall telemetry, scheduled alert execution, and the evaluated NSG deny decision.

**Not accepted as proven:** Complete APP/DB separation, all reverse-direction denies, full tunnel peer hardening, complete management-access policy, final billing closure, or production assurance.

**Traceability:** [Threat and risk register](02-threat-model-risk-assessment.md) · [Architecture](03-target-security-architecture.md) · [ADRs](04-architecture-decision-records.md) · [RTM](10-requirements-traceability-matrix.md) · [Assurance report](13-security-assurance-report.md).
