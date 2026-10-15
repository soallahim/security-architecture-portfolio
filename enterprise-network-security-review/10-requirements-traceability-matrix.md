# Security Requirements Traceability Matrix (RTM)

## 1. Purpose

Trace Enterprise X's fictional business and security requirements through architecture decisions, proposed policies, identified findings, and planned verification. This is **design traceability**, not evidence of implementation or successful testing.

**Sources:** `01-business-security-requirements.md`, `04-security-assessment-findings.md`, `06-proposed-secure-architecture.md`, `07-architecture-decision-records.md`, `08-security-validation-plan.md`, and `09-target-state-traffic-flow-matrix.md`.

## 2. Security Requirements Traceability

| Requirement | Proposed design / policy | Related finding / ADR | Verification reference | Coverage status |
|---|---|---|---|---|
| SR-01 — Separate security zones | SegFW routed zone boundaries; P-09, P-10 | ADR-001 | TC-07; **new:** verify zone routes and no SegFW bypass | Partial — routing test not yet specified |
| SR-02 — Least-privilege firewall rules | P-01 through P-10, default deny | F-01, F-02, F-03; ADR-001, ADR-004 | TC-01, TC-02, TC-03, TC-04, TC-07 | Planned — no execution evidence |
| SR-03 — Restrict direct database access | P-02, P-03, P-05 | F-01, F-02; ADR-004 | TC-01, TC-02, TC-03 | Planned — no execution evidence |
| SR-04 — MFA for remote and privileged access | P-04, P-07, P-11; identity platform | F-04; ADR-002, ADR-003 | TC-05, TC-06; **new:** remote employee MFA test and privileged MFA verification | Partial — existing tests do not cover all identities |
| SR-05 — Security logging and monitoring | P-12; SIEM/log collector | Monitoring design in file 06 | TC-07; **new:** verify log ingestion and alert delivery | Partial — no ingestion test specified |
| SR-06 — Vendor identity, destination and duration | P-04, P-05 | F-01, F-04; ADR-003 | TC-02, TC-05, TC-08 | Planned — no execution evidence |
| SR-07 — Secure administrative access | P-06, P-07; privileged access zone | F-03, F-04; ADR-002 | TC-04, TC-06 | Planned — protocols and target allowlists TBD |
| SR-08 — Document and review permitted flows | P-01 through P-12; policy ownership/approval fields | ADR-001 through ADR-004 | **New:** policy review against approved application dependencies | Partial — owners/approvals hypothetical |

## 3. Business Requirements Traceability

| Requirement | Proposed design | Verification / acceptance gap |
|---|---|---|
| BR-01 — Employee access to approved applications | P-01 | **New:** positive test of approved employee HTTPS access |
| BR-02 — Secure remote employee access | P-11 | **New:** VPN MFA, authorized destination, and unauthorized destination tests |
| BR-03 — Vendor access limited to approved systems | P-04, P-05, P-07 | TC-02, TC-05, TC-06, TC-08; confirm destination restrictions |
| BR-04 — Critical applications remain available | P-03, P-09; resilience design still open | **New:** availability, failover, and recovery criteria; no HA design yet |
| BR-05 — Controls support business operations | Exception and change-control process in file 09 | **New:** owner review, dependency checks, rollback and operational acceptance |

## 4. Finding-to-Remediation-to-Test Chain

| Finding | Risk | Proposed mitigation | Policies | Planned test(s) | Status |
|---|---|---|---|---|---|
| F-01 — Excessive vendor DB access | R-01 | Vendor restriction and database isolation | P-04, P-05 | TC-02, TC-05, TC-08 | Proposed / Not Tested |
| F-02 — Direct corporate DB access | R-02 | Database allowlisting | P-02, P-03 | TC-01, TC-03 | Proposed / Not Tested |
| F-03 — Broad corporate management access | R-03 | Management isolation and jump host | P-06, P-07 | TC-04, TC-06 | Proposed / Not Tested |
| F-04 — Vendor RDP controls unverified | R-04 (unscored) | Verify MFA, authorization and monitored privileged access | P-04, P-07 | TC-05, TC-06, TC-08; evidence review required | Pending evidence / Not Tested |

## 5. Identified Coverage Gaps

These are **open actions**, not completed test cases. The next revision of `08-security-validation-plan.md` should assign new test IDs, preconditions, expected results, and evidence requirements.

1. Verify inter-zone routing cannot bypass SegFW (SR-01).
2. Verify employee VPN MFA and access scope, including a denied destination (BR-02, SR-04).
3. Verify SIEM receipt, parsing and alerting for representative events (SR-05).
4. Verify DMZ reverse-proxy backend allowlisting and unauthorized backend denial (SR-01, SR-02).
5. Verify authorized employee-to-application connectivity (BR-01).
6. Verify application availability, firewall failure behavior, and rollback where feasible (BR-04, BR-05).
7. Review all policy exceptions, owner approvals, and expiration dates (SR-08).
8. Confirm privileged access MFA and session controls, not merely network reachability (SR-04, SR-07).

## 6. Traceability Rules and Limitations

- **Proposed** means documented in the design, not implemented.
- **Planned** means a test is documented, not executed.
- **Partial** means a requirement has a design reference but incomplete verification coverage.
- Do not mark any requirement **Verified** without actual results and evidence.
- Risk R-04 remains unscored until the missing access-control evidence is available.
- All owners, systems, policies, and requirements belong to a fictional case study.

## 7. Next Step

Update `08-security-validation-plan.md` to close the test coverage gaps, then consider a small authorized lab to collect actual evidence for selected controls.
