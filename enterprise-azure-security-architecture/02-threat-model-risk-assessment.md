# 02 — Threat Model and Risk Assessment

**Status:** Updated risk assessment for the observed Azure hybrid laboratory | **Method:** STRIDE-informed threat identification; qualitative likelihood × impact, using the original 1–3 scale. These are architectural judgments, not measured exploit probabilities.

## 1. System, assets and assumptions

**Assets:** Azure application workload, Azure Firewall policy and diagnostic events, WireGuard peer and routes, OPNsense segmentation, Event Hub event stream and scoped ingestion identity, Splunk indexed events and SEC-001 alert.

**Trust boundaries:** Azure workload → enforcement, Azure → local WireGuard network, Azure Firewall → Event Hubs, Event Hubs → Splunk, and management identity → privileged interfaces.

**Threat actor assumptions:** A compromised application process, misconfigured administrator, unauthorized tunnel peer, or party capable of disrupting the telemetry path. None of these threat scenarios is presented as an observed compromise.

## 2. Risk scoring

Likelihood (L) and impact (I) each range from 1 (low) to 3 (high); inherent risk = L × I. Original ratings are retained as **design-stage prioritization**. Current evidence changes the confidence in specific controls, not the original inherent risk score. No numeric residual risk is asserted without a fresh likelihood assessment.

## 3. Risk register and evidence-informed treatment

| Risk | Scenario | Original L×I | Relevant controls / requirements | Evidence and current treatment assessment |
|---|---|---|---|---|
| R-01 | Excessive APP access to local/DB services | 3×3 = 9 High | SEC-01, SEC-02, Azure Firewall and NSG | AZ-01 allowed intended TCP/5432; AZ-02 denied TCP/4444. **Partial mitigation evidence**; original TCP/22 and broader isolation not proven |
| R-02 | UDR, NAT or return-path bypass of intended firewall inspection | 3×3 = 9 High | SEC-04, route review, firewall policy | Effective-route screenshots and firewall events exist; no exhaustive symmetric packet-path proof. **Open assurance gap** |
| R-03 | Unauthorized WireGuard peer or overbroad routes | 2×3 = 6 High | SEC-05, SEC-07, peer restrictions | Hybrid tunnel works; independent peer/key abuse test not documented. **Partially evidenced** |
| R-04 | Excessive management reachability | 2×3 = 6 High | SEC-06, SEC-07, scoped management | Management-blocking screenshots retained; coverage against original management test contract not fully attributable. **Open assurance gap** |
| R-05 | Missing firewall events impede investigation | 3×2 = 6 High | SEC-08, Event Hubs, Splunk | AZ-02 and AZ-05 demonstrate event ingestion; AZ-03 detection triggered. **Observed mitigation**, not continuous availability proof |
| R-06 | Secrets exposed through repository or configuration | 2×3 = 6 High | SEC-09, publication hygiene | Owner reviewed screenshots for sensitive data; no comprehensive repository secret scan claimed. **Partially evidenced** |
| R-07 | Single hybrid gateway/firewall interruption | 2×2 = 4 Medium | Availability planning | No HA/failover test claimed. **Accepted lab design trade-off; production risk unresolved** |
| R-08 | Costs or undeleted resources exceed planned budget | 2×3 = 6 High | BUS-05, SEC-10 | Project resource group deletion confirmed; subscription resource listing showed only two Network Watchers. Final billing reconciliation pending. **Cleanup evidenced; billing not verified** |
| R-09 | Event Hub consumer misconfiguration or log loss | 2×2 = 4 Medium | SEC-08, SEC-09, scoped Data Receiver | Event ingestion observed; resilience, backlog and identity misuse not adversarially tested. **Partially mitigated** |

## 4. STRIDE mapping

| STRIDE | Representative risk | Relevant boundary | Evidence status |
|---|---|---|---|
| Spoofing | R-03, R-04 | Tunnel peer and management identity | Threat modeled; no spoofing exploit test |
| Tampering | R-01, R-02 | Routing and firewall/NSG policy | Selected deny and cleanup verification |
| Repudiation | R-05 | Firewall decision → event stream | Azure Firewall events searchable in Splunk |
| Information disclosure | R-01, R-06 | Hybrid network and published artifacts | Selected network restrictions; owner screenshot review |
| Denial of service | R-07, R-09 | Hybrid gateway and telemetry | No failover/resilience test |
| Elevation of privilege | R-04, R-09 | Management and ingestion identities | Receiver scope recorded; privilege abuse untested |

Detailed scenario mechanics are in [11 — STRIDE Threat Model](11-stride-threat-model.md); [12 — Attack Path Analysis](12-attack-path-analysis.md) covers potential paths rather than confirmed exploits.

## 5. Risk-to-evidence assessment

- **R-01:** AZ-01 and AZ-02 support selected allow/deny behavior. No evidence of a full default-deny assessment across all local subnets.
- **R-02:** Route-association/effective-route screenshots strengthen the design review, but do not alone establish inspected bidirectional forwarding.
- **R-05 and R-09:** AZ-02/03/05 demonstrate the telemetry/detection path at the observed time, not sustained delivery or recovery from failure.
- **R-06:** Screenshot review is distinct from scanning every historical Git commit or secret.
- **R-08:** Project resource-group deletion and post-deletion subscription inventory are confirmed from operator-provided Azure CLI output; final charges and billing closure remain unverified.

## 6. Risk treatment decisions

**Mitigate with observed controls:** Selective Azure Firewall/NSG policy, explicit routing, centralized firewall diagnostics and scheduled detection.

**Retain as assurance gaps:** Reverse-direction tests, management-source restrictions, tunnel peer misuse, failover, complete route inspection and final cost/teardown confirmation.

**Accept for laboratory scope:** No HA and no full-scale penetration test. These are bounded lab assumptions, not production acceptance decisions.

## 7. Assurance statement

The threat model supports risk-informed design and prioritization. It does **not** assert that every original risk is closed or that a high inherent score has been reduced to a quantified residual level. The definitive status for each original security requirement is in [10 — RTM](10-requirements-traceability-matrix.md); test results are in [07](07-security-validation-evidence.md).
