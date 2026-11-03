# 07 — Security Validation Evidence

## Verified on 3 November 2026

| ID | Control / observation | Result | Evidence |
| --- | --- | --- | --- |
| AZ-01 | Azure application VM (10.50.10.4) to local HTTP test listener (192.168.20.10:5432) | PASS — 3/3 TCP connections | [EV-AZURE-01-Firewall-Logs.png](./evidence/EV-AZURE-01-Firewall-Logs.png) |
| AZ-02 | Denied flow to TCP 4444 | PASS — deny events observed in Azure Firewall logs ingested by Splunk | [EV-AZURE-01-Firewall-Logs.png](./evidence/EV-AZURE-01-Firewall-Logs.png) |
| AZ-03 | Scheduled Splunk SEC-001 — Repeated Firewall Denied Connections | PASS — triggered alert observed | [EV-AZURE-02-SEC001-Triggered.png](./evidence/EV-AZURE-02-SEC001-Triggered.png) |
| AZ-04 | NSG private-network outbound control | PASS — Network Watcher IP flow verify returned Deny | [EV-AZURE-03-NSG-Deny.png](./evidence/EV-AZURE-03-NSG-Deny.png) |
| AZ-05 | Azure Firewall telemetry pipeline | PASS — Azure Firewall diagnostics → Event Hubs → Splunk `azure_security` | [EV-AZURE-01-Firewall-Logs.png](./evidence/EV-AZURE-01-Firewall-Logs.png) |

TCP 5432 was a temporary HTTP test listener, not a PostgreSQL database. The NSG IP flow verification evaluates security-group rules; it is not a substitute for a packet-traversal test.

## Published evidence and interpretation

All 15 screenshots are uploaded to [the evidence register](./evidence/README.md). They are retained pending image-by-image relevance and privacy review. The Azure Firewall, SEC-001, and NSG screenshots linked above use actual filenames. A screenshot alone does not establish comprehensive security control effectiveness.
