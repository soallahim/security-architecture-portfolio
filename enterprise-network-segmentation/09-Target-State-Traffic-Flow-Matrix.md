# Target-State Traffic Flow Matrix

## 1. Purpose and Scope

This document defines the network communication policies for the Enterprise X security architecture case study.

It distinguishes between two environments:

1. **Implemented Laboratory:** Network segmentation policies configured and tested using OPNsense in VirtualBox.
2. **Proposed Enterprise Target State:** A conceptual firewall policy design for the fictional Enterprise X organization.

The laboratory demonstrates selected least-privilege communication controls. The proposed enterprise policies have not been deployed or tested.

## 2. Implemented Laboratory Traffic Flow Matrix

### 2.1 Laboratory Network Zones

| Zone | Subnet | Firewall Interface | Connected Host |
|---|---|---|---|
| APP | 192.168.10.0/24 | em1 — 192.168.10.1 | APP-SERVER — 192.168.10.10 |
| DB | 192.168.20.0/24 | em2 — 192.168.20.1 | DB-SERVER — 192.168.20.10 |
| MGMT | 192.168.30.0/24 | em3 — 192.168.30.1 | Kali Linux — 192.168.30.10 |

### 2.2 Implemented Access Policy Matrix

| Policy ID | Source | Destination | Service | Intended Action | Enforcement | Validation |
|---|---|---|---|---|---|---|
| LAB-P-01 | APP-SERVER | DB-SERVER | TCP/5432 | Allow | Explicit OPNsense pass rule | LAB-01 — Pass |
| LAB-P-02 | APP-SERVER | DB-SERVER | TCP/5433 | Deny | Default-deny behavior | LAB-02 — Pass |
| LAB-P-03 | APP-SERVER | OPNsense MGMT | TCP/443 | Deny | Default-deny after anti-lockout remediation | LAB-03 — Pass |
| LAB-P-04 | DB-SERVER | OPNsense MGMT | TCP/443 | Deny | Intended default-deny policy | LAB-04 — Connectivity failed; complete firewall evidence pending |
| LAB-P-05 | Kali Linux | OPNsense MGMT | TCP/443 | Allow | Explicit OPNsense management pass rule | LAB-05 — Pass |

**Important:** LAB-P-02, LAB-P-03, and LAB-P-04 describe expected denied traffic. They are not separate explicit deny rules. The observed behavior depends on the applicable OPNsense rule processing and default-deny policy.

### 2.3 Database Test Service

The APP-to-DB test used a temporary Python HTTP listener bound to `192.168.20.10:5432`.

TCP port 5432 was selected to represent a typical PostgreSQL service port.

PostgreSQL was not installed, and no database authentication or queries were tested.

The successful test demonstrates network connectivity only.

### 2.4 Firewall Rule Configuration Considerations

The implemented application-to-database allow rule was restricted to:

- Source: `192.168.10.10`
- Destination: `192.168.20.10`
- Protocol: TCP
- Destination port: `5432`

During troubleshooting, TCP flag settings initially prevented the expected connection.

The rule was corrected to permit the required TCP connection establishment.

The final configuration successfully allowed the intended traffic.

### 2.5 Management Interface Security

An unintended management access path was identified during testing.

**Initial Behavior:**

APP-SERVER successfully connected to the OPNsense management interface on TCP/443.

Firewall logs identified the built-in anti-lockout rule as the permitting rule.

**Corrective Action:**

The administration anti-lockout rule was disabled after confirming that authorized Kali Linux management access remained available.

**Retest Results:**

- APP-to-MGMT TCP/443: Blocked.
- Kali-to-MGMT TCP/443: Allowed.

This demonstrates that firewall security reviews must consider automatically generated rules in addition to manually configured policies.

## 3. Proposed Enterprise Target-State Policy Matrix

The following policies represent the conceptual target architecture for Enterprise X.

**Status: Proposed — Not Implemented or Tested**

### 3.1 Enterprise Enforcement Assumptions

- **EdgeFW:** Perimeter firewall and VPN termination point.
- **SegFW:** Internal segmentation firewall for inter-zone policy enforcement.
- **Default Deny:** Unapproved inter-zone traffic is denied.
- **Remote Access:** MFA and identity-based authorization are required.
- **Privileged Access:** Sensitive administrative connections use controlled access paths.
- **Logging:** Relevant firewall and security events are centrally collected.
- **Stateful Inspection:** Return traffic for established permitted connections does not require separate reverse-direction allow rules.

### 3.2 Enterprise Firewall Policy Matrix

| Policy ID | Source | Destination | Service | Target Action | Enforcement | Status |
|---|---|---|---|---|---|---|
| P-01 | Approved corporate workstations | Approved application hosts | TCP/443 | Allow, scoped | SegFW | Proposed |
| P-02 | Corporate workstations | Database Zone | Database services | Deny | SegFW | Proposed |
| P-03 | Approved application hosts | Approved database hosts | TCP/1433 | Allow, scoped | SegFW | Proposed |
| P-04 | Authorized vendor VPN group | Privileged Access Zone | Approved access service — TBD | Allow with MFA and time-bound authorization | EdgeFW + SegFW + IAM | Proposed |
| P-05 | Vendor VPN network | Database Zone | Any | Deny | SegFW | Proposed |
| P-06 | Standard corporate workstations | Management Zone | Any | Deny | SegFW | Proposed |
| P-07 | Hardened jump host | Approved management targets | Approved admin services — TBD | Allow, scoped and logged | SegFW | Proposed |
| P-08 | Internet clients | Approved DMZ reverse proxy | TCP/443 | Allow, scoped | EdgeFW | Proposed |
| P-09 | DMZ reverse proxy | Approved application backend | TCP/443 | Allow, scoped | SegFW | Proposed |
| P-10 | Unapproved inter-zone sources | Protected zones | Any unapproved service | Deny by default | SegFW | Proposed |
| P-11 | Authorized remote employee VPN group | Approved application hosts | TCP/443 | Allow with MFA and authorization | EdgeFW + SegFW + IAM | Proposed |
| P-12 | Approved security log sources | SIEM / Log Collector | Approved transport — TBD | Allow, scoped | SegFW where applicable | Proposed |

The `Any` service in deny policies does not authorize traffic.

All `TBD` service definitions require detailed design and approval before deployment.

### 3.3 Policy Ownership and Logging Requirements

| Policy Group | Proposed Owner | Logging Requirement |
|---|---|---|
| Corporate-to-Application | Application Owner + Network Security | Approved session events |
| Application-to-Database | Application + Database Owners | Relevant connection and security events |
| Vendor Remote Access | IAM + System Owner | Authentication, authorization, and session events |
| Management Access | Infrastructure + Network Security | Administrative access and denied attempts |
| DMZ Access | Application + Network Security | Reverse-proxy and firewall security events |
| SIEM Log Transport | SOC + Platform Owner | Collection health and ingestion errors |
| Default-Deny Policies | Network Security | Relevant denied traffic with noise controls |

These roles are proposed ownership assignments, not approvals received from real system owners.

## 4. Current-State to Target-State Mapping

The following mappings apply to the fictional enterprise architecture, not the deployed laboratory.

| Current Flow | Current-State Exposure | Target Policy | Intended Improvement |
|---|---|---|---|
| TF-01 | Corporate-to-Application HTTPS | P-01 | Retain approved application access |
| TF-02 | Corporate-to-Database access | P-02 | Deny direct workstation database access |
| TF-03 | Vendor-to-Management RDP | P-04, P-07 | Introduce controlled privileged access |
| TF-04 | Vendor-to-Database unrestricted | P-05 | Deny direct vendor database access |
| TF-05 | Application-to-Database access | P-03 | Restrict to approved application services |
| TF-06 | Internet-to-DMZ HTTPS | P-08 | Restrict to approved published services |
| TF-07 | Corporate-to-Management unrestricted | P-06 | Deny standard workstation management access |

## 5. Policy Implementation Requirements

Before deploying any enterprise target-state rule, the following must be defined:

1. Source and destination addresses or approved object groups.
2. Exact protocols and service ports.
3. Business justification and system ownership.
4. Required authorization and approval.
5. Firewall rule order and interface placement.
6. NAT and routing dependencies.
7. Logging and monitoring requirements.
8. Change window and rollback procedure.
9. Validation tests and expected results.
10. Rule review and expiration requirements.

Exceptions must be documented as separate, narrowly scoped policies.

## 6. Validation Traceability

### Implemented Laboratory

| Policy | Validation Test | Result |
|---|---|---|
| LAB-P-01 | LAB-01 | Pass |
| LAB-P-02 | LAB-02 | Pass |
| LAB-P-03 | LAB-03 | Pass after remediation |
| LAB-P-04 | LAB-04 | Partially evidenced |
| LAB-P-05 | LAB-05 | Pass |

### Proposed Enterprise Architecture

| Policy Group | Recommended Validation | Status |
|---|---|---|
| P-01 to P-03 | Corporate, application, and database access testing | Not Tested |
| P-04 to P-07 | Vendor, MFA, and privileged access testing | Not Tested |
| P-08 to P-09 | DMZ and published application testing | Not Tested |
| P-10 | Default-deny and segmentation bypass testing | Not Tested |
| P-11 | Remote employee access testing | Not Tested |
| P-12 | SIEM log delivery and ingestion testing | Not Tested |

## 7. Open Design Decisions

The proposed enterprise architecture still requires decisions regarding:

- Vendor access gateway and approved services.
- Privileged management protocols and target systems.
- SIEM log transport and encryption.
- Firewall high availability.
- Routing and segmentation bypass prevention.
- Operational dependencies such as DNS, NTP, patching, and backups.
- Rule ownership, approval, and periodic review.

## 8. Limitations

- Enterprise X is fictional.
- The implemented laboratory contains only APP, DB, and MGMT security zones.
- The laboratory does not include enterprise VPN, MFA, DMZ, SIEM, or jump-host infrastructure.
- Laboratory validation covers selected TCP communication paths.
- The DB-to-MGMT test lacks complete firewall-log correlation.
- The enterprise policy matrix is conceptual and is not a production firewall rulebase.

## 9. Related Documentation

- `01-business-security-requirements.md`
- `03-traffic-flow-matrix.md`
- `04-security-assessment-findings.md`
- `05-risk-assessment-register.md`
- `06-proposed-secure-architecture.md`
- `07-architecture-decision-records.md`
- `08-security-validation-plan.md`
- `10-requirements-traceability-matrix.md`

## 10. Disclaimer

Enterprise X is a fictional organization.

The laboratory was independently developed for educational security architecture validation.

The proposed enterprise policies have not been deployed or approved for production use.
