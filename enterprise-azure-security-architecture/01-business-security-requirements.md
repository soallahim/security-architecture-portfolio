# 01 — Business and Security Requirements

**Project:** Enterprise Azure Security Architecture & Monitoring  
**Status:** Proposed / Not Implemented  
**Scenario:** Fictional enterprise case study  
**Version:** 1.0 — planning baseline

## 1. Business scenario

A fictional organization is moving an internal application and its supporting database to Microsoft Azure. Administrators work from a small on-premises environment. The organization needs to prevent unauthorized lateral movement, limit management access, and collect useful security telemetry for investigation. Its existing local internet connection is behind carrier-grade NAT (CGNAT), so it cannot rely on unsolicited inbound connectivity to the local firewall.

This portfolio project will demonstrate how to translate those needs into a defensible cloud/hybrid security architecture, make explicit design trade-offs, deploy a limited proof of concept when ready, and validate controls with evidence.

**Business value sought:** Reduce unnecessary network exposure, enable controlled hybrid administration, make policy decisions auditable, and identify residual risks before accepting a design.

## 2. Scope and boundaries

### In scope

- Proposed Azure virtual network in UAE North with separate application, database, WireGuard gateway, and Azure Firewall subnets.
- Network-level segmentation using Azure Firewall Basic, user-defined routes (UDRs), and network security groups (NSGs).
- A client-initiated WireGuard connection from local OPNsense to an Azure-hosted Linux VPN endpoint, subject to feasibility testing.
- Limited administrative access from a designated local management host to the application VM.
- Selected Azure Firewall and platform telemetry routed toward local Splunk Enterprise, with transport and connector feasibility to be verified.
- Documented requirements, threats, risks, architecture decision records, policy/flow matrices, automated deployment artifacts, tests, evidence, and an assurance report.
- A bounded, short-duration Azure proof of concept only after offline readiness review.

### Out of scope

- Production deployment, business-critical workloads, high availability, disaster recovery, and enterprise-scale performance benchmarking.
- Claims of PostgreSQL deployment unless PostgreSQL is actually installed; a temporary TCP 5432 listener may be used solely for connectivity testing and must be labeled accurately.
- Advanced threat inspection features unavailable in Azure Firewall Basic, such as IDPS and TLS inspection.
- Production identity federation, privileged-access management, or formal regulatory certification.
- Any claim that a conceptual attack path represents an observed attack.

### Assumptions and constraints

- Azure Free Trial is **not activated**; no Azure resources have been deployed for this project.
- The user's out-of-pocket budget ceiling is **SAR 150**. Trial-credit eligibility, resource availability, and exact billing remain unverified.
- The initial USD 32.44 calculator figure is a mixed-duration, incomplete planning estimate, not an approved maximum.
- Local lab includes OPNsense and Splunk Enterprise; actual readiness, network resources, and integration remain to be verified.
- CGNAT means the local side must initiate the VPN connection; public endpoint reachability on the Azure side must be configured and validated.
- Initial proposed addressing: Azure VNet `10.50.0.0/16`; APP `10.50.10.0/24`; DB `10.50.20.0/24`; VPN `10.50.1.0/27`; local `192.168.50.0/24`; WireGuard tunnel `172.27.50.0/24`. These are **proposed**, not deployed.
- Proposed region: UAE North; Azure Firewall Basic and selected VM size availability must be confirmed in the eventual subscription.
- Evidence will not be fabricated or inferred from an unsuccessful connection alone.

## 3. Business requirements

| ID | Requirement | Acceptance criterion | Verification method |
|---|---|---|---|
| BUS-01 | Support a small hybrid application environment with explicit trust boundaries. | Architecture identifies each subnet, trust boundary, workload role, and management path; deployed topology is compared to the approved design. | Architecture review and resource inventory |
| BUS-02 | Restrict unnecessary lateral movement between application and database workloads. | Only documented business-required traffic is permitted; at least one unauthorized flow is denied with corroborating policy and log evidence. | Traffic tests, effective routes, firewall logs |
| BUS-03 | Enable limited administration from the local environment despite CGNAT. | Authorized local management host can reach APP on the approved port through the intended VPN/firewall path; unauthorized management to DB is blocked and evidenced. | VPN state, route inspection, connection tests, logs |
| BUS-04 | Provide usable security monitoring for selected network decisions. | Selected Azure Firewall Allow/Deny events are demonstrably searchable in Splunk with identifiable source, destination, action, and timestamp where emitted by the source. | Source configuration, sample event, Splunk query |
| BUS-05 | Keep the exercise financially bounded and reproducible. | A reviewed cost model, cleanup procedure, and deployment configuration exist before trial activation; spending remains within the user-approved ceiling. | Cost review, preflight checklist, billing observations |
| BUS-06 | Publish an honest, reviewable architecture case study. | Requirements, design choices, tests, evidence, findings, and limitations are linked and clearly distinguish Proposed, Implemented, Tested, and Not Evidenced. | Documentation and assurance review |

## 4. Security requirements

| ID | Requirement | Acceptance criterion | Planned verification |
|---|---|---|---|
| SEC-01 | Isolate APP and DB into distinct subnets. | APP and DB have separate address spaces and security controls; direct unrestricted connectivity is not assumed. | Deployed subnet/NIC review |
| SEC-02 | Enforce least-privilege APP-to-DB traffic. | APP-to-DB TCP 5432 is allowed only if used as the approved test service; unauthorized ports such as TCP 22 are blocked. | Positive and negative flow tests plus Azure Firewall logs |
| SEC-03 | Prevent DB-initiated access to APP unless explicitly required. | New DB-to-APP connection attempts on selected test ports are denied and supported by routing/policy/log evidence. | Negative flow test and policy inspection |
| SEC-04 | Ensure intended inter-zone traffic traverses Azure Firewall. | Effective routes and packet/log observations support firewall traversal in both directions; no unintended bypass path is identified in tested flows. | Effective routes, firewall rule hits, source/destination validation |
| SEC-05 | Secure the hybrid VPN without exposing local inbound services. | Local OPNsense initiates WireGuard to Azure; approved peers/keys, tunnel routes, and forwarding restrictions are documented and tested. | Peer status, packet capture or route inspection, firewall configuration |
| SEC-06 | Restrict management access. | Only a designated local management source can access APP SSH through the approved path; DB SSH from local is denied. | Positive/negative SSH tests and logs |
| SEC-07 | Apply defense in depth. | NSGs and host firewalls limit exposure independently of Azure Firewall; unnecessary public management exposure is absent. | NSG, public-IP, and host firewall review |
| SEC-08 | Record and investigate network policy decisions. | Representative allowed and denied firewall events are available in Splunk and linked to their test cases; missing fields or events are documented. | Event Hub/connector validation, Splunk searches |
| SEC-09 | Protect secrets and published evidence. | No real keys, credentials, sensitive IP ownership details, or authentication tokens are committed; sample configuration uses placeholders. | Secret scan and publication review |
| SEC-10 | Preserve a safe teardown path. | Every deployed resource is inventoried; a documented deletion procedure is tested or explicitly marked untested; remaining billable resources are checked. | Teardown checklist and billing/resource review |

## 5. Initial authorized traffic intent

| Flow ID | Source | Destination | Service | Expected decision | Notes |
|---|---|---|---|---|---|
| FLOW-01 | APP subnet | DB test VM | TCP 5432 | Allow | Test listener only unless an actual DB service is installed |
| FLOW-02 | APP subnet | DB test VM | TCP 22 | Deny | Unauthorized lateral access |
| FLOW-03 | DB subnet | APP VM | Selected new TCP sessions | Deny | Stateful return traffic for permitted sessions is different |
| FLOW-04 | Designated local admin host | APP VM | TCP 22 | Allow | Must traverse WireGuard and Azure Firewall |
| FLOW-05 | Designated local admin host | DB VM | TCP 22 | Deny | Require corroborating firewall evidence |
| FLOW-06 | Untrusted Internet | APP/DB management ports | TCP 22 | Deny | No direct public management exposure |
| FLOW-07 | Local OPNsense | Azure WireGuard public endpoint | WireGuard UDP port (TBD) | Allow, restricted | Local initiates tunnel; not an application-data allow rule |

**Important:** These are intended policies, not observed outcomes. Exact source addresses, firewall rule priorities, UDR associations, return routes, SNAT behavior, and event forwarding must be finalized in the detailed design. A route or topology line does not by itself grant or deny traffic.

## 6. Initial validation and evidence contract

| Test ID | Related requirements | Intended outcome | Minimum evidence |
|---|---|---|---|
| NET-01 | BUS-02, SEC-02, SEC-04 | APP → DB TCP 5432 succeeds via approved path | Test output, service identification, effective route, matching firewall Allow event |
| NET-02 | SEC-02, SEC-04 | APP → DB TCP 22 denied | Test output, effective route, matching firewall Deny event |
| NET-03 | SEC-03, SEC-04 | New DB → APP connection denied | Test output, effective route, matching Deny event |
| VPN-01 | BUS-03, SEC-05 | OPNsense-initiated tunnel established | Peer handshake and tunnel route observations |
| VPN-02 | BUS-03, SEC-06 | Local admin → APP SSH allowed | SSH connection evidence and corresponding firewall log |
| VPN-03 | BUS-03, SEC-06 | Local admin → DB SSH denied | Test output, route/policy inspection, matching Deny event |
| LOG-01 | BUS-04, SEC-08 | Relevant Azure Firewall events searchable in Splunk | Azure source settings, ingestion path, SPL query and real sample events |
| ROUTE-01 | SEC-04 | No bypass or asymmetric return for selected flows | Effective routes, next-hop checks, and packet/log correlation |
| GOV-01 | BUS-05, SEC-09, SEC-10 | Budget, secrets, and teardown safeguards satisfied | Preflight checklist, secret scan, cleanup verification |

All tests start as **Not Tested**. Each executed test must record date, configuration revision, expected versus actual behavior, result (**Pass / Fail / Partial / Not Tested**), evidence links, and limitations. Connection failure alone is insufficient evidence of Azure Firewall enforcement.

## 7. Architecture decisions to document

- **ADR-01:** Azure Firewall Basic versus alternatives and feature/cost trade-offs.
- **ADR-02:** Azure-hosted WireGuard versus Azure VPN Gateway given local CGNAT and budget.
- **ADR-03:** Routing and inspection design, including UDR symmetry, NSGs, and NAT behavior.
- **ADR-04:** Azure log transport and Splunk ingestion architecture, including Event Hubs connector feasibility.
- **ADR-05:** Short-duration deployment, trial-credit controls, and teardown strategy.

## 8. Delivery gates

**Gate A — Offline design ready:** Requirements, threat model, diagrams, routing/policy matrices, ADRs, and measurable tests reviewed.

**Gate B — Local lab ready:** OPNsense, Splunk, WireGuard preparation, and host capacity verified locally without Azure.

**Gate C — Deployment ready:** IaC/scripts reviewed, secrets strategy defined, subscription/SKU feasibility checklist prepared, cost estimate revised, and teardown plan documented.

**Gate D — Azure activation:** Only after explicit approval; do not create cloud resources as part of this document.

**Gate E — Evidence and assurance:** Execute tests, preserve actual observations, document findings/remediation, verify cleanup, and publish a truthful final report.

## 9. Open questions and risks

| ID | Open item | Resolution required before |
|---|---|---|
| OPEN-01 | Azure Firewall Basic and selected VM SKU quota/availability in UAE North | Cloud deployment |
| OPEN-02 | Final bidirectional UDR, WireGuard routing, IP forwarding, and NAT design | Gate A |
| OPEN-03 | Whether selected Azure logs can reliably reach local Splunk through the chosen transport/connector within budget | Gate C |
| OPEN-04 | Local laptop resources and Splunk/OPNsense readiness | Gate B |
| OPEN-05 | Full billing estimate, credit coverage, and cleanup verification | Gate C |
| OPEN-06 | Exact approved management host IP and final WireGuard UDP port | Gate A |

---

**Integrity statement:** This document defines a proposed exercise. No Azure deployment, traffic tests, firewall enforcement, or Splunk ingestion are claimed as completed.
