# Enterprise Security Architecture — Microsoft Azure & Splunk Enterprise

**Security Architecture · Hybrid Networking · Azure Firewall · SIEM · Detection Engineering**

A hands-on security architecture laboratory integrating an Azure application workload with a local network through a WireGuard gateway. Network traffic is controlled through Azure Firewall and network security rules, while Azure Firewall telemetry is streamed to Splunk Enterprise for investigation and alerting.

## Architecture

```text
Local laboratory (192.168.20.0/24)
  └── WireGuard hybrid tunnel
        └── Azure gateway / routed network (10.50.0.0/16)
              ├── Azure Firewall (10.50.0.4)
              │     └── Firewall Policy / network rules
              └── Azure application VM (10.50.10.4)

Azure Firewall diagnostic logs
  → Azure Event Hubs (azure-firewall-logs)
  → Splunk Add-on for Microsoft Cloud Services
  → Splunk Enterprise (index: azure_security)
  → SEC-001 scheduled correlation alert
```

The diagram is a logical view of the tested traffic and telemetry paths; it is not a claim that every configuration step was automated.

## Implemented and validated

- Configured hybrid connectivity between the Azure application workload and a local laboratory using WireGuard and routed network segments.
- Implemented an Azure Firewall Policy with a narrowly scoped test flow and an NSG default-deny control for private-network outbound traffic.
- Validated **three successful TCP connection tests** from `10.50.10.4` to `192.168.20.10:5432`. The listener on TCP 5432 was used for a **test HTTP service**, not a PostgreSQL database.
- Generated denied-connection events for a separate test flow to TCP 4444 and verified their ingestion into Splunk.
- Enabled four Azure Firewall diagnostic log categories—`AZFWNetworkRule`, `AZFWApplicationRule`, `AZFWNatRule`, and `AZFWThreatIntel`—to an Event Hub.
- Ingested Azure Firewall telemetry using the Splunk Add-on for Microsoft Cloud Services; confirmed event timestamps and indexing in `azure_security`.
- Created and tested **SEC-001 — Repeated Firewall Denied Connections**, a scheduled Splunk alert; a triggered alert was observed on **3 November 2026**.
- Removed the temporary NSG rule used during deny testing and confirmed that `Deny-Private-Networks-Outbound` blocked the tested flow.
- Applied HTTPS-only and TLS 1.2 settings to the Azure Storage checkpoint account, with public blob access disabled.
- Scoped the Splunk service principal to **Azure Event Hubs Data Receiver** on the specific Event Hub.

## Test evidence summary

| Test | Observed result |
| --- | --- |
| Azure APP → local test listener, TCP 5432 | 3/3 successful connections |
| Azure APP → local target, TCP 4444 | Denied; firewall events ingested |
| Firewall → Event Hub → Splunk | Events observed in Splunk on 3 Nov 2026 |
| SEC-001 scheduled detection | Triggered alert observed at 05:10:01 (Arab Standard Time), 3 Nov 2026 |
| Temporary NSG test-rule removal | Removed; Network Watcher reported `Deny` by `Deny-Private-Networks-Outbound` |

These observations were collected during lab validation. The summary avoids including credentials, full Azure resource IDs, raw captures, or sensitive configuration.

## Security engineering decisions

**Least privilege:** A dedicated service principal has receiver-only access scoped to the firewall log Event Hub.

**Controlled traffic:** Firewall network rules and NSG policies restrict the tested network flows. The temporary test exception was removed after validation.

**Telemetry and detection:** Firewall diagnostics are collected centrally and converted into a scheduled Splunk detection, demonstrating an end-to-end control-validation workflow.

**Transport protection:** The checkpoint storage account was configured to require HTTPS and TLS 1.2.

## Architecture case-study approach

This portfolio documents security requirements, risk-based architecture choices, trust boundaries, control validation, findings, and assurance evidence. It is intentionally presented as an architecture case study rather than an infrastructure-as-code or configuration tutorial.

## Evidence handling

Published evidence is selected and sanitized to support architecture and security assurance claims. Operational commands, infrastructure templates, configuration files, credentials, and raw captures are not part of the public portfolio.

*Independent educational laboratory. Resource names and IP addresses shown are illustrative of the lab configuration, not production systems.*

## Architecture documentation

The original numbered design baseline (01–05) is preserved; subsequent documents record the implementation, assessment, threat analysis, traceability, and evidence-based assurance. This is an architecture case study, not a configuration tutorial.

1. [01 — Business and Security Requirements](./01-business-security-requirements.md)
2. [02 — Threat Model and Risk Assessment](./02-threat-model-risk-assessment.md)
3. [03 — Target Security Architecture](./03-target-security-architecture.md)
4. [04 — Architecture Decision Records](./04-architecture-decision-records.md)
5. [05 — Implementation and Validation Readiness Plan](./05-implementation-validation-readiness-plan.md)
6. [06 — Implemented Security Controls](./06-implemented-security-controls.md)
7. [07 — Security Validation Evidence](./07-security-validation-evidence.md)
8. [08 — Security Assessment Findings](./08-security-assessment-findings.md)
9. [09 — Security Traffic Flow Matrix](./09-security-traffic-flow-matrix.md)
10. [10 — Requirements Traceability Matrix](./10-requirements-traceability-matrix.md)
11. [11 — STRIDE Threat Model](./11-stride-threat-model.md)
12. [12 — Attack Path Analysis](./12-attack-path-analysis.md)
13. [13 — Security Assurance Report](./13-security-assurance-report.md)

[Security Validation Evidence Register](./evidence/README.md) — upload reviewed screenshots to the linked evidence folder.

Selected screenshots are published only after security review. The written evidence register records observed results and identifies the supporting evidence; it does not itself constitute a published screenshot.
