# Security Validation Evidence

## Overview

This directory retains **all 15 uploaded screenshots** for joint review. No image has been removed or renamed. Filenames below match the files currently in GitHub. The descriptions identify the screenshot's intended subject from its filename and the recorded lab results; they do not certify that every image has passed a sensitive-data or visual-content review.

## Evidence Index

| Evidence ID | Screenshot | Subject / intended supporting role | Review status |
|---|---|---|---|
| EV-01 | [EV-AZURE-01-Firewall-Logs.png](./EV-AZURE-01-Firewall-Logs.png) | Azure Firewall and detection: EV AZURE 01 Firewall Logs.png | Retained; owner privacy-reviewed; relevance assessment pending |
| EV-02 | [EV-AZURE-02-SEC001-Triggered.png](./EV-AZURE-02-SEC001-Triggered.png) | Azure Firewall and detection: EV AZURE 02 SEC001 Triggered.png | Retained; visual/privacy review pending |
| EV-03 | [EV-AZURE-03-NSG-Deny.png](./EV-AZURE-03-NSG-Deny.png) | Azure Firewall and detection: EV AZURE 03 NSG Deny.png | Retained; visual/privacy review pending |
| EV-04 | [EV-NETWORK-01-OPNsense-Static-Route.png](./EV-NETWORK-01-OPNsense-Static-Route.png) | Hybrid routing and network controls: EV NETWORK 01 OPNsense Static Route.png | Retained; visual/privacy review pending |
| EV-05 | [EV-NETWORK-02-OPNsense-Kali-to-DB-Rule.png](./EV-NETWORK-02-OPNsense-Kali-to-DB-Rule.png) | Hybrid routing and network controls: EV NETWORK 02 OPNsense Kali to DB Rule.png | Retained; visual/privacy review pending |
| EV-06 | [EV-NETWORK-03-UDR-Associations-Verified.png](./EV-NETWORK-03-UDR-Associations-Verified.png) | Hybrid routing and network controls: EV NETWORK 03 UDR Associations Verified.png | Retained; visual/privacy review pending |
| EV-07 | [EV-NETWORK-04-AZURE-APP-Effective-Routes.png](./EV-NETWORK-04-AZURE-APP-Effective-Routes.png) | Hybrid routing and network controls: EV NETWORK 04 AZURE APP Effective Routes.png | Retained; visual/privacy review pending |
| EV-08 | [EV-NETWORK-05-WIREGUARD-RouteTable-Association.png](./EV-NETWORK-05-WIREGUARD-RouteTable-Association.png) | Hybrid routing and network controls: EV NETWORK 05 WIREGUARD RouteTable Association.png | Retained; visual/privacy review pending |
| EV-09 | [EV-MGMT-01-Unauthorized-HTTPS-Blocked.png](./EV-MGMT-01-Unauthorized-HTTPS-Blocked.png) | Management access: EV MGMT 01 Unauthorized HTTPS Blocked.png | Retained; visual/privacy review pending |
| EV-10 | [EV-SPLUNK-01-Index-Write-Read.png](./EV-SPLUNK-01-Index-Write-Read.png) | Splunk monitoring and integration: EV SPLUNK 01 Index Write Read.png | Retained; visual/privacy review pending |
| EV-11 | [EV-SPLUNK-02-OPNsense-Syslog-Received.png](./EV-SPLUNK-02-OPNsense-Syslog-Received.png) | Splunk monitoring and integration: EV SPLUNK 02 OPNsense Syslog Received.png | Retained; visual/privacy review pending |
| EV-12 | [EV-SPLUNK-03-Firewall-Logs-Ingested.png](./EV-SPLUNK-03-Firewall-Logs-Ingested.png) | Splunk monitoring and integration: EV SPLUNK 03 Firewall Logs Ingested.png | Retained; visual/privacy review pending |
| EV-13 | [EV-SPLUNK-04-Unauthorized-Management-Blocked.png](./EV-SPLUNK-04-Unauthorized-Management-Blocked.png) | Splunk monitoring and integration: EV SPLUNK 04 Unauthorized Management Blocked.png | Retained; visual/privacy review pending |
| EV-14 | [EV-SPLUNK-05-Syslog-After-WiFi-Block.png](./EV-SPLUNK-05-Syslog-After-WiFi-Block.png) | Splunk monitoring and integration: EV SPLUNK 05 Syslog After WiFi Block.png | Retained; visual/privacy review pending |
| EV-15 | [EV-SPLUNK-06-eventhub-input-initialization.png](./EV-SPLUNK-06-eventhub-input-initialization.png) | Splunk monitoring and integration: EV SPLUNK 06 eventhub input initialization.png | Retained; visual/privacy review pending |

## Evidence interpretation

**Azure Firewall logs:** The recorded lab showed three successful TCP/5432 connections to a temporary HTTP test listener and denied TCP/4444 events in Splunk. This is not proof of database authentication.

**SEC-001:** The scheduled Splunk alert triggered on 3 November 2026; repeated executions should not be described as separate security incidents.

**NSG verification:** Network Watcher returned a Deny decision after removal of a temporary test rule; this is a rule-evaluation result, not a packet capture.

**OPNsense and local Splunk images:** These may document supporting hybrid-lab behavior, but should not be conflated with the separate Enterprise Network Segmentation project's validation scenarios without a specific cross-reference.

## Publication review

The screenshots are already present in this public repository. The repository owner has confirmed that the images have been reviewed for sensitive information. The evidence register does not independently certify each image's evidentiary relevance, nor does it modify or redact any image.

## Related documentation

- [Security Validation Evidence](../07-security-validation-evidence.md)
- [Security Assessment Findings](../08-security-assessment-findings.md)
- [Requirements Traceability](../10-requirements-traceability-matrix.md)
- [Security Assurance](../13-security-assurance-report.md)
