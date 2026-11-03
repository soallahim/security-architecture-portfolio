# 04 — Architecture Decision Records

**Decision register status:** Updated to distinguish design intent, implemented choices, observed evidence and remaining trade-offs. ADR IDs 01–06 are preserved.

## ADR governance

Each ADR identifies the problem, decision, alternatives, trade-offs and evidence. **Implemented** means the architecture choice was used; **validated** means only the stated test behavior was observed. An ADR is not proof of complete control effectiveness.

## ADR-01 — Central Azure network enforcement

**Problem:** Required hybrid application traffic must be allowed without opening broad Azure-to-local access.

**Decision:** Use Azure Firewall Policy as a central network policy point, with NSG restrictions for complementary control.

**Alternatives:** NSG-only filtering (lower operational complexity but different policy visibility); local-only filtering (moves enforcement farther from cloud workloads).

**Trade-off:** Central policy and diagnostics improve traceability but add cost, routing complexity and possible inspection-path ambiguity.

**Outcome:** Selected TCP/5432 connections succeeded (AZ-01); denied TCP/4444 events appeared in Splunk (AZ-02). **Scope:** Does not establish universal symmetric inspection or all-source default-deny behavior.

## ADR-02 — Hybrid connectivity under CGNAT

**Problem:** The local environment cannot assume inbound public connectivity.

**Decision:** Use a WireGuard-based hybrid link with Azure-hosted termination and local OPNsense routing.

**Alternatives:** Managed site-to-site VPN (different cost and edge requirements); public inbound local gateway (unsuitable under the stated CGNAT constraint).

**Trade-off:** Practical outbound-initiated connectivity, at the cost of peer/key management and explicit forwarding/return-path controls.

**Outcome:** Hybrid path used for the recorded Azure-to-local connectivity test. **Scope:** No claim of independent peer impersonation or all-route abuse testing.

## ADR-03 — Route-based inspection and defense in depth

**Problem:** Tunnel establishment and VNet routing alone cannot guarantee that selected traffic is inspected and restricted.

**Decision:** Use explicit UDR associations, Azure Firewall Policy, NSGs and local network controls.

**Alternatives:** Rely solely on default system routes or tunnel-level reachability (less explicit enforcement); apply only NSGs (different scope and telemetry).

**Trade-off:** Better layered policy intent, more moving parts and potential asymmetric paths requiring review.

**Outcome:** Effective-route/UDR screenshots retained; AZ-04 Network Watcher returned Deny after a temporary NSG test rule was removed. **Scope:** NSG evaluation is not packet-level end-to-end inspection proof.

## ADR-04 — Azure security telemetry to local Splunk

**Problem:** Network decisions must be observable in a centralized analysis environment.

**Decision:** Stream Azure Firewall diagnostic categories through Azure Event Hubs into Splunk Enterprise, with a receiver-scoped ingestion identity.

**Alternatives:** Native Azure log analysis only (less local SIEM integration); direct forwarding mechanisms (different integration dependencies).

**Trade-off:** Decoupled telemetry transport and reusable Splunk analytics, with added Event Hub and consumer-configuration dependencies.

**Outcome:** AZ-05 confirmed firewall events in `azure_security`; AZ-03 confirmed SEC-001 alert execution. **Scope:** Not a failover or end-to-end telemetry availability guarantee.

## ADR-05 — Cost governance and reproducibility

**Problem:** Cloud lab experimentation must remain financially bounded and explainable.

**Decision:** Retain an explicit cost ceiling, staged activation assumptions and teardown planning rather than presenting a permanent production footprint.

**Alternatives:** Long-lived lab (higher exposure to recurring costs); entirely offline simulation (cannot demonstrate real Azure diagnostics).

**Trade-off:** Short-lived testing limits repeatability without careful evidence retention.

**Outcome:** Planning and rationale documented. **Status:** Project resource-group deletion was confirmed by Azure CLI (`az group exists` returned `false`); a subsequent subscription resource list showed only two Network Watcher resources. Final billing and historical budget compliance remain unverified.

## ADR-06 — Test-service realism and evidence integrity

**Problem:** A network-layer TCP connectivity test must not be misrepresented as a successful database transaction.

**Decision:** Use a temporary HTTP listener on TCP/5432 as the local connectivity target, explicitly label the service and separate network reachability from application authorization.

**Alternatives:** Deploy a real database and test authentication (more representative but higher complexity); synthetic-only test (less faithful network evidence).

**Trade-off:** Low-cost, repeatable connectivity evidence without database security assurance.

**Outcome:** AZ-01 recorded 3/3 TCP connections to `192.168.20.10:5432`. No PostgreSQL or authenticated database access is claimed.

## Decision-to-evidence register

| ADR | Requirement | Risk | Test / evidence | Status |
|---|---|---|---|---|
| ADR-01 | SEC-02, SEC-04 | R-01, R-02 | AZ-01, AZ-02; firewall screenshot | Implemented; partially validated |
| ADR-02 | SEC-05 | R-03 | AZ-01; hybrid routing screenshots | Implemented; peer-security assurance partial |
| ADR-03 | SEC-01, SEC-04, SEC-07 | R-01, R-02 | AZ-04; UDR/effective-route screenshots | Implemented; selected NSG decision validated |
| ADR-04 | SEC-08, SEC-09 | R-05, R-09 | AZ-03, AZ-05; Splunk screenshots | Implemented; observed ingestion/detection validated |
| ADR-05 | BUS-05, SEC-10 | R-08 | Planning record | Project resource cleanup confirmed; final billing unverified |
| ADR-06 | SEC-02 | R-01 | AZ-01 | Test-service representation verified |

## Architecture review conclusion

The chosen controls are **coherent for a bounded educational hybrid security architecture lab**. The strongest evidence concerns the tested network flows and telemetry/detection path. Route-bypass, full management, peer hardening, resilience and cost closure remain outside the established test scope.

[Architecture](03-target-security-architecture.md) · [Requirements Traceability](10-requirements-traceability-matrix.md) · [Assurance](13-security-assurance-report.md).
