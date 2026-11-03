# 12 — Attack Path Analysis

## Purpose

Examine plausible ways an adversary could cross the hybrid trust boundary or degrade security visibility. The paths below are **analytical scenarios**; no compromise or exploitation is claimed.

## AP-01 — Unauthorized Azure-to-local service access

**Entry point:** Azure application workload or a compromised process on that workload.

**Potential path:** Attempt to reach an unapproved local service through hybrid routing.

**Security boundaries:** Azure workload subnet → network routing/firewall enforcement → WireGuard transport → local destination.

**Control assessment:** The TCP/4444 test generated denied events visible in Splunk. The positive TCP/5432 test reached only the intended HTTP listener. These outcomes support selected policy enforcement but do not demonstrate comprehensive segmentation across all ports and hosts.

**References:** TF-01, TF-02; AZ-01, AZ-02; [Firewall logs](./evidence/EV-AZURE-01-Firewall-Logs.png).

## AP-02 — Risk of retaining temporary network exceptions

**Entry point:** A permissive test-time NSG exception.

**Potential path:** Continued access that conflicts with the intended private-network outbound restriction.

**Control assessment:** The temporary rule was removed and Network Watcher IP flow verification subsequently returned Deny under `Deny-Private-Networks-Outbound`. This is an NSG decision check, not an exhaustive traversal assessment.

**References:** AZ-F-01; AZ-04; [NSG decision](./evidence/EV-AZURE-03-NSG-Deny.png).

## AP-03 — Loss of firewall telemetry visibility

**Entry point:** Disruption or misconfiguration of diagnostic event delivery or ingestion.

**Potential path:** Firewall events fail to reach the SIEM, reducing detection coverage.

**Control assessment:** Azure Firewall events were observed in Splunk and SEC-001 triggered. This confirms the tested pipeline at that time; continuous availability and failover were not stress-tested.

**References:** TF-03, TF-04; AZ-03, AZ-05; [Firewall logs](./evidence/EV-AZURE-01-Firewall-Logs.png), [SEC-001](./evidence/EV-AZURE-02-SEC001-Triggered.png).

## Architectural conclusion

The demonstrated strength is the combination of **network policy enforcement and independently searchable detection telemetry**. Validation supports the tested paths and observations only; it is not a claim that every possible attack path is blocked.

[Threat Model](11-stride-threat-model.md) · [Findings](08-security-assessment-findings.md) · [Evidence](evidence/README.md)
