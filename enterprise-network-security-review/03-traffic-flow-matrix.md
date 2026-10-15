
# Traffic Flow Matrix

## 1. Overview

This document defines the assumed network communication flows in Enterprise X's fictional environment.

The purpose is to assess whether existing access rules align with business requirements, least privilege, and network segmentation principles.

## 2. Current Traffic Flows

| ID | Source | Destination | Protocol / Port | Current Action |
|---|---|---|---|---|
| TF-01 | Corporate | Application | TCP/443 | Allow |
| TF-02 | Corporate | Database | TCP/1433 | Allow |
| TF-03 | Vendor VPN | Management | TCP/3389 | Allow |
| TF-04 | Vendor VPN | Database | Any | Allow |
| TF-05 | Application | Database | TCP/1433 | Allow |
| TF-06 | Internet | DMZ | TCP/443 | Allow |
| TF-07 | Corporate | Management | Any | Allow |

## 3. Preliminary Review

| Flow ID | Observation | Assessment |
|---|---|---|
| TF-01 | Corporate access to business applications over HTTPS | Requires application-level access validation |
| TF-02 | Direct corporate access to the database | Potential segmentation weakness |
| TF-03 | Vendor RDP access to management systems | Requires identity, MFA, and session controls |
| TF-04 | Unrestricted vendor access to the database | Excessive access privileges |
| TF-05 | Application-to-database communication | Potentially justified business flow |
| TF-06 | Internet access to DMZ services over HTTPS | Requires exposure and application security review |
| TF-07 | Unrestricted corporate access to management systems | Excessive administrative network exposure |

## 4. Assessment Notes

- All flows are fictional and defined for this case study.
- An allowed flow does not automatically indicate a security vulnerability.
- Final findings will consider business justification, access restrictions, and compensating controls.
- The proposed architecture will define approved communication paths and default-deny enforcement.

## 5. Next Step

Perform a structured security assessment and document findings with supporting evidence and risk ratings.
