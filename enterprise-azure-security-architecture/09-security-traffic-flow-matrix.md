# 09 — Security Traffic Flow Matrix

## Scope and interpretation

This matrix describes observed laboratory communication and telemetry flows. A network connection represents a tested route or service flow, not unrestricted access to every destination.

| Flow ID | Source | Destination | Service / channel | Control point | Expected / observed outcome | Evidence |
|---|---|---|---|---|---|---|
| TF-01 | Azure application VM `10.50.10.4` | Local HTTP test listener `192.168.20.10` | TCP/5432 | Azure Firewall Policy, hybrid routing | Allowed; **3/3** connectivity checks succeeded | AZ-01; EV-01 |
| TF-02 | Azure application VM / tested source | Local test destination | TCP/4444 | Azure Firewall Policy / tested network controls | Denied; events ingested into Splunk | AZ-02; EV-01 |
| TF-03 | Azure Firewall diagnostics | Azure Event Hubs | Diagnostic event delivery | Azure diagnostic settings and Event Hub | Events subsequently observed in Splunk | AZ-05; EV-01 |
| TF-04 | Azure Event Hub | Splunk Enterprise | Event Hub ingestion via Microsoft Cloud Services add-on | Event Hub-scoped Data Receiver role | Firewall events indexed in `azure_security` | AZ-05; EV-01 |
| TF-05 | Azure NSG policy evaluation | Evaluated private-network outbound flow | IP flow verification | NSG `Deny-Private-Networks-Outbound` | **Deny** reported after temporary rule removal | AZ-04; EV-03 |

## Trust boundaries

1. **Azure application subnet → Azure network enforcement:** Workload traffic is subject to routing and applicable network security policy.
2. **Azure ↔ local laboratory:** WireGuard carries the hybrid connection; allowed services must remain destination-specific.
3. **Azure control plane → telemetry transport:** Azure Firewall diagnostic events enter Event Hubs.
4. **Telemetry transport → security monitoring:** Splunk consumes the event stream and evaluates SEC-001.

## Validation boundaries

TF-01 proves TCP reachability to an HTTP test listener, **not** PostgreSQL connectivity. TF-05 proves an NSG policy decision, **not** a full packet traversal. No other untested flows are asserted as validated.

[Architecture](03-target-security-architecture.md) · [Controls](06-implemented-security-controls.md) · [Evidence](evidence/README.md)
