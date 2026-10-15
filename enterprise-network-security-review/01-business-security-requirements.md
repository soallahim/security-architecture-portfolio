
# Business & Security Requirements

## 1. Organization Overview

**Organization:** Enterprise X (Fictional)  
**Employees:** 500  
**Environment:** On-Premises Enterprise Network

Enterprise X operates internal business applications and critical databases. Employees require secure access to corporate services, while authorized remote users and third-party vendors require controlled access to designated systems.

## 2. Business Requirements

| ID | Requirement |
|---|---|
| BR-01 | Employees must access approved internal applications. |
| BR-02 | Remote employees must securely access authorized services. |
| BR-03 | Vendors must access only explicitly approved systems. |
| BR-04 | Critical business applications must remain available. |
| BR-05 | Security controls must support operational and business needs. |

## 3. Security Requirements

| ID | Requirement |
|---|---|
| SR-01 | Separate corporate, DMZ, application, and database security zones. |
| SR-02 | Apply least-privilege firewall access rules. |
| SR-03 | Prevent unauthorized direct access to critical databases. |
| SR-04 | Enforce MFA for remote and privileged access. |
| SR-05 | Log and monitor security-relevant network activity. |
| SR-06 | Restrict third-party access by identity, destination, and duration. |
| SR-07 | Use secure administrative access paths. |
| SR-08 | Document and review permitted inter-zone traffic flows. |

## 4. Initial Security Zones

- Internet / Remote Access
- Corporate Network
- DMZ
- Application Zone
- Database Zone
- Management Zone

## 5. Assumptions

- The environment is fictional and designed for portfolio purposes.
- Existing architecture weaknesses will be introduced as assessment scenarios.
- Security controls will be selected based on defined requirements and risks.
- No production systems or real client information are used.

## 6. Acceptance Criteria

The proposed architecture must:
- Provide documented and justified communication paths.
- Restrict unauthorized access between security zones.
- Protect critical databases from direct user and vendor access.
- Support controlled remote administration.
- Define measurable security validation activities.
