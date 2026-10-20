# Security Requirements Traceability Matrix (RTM)

## 1. Purpose

This document establishes traceability between business requirements, security requirements, architecture decisions, identified risks, security controls, and validation results.

The Enterprise X case study contains two distinct scopes:

1. **Implemented Laboratory:** Selected network segmentation and firewall security controls deployed and tested using OPNsense.
2. **Proposed Enterprise Architecture:** Conceptual security controls recommended for the fictional Enterprise X environment.

The matrix distinguishes between implemented, validated, partially evidenced, and proposed controls.

The objective is to demonstrate how security requirements can be translated into technical design decisions and verified through documented security testing.

## 2. Traceability Methodology

The project follows the relationship:

**Business Requirement → Security Requirement → Security Risk → Architecture Decision → Security Control → Validation Evidence**

### Status Definitions

| Status | Definition |
|---|---|
| Implemented | A security control was configured in the laboratory |
| Validated | The expected behavior was confirmed through testing and supporting evidence |
| Partially Evidenced | Testing was performed, but complete verification evidence is unavailable |
| Proposed | The control is documented but has not been implemented |
| Not Tested | No practical validation has been performed |

A proposed control is not considered implemented, and a successful TCP connection does not establish application-level security.

## 3. Security Requirements Traceability

The following matrix references the security requirements defined in `01-business-security-requirements.md`.

| Requirement | Architecture Decision | Security Control | Validation Reference | Coverage Status |
|---|---|---|---|---|
| SR-01 — Network segmentation | ADR-001 | Dedicated APP, DB, and MGMT zones | LAB-01 to LAB-05 | Implemented; selected paths validated |
| SR-02 — Least-privilege communication | ADR-001, ADR-002 | Explicit APP-to-DB allow rule and default-deny behavior | LAB-01, LAB-02 | Validated for tested paths |
| SR-03 — Database access restrictions | ADR-002 | APP-to-DB TCP/5432 permitted; unauthorized TCP/5433 denied | LAB-01, LAB-02 | Validated at network layer |
| SR-04 — Management access restrictions | ADR-003, ADR-004 | Restricted OPNsense management access | LAB-03, LAB-04, LAB-05 | Partially validated |
| SR-05 — Security monitoring and logging | ADR-001, ADR-004 | OPNsense firewall event logging | LAB-02, LAB-03 | Local firewall logging validated; centralized monitoring not implemented |
| SR-06 — Firewall policy enforcement and review | ADR-001, ADR-004 | Review of explicit and automatically generated firewall rules | LAB-03 | Validated for identified anti-lockout issue |
| SR-07 — Controlled privileged access | ADR-003, ADR-005 | Dedicated management workstation; proposed jump host | LAB-05 | Lab management path validated; enterprise controls proposed |
| SR-08 — Remote access and identity security | ADR-006 | Proposed MFA, vendor restrictions, and time-bound authorization | FUT-02 to FUT-05 | Proposed — Not Tested |
| SR-09 — Security documentation and assurance | ADR-001 to ADR-006 | Architecture documentation, policy matrix, risk register, and validation records | LAB-01 to LAB-05 | Documented; evidence completeness varies |

**Coverage Note:** The laboratory demonstrates selected network controls only. It does not establish complete enterprise-wide compliance with these requirements.

## 4. Business Requirements Traceability

| Requirement | Architecture Response | Validation / Evidence | Status |
|---|---|---|---|
| BR-01 — Approved application connectivity | Controlled communication between application and database zones | LAB-01 | Network connectivity demonstrated; broader employee application access not tested |
| BR-02 — Secure remote employee access | Proposed VPN, MFA, and destination-specific authorization | FUT-06 | Proposed |
| BR-03 — Restricted vendor access | Proposed vendor access restrictions and privileged access controls | FUT-02 to FUT-05 | Proposed |
| BR-04 — Application availability | Required application communication preserved through explicit firewall policy | LAB-01 | Selected connectivity validated; availability and failover not tested |
| BR-05 — Operational security assurance | Documented firewall rules, testing, and corrective action | LAB-01 to LAB-05 | Partially demonstrated |

## 5. Implemented Control Traceability

| Control ID | Security Objective | Implemented Control | Validation | Result |
|---|---|---|---|---|
| LAB-P-01 | Permit required application traffic | APP-to-DB TCP/5432 allow rule | LAB-01 | Pass |
| LAB-P-02 | Restrict unauthorized database services | Default-deny behavior for APP-to-DB TCP/5433 | LAB-02 | Pass |
| LAB-P-03 | Isolate firewall management from application workloads | Removal of unintended APP-to-MGMT access | LAB-03 | Pass after remediation |
| LAB-P-04 | Restrict database workload access to management | Intended default-deny behavior | LAB-04 | Partially evidenced |
| LAB-P-05 | Preserve authorized firewall administration | Explicit Kali-to-MGMT TCP/443 allow rule | LAB-05 | Pass |

## 6. Finding-to-Risk-to-Control Traceability

### 6.1 Hypothetical Enterprise Findings

| Finding | Risk | Architecture Decision | Proposed Policy | Validation Status |
|---|---|---|---|---|
| F-01 — Excessive vendor database access | R-01 | ADR-006 | P-04, P-05 | Not Tested |
| F-02 — Direct corporate database access | R-02 | ADR-001, ADR-002 | P-02, P-03 | Enterprise scenario not tested |
| F-03 — Unrestricted corporate management access | R-03 | ADR-003, ADR-005 | P-06, P-07 | Enterprise scenario not tested |
| F-04 — Vendor RDP controls unverified | R-04 | ADR-005, ADR-006 | P-04, P-07 | Not Tested |

These findings are based on fictional enterprise architecture assumptions.

### 6.2 Observed Laboratory Finding

| Field | Traceability |
|---|---|
| Finding | LAB-F-01 — Unintended OPNsense management access |
| Risk | R-05 — Management interface exposure |
| Security Requirement | SR-04, SR-06 |
| Architecture Decision | ADR-003, ADR-004 |
| Security Control | LAB-P-03 |
| Validation Test | LAB-03 |
| Initial Observation | APP-to-MGMT TCP/443 connected |
| Root Cause | OPNsense administration anti-lockout rule |
| Corrective Action | Disabled anti-lockout rule while preserving explicit management access |
| Retest Result | APP-to-MGMT TCP/443 blocked |
| Supporting Test | LAB-05 — Kali management access preserved |
| Final Status | Remediated and validated for the tested path |

This represents the complete documented chain from security finding to corrective action and validation.

## 7. Laboratory Validation Summary

| Test ID | Security Requirement | Expected Result | Actual Result | Status |
|---|---|---|---|---|
| LAB-01 | SR-02, SR-03 | APP-to-DB TCP/5432 allowed | Connected | Pass |
| LAB-02 | SR-02, SR-03 | APP-to-DB TCP/5433 denied | Failed; firewall block logged | Pass |
| LAB-03 | SR-04, SR-06 | APP-to-MGMT TCP/443 denied | Blocked after remediation | Pass |
| LAB-04 | SR-04 | DB-to-MGMT TCP/443 denied | Connection failed; complete firewall evidence unavailable | Partially Evidenced |
| LAB-05 | SR-04, SR-07 | Kali-to-MGMT TCP/443 allowed | Connected | Pass |

### Validation Metrics

- **Executed connectivity scenarios:** 5
- **Passed with supporting validation:** 4
- **Partially evidenced:** 1
- **Observed security findings:** 1
- **Remediated and retested findings:** 1

These metrics apply only to the documented laboratory test scope.

## 8. Proposed Enterprise Control Coverage

| Enterprise Control | Policy Reference | Planned Validation | Status |
|---|---|---|---|
| Corporate application access | P-01 | FUT-01 or dedicated positive application test | Not Tested |
| Corporate database restriction | P-02 | FUT-01 | Not Tested |
| Application-to-database allowlisting | P-03 | Enterprise application/database test | Not Tested |
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

These are documented limitations and future enhancement opportunities, not completed activities.

## 10. Assurance Conclusions

The implemented laboratory provides evidence that selected security requirements were translated into technical controls and validated through testing.

The strongest assurance result is the identification and remediation of unintended management access caused by the OPNsense anti-lockout rule.

The project demonstrates:

- Requirements-driven security architecture.
- Risk-based security control selection.
- Least-privilege firewall policy design.
- Network segmentation validation.
- Security finding investigation and remediation.
- Evidence-based security assurance.
- Documentation of residual risks and limitations.

The fictional enterprise architecture remains a proposed design and must not be represented as a deployed production solution.

## 11. Related Documentation

- `01-business-security-requirements.md`
- `02-current-architecture.md`
- `03-traffic-flow-matrix.md`
- `04-security-assessment-findings.md`
- `05-risk-assessment-register.md`
- `06-proposed-secure-architecture.md`
- `07-architecture-decision-records.md`
- `08-security-validation-plan.md`
- `09-Target-State-Traffic-Flow-Matrix.md`

## 12. Disclaimer

Enterprise X is a fictional organization.

The laboratory was independently developed for educational security architecture and security assurance purposes.

The documented results do not constitute production security certification, regulatory compliance verification, or comprehensive penetration testing.
