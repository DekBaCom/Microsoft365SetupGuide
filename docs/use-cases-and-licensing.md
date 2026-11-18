---
title: Use Cases & License Mapping
layout: default
nav_order: 12
has_children: false
permalink: /docs/use-cases
description: Group Microsoft 365 solutions by business use case and map them to the right license tier — Business Basic / Standard / Premium, E3, E5, F1/F3 (frontline), A1/A3/A5 (education), Nonprofit, and Government.
---

# Use Cases & License Mapping
{: .no_toc }

Pick the right **Microsoft 365 license** for your business size and use case — then jump straight to the sections of this guide that apply to you.
{: .fs-6 .fw-300 }

> **ภาษาไทย:** จับคู่ **Use Case** ของธุรกิจเข้ากับ **Microsoft 365 License** ที่เหมาะสม แล้วไปอ่านเฉพาะส่วนในคู่มือที่คุณต้องใช้งาน ไม่ต้องอ่านทั้งหมดในครั้งเดียว

---

## Table of Contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## 1. Pick Your Business Profile

Find the row that matches your organization — the **Recommended license** column is a starting point, not a hard rule.

| Business Profile | Headcount | Compliance Need | Recommended License | Notes |
|------------------|----------:|-----------------|---------------------|-------|
| **Startup / SMB — productivity only** | 1–25 | Low | **Business Basic** | Web/mobile Office + email + Teams. No desktop Office apps. |
| **Startup / SMB — full office suite** | 1–300 | Low | **Business Standard** | Adds desktop Office + webinars + Clipchamp. |
| **SMB — security-focused** | 1–300 | Medium | **Business Premium** ⭐ | Adds Intune, Conditional Access, Defender for Business, Info Protection. Best value for most Thai SMBs. |
| **Mid-market Enterprise** | 300–3,000 | Medium | **Microsoft 365 E3** | Adds Entra ID P1, unlimited users, Teams Phone (add-on), advanced Exchange. |
| **Regulated Enterprise** (finance, healthcare, government supplier) | 500+ | **High** | **Microsoft 365 E5** | Adds Entra ID P2 + PIM, Defender P2, advanced compliance (DLP+, Insider Risk), Purview, Priva, Power BI Pro. |
| **Frontline Worker** (retail, factory, hospitality) | Shift workers | Low | **F1 / F3** | Web/mobile Office, shared device sign-in, Teams for shift management. ~⅓ the cost of E3. |
| **K-12 / Higher Ed** | Any | Varies | **A1 / A3 / A5** | Same features as E-tier at education pricing. A1 is free for faculty + students. |
| **Nonprofit** | Any | Varies | **Business Premium / E3 / E5 Nonprofit** | Up to 10 free Business Premium seats + discounted E-tier. |
| **Government / Public Sector** (Thailand) | Any | **High (regulated)** | **GCC / GCC-High** | Dedicated government cloud — required for some PDPA-adjacent regulated workloads. |

{: .highlight }
**90% of Thai SMBs land on Business Premium.** It's the cheapest license that ships Intune + Conditional Access + Defender — the three features that give real security posture gains over Business Standard.

---

## 2. Use-Case Groups → Microsoft 365 Solutions

Scan the use case you need, then follow the pointer to the detailed setup page in this guide.

### 🔐 Group A — Identity & Access

| Use Case | Minimum License | Setup Page |
|----------|-----------------|------------|
| Centralized user accounts + SSO | Business Basic / E3 | [Microsoft Entra ID]({{ site.baseurl }}/docs/azure-ad-configuration) |
| MFA for all users | Any (Security Defaults) | [Combined Registration]({{ site.baseurl }}/docs/azure-ad-configuration#combined-registration) |
| Conditional Access (baseline) | Business Premium / E3 (**Entra ID P1**) | [CA Baseline]({{ site.baseurl }}/docs/azure-ad-configuration#conditional-access-baseline) |
| Risk-based sign-in policies | E5 (**Entra ID P2**) | [Microsoft Entra ID]({{ site.baseurl }}/docs/azure-ad-configuration) |
| Just-in-time admin access (PIM) | E5 (**Entra ID P2**) | [Privileged Identity Management]({{ site.baseurl }}/docs/privileged-identity-management) ⭐ |
| Self-service password reset | Business Premium / E3 | [SSPR]({{ site.baseurl }}/docs/azure-ad-configuration#self-service-password-reset) |
| Guest / external collaboration | Any | [Microsoft Entra ID — External]({{ site.baseurl }}/docs/azure-ad-configuration#user-settings) |

### 🖥️ Group B — Device Management (Intune)

| Use Case | Minimum License | Setup Page |
|----------|-----------------|------------|
| BYOD mobile (MAM only — no enrollment) | Business Premium / E3 | [App Protection (MAM)]({{ site.baseurl }}/docs/microsoft-endpoint-manager#app-protection-mam) |
| Corporate iOS / Android enrollment | Business Premium / E3 | [Mobile Devices (MDM)]({{ site.baseurl }}/docs/microsoft-endpoint-manager#mobile-devices-mdm) |
| Windows Autopilot zero-touch deployment | Business Premium / E3 | [Windows Autopilot]({{ site.baseurl }}/docs/microsoft-endpoint-manager#windows-autopilot) |
| Windows compliance + BitLocker policy | Business Premium / E3 | [Compliance Policies]({{ site.baseurl }}/docs/microsoft-endpoint-manager#compliance-policies) |
| Co-management with on-prem SCCM | E3 + SCCM | [Hybrid Join]({{ site.baseurl }}/docs/microsoft-endpoint-manager#windows-10--hybrid-join) |
| Endpoint DLP (block copy to USB / unmanaged cloud) | E5 | [PDPA — DLP]({{ site.baseurl }}/docs/pdpa#5-step-3--deploy-dlp-policies-for-pdpa-personal-data) |

### 🛡️ Group C — Email & Threat Protection

| Use Case | Minimum License | Setup Page |
|----------|-----------------|------------|
| Anti-spam, anti-malware, anti-phishing baseline | Any (EOP included) | [EOP & Defender Baseline]({{ site.baseurl }}/docs/tenant-configuration#eop--defender-for-office-365-baseline) |
| Safe Links + Safe Attachments | Business Premium / **Defender for Office 365 P1** | [EOP & Defender Baseline]({{ site.baseurl }}/docs/tenant-configuration#eop--defender-for-office-365-baseline) |
| Attack simulation training | **Defender for Office 365 P2** / E5 | [PDPA — Breach]({{ site.baseurl }}/docs/pdpa#8-step-6--72-hour-breach-notification-workflow) |
| SPF, DKIM, DMARC | Any | [Tenant — SPF/DKIM/DMARC]({{ site.baseurl }}/docs/tenant-configuration#eop--defender-for-office-365-baseline) |
| Office Message Encryption (OME) | Business Premium / E3 | Downloads — [Setup-OME.ps1]({{ site.baseurl }}/scripts/exchange-online/Setup-OME.ps1){:download} |

### 📂 Group D — Data Protection & Compliance

| Use Case | Minimum License | Setup Page |
|----------|-----------------|------------|
| Manual sensitivity labels | Business Premium / E3 | [Sensitivity Labels]({{ site.baseurl }}/docs/collaboration-governance#sensitivity-labels) |
| Auto-apply labels (content inspection) | **E5 / E5 Compliance / E5 Information Protection** | [PDPA — Labels]({{ site.baseurl }}/docs/pdpa#4-step-2--classify-thai-personal-data-sensitivity-labels--sensitive-info-types) |
| DLP for Exchange / SharePoint / OneDrive | Business Premium / E3 | [DLP]({{ site.baseurl }}/docs/collaboration-governance#data-loss-prevention) |
| DLP for Teams chat + Endpoint DLP | **E5 Compliance** | [PDPA — DLP]({{ site.baseurl }}/docs/pdpa#5-step-3--deploy-dlp-policies-for-pdpa-personal-data) |
| Retention policies (basic) | Business Premium / E3 | [Retention]({{ site.baseurl }}/docs/collaboration-governance#retention-policies) |
| Records management / adaptive scopes | **E5 Compliance** | [PDPA — Retention]({{ site.baseurl }}/docs/pdpa#6-step-4--retention-policies-for-pdpa-data-minimization) |
| Subject Rights Requests (DSR) | **E5 + Priva** | [PDPA — DSR]({{ site.baseurl }}/docs/pdpa#7-step-5--data-subject-rights-dsr-workflow) |
| Insider Risk Management | **E5 Compliance** | — |
| Communication Compliance | **E5 Compliance** | — |

### 📋 Group E — Compliance & Regulatory (Thailand)

| Use Case | Minimum License | Setup Page |
|----------|-----------------|------------|
| **PDPA (Thailand) full programme** | **E5** recommended (E3 + Compliance add-on works) | [PDPA Compliance Setup]({{ site.baseurl }}/docs/pdpa) ⭐ |
| Compliance Manager assessments | E3 / E5 | [PDPA — Compliance Manager]({{ site.baseurl }}/docs/pdpa#3-step-1--enable-the-pdpa-assessment-in-compliance-manager) |
| Legal hold / eDiscovery (basic) | E3 | Downloads — [Setup-ArchiveLegalHold.ps1]({{ site.baseurl }}/scripts/exchange-online/Setup-ArchiveLegalHold.ps1){:download} |
| eDiscovery (Premium — custodian hold, analytics) | **E5** | — |
| Audit log 1-year+ retention | **E5** | [PDPA — Audit]({{ site.baseurl }}/docs/pdpa#9-step-7--audit-logs--records-of-processing-ropa) |

### 📊 Group F — Monitoring & Reporting

| Use Case | Minimum License | Setup Page |
|----------|-----------------|------------|
| Monthly health report (licenses, MFA, CA, sign-in failures) | Business Premium / E3 | [Admin Monthly Report]({{ site.baseurl }}/docs/admin-monthly-report) |
| Incident response forensics | Business Premium / E3 | Downloads — [Incident Response]({{ site.baseurl }}/docs/downloads#incident-response) |
| Entra ID sign-in log retention beyond 30 days | **Entra ID P1** / P2 | [Microsoft Entra ID]({{ site.baseurl }}/docs/azure-ad-configuration) |
| SIEM integration (Sentinel / Splunk) | Depends on SIEM | — |

---

## 3. Recommended Deployment Path by Business Profile

### 👔 Thai SMB on Business Premium (most common)

1. [Prerequisites]({{ site.baseurl }}/docs/prerequisites) — tenant readiness check
2. [Tenant Configuration]({{ site.baseurl }}/docs/tenant-configuration) — domains, EOP + Defender baseline, alert policies
3. [Microsoft Entra ID]({{ site.baseurl }}/docs/azure-ad-configuration) — Combined Registration, SSPR, **Conditional Access baseline**
4. [Microsoft Intune]({{ site.baseurl }}/docs/microsoft-endpoint-manager) — compliance + App Protection for BYOD
5. [Collaboration Governance]({{ site.baseurl }}/docs/collaboration-governance) — basic DLP + retention + default sensitivity labels
6. [PDPA (Thailand)]({{ site.baseurl }}/docs/pdpa) — classification, DLP, retention mapping to PDPA 2562
7. [Admin Monthly Report]({{ site.baseurl }}/docs/admin-monthly-report) — recurring health check

### 🏢 Thai Enterprise on E5

Everything above **plus**:

- [Privileged Identity Management]({{ site.baseurl }}/docs/privileged-identity-management) — zero permanent Global Admins
- Enable Entra ID Protection (risk-based CA policies — not yet a dedicated page)
- Deploy **Insider Risk Management** and **Communication Compliance**
- Priva Subject Rights Requests (full DSR workflow for PDPA Section 30–37)
- Auto-apply sensitivity labels with content inspection

### 🏭 Frontline Workforce on F1/F3

- Shared device sign-in (Intune — Shared device mode)
- Mobile-only — skip desktop Office deployment steps
- Teams Shift Management + Walkie-Talkie
- Intune App Protection Policies for BYOD phones

### 🎓 Education on A3/A5

- Follow the E3/E5 path, but use the A-tier equivalent licenses
- Enable **Microsoft Teams for Education** (assignments, class notebooks)
- Enable **Minecraft Education** where licensed (A5)
- Student guest access: review guidance in [User Settings]({{ site.baseurl }}/docs/azure-ad-configuration#user-settings)

---

## 4. "Do I Need to Upgrade?" Decision Tree

Ask these questions in order. If you answer **Yes**, the right column is your minimum license.

| Question | Minimum License |
|----------|-----------------|
| Do you have > 300 users? | **E3** (Business plans cap at 300) |
| Do you need just-in-time admin access (PIM)? | **E5** (Entra ID P2) |
| Do you need risk-based Conditional Access? | **E5** (Entra ID P2) |
| Do you need Insider Risk Management or Communication Compliance? | **E5 Compliance** |
| Do you need Attack Simulation Training (phishing drills)? | **Defender for O365 P2 / E5** |
| Do you need **auto-apply sensitivity labels** or auto-classify personal data for PDPA? | **E5 / E5 Compliance** |
| Do you need Endpoint DLP (block copy to USB)? | **E5 Compliance** |
| Do you need eDiscovery Premium / full DSR automation for PDPA? | **E5 + Priva** |
| Do you need Power BI Pro included? | **E5** (or separate Power BI Pro add-on) |

{: .note }
Microsoft offers **E5 Compliance**, **E5 Security**, and **E5 Information Protection** as modular add-ons for E3 — often cheaper than jumping to full E5 if you only need one slice.

---

## 5. License Comparison — Quick Cheat Sheet

| Feature | Business Basic | Business Standard | **Business Premium ⭐** | E3 | **E5 ⭐** | F1 | F3 |
|---------|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| Web + Mobile Office | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Desktop Office | ❌ | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ |
| Exchange mailbox | 50 GB | 50 GB | 50 GB | 100 GB | 100 GB | 2 GB | 2 GB |
| Teams | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| SharePoint + OneDrive | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Microsoft Intune** | ❌ | ❌ | ✅ | ✅ | ✅ | ✅* | ✅ |
| **Entra ID P1** (Conditional Access) | ❌ | ❌ | ✅ | ✅ | ✅ | ✅* | ✅ |
| **Entra ID P2** (PIM, Identity Protection) | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ | ❌ |
| **Defender for Business** | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ |
| **Defender for Office 365 P1** | ❌ | ❌ | ✅ | ❌ | ✅ | ❌ | ❌ |
| **Defender for Office 365 P2** | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ | ❌ |
| Information Protection — manual labels | ❌ | ❌ | ✅ | ✅ | ✅ | ❌ | ❌ |
| Information Protection — auto-apply | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ | ❌ |
| DLP — Exchange/SPO/OneDrive | ❌ | ❌ | ✅ | ✅ | ✅ | ❌ | ❌ |
| DLP — Teams + Endpoint | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ | ❌ |
| Retention policies | ❌ | ❌ | ✅ | ✅ | ✅ | ❌ | ❌ |
| Insider Risk + Comm. Compliance | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ | ❌ |
| Max users | 300 | 300 | 300 | Unlimited | Unlimited | Unlimited | Unlimited |

> `*` F-tier Entra ID P1 and Intune coverage depends on license variant; check the current F1/F3 feature list.

---

## 6. References

- [Microsoft 365 plans comparison (official)](https://www.microsoft.com/en-us/microsoft-365/business/compare-all-plans){:target="_blank"}
- [Microsoft 365 licensing guidance for security & compliance](https://learn.microsoft.com/en-us/office365/servicedescriptions/microsoft-365-service-descriptions/microsoft-365-tenantlevel-services-licensing-guidance/microsoft-365-security-compliance-licensing-guidance){:target="_blank"}
- [Microsoft 365 Education plans](https://www.microsoft.com/en-us/education/products/microsoft-365){:target="_blank"}
- [Microsoft Nonprofit offers](https://www.microsoft.com/en-us/nonprofits){:target="_blank"}
- [Microsoft 365 Government (GCC / GCC-High / DoD) — product page](https://www.microsoft.com/en-us/microsoft-365/government){:target="_blank"}
- See also: [Prerequisites — Licensing Matrix]({{ site.baseurl }}/docs/prerequisites#2-licensing-matrix)
