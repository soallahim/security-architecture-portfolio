# STRIDE Threat Model — Enterprise X Network Segmentation

## 1. Scope and Evidence Classification

**Assessment type:** Design-time threat modeling. **Status:** Analytical exercise, not penetration testing.

This model covers (a) the implemented OPNsense laboratory and (b) the proposed Enterprise X target architecture. The two are assessed separately. Threat scenarios are hypotheses unless expressly tied to observed lab behavior.

**Implemented lab:** APP 192.168.10.10, DB 192.168.20.10, Kali 192.168.30.10, and OPNsense with zone gateways 192.168.10.1 / 192.168.20.1 / 192.168.30.1. A temporary Python HTTP listener on TCP/5432 simulated database reachability; no PostgreSQL was deployed.

**Proposed only:** EdgeFW/VPN/MFA, DMZ reverse proxy, SegFW, corporate and privileged-access zones, jump host, SIEM, and enterprise application/database services. No implementation or test evidence exists for these components.

## 2. Assets, Trust Boundaries, and Assumptions

| Asset | Security objective | Scope |
|---|---|---|
| OPNsense management interface | Prevent unauthorized administrative network reachability | Implemented lab |
| APP-to-DB service path | Allow only approved source/destination/service | Implemented lab |
| Firewall policy and logs | Maintain policy integrity and traceable decisions | Implemented lab |
| Corporate endpoints and application workloads | Restrict lateral movement and unapproved backend access | Proposed enterprise |
| Database systems | Prevent direct corporate/vendor access | Proposed enterprise |
| Remote identities, VPN, and jump host | Enforce authenticated, time-bound privileged access | Proposed enterprise |
| SIEM/log collector | Preserve availability and integrity of security telemetry | Proposed enterprise |

**Trust boundaries:** APP↔OPNsense↔DB; APP/DB↔firewall management plane; Kali↔firewall management plane; external/remote↔EdgeFW; DMZ↔SegFW↔application; corporate↔SegFW↔database; VPN↔privileged access↔management; security log sources↔SIEM.

**Assumptions:** Enterprise X is fictional; proposed controls and attack paths are design scenarios, not discovered weaknesses. A network path alone does not prove credentials, exploitability, or successful compromise.

## 3. STRIDE Analysis

STRIDE categories: **S**poofing, **T**ampering, **R**epudiation, **I**nformation Disclosure, **D**enial of Service, **E**levation of Privilege.

| ID | STRIDE | Threat scenario / entry point | Trust boundary and possible impact | Design mitigation | Related policy / requirement | Evidence status |
|---|---|---|---|---|---|---|
| TM-01 | S | Stolen vendor identity used for remote entry | Internet → VPN → privileged access; unauthorized session | MFA, scoped identity authorization, time-bound vendor permissions | P-04, P-05; SR-08 | Proposed, not tested |
| TM-02 | T | Unauthorized modification of firewall rules | Administrator → firewall control plane; bypass segmentation | Restricted management origin, change approval, logging, configuration backup | LAB-P-03, LAB-P-05; SR-04, SR-05 | Management-path controls partly tested; change controls not tested |
| TM-03 | R | Privileged user disputes an administrative change | Jump host / management → audit system; weak attribution | Named identities, synchronized timestamps, centralized tamper-resistant audit logs | P-07, P-12; SR-06 | Proposed, not tested |
| TM-04 | I | Compromised corporate endpoint reaches database service | Corporate → DB; potential data exposure | Deny direct workstation-to-DB; permit scoped APP-to-DB only; database authorization | P-02, P-03; SR-02, SR-03 | Enterprise scenario only; analogous lab port filtering tested |
| TM-05 | D | Traffic flood exhausts a published service or firewall | Internet → EdgeFW/DMZ; reduced availability | Rate limits, capacity planning, HA assessment, monitoring | P-08, P-12 | Proposed, not tested |
| TM-06 | E | APP workload reaches sensitive firewall administration interface | APP → OPNsense management; enlarged management attack surface | Explicit management restrictions; inspect automatic rules; retest | LAB-P-03, LAB-P-05; SR-04, SR-05, SR-06 | **Observed reachability**, anti-lockout rule identified, remediated; LAB-03 passed |
| TM-07 | S / E | Vendor bypasses jump host to reach DB directly | VPN → DB; unauthorized sensitive access | SegFW default deny; P-05; jump-host-only scoped access | P-04, P-05, P-07 | Proposed, not tested |
| TM-08 | T / R | Security telemetry altered, lost, or untraceable | Log source → collector; monitoring blind spot | Authenticated transport, integrity checks, retention, ingestion monitoring | P-12; SR-06 | Proposed SIEM; local OPNsense logs reviewed in lab |
| TM-09 | E | Management-plane access from DB network | DB → OPNsense management; potential attack surface | Deny DB-originated admin traffic and correlate firewall decision logs | LAB-P-04; SR-04 | LAB-04 connection failed; enforcement evidence incomplete |

**Important interpretation:** TM-06 documents an observed **network reachability** issue, not authentication bypass, privilege escalation, or compromise. Its STRIDE category describes potential consequences, not a demonstrated exploit.

## 4. Design-Time Threat Prioritization

| Priority | Scenario | Rationale | Disposition |
|---|---|---|---|
| High (observed) | TM-06 | Sensitive management endpoint was reachable contrary to intended segmentation | Remediated for tested APP path; EV-03 and EV-04 |
| High (hypothetical) | TM-01, TM-04, TM-07 | External identity and database trust boundaries | Proposed controls; validation required |
| Medium (hypothetical) | TM-02, TM-03, TM-05, TM-08 | Depends on deployment, identity, audit, and availability assumptions | Design review required |
| Evidence gap | TM-09 | Connection failure does not alone prove firewall policy enforcement | Keep LAB-04 partially evidenced |

Priorities are qualitative design judgments, **not CVSS scores** or findings against a deployed enterprise.

## 5. Threat-to-Validation Traceability

| Threat | Existing evidence or test | What is actually established | Remaining gap |
|---|---|---|---|
| TM-06 | LAB-03; EV-03, EV-04 | Initial management reachability and anti-lockout rule match; post-remediation firewall block | No comprehensive management attack-surface assessment |
| TM-04 | LAB-01, LAB-02; EV-01, EV-02 | Scoped TCP/5432 allowed; TCP/5433 denied and logged in lab | Enterprise DB and data-level access not tested |
| TM-09 | LAB-04; EV-05 | Failed DB-to-management connection | Full firewall rule/action correlation missing |
| TM-02 | LAB-05 result (no standalone published screenshot) | Authorized Kali HTTPS connectivity was observed | No firewall configuration tamper test |
| TM-01, TM-03, TM-05, TM-07, TM-08 | None | No practical validation | All proposed controls remain untested |

## 6. Recommended Design Actions

1. Specify exact remote access identities, permitted destinations, MFA enforcement and access expiration.
2. Define jump-host ingress and egress protocols, recording and administrative session attribution.
3. Verify that management services are reachable only through approved paths, including system-generated firewall rules.
4. Document application-to-database identity and authorization separately from network connectivity.
5. Define SIEM transport, integrity protection, retention, and monitoring for missing logs.
6. Review denial-of-service resilience, firewall HA, and routing/NAT bypass scenarios before production design approval.

## 7. References and Limitations

Internal sources: [Requirements](01-business-security-requirements.md), [Findings](04-security-assessment-findings.md), [Risk Register](05-risk-assessment-register.md), [Architecture](06-proposed-secure-architecture.md), [Validation](08-security-validation-plan.md), [Policy Matrix](09-Target-State-Traffic-Flow-Matrix.md), [Evidence](evidence/README.md).

This document adds **analytical threat modeling only**. It does not add tests, screenshots, vulnerabilities, or implementation claims.
