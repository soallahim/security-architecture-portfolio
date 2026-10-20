# Security Assurance Report — Enterprise Network Segmentation

## 1. Executive Assessment

**Scope:** Independent educational VirtualBox lab for fictional Enterprise X. This report consolidates existing documented tests and published evidence; it does **not** describe new testing.

**Assurance conclusion:** Selected network segmentation and firewall-management access controls were validated for specific laboratory paths. One unintended OPNsense management access path was discovered, corrected, and retested. Evidence does not support claims of complete segmentation assurance, production readiness, enterprise target deployment, or regulatory compliance.

| Measure | Result |
|---|---|
| Laboratory scenarios executed | 5 |
| Passed with supporting validation | 4 |
| Partially evidenced | 1 (LAB-04) |
| Observed configuration/policy finding | 1 (LAB-F-01) |
| Finding remediated and retested | 1 |
| Enterprise proposed policies validated | 0 |

## 2. Scope and Acceptance Basis

**Implemented:** OPNsense inter-zone firewall with APP (192.168.10.0/24), DB (192.168.20.0/24), and MGMT (192.168.30.0/24). Test endpoints: APP 192.168.10.10; DB 192.168.20.10; Kali 192.168.30.10; OPNsense MGMT 192.168.30.1.

**Excluded:** Production PostgreSQL, application-layer authentication, corporate network, VPN/MFA, DMZ, jump host, SIEM, firewall HA, penetration testing, and comprehensive inter-zone testing.

**Evidence standard:** A successful connection establishes TCP reachability, not application-level authorization. A failed connection alone does not establish a firewall block; logs showing source, destination, action, and rule should corroborate enforcement.

## 3. Test-to-Evidence Assurance Matrix

| Test | Requirement / policy | Intended result | Observed outcome | Published evidence | Assurance judgment |
|---|---|---|---|---|---|
| LAB-01 | SR-02, SR-03; LAB-P-01 | APP → DB TCP/5432 allowed | Connected | [EV-01](evidence/README.md#ev-01-application-to-database-connectivity) | Pass for TCP reachability; not DB authentication |
| LAB-02 | SR-02, SR-03; LAB-P-02 | APP → DB TCP/5433 denied | Failed; firewall block logged | [EV-02](evidence/README.md#ev-02-unauthorized-database-port-blocked) | Pass for tested blocked service |
| LAB-03 | SR-04, SR-05, SR-06; LAB-P-03 | APP → OPNsense MGMT TCP/443 denied | Initially connected via anti-lockout; blocked after remediation | [EV-03](evidence/README.md#ev-03-unintended-management-access-before-remediation), [EV-04](evidence/README.md#ev-04-management-access-blocked-after-remediation) | Pass after remediation for tested path |
| LAB-04 | SR-04; LAB-P-04 | DB → OPNsense MGMT TCP/443 denied | Connection failed; complete rule/action correlation missing | [EV-05](evidence/README.md#ev-05-database-to-management-investigation) | **Partially evidenced**; do not claim verified firewall deny |
| LAB-05 | SR-05; LAB-P-05 | Kali → OPNsense MGMT TCP/443 allowed | Connected | No dedicated published LAB-05 screenshot | Pass based on recorded test result; independent screenshot corroboration unavailable |

Published screenshots EV-01–EV-05 are indexed in the [Evidence Register](evidence/README.md). This report relies on their documented descriptions and prior validation records; it does not independently re-execute tests.

## 4. Security Finding and Remediation Assurance

**LAB-F-01 — Unintended management interface reachability**

| Phase | Recorded observation | Supporting source |
|---|---|---|
| Before | APP-SERVER reached OPNsense management TCP/443 unexpectedly | LAB-03; EV-03 |
| Root-cause analysis | OPNsense built-in anti-lockout rule permitted the connection | EV-03; [Findings](04-security-assessment-findings.md) |
| Corrective action | Anti-lockout disabled; explicit Kali management rule preserved | [ADR-004](07-architecture-decision-records.md) |
| After | APP-to-management TCP/443 blocked; firewall block log recorded | LAB-03; EV-04 |
| Availability check | Kali-to-management TCP/443 remained accessible | LAB-05 recorded outcome; no separate screenshot |

**Finding status:** Remediated and validated for the tested APP source/destination/service.

**Not demonstrated:** Administrative login bypass, successful compromise, exploitation, or validation of every possible management path. This was a firewall rule/policy interaction, not an OPNsense software vulnerability.

## 5. Requirements and Policy Coverage

| Control objective | Supporting tests | Conclusion |
|---|---|---|
| APP/DB/MGMT separation (SR-01) | LAB-01–05; architecture and addressing | Separate subnets/interfaces documented; only selected flows tested |
| Least-privilege application-to-database access (SR-02/03) | LAB-01, LAB-02 | Validated for TCP/5432 and TCP/5433 |
| Management isolation (SR-04) | LAB-03, LAB-04 | APP restriction validated after remediation; DB restriction partially evidenced |
| Authorized management access (SR-05) | LAB-05 and LAB-03 | Kali connectivity preserved; no dedicated LAB-05 image |
| Firewall logging and rule review (SR-06) | LAB-02, LAB-03 | Selected local logs validated; SIEM not deployed |
| Proposed enterprise policies (P-01–P-12) | None | Design only; not tested |

See [Requirements Traceability Matrix](10-requirements-traceability-matrix.md) and [Target-State Policy Matrix](09-Target-State-Traffic-Flow-Matrix.md).

## 6. Open Gaps and Residual Risks

| ID | Gap | Consequence | Recommended next action | Current disposition |
|---|---|---|---|---|
| AG-01 | LAB-04 lacks complete firewall decision/rule correlation | Cannot assert firewall enforced the DB-to-management deny | Preserve existing partial status; obtain corroboration only if retested later | Open evidence limitation |
| AG-02 | LAB-05 has no dedicated published screenshot | Weaker independent review of authorized management path | Keep result as recorded, disclose evidence gap | Open evidence limitation |
| AG-03 | Limited tested ports, hosts, and protocols | Cannot generalize to all zone paths | Define broader negative/positive validation matrix | Not executed |
| AG-04 | Enterprise target controls are conceptual | Cannot assert VPN/MFA/DMZ/jump host/SIEM effectiveness | Implement and test in a separate future scope | Not implemented |
| AG-05 | No real database or application authorization tests | TCP connectivity is not proof of data access control | Future application/database security tests | Out of scope |
| AG-06 | No formal operational review of HA, routing/NAT, or change management | Production feasibility not established | Detailed design and operational acceptance review | Proposed |

The risk register's R-05 residual risk is a **qualitative lab estimate**, not production risk acceptance.

## 7. Acceptance Statement

**Accepted for portfolio demonstration:** The five documented laboratory scenarios and the finding/remediation narrative, with the stated evidence limitations.

**Not accepted or claimed:** Comprehensive firewall assurance, production deployment, regulatory certification, or enterprise security control validation.

**Final assessment:** The project demonstrates a defensible architecture-to-control-to-test workflow and a meaningful observed configuration finding. Assurance confidence is strongest for LAB-02 and LAB-03 firewall-log-supported behavior, narrower for LAB-01 TCP reachability, and incomplete for LAB-04. LAB-05 has a recorded successful outcome without a standalone published screenshot.

## 8. Related Artifacts

[Requirements](01-business-security-requirements.md) · [Findings](04-security-assessment-findings.md) · [Risk Register](05-risk-assessment-register.md) · [Architecture](06-proposed-secure-architecture.md) · [Validation Plan](08-security-validation-plan.md) · [Traceability Matrix](10-requirements-traceability-matrix.md) · [Threat Model](11-stride-threat-model.md) · [Attack Path Analysis](12-attack-path-analysis.md) · [Evidence Register](evidence/README.md).
