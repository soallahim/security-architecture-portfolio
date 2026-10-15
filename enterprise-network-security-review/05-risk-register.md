
# Security Risk Assessment & Risk Register

## 1. Purpose

This document evaluates the security risks identified during the fictional Enterprise X security architecture assessment.

The objective is to prioritize security improvements based on the likelihood of adverse events and their potential business impact.

## 2. Risk Assessment Methodology

A simplified qualitative 5x5 risk matrix is used for this case study.

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

These scoring thresholds are defined for this fictional case study and are not presented as an official NIST risk matrix.

## 3. Risk Register

| Risk ID | Finding | Likelihood | Impact | Score | Level |
|---|---|---:|---:|---:|---|
| R-01 | Excessive vendor database access | 4 | 5 | 20 | Critical |
| R-02 | Direct corporate database access | 3 | 5 | 15 | High |
| R-03 | Unrestricted management network access | 4 | 4 | 16 | High |
| R-04 | Vendor RDP security controls unverified | TBD | TBD | TBD | Pending |

## 4. Risk Justification

### R-01: Excessive Vendor Database Access

**Likelihood: 4 — Likely (Assumed)**

Vendor VPN connectivity provides a broad path to database systems. The assumed absence of network restrictions increases potential exposure if vendor credentials or endpoints are compromised.

**Impact: 5 — Severe (Assumed)**

Unauthorized database access could affect sensitive business information, data integrity, and critical operations.

**Treatment:** Mitigate

**Priority:** Immediate architecture remediation.

### R-02: Direct Corporate Database Access

**Likelihood: 3 — Possible (Assumed)**

Corporate endpoints can communicate directly with database services. A compromised endpoint could attempt to exploit that access path, although database-level controls may reduce exposure.

**Impact: 5 — Severe (Assumed)**

Compromise of critical databases could lead to significant confidentiality, integrity, or availability impacts.

**Treatment:** Mitigate

**Priority:** High.

### R-03: Unrestricted Management Network Access

**Likelihood: 4 — Likely (Assumed)**

Broad connectivity from corporate systems to management infrastructure increases potential lateral movement opportunities.

**Impact: 4 — Major (Assumed)**

Compromised management systems could allow unauthorized configuration changes or disruption of enterprise services.

**Treatment:** Mitigate

**Priority:** High.

### R-04: Vendor RDP Security Controls Unverified

**Assessment Status:** Pending

RDP access is documented, but information about MFA, authorization, endpoint restrictions, and session monitoring is unavailable.

A formal risk score will be assigned only after these controls are assessed.

**Treatment:** Further assessment required.

## 5. Risk Treatment Strategy

Recommended risk treatment measures include:

- Restricting unauthorized inter-zone communication.
- Applying least-privilege firewall rules.
- Introducing controlled privileged access paths.
- Enforcing MFA and time-bound third-party access.
- Improving security logging and monitoring.
- Validating access restrictions through documented testing.

## 6. Assessment Limitations

- The environment and all risk scenarios are fictional.
- Likelihood and impact values are illustrative assumptions.
- No production configurations, vulnerabilities, or threat intelligence were assessed.
- Risk scores must not be interpreted as measured probabilities.
- Residual risk will be assessed after the proposed controls and validation evidence are defined.

## 7. Next Step

Develop the proposed secure network architecture and map each design improvement to the documented findings and risks.
