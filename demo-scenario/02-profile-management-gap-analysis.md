# Profile Management — Gap Analysis & Requirements

## Source Document
- **Project Brief**: `01-project-brief.md` — Sarah Mitchell, VP of Digital Banking, March 2026
- **Original Requirement**: *"7. Profile Management — Customers can update their contact info and preferences."*

## ADO Wiki Context

> **Note**: The ADO Wiki pages under `/Requirements-Context/` in project `Contoso-SelfService-Portal` were unreachable during this analysis (network firewall restriction). The following context was reconstructed from the repository's architecture documentation and domain rules specified in the codebase conventions.

| Wiki Page | Applied Context |
|---|---|
| **Domain Glossary** | Step-up MFA, Core Banking API (T24), KYC, BSA, SOX, JWT, PII, OTP, Available Balance, Ledger Balance |
| **Architecture Context** | React 18 + TypeScript/Vite (frontend), .NET 8 Web API (backend), JWT auth on all endpoints (except login/register), Core Banking API integration (REST + mTLS, 100 req/sec, 200-800ms), RFC 7807 error responses |
| **Requirements Standards** | User stories in "As a [role]…" format, Given/When/Then AC, Fibonacci story points |
| **Definition of Ready** | AC written, dependencies identified, security reviewed, ≤13 SP |
| **Acceptance Criteria Guide** | Specific values (never "appropriate"), happy path + error case minimum, Given/When/Then |

---

## Gap Analysis

The project brief provides **one sentence** for what is a compliance-heavy, security-critical feature in a regulated banking environment. Below are all identified gaps.

### CRITICAL Gaps (5)

| # | Area | Gap | Industry Default Applied |
|---|---|---|---|
| G-01 | **Security** | No step-up authentication for profile changes. Contact info changes are the #1 vector for account takeover. | Step-up MFA required for email, phone, mailing address, and security settings per NIST SP 800-63B §6.1.2.3. Display name changes do not require MFA. |
| G-02 | **Compliance** | No KYC/BSA re-verification triggers. Address and name changes may require re-verification under Bank Secrecy Act. | Name changes require document upload + manual review. Interstate address changes trigger enhanced due diligence. All changes logged per BSA. |
| G-03 | **Compliance** | No SOX-compliant audit trail. SOX requires immutable audit logs with 7-year retention. | All profile changes are SOX-auditable. Append-only audit log, 7-year retention, includes before/after values, timestamp, IP, device, user ID. Fail-closed: changes blocked if audit unavailable. |
| G-04 | **Data/Privacy** | No specification of which fields are editable vs. restricted. | Self-service editable: email, phone, mailing address, display name, communication preferences, security settings. NOT self-service: legal name (requires doc upload + review), SSN, DOB, account numbers. |
| G-05 | **Security** | No verification process for new contact information. | New email requires confirmation link (24h expiry). New phone requires SMS OTP (10min expiry). Old contact method receives change notification. 72-hour cool-down before new contact info used for account recovery. |

### HIGH Gaps (5)

| # | Area | Gap | Industry Default Applied |
|---|---|---|---|
| G-06 | **Compliance** | No communication consent management. CAN-SPAM, TCPA, and E-SIGN Act require explicit opt-in/opt-out. | Granular consent per channel (email, SMS, push, in-app) and per type (transactional, marketing, security alerts). Security alerts cannot be opted out. TCPA-compliant SMS consent with explicit opt-in. |
| G-07 | **Security** | No security settings management (password, MFA, devices, sessions). | Password change (requires current password + MFA, NIST SP 800-63B rules), MFA enrollment (TOTP, SMS, email), trusted device management, active session viewing and remote termination. |
| G-08 | **Error Handling** | No rate limiting on profile changes. | Max 5 email change requests per hour. Max 3 phone change requests per 24 hours. Max 10 total profile changes per 24 hours. RFC 7807 responses with Retry-After header. |
| G-09 | **Security** | No rollback capability for unauthorized changes. | Customer support rollback within 90 days. Automated rollback via notification link (72h expiry) sent to OLD contact info. Account lock on rollback. |
| G-10 | **UX/Accessibility** | No WCAG 2.1 AA or responsive design requirements. | WCAG 2.1 AA compliance. Breakpoints: mobile (320-767px), tablet (768-1023px), desktop (1024px+). Full keyboard navigation. Screen reader compatible with ARIA labels. |

### MEDIUM Gaps (6)

| # | Area | Gap | Industry Default Applied |
|---|---|---|---|
| G-11 | **Edge Cases** | No notification preference details. | Account alerts, security alerts, marketing, product offers, statements. Channels: email, SMS, push, in-app. Security alerts always on. Quiet hours configurable. |
| G-12 | **Performance** | No latency targets. | Profile load ≤ 2 seconds. Profile save ≤ 3 seconds. Verification code delivery ≤ 30 seconds. |
| G-13 | **Edge Cases** | No address validation. | USPS Address Validation API for US addresses. Suggest corrections. Allow override with confirmation. |
| G-14 | **Data/Privacy** | No data access rights. | Profile page serves as primary data access/correction mechanism. Export profile data as JSON/PDF. |
| G-15 | **Integration** | No core banking API sync strategy. | Synchronous write to core banking API. Queue on failure. Retry 3x with exponential backoff. |
| G-16 | **Edge Cases** | No authorized users / POA support. | Deferred to Phase 2. Phase 1: only primary account holder can modify profile. |

### LOW Gaps (2)

| # | Area | Gap | Industry Default Applied |
|---|---|---|---|
| G-17 | **UX** | No confirmation flow for changes. | Preview changes before save. Success confirmation with change summary. |
| G-18 | **Edge Cases** | No international address/phone support. | Phase 1: US-only (E.164 phone, USPS address validation). International deferred. |

---

## Gap Resolution Summary

| Severity | Count | Resolution |
|---|---|---|
| CRITICAL (G-01 to G-05) | 5 | ✅ Resolved with industry defaults |
| HIGH (G-06 to G-10) | 5 | ✅ Resolved with industry defaults |
| MEDIUM (G-11 to G-16) | 6 | ✅ Resolved; G-16 (authorized users) deferred to Phase 2 |
| LOW (G-17, G-18) | 2 | ✅ Resolved; G-18 (international) deferred |

### Items Requiring Stakeholder Validation ⚠️
1. **VoIP Number Policy** (PBI 1.2): Should VoIP/virtual numbers be rejected for phone changes?
2. **Address Override Policy** (PBI 1.3): Can customers override USPS validation failures?

---

## Work Item Hierarchy — Profile Management Epic

### Summary

| Metric | Value |
|---|---|
| **Epic** | 1 — Profile Management |
| **Features** | 5 |
| **Product Backlog Items** | 16 |
| **Total Raw Story Points** | 95 |
| **Compliance Frameworks** | SOX, BSA/KYC, CAN-SPAM, TCPA, E-SIGN Act, NIST SP 800-63B |

### Epic: Profile Management
- **Priority**: 2
- **Tags**: Profile, Phase-1, Q3-2026, Compliance, Security

### Feature 1: Contact Information Management (29 SP)

| PBI | Title | SP | Priority |
|---|---|---|---|
| 1.1 | Email Address Change with Verification | 8 | 1 |
| 1.2 | Phone Number Change with SMS OTP Verification | 8 | 1 |
| 1.3 | Mailing Address Change with USPS Validation | 8 | 1 |
| 1.4 | Profile View — Contact Information Display | 5 | 1 |

### Feature 2: Communication Preferences & Consent Management (13 SP)

| PBI | Title | SP | Priority |
|---|---|---|---|
| 2.1 | Notification Preference Management | 5 | 2 |
| 2.2 | SMS & Marketing Consent Management (TCPA/CAN-SPAM) | 5 | 1 |
| 2.3 | E-SIGN Act Electronic Delivery Consent | 3 | 2 |

### Feature 3: Security Settings Management (23 SP)

| PBI | Title | SP | Priority |
|---|---|---|---|
| 3.1 | Password Change | 5 | 1 |
| 3.2 | MFA Enrollment & Management | 8 | 1 |
| 3.3 | Trusted Device Management | 5 | 2 |
| 3.4 | Active Session Management | 5 | 2 |

### Feature 4: Profile Audit & Compliance (18 SP)

| PBI | Title | SP | Priority |
|---|---|---|---|
| 4.1 | Profile Change History — Customer-Facing Audit View | 5 | 2 |
| 4.2 | SOX-Compliant Audit Logging for Profile Changes | 8 | 1 |
| 4.3 | Unauthorized Profile Change Rollback | 5 | 2 |

### Feature 5: Profile Accessibility & Responsive Design (10 SP)

| PBI | Title | SP | Priority |
|---|---|---|---|
| 5.1 | WCAG 2.1 AA Compliance for Profile Pages | 5 | 1 |
| 5.2 | Responsive Design for Profile Management | 5 | 1 |

---

## Effort Estimation

### Sprint-by-Sprint Roadmap (32 SP/sprint velocity)

| Sprint | Focus | PBIs | SP |
|---|---|---|---|
| **Sprint 1** | Foundation + Audit Infrastructure | 4.2 (SOX Audit), 1.4 (Profile View), 5.2 (Responsive) | ~34 |
| **Sprint 2** | Core Contact Changes + Password | 1.1 (Email), 3.1 (Password), 2.3 (E-SIGN) | ~32 |
| **Sprint 3** | Phone + MFA + Consent | 1.2 (Phone), 3.2 (MFA), 2.2 (TCPA Consent) | ~34 |
| **Sprint 4** | Address + Sessions + Accessibility | 1.3 (Address/USPS), 3.3 (Devices), 3.4 (Sessions), 5.1 (WCAG) | ~36 |
| **Sprint 5** | Rollback + History + Polish | 4.3 (Rollback), 4.1 (Change History), 2.1 (Notification Prefs) | ~30 |

### Three-Point Estimate

| Scenario | Sprints | Calendar Weeks | Confidence |
|---|---|---|---|
| Optimistic | 4 | 8 weeks | 15% |
| **Likely** | **5** | **10 weeks** | **70%** |
| Pessimistic | 7 | 14 weeks | 95% |

**Recommended start**: Mid-July 2026 to meet Q3 target.
