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

## Source and deployment notes

The Bicep and supporting scripts are maintained as lab engineering artifacts. Some configuration and validation steps were performed separately from infrastructure templates. Deployment results should be verified against the live environment before reusing templates; no claim of fully automated, one-command deployment is made.

## Evidence handling

The public repository contains sanitized test outcomes. Original console outputs, screenshots, and operational logs should be reviewed and redacted before publication. Private keys, connection strings, SAS tokens, service-principal credentials, packet captures, and backup archives must not be committed.

*Independent educational laboratory. Resource names and IP addresses shown are illustrative of the lab configuration, not production systems.*

## Project documentation

- [Implemented security controls](./SECURITY-IMPLEMENTATION.md)
- [Validated results and evidence register](./VALIDATION-RESULTS.md)

The evidence register identifies screenshot filenames; the screenshots and source package are prepared separately for publication after final visual review. No image or IaC file is represented as uploaded until it exists in this repository.
