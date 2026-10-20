# Traffic Flow Matrix

## 1. Overview

This document defines and evaluates network communication flows for the Enterprise X security architecture case study.

It distinguishes between:

- **Assumed Current-State Flows:** Hypothetical enterprise communication paths used for architecture assessment.
- **Implemented Lab Flows:** Network communication paths configured and tested in the VirtualBox laboratory.

The objective is to enforce least-privilege communication, reduce unnecessary network exposure, and validate security policies through practical testing.

## 2. Assumed Current-State Traffic Flows

The following flows represent a fictional enterprise baseline. They were not observed or tested in a production environment.

| ID | Source | Destination | Protocol / Port | Assumed Action | Assessment |
|---|---|---|---|---|---|
| TF-01 | Corporate | Application | TCP/443 | Allow | Potentially justified business access |
| TF-02 | Corporate | Database | TCP/1433 | Allow | Direct database exposure requires review |
| TF-03 | Vendor VPN | Management | TCP/3389 | Allow | Requires privileged access controls |
| TF-04 | Vendor VPN | Database | Any | Allow | Excessive access privileges |
| TF-05 | Application | Database | TCP/1433 | Allow | Business justification required |
| TF-06 | Internet | DMZ | TCP/443 | Allow | Requires external exposure assessment |
| TF-07 | Corporate | Management | Any | Allow | Excessive administrative access |

These flows provide context for the initial security assessment and are not claims about the implemented laboratory.

## 3. Implemented Laboratory Network

| Security Zone | Network | System | IP Address |
|---|---|---|---|
| APP | 192.168.10.0/24 | APP-SERVER | 192.168.10.10 |
| DB | 192.168.20.0/24 | DB-SERVER | 192.168.20.10 |
| MGMT | 192.168.30.0/24 | Kali Linux | 192.168.30.10 |

**Firewall:** OPNsense

**Firewall Interfaces:**
- APP gateway: 192.168.10.1
- DB gateway: 192.168.20.1
- MGMT gateway: 192.168.30.1

## 4. Implemented Traffic Flow Matrix

| ID | Source | Destination | Protocol / Port | Expected Action | Validation Result |
|---|---|---|---|---|---|
| LAB-01 | APP-SERVER (192.168.10.10) | DB-SERVER (192.168.20.10) | TCP/5432 | Allow | Passed |
| LAB-02 | APP-SERVER (192.168.10.10) | DB-SERVER (192.168.20.10) | TCP/5433 | Deny | Passed |
| LAB-03 | APP-SERVER (192.168.10.10) | OPNsense MGMT (192.168.30.1) | TCP/443 | Deny | Passed |
| LAB-04 | DB-SERVER (192.168.20.10) | OPNsense MGMT (192.168.30.1) | TCP/443 | Deny | Connectivity failed; log correlation pending final evidence review |
| LAB-05 | Kali Linux (192.168.30.10) | OPNsense MGMT (192.168.30.1) | TCP/443 | Allow | Passed |

**Testing clarification:** TCP/5432 was validated using a temporary Python TCP listener on DB-SERVER. This simulated database service connectivity; a PostgreSQL database was not installed or tested.

## 5. Firewall Policy Design

### Application Zone

An explicit firewall rule permits the application server to reach the database test endpoint on TCP port 5432.

Other tested application-to-database ports are denied unless separately authorized.

### Database Zone

No general administrative access from DB-SERVER to the OPNsense management interface is intended.

### Management Zone

The authorized Kali Linux workstation is permitted to access the OPNsense HTTPS management interface.

### Default Deny

Traffic without an applicable allow rule is blocked by the firewall's default-deny behavior.

## 6. Security Validation Observations

| Observation | Security Significance |
|---|---|
| APP-to-DB TCP/5432 connectivity succeeded | Required communication is permitted |
| APP-to-DB TCP/5433 connectivity failed and was logged as blocked | Unauthorized database-port access is restricted |
| APP-to-MGMT TCP/443 was initially reachable through the anti-lockout rule | Administrative access exposure identified during testing |
| Anti-lockout rule was disabled and APP-to-MGMT TCP/443 was subsequently blocked | Security control corrected and validated |
| Kali-to-MGMT TCP/443 remained accessible | Authorized administrative access was preserved |
| DB-to-MGMT TCP/443 connectivity failed | Expected management isolation behavior observed |

## 7. Security Design Principles

- **Least Privilege:** Permit only explicitly required traffic.
- **Network Segmentation:** Separate workloads according to their security function.
- **Default Deny:** Block communication without an applicable allow rule.
- **Management Isolation:** Restrict administrative interfaces to authorized management endpoints.
- **Security Assurance:** Validate actual firewall behavior through testing and log inspection.

## 8. Scope Limitations

- The enterprise baseline is fictional.
- Only APP, DB, and MGMT zones were implemented in the practical laboratory.
- Corporate, DMZ, vendor VPN, MFA, and remote-access controls were not deployed.
- Validation covers selected TCP communication paths, not all possible protocols or attack paths.
- The laboratory does not represent a production-ready enterprise deployment.

## 9. Related Documentation

- `01-business-security-requirements.md`
- `02-current-architecture.md`
- `04-security-assessment-findings.md`
- `06-proposed-secure-architecture.md`
- `08-security-validation-plan.md`
