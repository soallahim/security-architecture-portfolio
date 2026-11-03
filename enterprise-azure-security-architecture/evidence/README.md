# Security Validation Evidence

## Overview

This directory contains selected, sanitized screenshots supporting the Azure hybrid security architecture and Splunk Enterprise validation case study. Upload only reviewed screenshots. This is an evidence register, not a deployment guide.

## Evidence Index

| Evidence ID | Proposed screenshot filename | Observation | Related validation |
|---|---|---|---|
| EV-01 | `EV-01_azure_firewall_traffic_logs.png` | Azure Firewall allow/deny events received in Splunk | AZ-01, AZ-02, AZ-05 |
| EV-02 | `EV-02_splunk_sec001_triggered_alert.png` | Scheduled SEC-001 detection triggered | AZ-03 |
| EV-03 | `EV-03_nsg_private_outbound_deny.png` | Network Watcher IP flow verify returned Deny | AZ-04 |
| EV-04 | `EV-04_hybrid_routing_validation.png` | Hybrid route/association evidence, subject to screenshot review | Hybrid routing |
| EV-05 | `EV-05_splunk_eventhub_input.png` | Event Hub input configuration/initialization, subject to screenshot review | Telemetry integration |

The index reserves filenames; **images are not yet uploaded**. The original evidence set contains additional network and Splunk screenshots, which must be checked for relevance and duplication before publication.

## EV-01 — Azure Firewall Telemetry

**Observed:** Allowed test connections to TCP/5432 and denied test traffic to TCP/4444 were recorded in Azure Firewall telemetry ingested into Splunk. TCP/5432 was an HTTP test listener, not a database authentication test.

## EV-02 — SEC-001 Detection

**Observed:** The scheduled repeated-denied-connections alert triggered on 3 November 2026. Multiple alert executions do not establish multiple independent security incidents.

## EV-03 — NSG Restriction

**Observed:** Network Watcher IP flow verification returned a Deny decision under the private-network outbound restriction. This is an NSG rule evaluation, not an end-to-end packet capture.

## Publication controls

Before uploading, inspect every image for subscription IDs, tenant identifiers, tokens, credentials, sensitive usernames, and connection strings. Redact sensitive information, preserve the relevant evidence, and ensure filenames match the index. Do not publish raw logs or deployment scripts.

## Related documentation

- [Security Validation and Evidence](../07-security-validation-evidence.md)
- [Implemented Security Controls](../06-implemented-security-controls.md)
- [Architecture Decisions](../04-architecture-decision-records.md)

*Independent educational security architecture laboratory.*
