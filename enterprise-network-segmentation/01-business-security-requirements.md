# Business & Security Requirements

## 1. Business Scenario

**Organization:** Enterprise X (Fictional)  
**Organization Size:** 500 Employees (Assumed)  
**Environment:** On-Premises Enterprise Network (Simulated Lab)

Enterprise X is a fictional organization that relies on internal business applications and databases to support its operations.

The organization requires a secure network architecture that limits unnecessary communication between systems, protects critical assets, and provides controlled administrative access.

This project demonstrates how selected security requirements can be translated into network segmentation policies and validated through practical testing.

## 2. Business Requirements

| ID | Requirement |
|---|---|
| BR-01 | Business applications must communicate with approved backend services. |
| BR-02 | Critical databases must be protected from unauthorized network access. |
| BR-03 | Administrative access must be restricted to designated management systems. |
| BR-04 | Security controls must allow required business communication without unnecessary exposure. |
| BR-05 | Security policies must be documented and validated before acceptance. |

## 3. Security Requirements

| ID | Requirement | Implementation Status |
|---|---|---|
| SR-01 | Separate application, database, and management systems into distinct security zones. | Implemented |
| SR-02 | Enforce least-privilege inter-zone firewall policies. | Implemented |
| SR-03 | Permit only explicitly authorized application-to-database traffic. | Implemented |
| SR-04 | Deny unauthorized application and database access to the management interface. | Implemented |
| SR-05 | Restrict firewall administration to an authorized management workstation. | Implemented for tested access paths |
| SR-06 | Enable logging and validate security-relevant firewall decisions. | Validated for selected flows |
| SR-07 | Document approved communication paths and expected security behavior. | Implemented |
| SR-08 | Apply MFA for privileged administrative access in a production environment. | Future Recommendation |
| SR-09 | Introduce dedicated DMZ, corporate, and controlled remote-access zones where required. | Out of Lab Scope |

## 4. Implemented Network Security Zones

| Zone | Network | System | Purpose |
|---|---|---|---|
| Application (APP) | 192.168.10.0/24 | APP-SERVER | Simulated application workload |
| Database (DB) | 192.168.20.0/24 | DB-SERVER | Simulated database service endpoint |
| Management (MGMT) | 192.168.30.0/24 | Kali Linux | Authorized firewall administration |

**Security Gateway:** OPNsense Firewall

Each zone is connected to a dedicated firewall interface, allowing inter-zone traffic to be controlled through explicit security policies.

## 5. Security Design Principles

**Network Segmentation:** Separate systems based on their security functions and required communication.

**Least Privilege:** Permit only the network traffic required for an approved purpose.

**Default Deny:** Traffic without an applicable allow rule is denied.

**Management Isolation:** Application and database systems must not have unauthorized access to the firewall management interface.

**Security Validation:** Firewall rules must be tested using connectivity checks and firewall logs rather than relying on configuration review alone.

## 6. Lab Scope and Assumptions

- Enterprise X is fictional; the 500-employee organization is a business scenario, not a deployed environment.
- The implementation is a VirtualBox-based laboratory using OPNsense, Debian, and Kali Linux.
- The laboratory includes APP, DB, and MGMT security zones.
- The DB endpoint uses a temporary Python TCP service listening on port 5432 to simulate database connectivity. PostgreSQL itself was not deployed.
- MFA, VPN, vendor access, corporate network segmentation, and DMZ deployment are outside the implemented laboratory scope.
- No production systems or real customer information are involved.

## 7. Acceptance Criteria and Validation

| ID | Validation Scenario | Expected Result | Observed Result |
|---|---|---|---|
| AC-01 | APP-SERVER → DB-SERVER, TCP 5432 | Allowed | Passed |
| AC-02 | APP-SERVER → DB-SERVER, TCP 5433 | Denied | Passed |
| AC-03 | APP-SERVER → Firewall MGMT, TCP 443 | Denied | Passed |
| AC-04 | DB-SERVER → Firewall MGMT, TCP 443 | Denied | Connectivity failed; firewall log correlation to be retained |
| AC-05 | Kali MGMT → Firewall MGMT, TCP 443 | Allowed | Passed |

The validation demonstrates that required application-to-database communication is permitted while tested unauthorized communication paths are restricted.

## 8. Project Deliverables

- Business and security requirements
- Network architecture and security zone definitions
- Traffic flow and firewall policy matrices
- Security assessment and risk documentation
- Architecture decision records
- Security validation results and supporting evidence
- Final project summary and lessons learned
