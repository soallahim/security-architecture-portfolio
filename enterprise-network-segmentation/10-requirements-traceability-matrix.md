# Security Requirements Traceability Matrix (RTM)

## 1. Purpose

This document establishes traceability between business requirements, security requirements, identified risks, architecture decisions, implemented security controls, and validation evidence.

The Enterprise X case study distinguishes between two scopes:

1. **Implemented Laboratory:** Network segmentation and selected firewall security controls deployed and tested using OPNsense.
2. **Proposed Enterprise Architecture:** Conceptual security controls recommended for the fictional Enterprise X environment but not implemented.

The objective is to demonstrate how security requirements are translated into technical controls and how their effectiveness is evaluated through documented validation activities.

## 2. Traceability Methodology

The project follows the relationship:

**Business Requirement → Security Requirement → Security Risk → Architecture Decision → Security Control → Validation Evidence**

### Status Definitions

| Status | Definition |
|---|---|
| Implemented | A security control was configured in the laboratory |
| Validated | Expected behavior was confirmed through testing and supporting evidence |
| Partially Evidenced | Testing was performed, but complete verification evidence is unavailable |
| Proposed | A security control was designed or recommended but not implemented |
| Not Tested | No practical validation was performed |

A proposed control is not considered implemented.

A successful TCP connection demonstrates network reachability but does not establish application-level authentication, authorization, or security.

## 3. Security Requirements Traceability

The following requirements are based on the authoritative definitions in [Business & Security Requirements](01-business-security-requirements.md).

| Requirement | Architecture Decision | Security Control / Response | Validation Reference | Coverage Status |
|---|---|---|---|---|
| SR-01 — Separate application, database, and management systems into distinct security zones | ADR-001 | Dedicated APP, DB, and MGMT firewall interfaces and subnets | LAB-01 to LAB-05 | Implemented; selected paths validated |
| SR-02 — Enforce least-privilege inter-zone firewall policies | ADR-001, ADR-002 | Explicit APP-to-DB TCP/5432 allow rule and default-deny behavior | LAB-01, LAB-02 | Validated for tested paths |
| SR-03 — Permit only explicitly authorized application-to-database traffic | ADR-002 | APP-to-DB TCP/5432 permitted; unauthorized TCP/5433 denied | LAB-01, LAB-02 | Validated for tested ports at network layer |
| SR-04 — Deny unauthorized application and database access to the management interface | ADR-003, ADR-004 | APP-to-MGMT restriction after anti-lockout remediation; intended DB-to-MGMT deny | LAB-03, LAB-04 | APP path validated; DB path partially evidenced |
| SR-05 — Restrict firewall administration to an authorized management workstation | ADR-003, ADR-004 | Explicit Kali-to-OPNsense HTTPS access; unintended APP access removed | LAB-03, LAB-05 | Validated for tested management paths |
| SR-06 — Enable logging and validate security-relevant firewall decisions | ADR-001, ADR-004 | Local OPNsense firewall logs and review of automatically generated rules | LAB-02, LAB-03; EV-02 to EV-04 | Validated for selected flows; no SIEM integration |
| SR-07 — Document approved communication paths and expected security behavior | ADR-001, ADR-002, ADR-003 | Traffic flow matrices, firewall policy definitions, and validation documentation | Documents 03, 08, 09 | Documented; selected lab paths tested |
| SR-08 — Apply MFA for privileged administrative access in a production environment | ADR-006 | Proposed MFA and identity-based privileged access | FUT-03 | Proposed — Not Implemented or Tested |
| SR-09 — Introduce dedicated DMZ, corporate, and controlled remote-access zones where required | ADR-005, ADR-006 | Conceptual enterprise target architecture and controlled access policies | FUT-02, FUT-06, FUT-07 | Out of Lab Scope — Not Tested |

**Coverage Note:** Laboratory evidence supports only the documented network communication paths. It does not establish enterprise-wide security compliance or production readiness.

## 4. Business Requirements Traceability

The business requirement descriptions below match [Business & Security Requirements](01-business-security-requirements.md).

| Requirement | Architecture Response | Validation / Evidence | Status |
|---|---|---|---|
| BR-01 — Business applications must communicate with approved backend services | Allow approved APP-to-DB TCP/5432 | LAB-01; EV-01 | Selected TCP connectivity validated; application-level operations not tested |
| BR-02 — Critical databases must be protected from unauthorized network access | Restrict APP-to-DB to an approved port and deny unauthorized TCP/5433 | LAB-01, LAB-02; EV-01, EV-02 | Selected network restrictions validated; no production database deployed |
| BR-03 — Administrative access must be restricted to designated management systems | Preserve authorized Kali management access and remove unintended APP access | LAB-03, LAB-04, LAB-05; EV-03 to EV-05 | APP and Kali paths validated; DB path partially evidenced |
| BR-04 — Security controls must allow required business communication without unnecessary exposure | Explicit least-privilege APP-to-DB rule and default-deny behavior | LAB-01, LAB-02 | Demonstrated for selected laboratory traffic |
| BR-05 — Security policies must be documented and validated before acceptance | Documented firewall policies, validation results, and remediation evidence | Documents 03, 08, 09; LAB-01 to LAB-05 | Documentation available; LAB-04 evidence incomplete |

## 5. Implemented Control Traceability

| Control ID | Security Objective | Implemented Control | Validation | Result |
|---|---|---|---|---|
| LAB-P-01 | Permit required application traffic | APP-to-DB TCP/5432 allow rule | LAB-01 | Pass |
| LAB-P-02 | Restrict unauthorized database services | Default-deny behavior for APP-to-DB TCP/5433 | LAB-02 | Pass |
| LAB-P-03 | Isolate firewall management from application workloads | Removal of unintended APP-to-MGMT access | LAB-03 | Pass after remediation |
| LAB-P-04 | Restrict database workload access to management | Intended default-deny behavior | LAB-04 | Partially Evidenced |
| LAB-P-05 | Preserve authorized firewall administration | Explicit Kali-to-MGMT TCP/443 allow rule | LAB-05 | Pass |

These controls were evaluated only within the documented laboratory environment.

## 6. Finding-to-Risk-to-Control Traceability

### 6.1 Hypothetical Enterprise Findings

| Finding | Risk | Architecture Decision | Proposed Policy | Validation Status |
|---|---|---|---|---|
| F-01 — Excessive vendor database access | R-01 | ADR-006 | P-04, P-05 | Not Tested |
| F-02 — Direct corporate database access | R-02 | ADR-001, ADR-002 | P-02, P-03 | Not Tested |
| F-03 — Unrestricted corporate management access | R-03 | ADR-003, ADR-005 | P-06, P-07 | Not Tested |
| F-04 — Vendor RDP controls unverified | R-04 | ADR-005, ADR-006 | P-04, P-07 | Not Tested |

These findings are based on fictional enterprise architecture assumptions. They do not represent confirmed vulnerabilities in a production environment.

### 6.2 Observed Laboratory Finding

| Field | Traceability |
|---|---|
| Finding | LAB-F-01 — Unintended OPNsense management access |
| Risk | R-05 — Management interface exposure |
| Security Requirement | SR-04, SR-05, SR-06 |
| Architecture Decision | ADR-003, ADR-004 |
| Security Control | LAB-P-03 |
| Validation Test | LAB-03 |
| Initial Observation | APP-to-MGMT TCP/443 connected |
| Root Cause | OPNsense administration anti-lockout rule |
| Corrective Action | Disabled the anti-lockout rule while preserving explicit management access |
| Retest Result | APP-to-MGMT TCP/443 blocked |
| Supporting Test | LAB-05 — Authorized Kali management access preserved |
| Evidence | EV-03, EV-04 |
| Final Status | Remediated and validated for the tested path |

This finding demonstrates traceability from an observed security issue through investigation, architecture decision, remediation, and retesting.

The finding represents an unintended firewall policy interaction, not a confirmed OPNsense software vulnerability.

## 7. Laboratory Validation Summary

| Test ID | Security Requirement | Expected Result | Actual Result | Status |
|---|---|---|---|---|
| LAB-01 | SR-02, SR-03 | APP-to-DB TCP/5432 allowed | Connected | Pass |
| LAB-02 | SR-02, SR-03 | APP-to-DB TCP/5433 denied | Failed; firewall block logged | Pass |
| LAB-03 | SR-04, SR-05, SR-06 | APP-to-MGMT TCP/443 denied | Blocked after remediation | Pass |
| LAB-04 | SR-04 | DB-to-MGMT TCP/443 denied | Connection failed; complete firewall evidence unavailable | Partially Evidenced |
| LAB-05 | SR-05 | Kali-to-MGMT TCP/443 allowed | Connected | Pass |

### Validation Metrics

- **Executed connectivity scenarios:** 5
- **Passed with supporting validation:** 4
- **Partially evidenced:** 1
- **Observed security findings:** 1
- **Remediated and retested findings:** 1

These metrics apply only to the documented laboratory test scope.

### Published Evidence

Supporting screenshots and their descriptions are available in the [Security Validation Evidence Register](evidence/README.md).

The published evidence covers EV-01 through EV-05, with separate source and destination screenshots for selected firewall log entries.

LAB-05 was confirmed during testing, but a dedicated published screenshot is not included in the current evidence set.

## 8. Proposed Enterprise Control Coverage

The following controls are part of the fictional enterprise target architecture and were not implemented in the laboratory.

| Enterprise Control | Policy Reference | Planned Validation | Status |
|---|---|---|---|
| Corporate application access | P-01 | Dedicated positive application connectivity test | Not Tested |
| Corporate database restriction | P-02 | FUT-01 | Not Tested |
| Application-to-database allowlisting | P-03 | Enterprise application/database connectivity test | Not Tested |
| Vendor privileged access | P-04 | FUT-02 to FUT-05 | Not Tested |
| Vendor database restriction | P-05 | FUT-02 | Not Tested |
| Corporate management restriction | P-06 | Enterprise management access test | Not Tested |
| Jump-host administration | P-07 | FUT-04 | Not Tested |
| DMZ published application access | P-08, P-09 | FUT-07 | Not Tested |
| Default-deny enforcement | P-10 | FUT-11 | Not Tested |
| Remote employee access | P-11 | FUT-06 | Not Tested |
| Centralized security logging | P-12 | FUT-08, FUT-09 | Not Tested |

## 9. Identified Coverage Gaps

### Laboratory Evidence Gaps

- Complete firewall log correlation for DB-to-MGMT TCP/443.
- Dedicated published screenshot for authorized Kali-to-OPNsense management access.
- Additional protocol and source/destination coverage.
- Application-level database authentication and authorization testing.
- Centralized log collection and alert validation.

### Enterprise Architecture Gaps

- VPN and MFA implementation.
- Vendor identity and access lifecycle controls.
- Controlled privileged access infrastructure.
- DMZ and reverse-proxy deployment.
- SIEM integration.
- Firewall high availability and recovery testing.
- Formal policy ownership, approvals, and exception management.
- Full routing and segmentation bypass assessment.

These limitations are documented for transparency and must not be represented as completed activities.

## 10. Assurance Conclusions

The implemented laboratory demonstrates how selected security requirements can be translated into firewall policies, tested against expected communication behavior, and supported by technical evidence.

The strongest assurance outcome is the identification and remediation of unintended management access caused by the OPNsense anti-lockout rule.

The project demonstrates:

- Requirements-driven security architecture.
- Risk-based security control selection.
- Least-privilege firewall policy design.
- Network segmentation validation.
- Security finding investigation and remediation.
- Evidence-based security assurance.
- Requirements-to-controls traceability.
- Transparent documentation of residual risks and limitations.

The fictional enterprise target architecture remains a proposed design and must not be represented as a deployed production solution.

## 11. Related Documentation

- [Business & Security Requirements](01-business-security-requirements.md)
- [Current Architecture](02-current-architecture.md)
- [Traffic Flow Matrix](03-traffic-flow-matrix.md)
- [Security Assessment Findings](04-security-assessment-findings.md)
- [Risk Assessment Register](05-risk-assessment-register.md)
- [Proposed Secure Architecture](06-proposed-secure-architecture.md)
- [Architecture Decision Records](07-architecture-decision-records.md)
- [Security Validation Plan](08-security-validation-plan.md)
- [Target-State Traffic Flow Matrix](09-Target-State-Traffic-Flow-Matrix.md)
- [Security Validation Evidence](evidence/README.md)

## 12. Disclaimer

Enterprise X is a fictional organization.

The laboratory was independently developed for educational security architecture and security assurance purposes.

The documented results do not constitute production security certification, regulatory compliance verification, or comprehensive penetration testing.
