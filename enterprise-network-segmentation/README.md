
# Enterprise Network Segmentation & Security Architecture

**Security Architecture | Network Segmentation | Risk Assessment | Firewall Validation**

An end-to-end cybersecurity architecture case study combining enterprise security design, risk assessment, and hands-on network segmentation validation using OPNsense.

The project demonstrates how security requirements are translated into architecture decisions, firewall policies, and practical validation evidence.

> **Project Scope:** The network segmentation laboratory was implemented and tested. The broader Enterprise X target architecture is a proposed design and was not deployed.

## Project Highlights

- Designed and implemented a segmented laboratory network with dedicated Application, Database, and Management zones.
- Configured least-privilege firewall policies using OPNsense.
- Executed five network connectivity validation scenarios.
- Identified unintended firewall management access caused by an OPNsense anti-lockout rule.
- Remediated the unintended access and verified that authorized administrative access remained available.
- Designed a fictional enterprise target architecture incorporating VPN, MFA, DMZ, privileged access, and centralized security monitoring.
- Documented security findings, risk assessments, architecture decisions, validation evidence, and requirements traceability.

## Architecture Overview

### Implemented Laboratory

The practical environment was deployed using Oracle VirtualBox, OPNsense, Debian Linux, and Kali Linux.

| Component | Technology / Address |
|---|---|
| Segmentation Firewall | OPNsense |
| Application Server | Debian Linux — `192.168.10.10` |
| Database Test Server | Debian Linux — `192.168.20.10` |
| Management Workstation | Kali Linux — `192.168.30.10` |
| Application Zone | `192.168.10.0/24` |
| Database Zone | `192.168.20.0/24` |
| Management Zone | `192.168.30.0/24` |
| Firewall APP Interface | `192.168.10.1` |
| Firewall DB Interface | `192.168.20.1` |
| Firewall MGMT Interface | `192.168.30.1` |

#### Implemented Lab Architecture — Network Diagram

The topology below shows the actual three-zone laboratory. All inter-zone traffic is routed through OPNsense; no direct APP-to-DB network link exists.

```mermaid
flowchart TB
    subgraph LAB["IMPLEMENTED LABORATORY — Oracle VirtualBox"]
        direction TB

        FW["OPNsense Firewall<br/>Stateful Inter-Zone Policy Enforcement"]

        subgraph APP_ZONE["APPLICATION ZONE — 192.168.10.0/24"]
            APP["APP-SERVER<br/>Debian Linux<br/>192.168.10.10"]
        end

        subgraph DB_ZONE["DATABASE TEST ZONE — 192.168.20.0/24"]
            DB["DB-SERVER<br/>Debian Linux<br/>192.168.20.10<br/>Temporary Python Listener: TCP/5432"]
        end

        subgraph MGMT_ZONE["MANAGEMENT ZONE — 192.168.30.0/24"]
            KALI["Kali Linux<br/>Authorized Management Workstation<br/>192.168.30.10"]
        end

        APP <-->|"APP interface: 192.168.10.1"| FW
        DB <-->|"DB interface: 192.168.20.1"| FW
        KALI <-->|"MGMT interface: 192.168.30.1"| FW
    end

    classDef firewall fill:#243447,color:#ffffff,stroke:#243447,stroke-width:2px
    classDef server fill:#e8f1ff,color:#183153,stroke:#5484bd
    classDef management fill:#e7f5ec,color:#175b36,stroke:#439766

    class FW firewall
    class APP,DB server
    class KALI management
```

**Validated Firewall Policy Paths**

| Test | Source | Destination | Intended Policy | Observed Result |
|---|---|---|---|---|
| LAB-01 | APP-SERVER | DB-SERVER TCP/5432 | Allow via OPNsense | Connected — Pass |
| LAB-02 | APP-SERVER | DB-SERVER TCP/5433 | Deny via OPNsense | Firewall block confirmed — Pass |
| LAB-03 | APP-SERVER | OPNsense MGMT TCP/443 | Deny | Blocked after anti-lockout remediation — Pass |
| LAB-04 | DB-SERVER | OPNsense MGMT TCP/443 | Deny | Connection failed; firewall evidence incomplete |
| LAB-05 | Kali workstation | OPNsense MGMT TCP/443 | Allow | HTTPS administration connected — Pass |

**Interpretation:** The diagram represents physical/logical zone connectivity, while the table represents security policy decisions. Connections to the firewall's own management interface are distinct from transit traffic between APP and DB zones.

A temporary Python HTTP listener on TCP port `5432` simulated database service connectivity. PostgreSQL was not deployed. Only the listed test paths were validated.

### Proposed Enterprise Target Architecture

A separate conceptual design for fictional Enterprise X includes:

- Perimeter firewall and controlled VPN access.
- Internal segmentation firewall.
- Corporate, Application, Database, and Management zones.
- DMZ and reverse proxy.
- Privileged access through a hardened jump host.
- MFA and time-bound vendor authorization.
- Centralized security monitoring.

**These enterprise-scale components are proposed design elements and were not implemented in the laboratory.**

For additional design details, see the [Secure Architecture Design](06-proposed-secure-architecture.md).

#### Proposed Enterprise Architecture — Network Diagram

> **Design Status:** Conceptual architecture only. None of the enterprise components or policies below were deployed or validated in the laboratory.

The diagram separates **network topology and enforcement boundaries** from **permitted traffic policies**. A connection to a firewall does not imply unrestricted access.

```mermaid
flowchart TB
    EXT["Internet / External Clients"]
    REMOTE["Remote Employees"]
    VENDOR["Third-Party Vendors"]

    EDGE["EdgeFW<br/>Perimeter Firewall and VPN Termination<br/>MFA and Identity Checks (Proposed)"]
    SEG["SegFW<br/>Internal Segmentation Firewall<br/>Default-Deny Inter-Zone Policy"]

    subgraph DMZ_ZONE["DMZ — PUBLISHED SERVICES"]
        PROXY["Reverse Proxy"]
    end

    subgraph CORP_ZONE["CORPORATE ZONE"]
        USERS["Approved Corporate Workstations"]
    end

    subgraph APP_ZONE["APPLICATION ZONE"]
        APP["Approved Application Hosts"]
    end

    subgraph DB_ZONE["DATABASE ZONE"]
        DB["Protected Database Hosts"]
    end

    subgraph PA_ZONE["PRIVILEGED ACCESS ZONE"]
        JUMP["Hardened Jump Host"]
    end

    subgraph MGMT_ZONE["MANAGEMENT ZONE"]
        TARGETS["Approved Management Targets"]
    end

    subgraph SOC_ZONE["SECURITY MONITORING ZONE"]
        SIEM["SIEM / Log Collector"]
    end

    EXT --> EDGE
    REMOTE -->|"VPN + MFA"| EDGE
    VENDOR -->|"Restricted VPN + MFA"| EDGE

    EDGE --- PROXY
    EDGE --- SEG

    PROXY --- SEG
    USERS --- SEG
    APP --- SEG
    DB --- SEG
    JUMP --- SEG
    TARGETS --- SEG
    SIEM --- SEG

    classDef firewall fill:#243447,color:#ffffff,stroke:#243447,stroke-width:2px
    classDef workload fill:#e8f1ff,color:#183153,stroke:#5484bd
    classDef privileged fill:#e7f5ec,color:#175b36,stroke:#439766
    classDef monitoring fill:#fff1db,color:#754b00,stroke:#c58b28

    class EDGE,SEG firewall
    class PROXY,USERS,APP,DB,TARGETS workload
    class JUMP,REMOTE,VENDOR privileged
    class SIEM monitoring
```

**Proposed Security Policy Paths**

| Policy | Source → Destination | Required Control | Status |
|---|---|---|---|
| P-01 | Approved corporate workstations → Application hosts | SegFW; scoped TCP/443 | Proposed |
| P-02 | Corporate workstations → Database zone | Deny direct database access | Proposed |
| P-03 | Application hosts → Approved database hosts | SegFW; scoped TCP/1433 | Proposed |
| P-04 | Authorized vendor VPN group → Privileged access zone | EdgeFW + SegFW + IAM; MFA and time-bound access | Proposed |
| P-05 | Vendor VPN network → Database zone | Deny direct access | Proposed |
| P-06 | Standard corporate workstations → Management zone | Deny direct access | Proposed |
| P-07 | Jump host → Approved management targets | SegFW; restricted administrative services and logging | Proposed |
| P-08 | Internet clients → DMZ reverse proxy | EdgeFW; scoped TCP/443 | Proposed |
| P-09 | DMZ reverse proxy → Approved application backend | SegFW; scoped TCP/443 | Proposed |
| P-10 | Unapproved inter-zone traffic → Protected zones | Default deny at SegFW | Proposed |
| P-11 | Authorized employee VPN group → Approved application hosts | EdgeFW + SegFW + IAM; MFA and scoped TCP/443 | Proposed |
| P-12 | Approved log sources → SIEM / Log Collector | Approved transport; scoped filtering | Proposed |

**Architecture Principles**

- **Perimeter enforcement:** EdgeFW terminates remote-access VPN sessions and controls external exposure; the DMZ reverse proxy is reached only through approved perimeter policies.
- **Internal segmentation:** SegFW controls access between corporate, application, database, privileged access, management, and monitoring zones.
- **Remote and vendor access:** Authentication alone does not grant network-wide access. Employee and vendor sessions require destination-specific authorization.
- **Privileged administration:** Authorized vendor access reaches the privileged access zone; subsequent jump-host connections to management targets are separately restricted and logged.
- **Database isolation:** Direct corporate and vendor database access is denied. Only approved application-to-database services are permitted.
- **Centralized monitoring:** Approved systems forward security events to the SIEM through restricted, defined transport paths.
- **Default deny:** Unapproved inter-zone flows remain blocked.

The [Target-State Traffic Flow Matrix](09-Target-State-Traffic-Flow-Matrix.md) is the authoritative source for policy identifiers and intended access decisions. Administrative protocols, SIEM transport, firewall high availability, routing, NAT, and detailed identity integrations remain open design items.

**Implementation Status:** Proposed — Not Implemented or Tested.

## Security Validation Results

Five network connectivity scenarios were executed to evaluate selected firewall policies and management access restrictions.

| Test ID | Communication Path | Expected Behavior | Observed Result | Status |
|---|---|---|---|---|
| LAB-01 | APP → DB TCP/5432 | Allow | Connected | Pass |
| LAB-02 | APP → DB TCP/5433 | Deny | Connection blocked; firewall log confirmed | Pass |
| LAB-03 | APP → Firewall MGMT TCP/443 | Deny | Blocked after remediation | Pass |
| LAB-04 | DB → Firewall MGMT TCP/443 | Deny | Connection failed; complete firewall-log correlation unavailable | Partially Evidenced |
| LAB-05 | Kali → Firewall MGMT TCP/443 | Allow | Connected | Pass |

### Validation Summary

- **5** connectivity scenarios executed.
- **4** scenarios passed with supporting validation.
- **1** scenario partially evidenced.
- **1** observed security finding remediated and retested.

**[View Security Validation Evidence](evidence/README.md)**

The evidence register includes published screenshots for selected tests (LAB-01 through LAB-04), including the anti-lockout finding and remediation. LAB-05 connectivity was confirmed during testing, but a dedicated LAB-05 screenshot is not published.

## Key Security Finding

### Unintended Management Access — OPNsense Anti-Lockout Rule

During validation, the Application Server unexpectedly established a TCP connection to the OPNsense HTTPS management interface.

Firewall log analysis identified the built-in anti-lockout rule as the permitting rule.

This behavior conflicted with the intended management isolation policy.

**Remediation performed:**

1. Confirmed authorized management connectivity from Kali Linux.
2. Disabled the OPNsense administration anti-lockout rule.
3. Preserved the explicit authorized management access policy.
4. Retested application-to-management connectivity.
5. Confirmed the unauthorized connection was blocked.

**Outcome:** The unintended management access path was removed for the tested application host without disrupting authorized administration.

This finding demonstrates why firewall security validation must include automatically generated rules and observed traffic behavior, not only manually configured policies.

The finding was a firewall configuration and policy interaction, not evidence of an OPNsense software vulnerability.

## Project Documentation

The project follows a structured security architecture lifecycle.

| # | Document | Description |
|---|---|---|
| 01 | [Business & Security Requirements](01-business-security-requirements.md) | Business objectives, security requirements, and scope |
| 02 | [Current Architecture](02-current-architecture.md) | Fictional enterprise baseline and trust boundaries |
| 03 | [Traffic Flow Matrix](03-traffic-flow-matrix.md) | Assumed enterprise flows and observed laboratory traffic |
| 04 | [Security Assessment Findings](04-security-assessment-findings.md) | Hypothetical findings and observed laboratory security issue |
| 05 | [Risk Assessment & Register](05-risk-assessment-register.md) | Risk evaluation, treatment, and residual risk |
| 06 | [Secure Architecture Design](06-proposed-secure-architecture.md) | Implemented laboratory and proposed enterprise target design |
| 07 | [Architecture Decision Records](07-architecture-decision-records.md) | Design rationale, alternatives, and trade-offs |
| 08 | [Security Validation Plan & Results](08-security-validation-plan.md) | Executed tests, results, and evidence requirements |
| 09 | [Target-State Traffic Flow Matrix](09-Target-State-Traffic-Flow-Matrix.md) | Implemented laboratory policies and proposed enterprise policies |
| 10 | [Requirements Traceability Matrix](10-requirements-traceability-matrix.md) | Requirements-to-controls-to-validation mapping |
| 11 | [STRIDE Threat Model](11-stride-threat-model.md) | Design-time threats, trust boundaries, mitigations, and evidence limitations |
| 12 | [Attack Path Analysis](12-attack-path-analysis.md) | Hypothetical attack paths and defensive controls; observed lab path clearly separated |
| 13 | [Security Assurance Report](13-security-assurance-report.md) | Control validation, evidence coverage, and residual assurance gaps |

### Supporting Evidence

[Security Validation Evidence Register](evidence/README.md) — Screenshots and explanations documenting selected firewall validation results.

## Methodology

1. **Requirements Definition:** Identify business objectives and security requirements.
2. **Architecture Assessment:** Review network boundaries and communication flows.
3. **Risk Assessment:** Identify and prioritize security risks.
4. **Secure Design:** Develop segmentation architecture and access policies.
5. **Architecture Decisions:** Document alternatives, rationale, and trade-offs.
6. **Implementation:** Configure selected security controls in the laboratory.
7. **Validation:** Execute connectivity tests and review firewall logs.
8. **Remediation:** Investigate unexpected access and verify corrective actions.
9. **Traceability:** Map requirements to controls, findings, and validation results.

## Technologies & Security Concepts

**Technologies:** OPNsense, Oracle VirtualBox, Debian Linux, Kali Linux.

**Security Concepts:** Security Architecture, Network Segmentation, Firewall Policy Design, Least Privilege, Default Deny, Security Risk Assessment, Security Assurance, Architecture Decision Records, Requirements Traceability.

## Project Status

| Area | Status |
|---|---|
| Core Documentation | Completed |
| Laboratory Implementation | Completed for the documented test scope |
| Security Validation | 5 scenarios executed; 4 passed with supporting validation and 1 partially evidenced |
| Evidence Publication | [Published — View Evidence](evidence/README.md) |
| Enterprise Target Architecture | Proposed — Not Implemented |

## Scope and Limitations

This is an independently developed cybersecurity portfolio project.

Enterprise X is fictional. The practical laboratory uses isolated virtual machines and does not represent a production deployment.

The laboratory demonstrates selected network security controls and does not claim to establish:

- Production PostgreSQL database security.
- Application-level authentication or authorization.
- Enterprise VPN or MFA implementation.
- SIEM integration or centralized alerting.
- Jump-host deployment.
- DMZ or reverse-proxy deployment.
- Firewall high availability or disaster recovery.
- Comprehensive penetration testing.
- Regulatory compliance certification.

All implementation and validation claims are limited to the documented laboratory scope.

## Disclaimer

All organizational details, enterprise architecture assumptions, and scenario-based risks are fictional.

The implemented laboratory and its documented validation results are presented for educational and professional portfolio purposes only.
