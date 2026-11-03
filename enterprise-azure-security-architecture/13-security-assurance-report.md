# 13 — Security Assurance Report

## Executive assessment

The Azure hybrid security architecture laboratory demonstrates a traceable sequence from security objectives and design choices to selected control validation and SIEM detection evidence. The assessment concerns a **laboratory case study**, not production certification or a comprehensive penetration test.

## Validated outcomes

| Area | Evidence-backed outcome | Assurance strength |
|---|---|---|
| Required hybrid communication | Three of three TCP/5432 connections to a local HTTP test listener succeeded | Strong for the selected TCP reachability test |
| Unauthorized test traffic | Denied TCP/4444 events appeared in Azure Firewall telemetry ingested into Splunk | Strong for observed deny-event logging |
| NSG policy enforcement | Network Watcher IP flow verification returned Deny after temporary test-rule removal | Strong for NSG rule decision; not end-to-end traversal |
| Security monitoring | Firewall events indexed in Splunk; SEC-001 scheduled alert triggered | Strong for observed pipeline and alert execution |
| Identity and storage safeguards | Event Hub-scoped receiver role; HTTPS/TLS 1.2 and no anonymous blob access recorded | Configuration evidence; not adversarial validation |

## Architecture decisions and trade-offs

- **WireGuard hybrid link:** Practical outbound-initiated connectivity under local CGNAT, requiring careful routing and policy boundaries.
- **Azure Firewall plus NSG:** Layered network controls with different enforcement scopes; NSG rule evaluation is not interchangeable with firewall event evidence.
- **Event Hubs to Splunk:** Decoupled cloud telemetry transport and SIEM analysis; a triggered alert demonstrates a working detection path at the observed time, not a measured incident response outcome.
- **Scoped Event Hub receiver identity:** Limits ingestion permissions to the relevant Event Hub rather than broader administrative access.

## Finding disposition

**AZ-F-01:** Temporary NSG test exception removed; subsequent rule verification returned Deny. No security compromise is alleged.

## Assurance conclusion

**Accepted for portfolio demonstration:** Selected hybrid network flows, firewall telemetry ingestion, scheduled detection, and the documented NSG decision check.

**Not claimed:** Enterprise-wide segmentation assurance, real database authentication, comprehensive attack-path testing, production resilience, or regulatory certification.

All 15 screenshots are present in the evidence folder and indexed by their actual filenames; content and privacy review remains pending.

## Traceability

[Requirements](01-business-security-requirements.md) · [Threat Model](11-stride-threat-model.md) · [Traffic Matrix](09-security-traffic-flow-matrix.md) · [Findings](08-security-assessment-findings.md) · [Traceability Matrix](10-requirements-traceability-matrix.md) · [Validation](07-security-validation-evidence.md) · [Evidence](evidence/README.md)
