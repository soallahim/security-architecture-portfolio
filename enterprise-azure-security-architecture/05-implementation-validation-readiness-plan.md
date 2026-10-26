# 05 — Implementation and Validation Readiness Plan

**Project:** Enterprise Azure Security Architecture & Monitoring  
**Version:** 1.0 — offline preparation plan  
**Status:** Planned / Not Implemented / Not Tested  
**Azure activation:** Explicitly deferred; this document does not authorize deployment.

References: [Requirements](./01-business-security-requirements.md) · [Threat Model](./02-threat-model-risk-assessment.md) · [Target Architecture](./03-target-security-architecture.md) · [ADRs](./04-architecture-decision-records.md)

## 1. Purpose and success definition

Prepare every feasible design, local-lab, automation, test and evidence task **before** activating an Azure Free Trial. The intended end state is a reproducible short-lived hybrid proof of concept, not an installation tutorial or production deployment.

**Ready to activate** means: offline design is reviewed; local resources and tools are verified; scripts/configurations are prepared and reviewed; test steps have objective expected results; billing and teardown safeguards are documented; remaining subscription-only checks are identified; and the user separately approves activation.

No step in this plan is marked complete solely because it is described.

## 2. Dependencies and execution order

| Phase | Deliverable | Dependency | Execution location | Current state |
|---|---|---|---|---|
| P0 | Confirm requirements, threat model, architecture and ADR consistency | Existing docs | GitHub/offline | Drafts exist; review pending |
| P1 | Local capacity and network inventory | User PC and available hypervisor | Local | Not verified |
| P2 | OPNsense local lab configuration | P1 | Local | Not verified |
| P3 | Splunk local readiness and sample-event parsing | P1 | Local | Not verified |
| P4 | WireGuard configuration drafts and offline validation | P1–P2 | Local | Not started |
| P5 | Infrastructure-as-code and VM bootstrap scripts | P0, P4 | Local Git working tree | Not started |
| P6 | Azure routing, firewall policy and log-ingestion implementation plan | P0, P5 | Offline | Not started |
| P7 | Test procedures, evidence templates and security review | P2–P6 | Local/GitHub | Not started |
| P8 | Cost, subscription prerequisites, teardown and go/no-go review | P0–P7 | Offline + public documentation | Not started |
| P9 | Activate Azure trial and verify subscription-only capabilities | Explicit user approval | Azure | **Blocked until approval** |
| P10 | Deploy, validate, document findings and remove resources | P9 | Azure + local | Not started |

A local task is only complete after the operator records what was actually checked. Existing documentation is not evidence of working infrastructure.

## 3. Local machine readiness (P1)

Proposed host: Windows PC, approximately 16 GB RAM and Intel i7-1065G7, **unverified for this project**. Do not assume adequate free RAM/disk or functioning virtualization.

**Checklist**

- [ ] Capture Windows edition/build, available RAM, free SSD space, CPU virtualization and hypervisor availability.
- [ ] Record whether VirtualBox, Hyper-V, WSL2 or other hypervisors are installed; resolve conflicts before VM creation.
- [ ] Confirm OPNsense VM image/version, virtual NIC count, isolated LAN network, and snapshot strategy.
- [ ] Confirm local lab subnet `192.168.50.0/24` does not overlap existing home LAN or VPN networks.
- [ ] Identify an admin test host IP within the local lab and whether it is routed through OPNsense.
- [ ] Confirm outbound UDP connectivity can be tested without exposing inbound ports on the home router.
- [ ] Check whether Splunk Enterprise is installed, licensed for the intended local use, and has sufficient disk.
- [ ] Record screenshots or command outputs **only after actual inspection**, sanitized for publication.

**Evidence placeholder:** `EV-LOCAL-01` host inventory and virtualization status; no evidence exists yet.

## 4. OPNsense readiness (P2)

- [ ] Prepare an isolated OPNsense VM with documented WAN/LAN interfaces and static local lab addressing.
- [ ] Restrict web/SSH management to the designated admin host; review any anti-lockout rules explicitly.
- [ ] Create a dedicated local network or test host that will be routed through OPNsense.
- [ ] Define routes for Azure `10.50.0.0/16` via WireGuard after tunnel establishment.
- [ ] Draft a least-privilege OPNsense rule matrix for admin→APP TCP 22 and deny admin→DB TCP 22.
- [ ] Verify outbound WireGuard initiation model; do not attempt to expose local inbound services through CGNAT.
- [ ] Plan packet capture points and logging to distinguish OPNsense drops from Azure Firewall decisions.
- [ ] Save sanitized config snapshots and a rollback/snapshot procedure.

**Evidence placeholders:** `EV-LOCAL-02` topology/interfaces, `EV-LOCAL-03` local firewall and routes. Not evidenced.

## 5. Splunk readiness (P3)

- [ ] Confirm installed Splunk Enterprise version and local service health.
- [ ] Create a dedicated lab index (proposed `azure_security_lab`), appropriate retention, and role-limited access.
- [ ] Validate local search and timestamp handling using clearly labeled **synthetic** sample events.
- [ ] Identify supported Event Hubs input method, add-on/connector version, required outbound ports, permissions and authentication.
- [ ] Draft field extraction and searches for action, source IP, destination IP, destination port, rule and timestamp.
- [ ] Separate **sample parsing success** from **real Azure ingestion success**. The latter requires actual Azure events and LOG-01.
- [ ] Estimate ingestion/storage and Event Hubs costs before cloud activation.

**Evidence placeholders:** `EV-LOCAL-04` Splunk health; `EV-LOCAL-05` synthetic parser output. Neither proves Azure log integration.

## 6. WireGuard configuration preparation (P4)

**Proposed network:** Azure VM `10.50.1.4`, tunnel `172.27.50.1`; OPNsense peer `172.27.50.2`; local routed prefix `192.168.50.0/24`.

- [ ] Choose WireGuard UDP port and document public-endpoint exposure.
- [ ] Create **templates with placeholders only** for private/public keys, endpoint IP and allowed peer prefixes.
- [ ] Document peer-specific `AllowedIPs`, Linux forwarding, Azure NIC IP forwarding and restricted forwarding/filter rules.
- [ ] Ensure source preservation for `192.168.50.x` if Azure Firewall policies match that source; avoid unplanned SNAT.
- [ ] Specify bidirectional return routes and packet walks for admin→APP and admin→DB.
- [ ] Define secure key-generation/storage process outside the repository.
- [ ] Offline-review Linux and OPNsense configuration; do not claim a working cross-site tunnel until VPN-01 executes.

**Evidence placeholder:** `EV-DESIGN-01` reviewed configuration templates, not live tunnel evidence.

## 7. Infrastructure-as-code and bootstrap plan (P5)

Use one reproducible IaC approach (Terraform or Bicep), to be selected in a later ADR update. **No IaC files have been created by this plan.**

**Proposed module/resource order:**

1. Resource group, region parameters, naming, tags and short-lived-lab ownership marker.
2. VNet/subnets including required Azure Firewall management subnet.
3. NSGs, route tables and associations; prevent circular dependency on the firewall's assigned private IP.
4. Azure Firewall Basic, its policy and required public/management IP configuration.
5. WireGuard Linux VM/NIC/public endpoint and Azure NIC IP forwarding.
6. APP and DB Linux VMs, with no direct public SSH endpoints.
7. Azure Monitor diagnostic settings and Event Hubs resources if ADR-04 feasibility is confirmed.
8. Parameterized configuration output for WireGuard, OPNsense and Splunk connector.

**Script quality gates:**

- [ ] All names, regions, CIDRs, VM SKUs, ports and authorized admin IPs are parameters.
- [ ] No hardcoded passwords, tokens, real SSH private keys, or WireGuard private keys.
- [ ] Idempotent provisioning or explicit safe rerun procedure.
- [ ] Static validation/linting and a documented version pin strategy.
- [ ] Deployment dependency order and rollback steps reviewed.
- [ ] Resource inventory and teardown automation reviewed.
- [ ] Public IP and billable resources explicitly listed; no uncontrolled autoscaling.
- [ ] Every claimed capability maps to a requirement and test.

## 8. Security policy and routing preflight (P6)

| Check ID | Required design verification | Blocker if unresolved |
|---|---|---|
| PRE-01 | Azure Firewall Basic subnet/public management prerequisites, region availability | Yes |
| PRE-02 | UDR applicability on AzureFirewallSubnet and return route to WireGuard NVA | Yes |
| PRE-03 | APP→DB forward and return via firewall | Yes |
| PRE-04 | Local→APP/DB forward and return via firewall with source preservation | Yes |
| PRE-05 | WireGuard peer AllowedIPs, Linux/OPNsense routes, forwarding and NAT | Yes |
| PRE-06 | NSG/host policies do not mask intended Azure Firewall enforcement evidence | Yes |
| PRE-07 | DNS, necessary platform egress and default routes explicitly designed | Yes |
| PRE-08 | Azure Firewall event categories and Event Hubs-to-Splunk connector feasible | Yes |
| PRE-09 | Firewall fixed costs, public IPs, VMs, disks, Event Hubs and log/data costs reviewed | Yes |

**Warning:** Documentation review can establish logical consistency but cannot replace subscription-specific effective-route and runtime tests. Those remain explicit deployment-time validation steps.

## 9. Test execution contract (P7 and P10)

| Test | Expected result | Required evidence ID(s) | Result now |
|---|---|---|---|
| NET-01 | APP→DB TCP 5432 allowed by intended firewall | EV-NET-01 connection, EV-FW-01 Allow, EV-ROUTE-01 | Not Tested |
| NET-02 | APP→DB TCP 22 denied by intended firewall | EV-NET-02 failure, EV-FW-02 Deny, EV-ROUTE-01 | Not Tested |
| NET-03 | DB→APP new session denied | EV-NET-03 failure, EV-FW-03 Deny, EV-ROUTE-02 | Not Tested |
| VPN-01 | OPNsense initiates WireGuard tunnel | EV-VPN-01 handshake, EV-VPN-02 peer routes | Not Tested |
| VPN-02 | Authorized local admin→APP SSH allowed | EV-VPN-03 SSH, EV-FW-04 Allow, EV-ROUTE-03 | Not Tested |
| VPN-03 | Local admin→DB SSH denied | EV-VPN-04 failure, EV-FW-05 Deny, EV-ROUTE-03 | Not Tested |
| ROUTE-01 | Intended traffic paths inspected, no observed bypass | EV-ROUTE-01/02/03 effective routes, gateway forwarding/NAT review | Not Tested |
| LOG-01 | Real selected Azure Firewall events searchable in Splunk | EV-LOG-01 diagnostic config, EV-LOG-02 source event, EV-LOG-03 SPL result | Not Tested |
| GOV-01 | Cost, secrets and teardown controls verified | EV-GOV-01 budget, EV-GOV-02 secret scan, EV-GOV-03 cleanup | Not Tested |

**Test record fields:** Test ID, date/time zone, environment/revision, requirement/policy IDs, source/destination/port, expected outcome, actual observation, enforcing control, evidence link, result (Pass/Fail/Partial/Not Tested), finding ID and limitation.

**Evidence rule:** Connection failure alone does not prove firewall enforcement. Correlate routes, configured policies and matching Azure Firewall logs. A missing log is a visibility gap, not an automatic Pass. Synthetic Splunk events are not Azure evidence.

## 10. Proposed evidence directory structure

```text
enterprise-azure-security-architecture/
  README.md
  01-business-security-requirements.md
  02-threat-model-risk-assessment.md
  03-target-security-architecture.md
  04-architecture-decision-records.md
  05-implementation-validation-readiness-plan.md
  architecture/        # future reviewed diagrams / flow matrices
  infrastructure/      # future IaC, templates, bootstrap scripts
  tests/               # future test procedures and records
  evidence/            # future sanitized real observations only
  assurance/           # future findings, limitations, residual risks
```

These directories are **planned**, not created by this document. Evidence files must only be added after collection, reviewed for secrets and private information.

## 11. Budget and teardown controls (P8)

**Hard user constraint:** Maximum SAR 150 out of pocket. Azure trial credit and its eligibility are not guaranteed. Prior USD 32.44 mixed-duration estimate is incomplete.

- [ ] Obtain current calculator estimate using the **same** deployment duration for all resources.
- [ ] Include firewall fixed/hourly usage, management/public IPs, VM runtime/disks, Event Hubs throughput, Azure Monitor diagnostics, ingestion, data transfer and residual storage.
- [ ] Check which resource charges are eligible for the specific trial and whether any authorization/verification holds apply.
- [ ] Use the smallest practical deployment window; avoid unattended resources.
- [ ] Define explicit resource group naming and a full teardown inventory.
- [ ] Prepare resource deletion steps and verify post-deletion resource inventory and subsequent billing.
- [ ] Use spending alerts as warnings only; do not assume they automatically stop all charges.
- [ ] If a credible estimate exceeds the approved out-of-pocket limit, stop and redesign before activation.

## 12. Go/no-go checklist for Azure activation

| Gate | Approval condition | Current disposition |
|---|---|---|
| GATE-A Design | Requirements, risks, packet paths, ADRs and open blockers reviewed | **No-go — review incomplete** |
| GATE-B Local | OPNsense/Splunk and host readiness actually verified | **No-go — not evidenced** |
| GATE-C Automation | IaC, scripts, secrets handling, test/evidence templates and teardown reviewed | **No-go — not created** |
| GATE-D Cost | Region/SKU prerequisites, credit eligibility and SAR 150 exposure evaluated | **No-go — incomplete** |
| GATE-E Authorization | User explicitly approves Azure activation after readiness review | **No-go — not requested** |

## 13. Immediate next action

Start **P1 — Local machine readiness**. Obtain actual host capacity and installed-tool information before prescribing VM sizes or creating local VMs. Then prepare the offline OPNsense and Splunk environments. Do not activate Azure.

---

**Assurance statement:** This is an execution plan, not evidence of a working deployment, successful security control, or completed test.
