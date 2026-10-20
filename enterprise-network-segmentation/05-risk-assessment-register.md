# Security Risk Assessment & Risk Register

## 1. Purpose

This document evaluates and prioritizes security risks associated with the fictional Enterprise X network architecture and the practical OPNsense network segmentation laboratory.

The assessment distinguishes between:

- **Scenario-Based Risks:** Hypothetical risks identified through the fictional enterprise architecture review.
- **Observed Lab Risk:** A security configuration issue identified and remediated during practical firewall validation.

The objective is to demonstrate a structured approach to risk identification, evaluation, treatment, and validation.

## 2. Risk Assessment Methodology

A simplified qualitative 5×5 risk matrix is used.

**Risk Score = Likelihood × Impact**

### Likelihood Scale

| Rating | Description |
|---|---|
| 1 | Rare |
| 2 | Unlikely |
| 3 | Possible |
| 4 | Likely |
| 5 | Almost Certain |

### Impact Scale

| Rating | Description |
|---|---|
| 1 | Negligible |
| 2 | Minor |
| 3 | Moderate |
| 4 | Major |
| 5 | Severe |

### Risk Classification

| Score | Risk Level |
|---|---|
| 1–5 | Low |
| 6–11 | Medium |
| 12–19 | High |
| 20–25 | Critical |

These scales and thresholds are defined for this educational case study. They are not official NIST risk-scoring thresholds.

### Risk Terminology

**Inherent Risk:** The estimated risk before applying the proposed or corrective security controls.

**Residual Risk:** The estimated risk remaining after security controls have been implemented and their effectiveness considered.

All numerical ratings are illustrative judgments rather than measured probabilities.

## 3. Risk Register

| Risk ID | Related Finding | Risk Description | Type | Inherent Score | Treatment Status |
|---|---|---|---|---|---|
| R-01 | F-01 | Excessive third-party database access | Hypothetical | 20 — Critical | Proposed |
| R-02 | F-02 | Direct corporate access to database systems | Hypothetical | 15 — High | Proposed |
| R-03 | F-03 | Unrestricted corporate access to management systems | Hypothetical | 16 — High | Proposed |
| R-04 | F-04 | Vendor RDP controls not verified | Hypothetical | Not Rated | Further Assessment |
| R-05 | LAB-F-01 | Unintended application access to OPNsense management interface | Observed in Lab | 12 — High | Remediated and Validated |

## 4. Risk Evaluation and Justification

### R-01: Excessive Third-Party Database Access

**Likelihood:** 4 — Likely (Assumed)  
**Impact:** 5 — Severe (Assumed)  
**Inherent Risk:** 20 — Critical

**Risk Scenario:**

The fictional enterprise baseline permits unrestricted vendor VPN connectivity to database systems.

A compromised vendor account or endpoint could provide an unauthorized access path to sensitive data.

**Recommended Treatment:**

- Deny direct vendor-to-database connectivity by default.
- Restrict third-party access to approved destinations and services.
- Enforce MFA and time-bound authorization.
- Introduce controlled privileged-access mechanisms.
- Log and monitor third-party access.

**Status:** Proposed — Not Implemented in Lab

### R-02: Direct Corporate Database Access

**Likelihood:** 3 — Possible (Assumed)  
**Impact:** 5 — Severe (Assumed)  
**Inherent Risk:** 15 — High

**Risk Scenario:**

Corporate endpoints in the fictional baseline can communicate directly with database services.

A compromised workstation could attempt unauthorized database access.

**Recommended Treatment:**

- Permit database connectivity only from approved application systems.
- Deny general corporate-to-database access.
- Apply database authentication and authorization controls.
- Monitor unauthorized access attempts.

**Status:** Proposed — Not Implemented in Lab

### R-03: Unrestricted Corporate-to-Management Access

**Likelihood:** 4 — Likely (Assumed)  
**Impact:** 4 — Major (Assumed)  
**Inherent Risk:** 16 — High

**Risk Scenario:**

The fictional enterprise baseline allows broad corporate network access to administrative systems.

This increases the potential for unauthorized administrative access and lateral movement.

**Recommended Treatment:**

- Separate administrative systems into a dedicated management zone.
- Restrict access to approved administrative workstations.
- Apply MFA and privileged-access controls.
- Monitor administrative access attempts.

**Status:** Proposed — Management Isolation Principle Demonstrated in Lab

The laboratory demonstrates management access restrictions for selected endpoints, but it does not validate the fictional corporate environment.

### R-04: Vendor RDP Controls Not Verified

**Likelihood:** Not Assessed  
**Impact:** Not Assessed  
**Risk Score:** Pending

**Risk Scenario:**

The fictional enterprise baseline includes vendor RDP access, but the availability of MFA, session monitoring, endpoint restrictions, and time-bound access controls is unknown.

The presence of RDP alone is insufficient to assign a defensible risk rating.

**Recommended Treatment:**

- Verify authentication and authorization controls.
- Review vendor access restrictions.
- Validate session logging and monitoring.
- Assess privileged-access controls.
- Assign a risk score once supporting information is available.

**Status:** Further Assessment Required

### R-05: Unintended Management Interface Access

**Related Finding:** LAB-F-01  
**Affected Component:** OPNsense Firewall  
**Source:** APP-SERVER — 192.168.10.10  
**Destination:** OPNsense Management Interface — 192.168.30.1  
**Protocol:** TCP/443

**Likelihood:** 3 — Possible (Illustrative)  
**Impact:** 4 — Major (Illustrative)  
**Inherent Risk:** 12 — High

**Risk Scenario:**

During practical validation, APP-SERVER was able to establish a TCP connection to the OPNsense management interface despite the intended management isolation policy.

Firewall logs identified the built-in anti-lockout rule as the permitting rule.

This increased the administrative interface's network exposure.

The observation demonstrated network reachability, not successful authentication or administrative compromise.

**Risk Treatment Implemented:**

1. Verified that the Kali Linux management workstation could access OPNsense.
2. Disabled the administration anti-lockout rule.
3. Retained authorized management access through an explicit firewall rule.
4. Repeated the APP-to-management TCP/443 test.
5. Confirmed the unauthorized connection was blocked through firewall log inspection.

**Status:** Remediated and Validated in Lab

## 5. Residual Risk Assessment

Residual risk is assessed only where corrective controls were actually implemented and tested.

| Risk ID | Inherent Risk | Residual Risk | Basis |
|---|---|---|---|
| R-01 | Critical (20) | Not Assessed | Hypothetical enterprise risk |
| R-02 | High (15) | Not Assessed | Hypothetical enterprise risk |
| R-03 | High (16) | Not Assessed | Corporate environment not deployed |
| R-04 | Not Rated | Not Assessed | Insufficient information |
| R-05 | High (12) | Low (Illustrative) | Tested APP-to-management path blocked after remediation |

**Residual Risk Considerations for R-05:**

The tested unauthorized network path was successfully blocked.

However, this does not prove that every potential management access path is restricted or that the management interface is protected against all threats.

The residual rating is a qualitative laboratory estimate, not a formal production risk acceptance decision.

## 6. Risk Treatment Strategy

The project demonstrates the following risk treatment practices:

- **Avoid unnecessary exposure:** Remove unintended access paths.
- **Mitigate identified risks:** Apply restrictive firewall policies.
- **Apply least privilege:** Authorize only required network communication.
- **Validate controls:** Confirm firewall behavior through repeatable connectivity tests.
- **Review evidence:** Use firewall logs to identify rule matches and confirm remediation.
- **Document residual limitations:** Avoid treating limited testing as comprehensive security assurance.

## 7. Traceability Matrix

| Risk | Security Control | Validation |
|---|---|---|
| R-01 | Controlled third-party database access | Not Implemented |
| R-02 | Restricted database access | APP-to-DB least-privilege principle demonstrated |
| R-03 | Dedicated management access restrictions | Selected management access tests completed |
| R-04 | MFA and controlled remote access | Not Implemented |
| R-05 | Removal of unintended management access | APP-to-MGMT blocked; Kali management access preserved |

## 8. Assessment Limitations

- Enterprise X is fictional.
- Scenario-based risk scores are illustrative assumptions.
- The practical laboratory covers selected network segmentation controls only.
- The observed management exposure was caused by firewall rule behavior, not a confirmed software vulnerability.
- No production environment, business impact assessment, or formal risk acceptance process was involved.
- Residual risk ratings are limited by the scope of the completed tests.
- The laboratory does not demonstrate MFA, VPN, vendor access, or database-level authorization controls.

## 9. Conclusion

The risk assessment demonstrates how security architecture findings can be translated into prioritized security improvements.

The practical laboratory further demonstrates that risk treatment should be followed by control validation.

The most significant observed result was the identification and remediation of unintended management interface exposure caused by an OPNsense anti-lockout rule.

This finding illustrates the value of validating actual security enforcement rather than relying exclusively on firewall configuration reviews.

## 10. Related Documentation

- `01-business-security-requirements.md`
- `03-traffic-flow-matrix.md`
- `04-security-assessment-findings.md`
- `06-proposed-secure-architecture.md`
- `08-security-validation-plan.md`
