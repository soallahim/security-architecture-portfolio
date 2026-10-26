# 04 — Architecture Decision Records (ADRs)

**Project:** Enterprise Azure Security Architecture & Monitoring  
**Version:** 1.0 — design-stage decisions  
**Implementation:** Not deployed | **Validation:** Not tested | **Azure trial:** Not activated

Related documents: [Requirements](./01-business-security-requirements.md) · [Threat model and risks](./02-threat-model-risk-assessment.md) · [Target architecture](./03-target-security-architecture.md)

## Decision governance

These records document **provisional design choices**, not implemented controls. "Accepted for design" means suitable for further preparation, **not** approved for Azure deployment. Revisit a decision if product capabilities, trial eligibility, budget, or lab observations contradict an assumption.

Decision criteria: (1) demonstrable security control and traceable evidence; (2) feasibility under the SAR 150 out-of-pocket limit; (3) compatibility with local CGNAT; (4) manageable implementation complexity; (5) honest treatment of residual risk.

| ADR | Topic | Design disposition | Deployment gate |
|---|---|---|---|
| ADR-01 | Central network enforcement | Azure Firewall Basic provisionally selected | Validate SKU, region, billing and route behavior |
| ADR-02 | Hybrid connectivity | Azure-hosted WireGuard gateway provisionally selected | Verify forwarding, key management, NAT and routing |
| ADR-03 | Inspection and segmentation | UDR + Azure Firewall + NSG layered model selected for design | Verify symmetrical inspected paths |
| ADR-04 | Security telemetry | Azure diagnostics → Event Hubs → local Splunk as preferred candidate | Prove connector and cost feasibility |
| ADR-05 | Deployment lifecycle and budget | Offline-first, short-lived PoC and verified teardown | Complete cost/credit/preflight review |
| ADR-06 | Database representation | Minimal TCP 5432 test service unless DB installed | Label service and evidence accurately |

---

## ADR-01 — Central Azure network enforcement

**Status:** Accepted for design; pending platform and cost verification.

**Context:** Requirements SEC-01 through SEC-04 call for explicit inter-zone decisions and evidence that traffic traverses a policy enforcement point. The project is a short-lived, small-scale proof of concept, not a production architecture.

**Options considered**

| Option | Advantages | Limitations |
|---|---|---|
| Azure Firewall Basic | Managed stateful network policy, Azure-native diagnostics, appropriate case study for centralized enforcement | Fixed hourly charges, additional public/management IP requirements, limited advanced inspection |
| Linux NVA with nftables | Potentially lower direct service charges; highly configurable | Operator-managed rules/logs, patching and HA, less direct evidence of Azure Firewall design competence |
| NSGs only | Native, inexpensive subnet/NIC filtering | Cannot alone demonstrate centralized Azure Firewall inspection or firewall policy/log correlation |

**Decision:** Use **Azure Firewall Basic** as the proposed central network control, with NSGs and host controls as additional layers. Do not attribute IDPS, TLS inspection, or premium threat detection to Basic.

**Consequences:** Azure Firewall Basic's fixed cost may dominate a 24-hour lab. If quota, regional support, trial coverage, or total budget makes it infeasible, stop and revise the architecture/ADR before deployment; do not silently substitute an NVA while claiming Azure Firewall evidence.

**Verification gate:** Confirm SKU and subnet/public-IP prerequisites in current Microsoft documentation and the eventual subscription; estimate full hourly, public IP, logging and data-processing charges; verify logs and effective routes after deployment.

**Traceability:** BUS-02, BUS-05, SEC-02, SEC-04, SEC-08; R-01, R-02, R-08; NET-01/02, ROUTE-01, LOG-01.

---

## ADR-02 — Hybrid connectivity from CGNAT-protected local lab

**Status:** Accepted for design; routing and operations unresolved.

**Context:** Local OPNsense is behind a Zain 5G connection with CGNAT. Inbound-initiated VPN service on the local edge is not a reliable assumption. The lab needs limited management connectivity to APP.

**Options considered**

| Option | Advantages | Limitations |
|---|---|---|
| Azure-hosted Linux WireGuard server; OPNsense initiates | Works conceptually with outbound-only local initiation; low VM footprint; useful packet-path validation | Self-managed keys, Linux forwarding, IP routing, public UDP exposure, single point of failure |
| Azure VPN Gateway | Managed Azure VPN integration | Cost, SKU and protocol compatibility, and local CGNAT/endpoint assumptions require additional evaluation |
| Public SSH directly to workload | Simple to set up | Conflicts with intended private management access and least privilege |

**Decision:** Propose a **WireGuard endpoint on an Azure Linux VM**; OPNsense initiates the tunnel. APP and DB remain without directly exposed public SSH.

**Consequences:** Peer AllowedIPs, local routes, Azure VM NIC IP forwarding, Linux forwarding/filter rules, source preservation, and return routes become critical security dependencies. The gateway is not production HA.

**Verification gate:** Offline draft of peer configs using placeholders; confirm no secrets in GitHub; inspect packet paths both ways; test handshake and both permitted and denied management flows when Azure is active.

**Traceability:** BUS-03, SEC-05, SEC-06, SEC-09; R-03, R-04, R-06, R-07; VPN-01/02/03.

---

## ADR-03 — Route-based inspection and defense in depth

**Status:** Conditionally accepted for design; **deployment-blocking open question**.

**Context:** Intra-VNet system routes may connect APP and DB directly. Hybrid flows require an inspected forward and return path. A topology diagram does not enforce traffic policy.

**Options considered**

| Option | Advantages | Limitations |
|---|---|---|
| Specific UDRs + Azure Firewall + NSGs | Explicit next hops for relevant prefixes; policy/log evidence; layered controls | Risk of bypass, asymmetric return, SNAT/source mismatch and platform-specific route constraints |
| NSGs only | Simpler and lower cost | Does not satisfy centralized firewall enforcement evidence goal |
| Single shared workload subnet | Minimal routing complexity | Weak trust separation and no meaningful APP/DB inspection boundary |

**Decision:** Use distinct APP, DB and VPN subnets. Propose RT-APP/RT-DB/RT-WG with specific routes via Azure Firewall and RT-FW on AzureFirewallSubnet for return to the WireGuard VM, **subject to Microsoft-supported routing constraints**. Do not attach RT-FW to AzureFirewallManagementSubnet.

**Required invariants before a test can pass**

1. Forward and return effective routes include the intended enforcement point.
2. Source IPs match the firewall policy (or the design explicitly accounts for SNAT).
3. WireGuard peer routes and Linux/OPNsense forwarding do not introduce an alternate bypass.
4. NSG/host filtering does not get misidentified as an Azure Firewall denial.
5. A failed connection is not considered proof of firewall enforcement without route, policy and event corroboration.

**Consequences:** More design work and test evidence, but stronger assurance. If Azure Firewall Basic route limitations make the path infeasible, revise the architecture rather than claim success.

**Verification gate:** Route-table review, bidirectional packet walk, effective route inspection, matching Allow/Deny firewall events, and ROUTE-01.

**Traceability:** SEC-01 through SEC-07; R-01, R-02, R-04; NET-01/02/03, VPN-02/03, ROUTE-01.

---

## ADR-04 — Azure security telemetry in local Splunk

**Status:** **Preferred candidate only — not technically approved.**

**Context:** BUS-04 and SEC-08 require searchable evidence of Azure Firewall decisions in local Splunk. The lab is behind CGNAT, and transport and ingestion costs must remain bounded.

**Options considered**

| Option | Advantages | Limitations |
|---|---|---|
| Azure Monitor diagnostics → Event Hubs → local Splunk consumer | Azure-native event stream; local outbound consumer may avoid inbound CGNAT issue | Event Hubs tier/throughput billing, connector support, consumer auth and event schema not yet verified |
| Azure-native Log Analytics only | Simple Azure integration and querying | Does not meet local Splunk integration objective; ingestion/retention charges |
| Export files and manually ingest to Splunk | Potential fallback for a constrained PoC | Not equivalent to continuous streaming; different evidence and operational claims |

**Decision:** Retain **Event Hubs → local Splunk** as the preferred candidate, not a final implementation decision. Before cloud activation, confirm a supported local Splunk input/connector, outbound access, permissions, event formats, ingestion limits and total cost. Document the precise component/version used.

**Fallback:** If streaming is infeasible, formally amend BUS-04/LOG-01 and this ADR before choosing a manual, accurately labeled demonstration. Never claim continuous integration when using imported files.

**Verification gate:** End-to-end LOG-01 with a real source event, delivery settings, actual Splunk query, timestamps, action, source/destination and correlation to a specific network test. Log gaps are findings, not passes.

**Traceability:** BUS-04, SEC-08, SEC-09; R-05, R-09; LOG-01.

---

## ADR-05 — Offline-first preparation, budget and teardown

**Status:** Accepted for planning; cost verification pending.

**Context:** Azure Free Trial time should not be consumed preparing GitHub documentation, local VMs, scripts or test plans. The user's out-of-pocket ceiling is SAR 150.

**Options considered**

| Option | Advantages | Limitations |
|---|---|---|
| Prepare locally, then activate and deploy briefly | Conserves trial time; allows preflight and review | Some platform/quotas cannot be verified until subscription access |
| Activate Azure early and develop in cloud | Earlier access to exact platform behavior | Consumes trial window and risks idle resources |
| Skip Azure deployment | No cloud cost | Cannot demonstrate deployed Azure Firewall or actual cloud traffic evidence |

**Decision:** Finish requirements, threat model, architecture, ADRs, local lab, IaC/configuration drafts, test scripts, evidence templates and cleanup plan **before activating the trial**. Activation requires explicit separate approval.

**Cost controls:** Refresh estimates for all resources and durations; include firewall fixed hours, management/public IPs, VM disks, Event Hubs, diagnostic logs, data transfer and any additional billable components. The prior USD 32.44 mixed-duration estimate is **not** a total project cap. Verify credit coverage/eligibility and subscription spending controls. Record resource inventory and teardown steps. Do not assume alerts are hard spending limits.

**Verification gate:** GOV-01 readiness checklist, secret scan, preflight approval, and after deployment verify deletion of all billable resources. No spending or cleanup success is claimed yet.

**Traceability:** BUS-05, BUS-06, SEC-09, SEC-10; R-06, R-08; GOV-01.

---

## ADR-06 — Test service realism and evidence integrity

**Status:** Accepted for design.

**Context:** SEC-02 and NET-01 require demonstrating a narrowly authorized APP-to-DB TCP 5432 flow. A genuine database service is not required to prove network-level reachability, but test evidence must be accurately described.

**Options considered**

| Option | Advantages | Limitations |
|---|---|---|
| Temporary TCP listener on DB VM port 5432 | Lightweight, tests network policy path | Does not demonstrate PostgreSQL, database authentication, or application-layer security |
| Install PostgreSQL | More realistic service validation | Extra setup and configuration scope, more complex assurance |
| Connectivity check without listener | Easy negative test | Cannot distinguish network filtering from absence of a listening service |

**Decision:** A **temporary TCP 5432 listener** is acceptable for network-policy verification if clearly labeled, with positive and negative tests and matching firewall evidence. PostgreSQL must only be claimed if actually installed and validated.

**Verification gate:** Record listener command, host address, expected response, client output, effective routes, and Azure Firewall log correlation. Do not infer policy enforcement from a timeout alone.

**Traceability:** SEC-02, BUS-06; R-01; NET-01/02.

---

## Architecture review: unresolved decisions

| Blocker | Required resolution before Azure activation |
|---|---|
| ARCH-01 | Confirm Azure Firewall Basic availability, management/public IP and region/SKU prerequisites |
| ARCH-02 | Validate UDR support and bidirectional inspected paths, including NAT and source preservation |
| ARCH-03 | Review OPNsense/WireGuard peer configuration, Linux forwarding and local lab readiness |
| ARCH-04 | Validate Splunk/Event Hubs connector, authentication, schema and cost |
| ARCH-05 | Choose exact management host and rule priorities; define egress/DNS and NSG/host precedence |
| ARCH-06 | Complete current full-cost estimate, trial-eligibility checks and teardown safeguards |

**Design assurance conclusion:** Six ADRs documented with alternatives, rationale, consequences and verification gates. **No control effectiveness is evidenced and deployment is not authorized.** Next artifact: implementation/readiness plan and validation procedures, including evidence identifiers.
