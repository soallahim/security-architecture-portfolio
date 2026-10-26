# 02 — Threat Model and Risk Assessment

**Project:** Enterprise Azure Security Architecture & Monitoring  
**Status:** Proposed / Not Implemented / Not Tested  
**Version:** 1.0 — planning baseline  
**Reference:** [01 — Business and Security Requirements](./01-business-security-requirements.md)

> This document models hypothetical threats against a fictional enterprise environment. No attack, compromise, or control effectiveness has been observed or tested in Azure.

## 1. Assessment purpose and method

Identify plausible threats to the proposed hybrid architecture, prioritize the resulting risks, select proportionate safeguards, and define the evidence needed to assess whether those safeguards work. STRIDE is used to organize threat scenarios; likelihood and impact are qualitative planning judgments, not measured frequencies or loss estimates.

The assessment covers network isolation, administrative access, VPN routing, Azure firewall enforcement, security log delivery, and cost/credential exposure. Production-grade availability and business continuity are outside the proof-of-concept scope.

## 2. System context and assets

| Asset ID | Asset / trust role | Primary security concern | Status |
|---|---|---|---|
| AST-01 | Application VM, proposed `10.50.10.4` | Unauthorized access, lateral movement | Proposed |
| AST-02 | Database/test-service VM, proposed `10.50.20.4` | Data-tier exposure, unwanted inbound access | Proposed |
| AST-03 | Azure Firewall Basic and policy | Rule correctness, inspected path, auditability | Proposed |
| AST-04 | Azure route tables, NICs, NSGs | Routing bypass, asymmetric flows, unwanted public access | Proposed |
| AST-05 | Azure Linux WireGuard gateway, proposed `10.50.1.4` | VPN key compromise, unintended forwarding | Proposed |
| AST-06 | Local OPNsense and management host, `192.168.50.0/24` | Privileged-origin compromise, VPN misuse | Planned local lab |
| AST-07 | Local Splunk Enterprise and log ingestion pipeline | Visibility gaps, event tampering, ingestion failure | Planned local lab |
| AST-08 | Azure subscription, IaC state and secrets | Unauthorized changes, spend, leaked credentials | Not activated |
| AST-09 | Azure Event Hubs / Azure Monitor diagnostic pipeline | Delivery failure, unintended data disclosure, cost | Proposed |

**Data classification:** Fictional test traffic and synthetic event data only. No production customer records or credentials will be used. A TCP 5432 test listener is **not** evidence of PostgreSQL or a production database.

## 3. Trust boundaries and attack surface

| Boundary ID | Boundary | Crossing / entry point | Security decision |
|---|---|---|---|
| TB-01 | Untrusted Internet → Azure public VPN endpoint | WireGuard UDP listener | Authenticate peer, restrict listener, minimize exposure |
| TB-02 | Local network → encrypted WireGuard tunnel | OPNsense peer and local management host | Authenticate peers, restrict routed source networks |
| TB-03 | WireGuard VM → Azure workload subnets | Linux forwarding, NIC forwarding, UDRs, Azure Firewall | Force intended flows through inspection; avoid permissive forwarding |
| TB-04 | APP subnet ↔ DB subnet | UDRs, Azure Firewall rules, NSGs | Least-privilege service access; block unauthorized new sessions |
| TB-05 | Administrator → workload management plane | SSH via approved local source | Source restriction, host authentication, no direct Internet SSH |
| TB-06 | Azure security telemetry → Event Hubs → local Splunk | Diagnostic settings, consumer authentication, transport | Secure collection, least privilege, verifiable ingestion |
| TB-07 | Operator → Azure subscription / IaC | Portal, API, credentials, state files | Least privilege, secret handling, budget and cleanup controls |

The topology does not itself prove that traffic traverses Azure Firewall. Azure effective routes, stateful rule behavior, WireGuard AllowedIPs, NAT, return paths, and packet/log correlation require separate verification.

## 4. STRIDE threat scenarios

| Threat ID | STRIDE category | Hypothetical threat | Affected assets/boundaries | Related risks |
|---|---|---|---|---|
| TH-01 | Spoofing | Unauthorized WireGuard peer or stolen peer key impersonates an approved endpoint | AST-05/06, TB-01/02 | R-03 |
| TH-02 | Tampering | Misconfigured UDR/NSG/firewall policy permits unintended APP↔DB access | AST-03/04, TB-03/04 | R-01, R-02 |
| TH-03 | Repudiation | Firewall events are absent or cannot be correlated to a validation attempt | AST-03/07/09, TB-06 | R-05 |
| TH-04 | Information disclosure | Public management service or overly broad VPN routes expose APP/DB | AST-01/02/05, TB-01/03/05 | R-03, R-04 |
| TH-05 | Denial of service | Azure VPN VM/firewall is unavailable, or trial resources/credits are exhausted | AST-03/05/08, TB-01/07 | R-07, R-08 |
| TH-06 | Elevation of privilege | Compromised management host or excessive forwarding privileges allow unauthorized administrative reach | AST-05/06, TB-02/03/05 | R-04, R-06 |
| TH-07 | Tampering / Information disclosure | Secrets in GitHub or deployment artifacts expose Azure/VPN/log credentials | AST-05/08/09, TB-06/07 | R-06 |
| TH-08 | Tampering / Repudiation | Misconfigured Event Hubs/Splunk transport silently drops or mislabels security events | AST-07/09, TB-06 | R-05 |
| TH-09 | Denial of service | Unintended billable resources persist after lab shutdown | AST-08/09, TB-07 | R-08 |

STRIDE categories are analytical labels, not evidence that the threats occurred.

## 5. Hypothetical attack paths

### AP-01 — Application-to-database lateral movement

1. Assume an attacker has execution on the APP VM.
2. They attempt DB SSH or an unapproved TCP port.
3. An overly permissive UDR, firewall policy, NSG, or host rule might permit access.
4. **Target safeguard:** APP↔DB inspection via Azure Firewall, explicit least-privilege rules, NSGs and host controls.
5. **Evidence needed:** APP-to-DB negative test, effective routes, matching firewall Deny event, and configuration snapshots.

**Status:** Hypothetical / Not Tested. See NET-02, ROUTE-01; SEC-02, SEC-04.

### AP-02 — VPN gateway bypass of central inspection

1. Assume a local management host sends traffic through WireGuard.
2. The Azure gateway forwards it directly to APP/DB due to an incorrect route or Linux forwarding rule.
3. A connection could succeed without traversing Azure Firewall.
4. **Target safeguard:** UDRs on relevant subnets, restricted gateway forwarding, symmetrical return routes, independent NSG rules.
5. **Evidence needed:** Effective route and next-hop checks, gateway forwarding/NAT inspection, and correlated Azure Firewall logs for permitted and denied flows.

**Status:** Hypothetical / Not Tested. See VPN-02, VPN-03, ROUTE-01; SEC-04 to SEC-07.

### AP-03 — Compromised VPN peer or management origin

1. Assume a peer private key or local administrative host is compromised.
2. An unauthorized actor uses the tunnel to probe cloud workloads.
3. Overly broad AllowedIPs, permissive firewall policies, or weak host authentication increases exposure.
4. **Target safeguard:** Peer-specific keys, limited routes, source-scoped rules, secure key storage, SSH key authentication, key rotation plan.
5. **Evidence needed:** Peer config review, negative reachability tests, authentication settings, and evidence of denied flows.

**Status:** Hypothetical / Not Tested. See VPN-01/03; SEC-05/06/09.

### AP-04 — Security monitoring blind spot

1. Assume a network policy is violated or a rule unexpectedly allows traffic.
2. Diagnostic settings, Event Hubs, transport, or Splunk ingestion fails.
3. Investigators lack usable records to distinguish enforcement from simple connectivity failure.
4. **Target safeguard:** Diagnostic configuration review, health checks, test-event correlation, and documented gaps.
5. **Evidence needed:** Source event, delivery configuration, searchable Splunk event, time/action/5-tuple correlation where available.

**Status:** Hypothetical / Not Tested. See LOG-01; SEC-08.

## 6. Risk scoring

**Likelihood (L):** 1 = Unlikely under lab assumptions; 2 = Plausible; 3 = Likely without controls.  
**Impact (I):** 1 = Limited lab effect; 2 = Significant loss of isolation/visibility; 3 = Serious control failure, credential exposure, or spending beyond approved limit.  
**Score = L × I.** 1–2 Low; 3–4 Medium; 6–9 High.

Scores reflect **pre-control planning assumptions** and must be revisited after implementation. They are not claims about real incidents.

## 7. Risk register

| Risk ID | Risk statement | L | I | Score / priority | Proposed mitigation | Owner / linked controls | Validation | Residual status |
|---|---|---:|---:|---|---|---|---|---|
| R-01 | APP can reach unapproved DB services due to permissive segmentation rules | 3 | 3 | 9 High | Least-privilege Firewall network rules, NSGs, negative tests | Project operator; SEC-01/02 | NET-01/02 | Not assessed |
| R-02 | Inter-zone or hybrid flows bypass Azure Firewall through UDR/NAT/return-path errors | 3 | 3 | 9 High | Review both directions, effective routes, WireGuard forwarding, NAT and firewall log correlation | Project operator; SEC-04 | ROUTE-01, VPN-02/03 | Not assessed |
| R-03 | Unauthorized WireGuard peer or excessive tunnel routing exposes Azure subnets | 2 | 3 | 6 High | Unique peer keys, restrictive AllowedIPs, UDP ingress and forwarding rules | Project operator; SEC-05/07 | VPN-01/03 | Not assessed |
| R-04 | Direct Internet SSH or excessive local administrator access exposes workloads | 2 | 3 | 6 High | No direct APP/DB public SSH, source-scoped SSH, host firewall, SSH key auth | Project operator; SEC-06/07 | VPN-02/03, configuration review | Not assessed |
| R-05 | Missing or unusable logs undermine enforcement evidence and investigation | 3 | 2 | 6 High | End-to-end logging validation, event correlation, ingestion health checks | Project operator; SEC-08 | LOG-01 | Not assessed |
| R-06 | Leaked keys or credentials in repository/IaC permit unauthorized access | 2 | 3 | 6 High | Placeholders, .gitignore, secure secret handling, pre-publication scan | Project operator; SEC-09 | GOV-01 | Not assessed |
| R-07 | Single WireGuard VM or Firewall disruption breaks hybrid management | 2 | 2 | 4 Medium | Explicit single-point-of-failure limitation; no HA claims; controlled lab duration | Project operator; BUS-03 | VPN-01, limitation review | Accepted for PoC only, pending review |
| R-08 | Incomplete cost model, free-trial limits, or orphaned resources exceed SAR 150 | 2 | 3 | 6 High | Updated pricing, spending guardrails, staged deployment, inventory and teardown verification | Project operator; BUS-05, SEC-10 | GOV-01 | Not assessed |
| R-09 | Misconfigured Event Hubs consumer or forwarding path discloses or loses security events | 2 | 2 | 4 Medium | Least-privilege consumer access, transport review, sanitized events, monitoring | Project operator; SEC-08/09 | LOG-01, GOV-01 | Not assessed |

**Risk acceptance:** Only R-07 is a candidate for conscious acceptance within this short-lived, non-production PoC. No other risk is accepted or reduced merely by documenting a proposed control.

## 8. Treatment and assurance priorities

**Priority 1 — architecture blockers (before Azure activation):** R-02 routing symmetry/inspection; R-08 cost/cleanup; R-06 secret handling; R-05 ingestion feasibility. Each requires a concrete design and offline review, not just a narrative.

**Priority 2 — deployment-time validation:** R-01/03/04 with allowed and denied traffic, firewall policy/route evidence, VPN and host configuration review.

**Priority 3 — explicit limitations:** R-07 availability, R-09 telemetry exposure and reliability. Record any residual risk after actual testing and include a finding owner and next action.

## 9. Requirement, test and evidence traceability

| Risk | Requirements | Planned tests | Evidence required |
|---|---|---|---|
| R-01 | SEC-01, SEC-02, SEC-03 | NET-01, NET-02, NET-03 | Configuration, connection results, firewall logs |
| R-02 | SEC-04, SEC-05 | ROUTE-01, VPN-02, VPN-03 | Effective routes, gateway forwarding, log correlation |
| R-03 | SEC-05, SEC-07 | VPN-01, VPN-03 | Peer/routing configuration, negative access test |
| R-04 | SEC-06, SEC-07 | VPN-02, VPN-03 | SSH and NSG/host firewall configuration |
| R-05, R-09 | SEC-08 | LOG-01 | Diagnostic settings, delivery path, Splunk event |
| R-06 | SEC-09 | GOV-01 | Secret scan, sanitized configuration review |
| R-07 | BUS-03 | VPN-01 | Availability limitation and operational note |
| R-08 | BUS-05, SEC-10 | GOV-01 | Cost model, resource inventory, cleanup checks |

## 10. Review findings and open decisions

| Finding ID | Observation | Required next action | Status |
|---|---|---|---|
| TM-01 | UDR/forwarding design is proposed; firewall traversal and return path are not demonstrated | Finalize both-direction packet walks and route tables before deployment | Open |
| TM-02 | Azure Firewall Basic SKU/VM availability in UAE North is subscription-dependent | Check quotas/availability at deployment readiness | Open |
| TM-03 | Event Hubs-to-local-Splunk transport and authentication approach are not finalized | Produce ingestion ADR and offline configuration plan | Open |
| TM-04 | No actual local or Azure lab evidence has been collected for this project | Keep all test statuses Not Tested until execution | Open |
| TM-05 | Trial cost estimate is incomplete and no trial account has been activated | Revise budget and teardown plan before cloud activation | Open |

## 11. Assurance position

**Current assessment:** Design-stage risk identification completed; mitigation effectiveness **Not Evidenced**. This document does not approve Azure activation or represent a passed penetration test. The next artifact should define the target architecture and bidirectional routing/inspection paths, followed by ADRs and a validation plan.

---

*Prepared for a fictional educational architecture case study. Do not publish live credentials, private keys, or unsanitized operational evidence.*
