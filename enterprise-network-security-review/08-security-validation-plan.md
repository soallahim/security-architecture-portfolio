# Security Architecture Validation Plan — Revised

## 1. Purpose and Evidence Standard

Define **planned**, repeatable validation for the fictional Enterprise X target architecture. This revision aligns with `06-proposed-secure-architecture.md`, `09-target-state-traffic-flow-matrix.md`, and `10-requirements-traceability-matrix.md`. **No tests have been executed; no control is claimed to be implemented or effective.**

## 2. Test Environment and Prerequisites

- Use only a self-owned lab or an explicitly authorized test environment; never use production or client networks for this portfolio.
- Establish the test network diagram, IP addressing, zones, and approved source/destination identities before execution.
- Resolve policy placeholders for P-04 (vendor gateway), P-07 (management ports), and P-12 (logging transport) before attempting their tests.
- Record the relevant EdgeFW/SegFW policy versions, route tables, MFA/PAM configuration and log collector health.
- Confirm test authorization, maintenance window where necessary, safety precautions, and rollback procedures.
- Define application availability thresholds and HA behavior with fictional business assumptions before evaluating TC-19.

## 3. Planned Test Matrix

Tests are grouped by security control domain for readability. **Test IDs remain unchanged** to preserve references in other project documents. All tests are planned and have not been executed.

### 3.1 Network Segmentation & Database Protection

| ID | Policies | Requirements / Findings | Test scenario | Expected result | Preconditions / evidence source | Status |
|---|---|---|---|---|---|---|
| TC-01 | P-02 | SR-03; F-02 | Corporate workstation to DB TCP/1433 | Deny; firewall deny log | Workstation and DB test addresses; SegFW policy | Not Tested |
| TC-02 | P-05 | SR-03, SR-06; F-01 | Vendor VPN address to DB (TCP/1433 and representative other ports) | Deny; firewall deny log | Authorized vendor test identity, VPN pool and DB target | Not Tested |
| TC-03 | P-03 | BR-04, SR-03; F-02 | Approved app host to approved DB TCP/1433 | Allow; DB connection succeeds; log as configured | App/DB test hosts and DB test credentials | Not Tested |
| TC-04 | P-06 | SR-07; F-03 | Standard corporate workstation to management services | Deny; firewall deny log | Corporate and management test addresses | Not Tested |
| TC-07 | P-10 | SR-01, SR-02 | Unapproved source initiates cross-zone session | Deny; attributable log | At least two representative zone pairs | Not Tested |
| TC-16 | P-01 to P-12 | SR-01 | Review routes and attempt representative zone-to-zone path bypassing SegFW | No alternate inter-zone forwarding path; route review evidence | Routing tables, topology and firewall interface map | Not Tested |

### 3.2 Identity, Remote & Privileged Access

| ID | Policies | Requirements / Findings | Test scenario | Expected result | Preconditions / evidence source | Status |
|---|---|---|---|---|---|---|
| TC-05 | P-04 | SR-04, SR-06; F-04 | Vendor attempts access without successful MFA | Authentication rejected; no privileged session | Test vendor account and MFA policy | Not Tested |
| TC-06 | P-04, P-07 | SR-04, SR-07; F-03, F-04 | Approved administrator reaches named management target via jump host | Allow only approved target/protocol; MFA and session audit present | Approved role, jump host and target; resolved P-04/P-07 ports | Not Tested |
| TC-08 | P-04 | SR-06; F-01, F-04 | Vendor attempts new access after approved time window | Access denied; revocation/expiry event recorded | Time-bound test account and access window | Not Tested |
| TC-10 | P-11 | BR-02, SR-04 | Remote employee VPN sign-in with and without MFA | Without MFA deny; with MFA and correct group allow | Remote test user, VPN client and identity logs | Not Tested |
| TC-11 | P-11, P-10 | BR-02, SR-02 | Authenticated remote employee tries unauthorized internal destination | Deny; log attempted access | Authorized VPN session and unapproved test target | Not Tested |
| TC-17 | P-04, P-07 | SR-04, SR-07 | Verify privileged MFA, role scoping and session recording | Unauthorized role denied; authorized session audited | Privileged IAM/PAM policies and test identities | Not Tested |

### 3.3 Application & DMZ Connectivity

| ID | Policies | Requirements / Findings | Test scenario | Expected result | Preconditions / evidence source | Status |
|---|---|---|---|---|---|---|
| TC-09 | P-01 | BR-01, SR-02 | Approved corporate user reaches approved app via HTTPS | HTTPS succeeds; unrelated destination still restricted | App owner-approved source and endpoint | Not Tested |
| TC-14 | P-08, P-09 | SR-01, SR-02 | Published HTTPS reaches approved reverse proxy and backend | Approved path works; backend destination matches allowlist | DMZ proxy, approved app endpoint, test DNS/NAT | Not Tested |
| TC-15 | P-09, P-10 | SR-01, SR-02 | DMZ proxy attempts unapproved backend/port | Deny; firewall deny log | Approved proxy source and unauthorized backend test target | Not Tested |

### 3.4 Logging, Monitoring & Detection

| ID | Policies | Requirements / Findings | Test scenario | Expected result | Preconditions / evidence source | Status |
|---|---|---|---|---|---|---|
| TC-12 | P-12 | SR-05 | Generate representative firewall deny, VPN auth and jump-host events | Collector receives and correctly parses events with timestamps/source | Approved log transport/ports; SIEM/collector access | Not Tested |
| TC-13 | P-12 | SR-05 | Trigger agreed detection rule for repeated prohibited DB attempts | Expected alert generated and linked to events | Detection rule, threshold and alert destination defined | Not Tested |

### 3.5 Governance & Policy Review

| ID | Policies | Requirements / Findings | Test scenario | Expected result | Preconditions / evidence source | Status |
|---|---|---|---|---|---|---|
| TC-18 | P-01 to P-12 | SR-08; BR-05 | Review policy inventory, approvals, justifications and expirations | Every allow rule has owner, scope, approval and review date | Proposed rule inventory and fictional approval records | Not Tested |

### 3.6 Availability & Change Management

| ID | Policies | Requirements / Findings | Test scenario | Expected result | Preconditions / evidence source | Status |
|---|---|---|---|---|---|---|
| TC-19 | P-03, P-09 | BR-04 | Exercise approved app health and documented firewall failover where lab supports it | Business-defined recovery targets met; no unintended bypass | HA design, maintenance window and rollback plan; defer if no HA lab | Not Tested |
| TC-20 | P-01 to P-12 | BR-05 | Dry-run change/rollback and verify business dependencies | Approved service flows restored; deviations documented | Change plan, dependency inventory and rollback checkpoints | Not Tested |

**Execution note:** “Deny” requires corroborating evidence from the enforcing control, not only a failed connection. TC-19 must remain Not Tested or Blocked if the lab has no HA capability.

## 4. Test Execution Procedure

For each test:

1. Confirm source identity, source IP, destination IP, port, policy ID, and test approval.
2. Capture pre-test configuration/version and confirm logs are flowing.
3. Execute the specific positive or negative access attempt within the approved lab.
4. Capture the observed result and correlate it with firewall, VPN, IAM, jump-host or SIEM evidence.
5. Compare actual result with the documented expectation and mark **Pass**, **Fail**, **Blocked**, or **Not Tested**.
6. Record defects, exceptions, rollback actions, and retest references.

A blocked connection alone does **not** prove the firewall caused the block; corroborate with the enforcing control log and route/policy review. A successful TCP connection alone does **not** prove application-level authorization.

## 5. Evidence Record Template

| Field | Value |
|---|---|
| Test ID | TC-XX |
| Date / tester | Not executed |
| Lab scope / authorization | TBD |
| Source identity and IP | TBD |
| Destination IP / service | TBD |
| Firewall / identity policy version | TBD |
| Test command or procedure | TBD |
| Expected result | See test matrix |
| Actual result | Not executed |
| Evidence links (logs/screenshots/config excerpts) | None |
| Outcome | Not Tested |
| Issue / exception / retest reference | None |

Redact secrets, tokens, private addresses belonging to third parties, and any non-lab information before publication.

## 6. Acceptance and Traceability

- **SR-01 / SR-02:** TC-07, TC-14, TC-15, TC-16, TC-18.
- **SR-03:** TC-01, TC-02, TC-03.
- **SR-04:** TC-05, TC-06, TC-10, TC-17.
- **SR-05:** TC-12, TC-13.
- **SR-06:** TC-02, TC-05, TC-08, TC-17.
- **SR-07:** TC-04, TC-06, TC-17.
- **SR-08:** TC-18.
- **BR-01:** TC-09. **BR-02:** TC-10, TC-11. **BR-03:** TC-02, TC-05, TC-08. **BR-04:** TC-03, TC-19. **BR-05:** TC-18, TC-20.

An individual test passes only with supporting evidence. Overall architecture acceptance also requires review of untested scenarios, exceptions, operational dependencies, and residual risks. **TC-19 must remain Blocked or Not Tested if the lab lacks an HA/failover design; do not infer resilience from network reachability tests.**

## 7. Known Design and Verification Gaps

- Operational service dependencies (DNS, AD, NTP, patching, backups, monitoring) require their own approved target flows and tests.
- Exact IP objects, port assignments, NAT behavior, and firewall rule order remain to be designed.
- Centralized logging must be tested end-to-end, not inferred from configured forwarding.
- Database authentication/authorization and application security are out of scope of simple network connection tests.
- This plan does not demonstrate compliance certification or a full security assurance assessment.

## 8. Execution Status

**0 of 20 tests executed.** All results are **Not Tested**. A proposed policy, a design diagram, and a test plan are not implementation evidence.

## 9. Next Step

Build a small, authorized virtual lab, prioritize TC-01, TC-02, TC-03, TC-04, TC-07, and TC-12, then capture real evidence and update the traceability matrix with actual outcomes.

## Disclaimer

All scenarios and organizational details are fictional. This is a personal educational security architecture case study.
