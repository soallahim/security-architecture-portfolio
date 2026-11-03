# Implemented security architecture

## Hybrid connectivity and network controls

- Azure virtual network: `10.50.0.0/16`.
- Azure application workload: `10.50.10.4`.
- Azure Firewall private IP: `10.50.0.4`.
- WireGuard provides connectivity between the Azure laboratory and local network segments.
- Azure Firewall Policy, UDRs, and NSG controls govern tested traffic paths.
- Authorized APP-to-local test listener traffic to TCP 5432 succeeded in 3/3 recorded tests.
- Denied TCP 4444 events were visible in the central logging pipeline.
- Temporary test NSG rule was removed; IP flow verify confirmed the named deny rule.

## Logging and detection

Azure Firewall diagnostic categories enabled: `AZFWNetworkRule`, `AZFWApplicationRule`, `AZFWNatRule`, and `AZFWThreatIntel`.

The pipeline sends firewall telemetry to Azure Event Hubs, consumed through the Splunk Add-on for Microsoft Cloud Services, with events indexed in `azure_security`.

The scheduled Splunk alert `SEC-001 — Repeated Firewall Denied Connections` triggered during validation on 3 November 2026.

## Identity and transport controls

- Splunk's dedicated Entra service principal was granted `Azure Event Hubs Data Receiver` at the specific Event Hub scope.
- Checkpoint storage enforces HTTPS and TLS 1.2; anonymous public blob access is disabled.

## Engineering note

These statements reflect observed laboratory behavior and configuration reviews. Infrastructure templates, operational scripts, and manual deployment actions were used at different stages; the project does not claim complete automated reconstruction from Bicep alone.
