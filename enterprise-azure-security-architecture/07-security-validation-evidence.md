# Validated security controls and evidence

## Verified on 3 November 2026

| ID | Control / observation | Result | Evidence |
| --- | --- | --- | --- |
| AZ-01 | Azure application VM (10.50.10.4) to local HTTP test listener (192.168.20.10:5432) | PASS — 3/3 TCP connections | `evidence/EV-AZURE-01-Firewall-Logs.png` |
| AZ-02 | Denied flow to TCP 4444 | PASS — deny events observed in Azure Firewall logs ingested by Splunk | `evidence/EV-AZURE-01-Firewall-Logs.png` |
| AZ-03 | Scheduled Splunk SEC-001 — Repeated Firewall Denied Connections | PASS — triggered alert observed | `evidence/EV-AZURE-02-SEC001-Triggered.png` |
| AZ-04 | NSG private-network outbound control | PASS — Network Watcher IP flow verify returned Deny | `evidence/EV-AZURE-03-NSG-Deny.png` |
| AZ-05 | Azure Firewall telemetry pipeline | PASS — Azure Firewall diagnostics → Event Hubs → Splunk `azure_security` | `evidence/EV-AZURE-01-Firewall-Logs.png` |

TCP 5432 was a temporary HTTP test listener, not a PostgreSQL database. The NSG IP flow verification evaluates security-group rules; it is not a substitute for a packet-traversal test.

## Evidence publishing

Screenshots are maintained as supporting evidence and must be redacted before publication. Do not commit subscription IDs, credentials, private keys, SAS tokens, connection strings, or unfiltered logs. Evidence files listed above are referenced by their intended paths; links are added only when the corresponding sanitized image is actually present in the repository.
