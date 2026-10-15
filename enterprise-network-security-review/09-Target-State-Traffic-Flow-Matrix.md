# Target-State Traffic Flow Matrix

## 1. Purpose and Status

This document translates the proposed Enterprise X logical security architecture into reviewable, least-privilege communication requirements. It complements `03-traffic-flow-matrix.md` (fictional **current state**) and `06-proposed-secure-architecture.md` (**target state**).

**Status:** Proposed policy specification. No rules have been implemented, tested, or approved by real system owners. All addresses, identities, and applications are fictional; object names are placeholders rather than deployable firewall objects.

## 2. Enforcement and Design Assumptions

- **EdgeFW:** Perimeter firewall and VPN termination point; controls internet exposure and remote-session entry.
- **SegFW:** Internal segmentation firewall; all inter-zone traffic must traverse it. Inter-zone routing bypasses are prohibited.
- **Vendor remote access:** MFA and time-limited authorization are enforced before access to the privileged access service. Vendor sessions receive a restricted identity/policy group.
- **Default deny:** No inter-zone flow is allowed unless specifically approved. Denied attempts are logged according to the monitoring policy, with appropriate filtering to avoid excessive volume.
- **Application and database access:** Only approved host groups are allowed; broad zone-to-zone access is not intended.
- **DMZ:** Published HTTPS terminates at an approved reverse proxy. Backend traffic crosses SegFW before reaching approved application servers.
- **Return traffic:** Stateful return traffic for an established allowed session is permitted; no separate reverse-direction allow rule is implied.
- **Identity controls:** Firewall network rules alone do not satisfy authentication, authorization, or session monitoring requirements.

## 3. Target-State Policy Matrix

| Policy ID | Source / Identity | Destination | Service | Enforcement | Target Action / Conditions | Logging | Owner / Approval | Related Requirements / Findings / Tests |
|---|---|---|---|---|---|---|---|---|
| P-01 | Approved corporate workstation group | Approved application hosts | TCP/443 | SegFW | Allow only approved app destinations | Session allow + security events | App owner + Network Security | BR-01, SR-01, SR-02; TC-07 |
| P-02 | Corporate workstation zone | Database zone | TCP/1433 (and other DB services by default) | SegFW | Deny direct database access | Deny / alert on suspicious patterns | Database owner + Network Security | SR-03; F-02; TC-01 |
| P-03 | Approved application host group | Approved database host group | TCP/1433 | SegFW | Allow only justified app-to-DB sessions | Session allow + relevant events | App + Database owners | BR-04, SR-02, SR-03; F-02; TC-03 |
| P-04 | Approved vendor identity group / VPN address pool | Approved privileged access service | **TBD**: service and port depend on chosen access gateway | EdgeFW + SegFW + identity platform | Allow only after MFA, explicit authorization, and within approved time window | Authentication, authorization, session metadata | System owner + IAM + Network Security | BR-03, SR-04, SR-06; F-01, F-04; TC-05, TC-08 |
| P-05 | Vendor VPN address pool | Database zone | Any | SegFW | Deny direct vendor-to-DB traffic | Deny + high-priority alert for repeated attempts | Database owner + Network Security | SR-03, SR-06; F-01; TC-02 |
| P-06 | Standard corporate workstation zone | Management zone | Any | SegFW | Deny direct management access | Deny / investigate exceptions | Infrastructure owner + Network Security | SR-07; F-03; TC-04 |
| P-07 | Hardened jump host | Specifically approved management targets | **TBD**: approved RDP/SSH/HTTPS per target | SegFW + privileged access controls | Allow named admin roles and destinations only; monitor sessions | Session and admin activity logs | Infrastructure owner + IAM | SR-04, SR-07; F-03, F-04; TC-06 |
| P-08 | Internet public clients | Published DMZ reverse proxy | TCP/443 | EdgeFW | Allow only approved published application endpoint | Web access + edge security events | App owner + Network Security | BR-02 where applicable, SR-02; TC-07 |
| P-09 | Approved DMZ reverse proxy | Approved application backend | TCP/443 | SegFW | Allow named backend services only; enforce backend authentication as required | Reverse-proxy and firewall events | App owner + Network Security | SR-01, SR-02; TC-07 |
| P-10 | Unapproved inter-zone sources | All protected zones | Any not explicitly permitted | SegFW | Deny by default | Deny logging with noise controls | Network Security | SR-01, SR-02, SR-08; TC-07 |
| P-11 | Authorized remote employee group / VPN pool | Approved internal application hosts | TCP/443 | EdgeFW + SegFW + identity platform | Allow only after MFA and group-based authorization | VPN auth + relevant sessions | IAM + App owner | BR-02, SR-04; additional test required |
| P-12 | Approved security log sources (firewalls, VPN, jump host, servers) | SIEM / log collector | **TBD**: approved agent/syslog transport and port | SegFW where crossing zones | Allow only approved log sources and collector destinations; secure transport preferred | Collector ingestion health + errors | SOC + Platform owner | SR-05; additional test required |

**Important:** The `Any` service in **deny** rows does not authorize any traffic. Placeholder `TBD` services must be resolved before deployment. P-08 and P-09 do not imply that all corporate applications are publicly exposed.

## 4. Exceptions and Implementation Details

Before implementing any rule, record:

1. Source and destination IP/CIDR or address-group objects, with ownership.
2. Application/service and exact ports; no unreviewed `Any` in an allow rule.
3. Business justification, requestor, approver, and review/expiry date.
4. Rule order, zones/interfaces, NAT requirements, and expected return path.
5. Identity conditions, inspection profile, and log retention requirements where applicable.
6. Change window, rollback plan, and validation evidence.

Any required exception (for example, approved database administration or emergency access) must be documented as a **separate narrowly scoped rule** rather than silently broadening P-03 or P-07.

## 5. Current-to-Target Traceability

| Current Flow | Current Exposure | Target Policy | Intended Change |
|---|---|---|---|
| TF-01 | Corporate → Application TCP/443 allowed | P-01 | Retain with approved source/destination scope |
| TF-02 | Corporate → Database TCP/1433 allowed | P-02 | Deny direct workstation database access |
| TF-03 | Vendor VPN → Management TCP/3389 allowed | P-04, P-07 | Replace direct path with controlled privileged access; verify MFA and monitoring |
| TF-04 | Vendor VPN → Database Any allowed | P-05 | Deny direct vendor database access |
| TF-05 | Application → Database TCP/1433 allowed | P-03 | Retain only approved application/database pairs |
| TF-06 | Internet → DMZ TCP/443 allowed | P-08 | Retain only approved published HTTPS endpoint |
| TF-07 | Corporate → Management Any allowed | P-06 | Deny direct standard-user management access |

## 6. Validation and Evidence Gaps

Existing planned tests TC-01 through TC-08 cover core access restrictions. The validation plan must also add tests for:

- Remote employee VPN/MFA and destination restrictions (P-11).
- Approved log delivery and collector ingestion (P-12).
- DMZ-to-backend allowlisting and denial of unapproved backends (P-09).
- Routing verification that inter-zone traffic cannot bypass SegFW.
- Expired/disabled vendor identity authorization and revocation behavior (P-04).

**All results remain Not Tested.** A proposed policy or test case is not evidence that a security control works.

## 7. Open Decisions

- Vendor access gateway/service and exact port for P-04.
- Approved management protocols and targets for P-07.
- SIEM ingestion method, encryption, and ports for P-12.
- Detailed firewall HA, routing, NAT, and rule order.
- Operational service flows (DNS, AD, NTP, backups, patching, monitoring) and their approved owners.

## Disclaimer

Enterprise X is fictional. This matrix is a design artifact for a personal security architecture portfolio and is not a production firewall rulebase.
