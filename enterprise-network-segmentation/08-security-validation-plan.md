# Security Validation Plan & Results

## 1. Purpose

This document defines the security validation approach and records the results of network segmentation testing performed in the Enterprise X portfolio laboratory.

The validation focuses on verifying firewall policy enforcement, least-privilege communication, and management interface isolation.

Two scopes are distinguished:

- **Implemented Lab Validation:** Tests executed using OPNsense, Debian Linux, and Kali Linux in VirtualBox.
- **Proposed Enterprise Validation:** Additional tests recommended for the fictional Enterprise X target architecture but not executed.

## 2. Laboratory Environment

| Component | Configuration |
|---|---|
| Virtualization | Oracle VirtualBox |
| Segmentation Firewall | OPNsense |
| Application Workload | Debian Linux — 192.168.10.10 |
| Database Test Workload | Debian Linux — 192.168.20.10 |
| Management Workstation | Kali Linux — 192.168.30.10 |
| APP Network | 192.168.10.0/24 |
| DB Network | 192.168.20.0/24 |
| MGMT Network | 192.168.30.0/24 |
| Firewall APP Interface | 192.168.10.1 |
| Firewall DB Interface | 192.168.20.1 |
| Firewall MGMT Interface | 192.168.30.1 |

A temporary Python HTTP listener was used on TCP port 5432 to simulate database service reachability. PostgreSQL was not deployed.

## 3. Validation Methodology

The laboratory validation followed these steps:

1. Identify the source and destination security zones.
2. Define the expected network communication behavior.
3. Configure the relevant firewall access policies.
4. Generate TCP connection attempts from the test systems.
5. Compare observed connectivity with the expected result.
6. Review OPNsense firewall logs to identify permitting or blocking rules.
7. Correct unintended access where identified.
8. Repeat affected tests and record the outcome.

A failed TCP connection is not, by itself, sufficient evidence of firewall enforcement. Firewall logs are used where available to corroborate denied traffic.

## 4. Executed Laboratory Test Matrix

| Test ID | Source | Destination | Expected Result | Observed Result | Status |
|---|---|---|---|---|---|
| LAB-01 | APP 192.168.10.10 | DB 192.168.20.10 TCP/5432 | Allow | Connected | Pass |
| LAB-02 | APP 192.168.10.10 | DB 192.168.20.10 TCP/5433 | Deny | Failed; firewall block confirmed | Pass |
| LAB-03 | APP 192.168.10.10 | OPNsense 192.168.30.1 TCP/443 | Deny | Blocked after remediation; firewall log confirmed | Pass |
| LAB-04 | DB 192.168.20.10 | OPNsense 192.168.30.1 TCP/443 | Deny | Connection failed | Connectivity Verified; firewall evidence incomplete |
| LAB-05 | Kali 192.168.30.10 | OPNsense 192.168.30.1 TCP/443 | Allow | Connected | Pass |

**Summary:** Five connectivity scenarios were executed. Four have documented outcomes supporting their expected behavior; LAB-04 requires complete firewall-log correlation before being classified as a fully verified firewall deny.

## 5. Detailed Validation Results

### LAB-01: Authorized Application-to-Database Communication

**Objective:** Verify that the approved application server can reach the database test endpoint.

- Source: 192.168.10.10
- Destination: 192.168.20.10
- Protocol: TCP
- Destination Port: 5432
- Expected: Allow
- Observed: Connected

**Result:** Pass

The test confirms TCP connectivity to the approved destination and service. It does not demonstrate PostgreSQL authentication, authorization, or application-layer database operations.

### LAB-02: Unauthorized Application-to-Database Port

**Objective:** Verify that an unapproved database service port is restricted.

- Source: 192.168.10.10
- Destination: 192.168.20.10
- Protocol: TCP
- Destination Port: 5433
- Expected: Deny
- Observed: Connection failed
- Firewall Evidence: OPNsense block log observed

**Result:** Pass

The test demonstrates that the firewall blocked the selected unauthorized communication attempt.

### LAB-03: Application-to-Management Isolation

**Objective:** Verify that the application server cannot access the firewall management interface.

- Source: 192.168.10.10
- Destination: 192.168.30.1
- Protocol: TCP
- Destination Port: 443
- Expected: Deny

**Initial Observation:** Connected

OPNsense firewall logs identified the built-in anti-lockout rule as the permitting rule.

**Remediation:**

1. Confirmed authorized Kali management connectivity.
2. Disabled the OPNsense administration anti-lockout rule.
3. Preserved the explicit authorized management access policy.
4. Repeated the application-to-management test.
5. Reviewed firewall logs.

**Final Observation:** Blocked

**Result:** Pass after remediation

This test demonstrates the importance of validating automatically generated firewall rules as part of security architecture assurance.

### LAB-04: Database-to-Management Isolation

**Objective:** Verify that the database test server cannot reach the firewall management interface.

- Source: 192.168.20.10
- Destination: 192.168.30.1
- Protocol: TCP
- Destination Port: 443
- Expected: Deny
- Observed: Connection failed

**Result:** Connectivity failure observed; firewall enforcement evidence requires final correlation.

The available evidence supports the failed connection attempt, but complete source, destination, action, and rule attribution should be retained before claiming a fully verified firewall block.

### LAB-05: Authorized Management Access

**Objective:** Confirm that the designated management workstation retains access to OPNsense.

- Source: 192.168.30.10
- Destination: 192.168.30.1
- Protocol: TCP
- Destination Port: 443
- Expected: Allow
- Observed: Successful HTTPS management access

**Result:** Pass

The authorized management path remained available after disabling the anti-lockout rule.

## 6. Security Finding and Remediation Validation

**Finding:** LAB-F-01 — Unintended Management Interface Access

| Stage | Observation |
|---|---|
| Initial testing | APP-to-MGMT TCP/443 connected |
| Investigation | OPNsense anti-lockout rule permitted traffic |
| Corrective action | Anti-lockout rule disabled |
| Retest | APP-to-MGMT TCP/443 blocked |
| Management availability | Kali-to-MGMT TCP/443 remained accessible |
| Final status | Remediated and validated for the tested path |

This was a firewall configuration and policy interaction, not evidence of an OPNsense software vulnerability.

## 7. Evidence Register

| Evidence ID | Test / Finding | Evidence Description |
|---|---|---|
| EV-01 | LAB-01 | Successful APP-to-DB TCP/5432 connectivity |
| EV-02 | LAB-02 | OPNsense firewall log showing APP-to-DB TCP/5433 blocked |
| EV-03 | LAB-03 | Initial anti-lockout rule log permitting APP-to-MGMT TCP/443 |
| EV-04 | LAB-03 | OPNsense firewall log showing APP-to-MGMT TCP/443 blocked after remediation |
| EV-05 | LAB-04 | DB-to-MGMT connectivity failure and available firewall log details |
| EV-06 | LAB-05 | Authorized Kali-to-OPNsense HTTPS management access |
| EV-07 | Firewall Configuration | Explicit APP-to-DB TCP/5432 allow rule |

Evidence files will be published separately in the project repository. This register describes the intended evidence set and does not claim that every screenshot has already been uploaded.

## 8. Proposed Enterprise Validation — Not Executed

The following tests apply to the conceptual Enterprise X target architecture.

| Test ID | Proposed Test | Status |
|---|---|---|
| FUT-01 | Corporate-to-database access restrictions | Not Tested |
| FUT-02 | Vendor VPN database access restrictions | Not Tested |
| FUT-03 | Vendor MFA enforcement | Not Tested |
| FUT-04 | Controlled jump-host administration | Not Tested |
| FUT-05 | Vendor access expiration and revocation | Not Tested |
| FUT-06 | Remote employee VPN access | Not Tested |
| FUT-07 | DMZ reverse-proxy access controls | Not Tested |
| FUT-08 | Centralized SIEM log collection | Not Tested |
| FUT-09 | Detection and alert generation | Not Tested |
| FUT-10 | Firewall high availability and failover | Not Tested |
| FUT-11 | Routing and segmentation bypass assessment | Not Tested |
| FUT-12 | Policy approval and change-management review | Not Tested |

These tests are recommendations for future implementation. They are not included in the completed laboratory results.

## 9. Acceptance Criteria

A laboratory test is considered passed when:

- The observed behavior matches the expected communication policy.
- The source, destination, and service are clearly identified.
- For denied traffic, firewall logs corroborate the enforcement decision where a firewall block is claimed.
- Any unexpected access is investigated, corrected, and retested.
- Supporting evidence is retained for review.

The implemented laboratory meets these criteria for the documented, fully verified test paths. LAB-04 remains partially evidenced.

## 10. Limitations

- The environment is an isolated educational laboratory.
- Enterprise X is fictional.
- Only selected TCP communication paths were tested.
- No production PostgreSQL database was deployed.
- No penetration test or comprehensive vulnerability assessment was performed.
- MFA, VPN, SIEM, DMZ, jump-host, and high-availability controls were not implemented.
- TCP connectivity does not demonstrate application-level authorization.
- The validation does not establish production readiness or formal compliance certification.

## 11. Validation Summary

**Executed Connectivity Scenarios:** 5

**Passed with Supporting Validation:** 4

**Partially Evidenced:** 1

**Observed Security Finding:** 1

**Remediated and Retested Findings:** 1

The practical validation demonstrates the effectiveness of selected least-privilege network segmentation controls and highlights the importance of identifying unintended access caused by system-generated firewall rules.

## 12. Related Documentation

- `01-business-security-requirements.md`
- `03-traffic-flow-matrix.md`
- `04-security-assessment-findings.md`
- `05-risk-assessment-register.md`
- `06-proposed-secure-architecture.md`
- `07-architecture-decision-records.md`
