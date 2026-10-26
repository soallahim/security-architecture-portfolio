# Enterprise Azure Security Architecture & Monitoring

**Status: Planning / Proposed — no Azure resources deployed or security tests executed.**

## Project overview

This project will design, implement, and validate a small hybrid enterprise security architecture using Microsoft Azure, a local OPNsense lab, WireGuard, and Splunk Enterprise. The focus is on defensible architecture decisions, controlled traffic flows, observable security controls, and evidence-based assurance—not a product installation walkthrough.

## Business problem

A fictional organization needs to isolate application and database workloads, control administrator access from an on-premises environment, and centrally review security-relevant network events. Uncontrolled lateral movement, exposed management services, and incomplete monitoring create avoidable risks.

## Proposed scope

- Separate Azure application, database, VPN, and firewall subnets.
- Evaluate Azure Firewall Basic network rules, UDRs, NSGs, and routing symmetry.
- Establish a client-initiated WireGuard tunnel from a local environment behind CGNAT.
- Forward selected Azure security logs for analysis in a local Splunk Enterprise instance, subject to connector and cost feasibility.
- Validate allowed and denied flows with test records, effective routes, firewall logs, and documented limitations.

## Architecture status

All network ranges, components, and policies are **proposed** and subject to pre-deployment verification. The initial concept uses Azure UAE North, three small Linux VMs (application, database, and WireGuard), Azure Firewall Basic, and a local OPNsense/Splunk lab. A diagram alone does not demonstrate that a traffic path is enforced.

## Delivery stages

1. Business and security requirements, acceptance criteria, and scope.
2. Asset inventory, trust boundaries, threats, risks, and architecture decisions.
3. Detailed network design, policy and routing matrices, and cost safeguards.
4. Local lab preparation and deployment automation reviewed without activating Azure.
5. Azure deployment and controlled validation **only after a separate readiness decision**.
6. Evidence-backed test results, assurance report, residual risks, and portfolio review.

## Validation principles

Test results will be labeled **Pass**, **Fail**, **Partial**, or **Not Tested**. A connection failure alone will not be treated as proof of firewall enforcement. Logs, screenshots, and outcomes will only be published if actually observed. Proposed architecture will remain clearly separate from implemented controls.

## Cost and readiness

The initial Azure Pricing Calculator estimate was approximately **USD 32.44** for a mixed-duration configuration (including 24-hour compute/firewall usage and monthly disk/monitoring estimates). It is **not** a final or complete deployment cost. Azure free-trial activation is intentionally deferred until documentation, local preparation, scripts, and a pre-deployment review are complete.

## Next deliverable

Define traceable business/security requirements and measurable acceptance criteria in `01-business-security-requirements.md` before building the lab or activating Azure.

---

*Fictional enterprise scenario. This README describes planned work, not verified deployment or test outcomes.*
