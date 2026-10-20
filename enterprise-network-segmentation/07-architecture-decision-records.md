# Architecture Decision Records (ADR)

## 1. Purpose

This document records the key security architecture decisions made during the Enterprise X network segmentation case study.

Each Architecture Decision Record (ADR) documents the context, selected approach, alternatives, rationale, trade-offs, and validation status.

The decisions are divided into:

- **Implemented Decisions:** Applied and tested in the VirtualBox laboratory.
- **Proposed Decisions:** Recommended for the fictional enterprise target architecture but not implemented.

Enterprise X is a fictional organization. Laboratory decisions do not represent production architecture approvals.

---

## ADR-001: Implement Firewall-Based Network Segmentation

**Status:** Implemented and Validated in Lab  
**Related Findings:** F-02, F-03  
**Related Requirements:** SR-01, SR-02

### Context

The fictional enterprise baseline highlights the risks of excessive communication between application, database, and management environments.

A practical laboratory was required to demonstrate security zone separation and enforceable inter-zone access restrictions.

### Decision

Deploy OPNsense as a centralized segmentation firewall with dedicated interfaces for three security zones:

- APP: 192.168.10.0/24
- DB: 192.168.20.0/24
- MGMT: 192.168.30.0/24

Apply explicit least-privilege firewall policies and rely on default-deny behavior for unauthorized traffic.

### Alternatives Considered

1. Flat network with host-based controls only.
2. VLAN segmentation using switch ACLs.
3. Dedicated firewall interfaces with stateful policy enforcement.

### Rationale

Firewall-based segmentation provides centralized control over inter-zone traffic and enables rule-based access restrictions and logging.

Dedicated interfaces also simplify the laboratory topology and make trust boundaries easier to validate.

### Trade-offs

- Centralized firewall availability dependency.
- Additional configuration and policy management.
- Potential performance limitations.
- Requires continuous rule review and validation.

### Validation

- APP-to-DB TCP/5432: Allowed.
- APP-to-DB TCP/5433: Blocked.
- APP-to-MGMT TCP/443: Blocked after remediation.
- Kali-to-MGMT TCP/443: Allowed.

**Outcome:** Selected segmentation controls implemented and validated for the tested communication paths.

---

## ADR-002: Restrict Database Connectivity to Approved Application Traffic

**Status:** Implemented and Validated in Lab  
**Related Findings:** F-01, F-02  
**Related Requirements:** SR-02, SR-03

### Context

Unrestricted access to database services increases unnecessary network exposure.

The architecture requires an explicitly defined application-to-database communication path while restricting unauthorized services.

### Decision

Permit APP-SERVER (192.168.10.10) to access DB-SERVER (192.168.20.10) on TCP port 5432.

Do not introduce broad application-to-database allow rules.

### Alternatives Considered

1. Allow unrestricted communication between APP and DB zones.
2. Restrict communication by source and destination only.
3. Restrict communication by source, destination, protocol, and port.

### Rationale

The selected policy follows least-privilege principles and permits only the required test service.

### Trade-offs

- Application dependencies must be identified accurately.
- Service changes may require firewall policy updates.
- Network filtering does not replace database authentication or authorization.

### Validation

- TCP/5432: Connection successful.
- TCP/5433: Connection failed; firewall logs confirmed the blocked attempt.

**Implementation Note:** The DB-SERVER used a temporary Python TCP listener on port 5432 to simulate database service connectivity. PostgreSQL was not deployed.

**Outcome:** Approved communication was preserved while the tested unauthorized port was blocked.

---

## ADR-003: Restrict Firewall Administration to the Management Zone

**Status:** Implemented and Validated for Selected Paths  
**Related Findings:** F-03, LAB-F-01  
**Related Requirements:** SR-04, SR-05

### Context

Administrative interfaces are sensitive security assets.

Application and database workloads should not have unnecessary network access to firewall management services.

### Decision

Use the Kali Linux workstation (192.168.30.10) as the designated management endpoint for OPNsense administration.

Permit authorized HTTPS administration and restrict unauthorized application and database access to the firewall management interface.

### Alternatives Considered

1. Allow administration from multiple internal zones.
2. Restrict administration using source-based firewall rules.
3. Deploy a dedicated jump host or privileged access workstation architecture.

### Rationale

A dedicated management zone reduces the administrative attack surface and provides a clear boundary between operational workloads and firewall administration.

### Trade-offs

- Management access must remain available during firewall policy changes.
- Incorrect rules may cause administrative lockout.
- Dedicated privileged-access infrastructure would provide stronger controls in a production environment.

### Validation

- Kali-to-MGMT TCP/443: Successful.
- APP-to-MGMT TCP/443: Blocked after remediation.
- DB-to-MGMT TCP/443: Connectivity failed; full firewall log correlation remains a documentation item.

**Outcome:** Authorized management access was preserved while selected unauthorized access paths were restricted.

---

## ADR-004: Review and Disable the OPNsense Anti-Lockout Rule

**Status:** Implemented and Validated in Lab  
**Related Finding:** LAB-F-01  
**Related Risk:** R-05

### Context

During security validation, APP-SERVER unexpectedly established a TCP connection to the OPNsense HTTPS management interface.

Firewall log inspection identified the built-in anti-lockout rule as the permitting rule.

This behavior conflicted with the intended management isolation policy.

### Decision

Disable the administration anti-lockout rule after confirming that explicit authorized management access from Kali Linux remained available.

### Alternatives Considered

1. Retain the anti-lockout rule and accept the unintended access path.
2. Restrict the firewall management service through additional interface or listener configuration.
3. Disable the anti-lockout rule and rely on explicit management access policies.

### Rationale

The selected approach removes the unintended access path while preserving the required administrative connectivity.

It also demonstrates the importance of reviewing automatically generated firewall rules during security assurance activities.

### Trade-offs

- Incorrect management rules could lock administrators out.
- Administrative access recovery procedures become more important.
- Firewall policy changes require careful validation.

### Validation

**Before Remediation:**
- APP-to-MGMT TCP/443: Connected.
- Firewall logs identified the anti-lockout rule as the permitting rule.

**After Remediation:**
- APP-to-MGMT TCP/443: Blocked.
- Firewall logs confirmed the denied connection.
- Kali-to-MGMT TCP/443: Authorized access preserved.

**Outcome:** The unintended management access path was remediated for the tested application server.

---

## ADR-005: Introduce Controlled Privileged Access Through a Jump Host

**Status:** Proposed — Not Implemented  
**Related Findings:** F-03, F-04

### Context

A larger enterprise environment may require privileged administration by multiple internal teams and authorized third parties.

Direct administrative access from general-purpose workstations increases exposure.

### Decision

Introduce a hardened jump host or equivalent privileged-access solution for enterprise administrative access.

### Alternatives Considered

1. Direct administrative access with source restrictions.
2. Dedicated privileged access workstations.
3. Controlled jump host with strong authentication and monitoring.

### Rationale

A controlled administrative access point can improve access restrictions, monitoring, and accountability.

### Trade-offs

- Additional infrastructure and maintenance.
- Increased operational complexity.
- Availability and emergency access requirements.
- Does not replace identity security or endpoint hardening.

**Outcome:** Recommended for the enterprise target architecture; not deployed in the laboratory.

---

## ADR-006: Enforce MFA and Restricted Third-Party Access

**Status:** Proposed — Not Implemented  
**Related Findings:** F-01, F-04  
**Related Requirements:** SR-08

### Context

Remote and third-party access introduces additional security risks, particularly when privileged systems are involved.

### Decision

Require MFA, destination-specific authorization, and time-bound access for third-party connectivity.

### Alternatives Considered

1. Password-only VPN access.
2. VPN with MFA and network restrictions.
3. Identity-aware access with MFA, granular authorization, and session monitoring.

### Rationale

Strong authentication and restricted access reduce unnecessary exposure and limit the consequences of compromised credentials.

### Trade-offs

- Identity integration and lifecycle management.
- Potential licensing costs.
- Additional administrative processes.
- Emergency access requirements.

**Outcome:** Recommended for the fictional enterprise target architecture; not implemented or validated.

---

## 2. Decision Summary

| ADR | Architecture Decision | Status |
|---|---|---|
| ADR-001 | Firewall-Based Network Segmentation | Implemented and Validated |
| ADR-002 | Least-Privilege Database Connectivity | Implemented and Validated |
| ADR-003 | Management Zone Isolation | Implemented for Selected Paths |
| ADR-004 | Anti-Lockout Rule Remediation | Implemented and Validated |
| ADR-005 | Controlled Privileged Access / Jump Host | Proposed |
| ADR-006 | MFA and Restricted Third-Party Access | Proposed |

## 3. Key Architecture Lessons

The practical laboratory demonstrated that:

- Network segmentation must be supported by enforceable firewall policies.
- Least-privilege access requires clearly defined communication requirements.
- Administrative interfaces should be isolated from general-purpose workloads.
- Automatically generated firewall rules may affect intended security boundaries.
- Security architecture decisions should be validated through practical testing.
- Successful connectivity testing alone does not prove comprehensive security.

## 4. Related Documentation

- `01-business-security-requirements.md`
- `03-traffic-flow-matrix.md`
- `04-security-assessment-findings.md`
- `05-risk-assessment-register.md`
- `06-proposed-secure-architecture.md`
- `08-security-validation-plan.md`
