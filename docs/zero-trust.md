---
title: Zero Trust on Microsoft 365
layout: default
nav_order: 2.7
has_children: false
permalink: /docs/zero-trust
description: End-to-end Zero Trust deployment on Microsoft 365 — identity, devices, apps, data, infrastructure, network. Step-by-step setup aligned to Microsoft's Zero Trust architecture with a PowerShell assessment script.
---

# Zero Trust on Microsoft 365
{: .no_toc }

A practical, step-by-step playbook to apply **Microsoft's Zero Trust architecture** to a Microsoft 365 tenant — identity, device, app, data, infrastructure, and network — with a bundled **PowerShell assessment script** you can run before and after each milestone.
{: .fs-6 .fw-300 }

> **ภาษาไทย:** คู่มือตั้งค่า Microsoft 365 ตามสถาปัตยกรรม **Zero Trust** ของ Microsoft แบบ Step-by-Step ครอบคลุม 6 เสาหลัก (Identity, Device, App, Data, Infrastructure, Network) พร้อม PowerShell Script ตรวจสอบสถานะก่อน-หลัง

{: .highlight }
Zero Trust is a **security model**, not a product. The three guiding principles are:
1. **Verify explicitly** — authenticate and authorize every request based on all signals
2. **Use least-privilege access** — just-in-time + just-enough-access (JIT/JEA)
3. **Assume breach** — segment, verify end-to-end encryption, use analytics for threat detection

---

## Table of Contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## 1. The Six Zero Trust Pillars — Microsoft 365 Mapping

| Pillar | What Zero Trust asks | Microsoft 365 feature used |
|--------|---------------------|----------------------------|
| **🧍 Identity** | Verify every user explicitly | Microsoft Entra ID P1/P2, MFA, Conditional Access, Identity Protection, PIM |
| **💻 Device** | Only healthy, compliant devices connect | Microsoft Intune (MDM + MAM), Compliance Policies, Defender for Endpoint |
| **📱 App** | Access only to apps per policy | Entra ID Application Proxy, App Protection Policies, Defender for Cloud Apps |
| **📂 Data** | Classify, protect, monitor data wherever it goes | Sensitivity Labels, DLP, Retention, Microsoft Purview Information Protection |
| **🏗️ Infrastructure** | Detect anomalies, enforce JEA | Microsoft Defender for Cloud, Defender XDR, Entra ID Protection |
| **🌐 Network** | Micro-segment, encrypt end-to-end | Microsoft Entra Internet/Private Access, Named Locations in CA |

{: .note }
This page focuses on the **M365-centric pillars** (Identity, Device, App, Data). Infrastructure and Network are referenced where they intersect M365, with links to Azure docs for depth.

---

## 2. Prerequisites

- [ ] Baseline tenant readiness completed — see [Prerequisites]({{ site.baseurl }}/docs/prerequisites)
- [ ] Break-glass accounts created — see [Tenant Configuration]({{ site.baseurl }}/docs/tenant-configuration#emergency-access-accounts)
- [ ] License targets confirmed — see [Use Cases & License Mapping]({{ site.baseurl }}/docs/use-cases)
- [ ] At least **Microsoft 365 Business Premium** (SMB) **or Microsoft 365 E3** (enterprise); **E5** unlocks risk-based CA, Priva, and Insider Risk

---

## 3. Step 1 — Baseline Assessment (Run the Script First)

Before changing anything, capture your current posture. The provided PowerShell script scores your tenant against a Zero Trust rubric and exports a dated HTML report.

1. Download **[Get-M365SecurityPosture.ps1]({{ site.baseurl }}/scripts/security-assessment/Get-M365SecurityPosture.ps1){:download}** from the Downloads page.

2. Open **PowerShell 7+** as a user with the following Microsoft Graph scopes available:
   - `Policy.Read.All`, `User.Read.All`, `Directory.Read.All`, `AuditLog.Read.All`,
     `Organization.Read.All`, `RoleManagement.Read.Directory`,
     `UserAuthenticationMethod.Read.All`, `Reports.Read.All`

3. Run:
   ```powershell
   .\Get-M365SecurityPosture.ps1 -OutputPath "C:\Reports\ZT-Baseline-$(Get-Date -Format 'yyyy-MM').html"
   ```

   <!-- Screenshot placeholder — /assets/images/zt_01_baseline_script.png
        Caption: "Zero Trust baseline script running in PowerShell" -->

4. Open the HTML report. Record the score for each pillar — this is your **Day 0 baseline**.

   <!-- Screenshot placeholder — /assets/images/zt_02_baseline_report.png
        Caption: "Baseline HTML report with per-pillar score" -->

{: .warning }
Re-run this script **after each pillar milestone** below. Zero Trust is iterative — the goal is steady score improvement, not a one-time 100%.

---

## 4. Step 2 — Identity Pillar (The Foundation)

**Goal:** Every sign-in is authenticated, risk-evaluated, and conditionally authorized.

### 4.1 Disable Security Defaults → Enable Conditional Access

Security Defaults is a free entry-level MFA policy. It's good for day one, but Conditional Access gives you granular control. You must disable Security Defaults before deploying CA policies.

1. Microsoft Entra admin center > **Properties** > **Manage Security Defaults** → **Disabled**

   <!-- Screenshot placeholder — /assets/images/zt_03_security_defaults_off.png
        Caption: "Disable Security Defaults before enabling Conditional Access" -->

2. Deploy the three baseline CA policies — follow [Microsoft Entra ID — Conditional Access Baseline]({{ site.baseurl }}/docs/azure-ad-configuration#conditional-access-baseline):
   - **BLOCK**: Legacy authentication
   - **GRANT**: Require MFA (all users, all cloud apps)
   - **BLOCK**: Unsupported device platforms

3. **Automate** with the included script:
   ```powershell
   .\scripts\azure-ad\Install-BaselineCAPolicies.ps1
   ```

### 4.2 Combined MFA + SSPR Registration

Both MFA and self-service password reset use the same registration flow.

1. Microsoft Entra admin center > **Users** > **User settings** > **Manage user feature preview settings** → set **Combined security information registration** to **All**.

   <!-- Screenshot placeholder — /assets/images/zt_04_combined_registration.png
        Caption: "Enable combined MFA + SSPR registration for all users" -->

### 4.3 Identity Protection (E5 / Entra ID P2 only)

1. Microsoft Entra admin center > **Protection** > **Identity Protection**.
2. Enable the two risk policies — initially in **Report-only** mode:
   - **Sign-in risk policy** → block **High** risk sign-ins
   - **User risk policy** → require password change on **High** user risk

   <!-- Screenshot placeholder — /assets/images/zt_05_identity_protection.png
        Caption: "Risk-based policies in Microsoft Entra ID Protection" -->

### 4.4 PIM — Zero Permanent Admins (E5)

Follow the full [PIM step-by-step guide]({{ site.baseurl }}/docs/privileged-identity-management) — the single biggest Zero Trust win for identity.

---

## 5. Step 3 — Device Pillar

**Goal:** A device cannot access corporate data unless it is managed, compliant, and healthy.

### 5.1 Enroll Devices into Intune

Follow [Microsoft Intune — Device Enrollment Settings]({{ site.baseurl }}/docs/microsoft-endpoint-manager#device-enrollment-settings).

- Windows: Windows Autopilot (cloud-native) or Microsoft Entra hybrid join
- iOS / iPadOS: Apple MDM Push Certificate, ADE for corporate devices
- Android: Managed Google Play, Android Enterprise

<!-- Screenshot placeholder — /assets/images/zt_06_intune_enrollment.png
     Caption: "Intune enrollment restrictions and platform matrix" -->

### 5.2 Compliance Policies

Deploy the baseline compliance policy per platform — BitLocker, Secure Boot, password complexity, OS minimum version. See [Compliance Policies]({{ site.baseurl }}/docs/microsoft-endpoint-manager#compliance-policies).

### 5.3 Grant Control: **Require Compliant Device**

Once ≥ 90% of devices are enrolled and compliant, add a new CA policy:

- **Users**: All users (exclude break-glass)
- **Cloud apps**: All cloud apps
- **Grant**: Require device to be marked as compliant
- **Mode**: Report-only for 2 weeks → Enforce

<!-- Screenshot placeholder — /assets/images/zt_07_require_compliant_device.png
     Caption: "CA policy — Require compliant device grant control" -->

{: .warning }
Enabling this before enrollment is complete will **lock out** unenrolled devices. Verify Intune compliance coverage first via the script in Step 1.

### 5.4 Defender for Endpoint Integration (E5)

1. Intune admin center > **Endpoint security** > **Microsoft Defender for Endpoint**.
2. Turn on **Microsoft Defender for Endpoint connection** and **App Protection Policy evaluation for iOS/Android**.
3. Set **Device risk score for CA** to **Medium**.

---

## 6. Step 4 — App Pillar

**Goal:** Only sanctioned apps, with policy-based data boundaries, can interact with M365.

### 6.1 Deploy App Protection Policies (MAM) for BYOD

See [App Protection (MAM)]({{ site.baseurl }}/docs/microsoft-endpoint-manager#app-protection-mam) — enforce copy/paste isolation, PIN, encryption, and conditional launch.

### 6.2 Block Legacy Authentication (already done in Step 4.1)

Confirmed via CA policy #1.

### 6.3 Admin Consent Workflow

Prevent users from independently granting permissions to third-party OAuth apps. See [Microsoft Entra ID — Admin Consent]({{ site.baseurl }}/docs/azure-ad-configuration#admin-consent-requests).

<!-- Screenshot placeholder — /assets/images/zt_08_admin_consent.png
     Caption: "Admin consent workflow — users request, admins approve" -->

### 6.4 Defender for Cloud Apps / MCAS (E5)

1. Enable **Cloud App Discovery** in Defender for Cloud Apps.
2. Import your firewall logs or enable **Defender for Endpoint → Cloud Discovery** integration.
3. Classify discovered apps by risk → sanction or block via Conditional Access.

---

## 7. Step 5 — Data Pillar

**Goal:** Data is classified, protected at rest and in transit, and monitored wherever it moves.

### 7.1 Sensitivity Labels (Information Protection)

Follow [Sensitivity Labels]({{ site.baseurl }}/docs/collaboration-governance#sensitivity-labels). Minimum label set:

| Label | Encryption | Marking | Scope |
|-------|------------|---------|-------|
| Public | No | None | Files, emails |
| General | No | Footer | Files, emails |
| Confidential | Yes — internal only | Watermark | Files, emails |
| Highly Confidential | Yes — named recipients | Watermark + Header | Files, emails, sites |

<!-- Screenshot placeholder — /assets/images/zt_09_sensitivity_labels.png
     Caption: "Publishing the Zero Trust sensitivity label set" -->

### 7.2 Data Loss Prevention (DLP)

Deploy baseline DLP — see [Collaboration Governance — DLP]({{ site.baseurl }}/docs/collaboration-governance#data-loss-prevention) and, for Thai PDPA alignment, [PDPA — DLP step]({{ site.baseurl }}/docs/pdpa#5-step-3--deploy-dlp-policies-for-pdpa-personal-data).

### 7.3 Retention + Records Management

- Baseline retention per workload (Exchange / SharePoint / OneDrive / Teams): **2–7 years**
- Records management for regulated data (E5 Compliance)

### 7.4 Auto-Labelling (E5)

Upgrade manual labels to **auto-apply** based on sensitive info type detection. Pilot on one SharePoint site → expand.

---

## 8. Step 6 — Infrastructure & Network Pillars (Overview)

These pillars extend beyond M365 but have M365 touchpoints:

### 8.1 Microsoft Defender XDR

Unified incident view across identity (Defender for Identity), endpoint (Defender for Endpoint), email (Defender for Office 365), and cloud apps (Defender for Cloud Apps).

- **Portal:** [security.microsoft.com](https://security.microsoft.com){:target="_blank"}
- Enable **automatic attack disruption** for ransomware and BEC.

<!-- Screenshot placeholder — /assets/images/zt_10_defender_xdr.png
     Caption: "Microsoft Defender XDR — unified incident queue" -->

### 8.2 Named Locations in CA

Microsoft Entra admin center > **Protection** > **Conditional Access** > **Named locations** — define trusted corporate IPs and allowed countries. Use as a **signal**, not a hard allowlist.

### 8.3 Microsoft Entra Internet Access / Private Access (SSE)

Microsoft's Secure Service Edge offering integrates with M365 Conditional Access for a complete Zero Trust Network Access (ZTNA) story. See [Microsoft Entra Global Secure Access](https://learn.microsoft.com/en-us/entra/global-secure-access/overview-what-is-global-secure-access){:target="_blank"}.

---

## 9. Step 7 — Measure, Iterate, Report

Re-run the **assessment script** monthly:

```powershell
.\Get-M365SecurityPosture.ps1 -OutputPath ".\ZT-$(Get-Date -Format 'yyyy-MM').html"
```

Track the per-pillar score trend month-over-month. Target state:

| Pillar | Minimum target | Ideal |
|--------|---------------:|------:|
| Identity | 70% | ≥ 90% |
| Device | 60% | ≥ 85% |
| App | 60% | ≥ 80% |
| Data | 50% | ≥ 80% |
| Infrastructure (Defender XDR coverage) | 50% | ≥ 80% |
| **Overall** | **60%** | **≥ 85%** |

### Integrate with Compliance Manager

Compliance Manager has a built-in **Microsoft Zero Trust** assessment template — use it as your audit-ready complement to the PowerShell script.

Microsoft Purview > **Compliance Manager** > **Assessments** > **+ Add assessment** → search **"Zero Trust"** → create.

---

## 10. Suggested 90-Day Rollout Plan

| Week | Focus | Milestone |
|------|-------|-----------|
| **W1–W2** | Baseline | Run script, export report, present to stakeholders |
| **W3–W4** | Identity — foundational CA | Block legacy auth, require MFA, enforce for all users |
| **W5–W6** | Identity — risk-based CA + PIM | Report-only risk policies + PIM for Global Admin |
| **W7–W8** | Device — enrollment push | 90 %+ Windows / iOS / Android enrolled |
| **W9–W10** | Device — grant enforcement | Flip "Require compliant device" to Enforce |
| **W11** | App — App Protection + Admin consent | MAM for BYOD, admin consent workflow live |
| **W12** | Data — Sensitivity labels + DLP | Labels published org-wide, baseline DLP enforced |
| **W13** | Review | Re-run script, compare to baseline, publish results |

---

## 11. Verification Checklist

- [ ] Script shows ≥ 60 % overall posture score
- [ ] All CA baseline policies **enforced** (not report-only)
- [ ] Zero permanent Global Administrators other than 2 break-glass (if E5)
- [ ] ≥ 90 % of in-scope devices Intune-compliant
- [ ] Sensitivity labels published to all users; ≥ 1 auto-labelling policy (E5)
- [ ] Baseline DLP policy enforcing for Exchange + SharePoint + OneDrive
- [ ] Audit log retention ≥ 1 year
- [ ] Monthly report shared with security leadership

---

## 12. References

- [Microsoft Zero Trust Guidance Center](https://learn.microsoft.com/en-us/security/zero-trust/){:target="_blank"}
- [Zero Trust deployment plan — Microsoft 365](https://learn.microsoft.com/en-us/security/zero-trust/deploy/overview){:target="_blank"}
- [Zero Trust architecture — identity pillar](https://learn.microsoft.com/en-us/security/zero-trust/deploy/identity){:target="_blank"}
- [Microsoft Secure Score](https://learn.microsoft.com/en-us/defender-xdr/microsoft-secure-score){:target="_blank"}
- [Microsoft Defender XDR](https://learn.microsoft.com/en-us/defender-xdr/microsoft-365-defender){:target="_blank"}
- [Compliance Manager — Zero Trust assessment](https://learn.microsoft.com/en-us/purview/compliance-manager){:target="_blank"}
- [Microsoft Entra Global Secure Access](https://learn.microsoft.com/en-us/entra/global-secure-access/overview-what-is-global-secure-access){:target="_blank"}

---

{: .note }
**Screenshots coming soon.** The 10 image placeholders use the `zt_NN_name.png` convention. Contributions welcome — see [SECURITY.md](https://github.com/DekBaCom/Microsoft365SetupGuide/blob/main/SECURITY.md).
