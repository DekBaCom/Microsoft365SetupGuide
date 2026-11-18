---
title: PDPA (Thailand) Compliance Setup
layout: default
nav_order: 8
has_children: false
permalink: /docs/pdpa
description: Configure Microsoft 365 to support Thailand's Personal Data Protection Act (PDPA) — Compliance Manager assessment, data classification, retention, DLP for Thai personal data, Data Subject Rights workflow, and 72-hour breach notification.
---

# PDPA (Thailand) Compliance Setup
{: .no_toc }

Configure Microsoft 365 to support **Thailand's Personal Data Protection Act B.E. 2562 (2019)** — enforced from **1 June 2022** — using Microsoft Purview Compliance Manager, Information Protection, DLP, retention policies, and Data Subject Rights (DSR) workflows.
{: .fs-6 .fw-300 }

> **ภาษาไทย:** หน้านี้เป็นคู่มือตั้งค่า Microsoft 365 เพื่อรองรับการปฏิบัติตาม **พระราชบัญญัติคุ้มครองข้อมูลส่วนบุคคล พ.ศ. 2562 (PDPA)** ซึ่งมีผลบังคับใช้เต็มรูปแบบ 1 มิถุนายน 2565 โดยใช้เครื่องมือในกลุ่ม Microsoft Purview, Information Protection, DLP, Retention, และ Data Subject Rights (DSR)

{: .warning }
**Disclaimer.** This page is technical configuration guidance and **not** legal advice. Consult your **Data Protection Officer (DPO)** and a Thai privacy lawyer for legal compliance obligations. The PDPC (Personal Data Protection Committee) is the official regulator — see [pdpc.or.th](https://www.pdpc.or.th){:target="_blank"}.

---

## Table of Contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## 1. PDPA at a Glance (What You Must Configure)

| PDPA Obligation | Thai Law Reference | Microsoft 365 Feature |
|-----------------|--------------------|------------------------|
| Lawful basis for processing | Section 24 | Compliance Manager — document in Records of Processing |
| Data subject rights (access, rectify, erase, portability, object) | Section 30–37 | **Microsoft Purview DSR** (Data Subject Requests) + eDiscovery |
| Breach notification within **72 hours** | Section 37(4) | **Microsoft Defender** alerts + Communication Compliance |
| Data minimization & retention limits | Section 23, 37(3) | **Retention policies** + auto-deletion |
| Security measures (confidentiality, integrity) | Section 37(1) | Conditional Access, MFA, Encryption, DLP, [PIM]({{ site.baseurl }}/docs/privileged-identity-management) |
| Records of processing activities (ROPA) | Section 39 | **Compliance Manager** — Records of Processing |
| Consent management | Section 19, 24(1) | Form consent + Compliance Manager |
| Cross-border data transfer | Section 28–29 | Microsoft **Data residency** disclosures + tenant region |
| Data processor agreement (DPA) | Section 40 | **Microsoft Online Services DPA** — pre-signed |

{: .highlight }
Thai PDPA closely mirrors the EU **GDPR**. If you already follow GDPR controls, you have ~80% of PDPA coverage — the remaining 20% is terminology, local regulator notification channels, and Thai-specific personal data types (e.g. **Thai National ID** `13-digit format`).

---

## 2. Prerequisites Checklist

- [ ] **Microsoft 365 E3 or E5** — PDPA baseline needs E3 minimum; E5 unlocks auto-labelling, Communication Compliance, Insider Risk
- [ ] Appointed **Data Protection Officer (DPO)** — required if you process large amounts of personal data (Section 41)
- [ ] Appointed **Compliance Manager** administrator — see Step 3
- [ ] Baseline M365 security already deployed — see [Tenant Configuration]({{ site.baseurl }}/docs/tenant-configuration), [Microsoft Entra ID]({{ site.baseurl }}/docs/azure-ad-configuration), [PIM]({{ site.baseurl }}/docs/privileged-identity-management)
- [ ] Sensitivity Labels **enabled and published** — see [Collaboration Governance — Sensitivity Labels]({{ site.baseurl }}/docs/collaboration-governance#sensitivity-labels)
- [ ] Retention Policies deployed — see [Collaboration Governance — Retention]({{ site.baseurl }}/docs/collaboration-governance#retention-policies)
- [ ] **Breach notification contact list** prepared — DPO, CISO, legal counsel, PR, PDPC contact channel

---

## 3. Step 1 — Enable the PDPA Assessment in Compliance Manager

**Microsoft Purview Compliance Manager** ships with a pre-built **Thailand PDPA assessment template**. It gives you a scored, auditable roadmap of what to configure.

1. Sign in to **[Microsoft Purview](https://purview.microsoft.com)** as a **Compliance Administrator** or Global Administrator.

2. Navigate to **Compliance Manager** > **Assessments** > **Add assessment**.

   <!-- Screenshot placeholder — /assets/images/pdpa_01_compliance_manager.png
        Caption: "Compliance Manager landing page" -->

3. Click **Use a template** and search for:

   ```
   Thailand Personal Data Protection Act (PDPA)
   ```

4. Select the template and configure:

   | Field | Value |
   |-------|-------|
   | **Assessment name** | `PDPA 2562 — Production` |
   | **Group** | Create new group `Thai PDPA` |
   | **Product** | Microsoft 365 |
   | **In-scope services** | Exchange, SharePoint, OneDrive, Teams |

   <!-- Screenshot placeholder — /assets/images/pdpa_02_template.png
        Caption: "Selecting the Thailand PDPA assessment template" -->

5. Click **Create assessment**. Compliance Manager starts scoring your tenant against 60+ PDPA-aligned controls.

6. Open the new assessment and review:
   - **Microsoft actions** (already implemented by Microsoft) — contributes to your score automatically
   - **Your improvement actions** — technical + operational controls you must implement

   <!-- Screenshot placeholder — /assets/images/pdpa_03_score.png
        Caption: "PDPA assessment score and improvement actions" -->

{: .note }
Target initial score: **≥ 70%** after deploying the rest of this guide. Score **100%** is rarely required by the regulator — the audit trail of *implemented controls* matters more.

---

## 4. Step 2 — Classify Thai Personal Data (Sensitivity Labels + Sensitive Info Types)

PDPA personal data includes anything that identifies a natural person: **name, Thai National ID (13 digits), Thai passport, phone, email, address, biometrics, health info**, etc.

### 4.1 Enable Thai-specific Sensitive Information Types

Microsoft Purview ships with built-in sensitive info types (SITs) relevant to Thailand:

| Sensitive Info Type (SIT) | Pattern |
|---------------------------|---------|
| **Thailand Population Identification Code** | 13-digit Thai National ID |
| **Thailand Passport Number** | Thai passport format |
| **International Classification of Diseases (ICD-10)** | Health records |
| **Credit Card Number** | Generic (16-digit Luhn) |
| **International Banking Account Number (IBAN)** | Cross-border financial |

1. Go to **[Microsoft Purview](https://purview.microsoft.com)** > **Data classification** > **Sensitive info types**.

2. Search for **"Thailand"** and confirm both Thai SITs are present and **active**.

   <!-- Screenshot placeholder — /assets/images/pdpa_04_sit_thailand.png
        Caption: "Thailand sensitive info types in Microsoft Purview" -->

### 4.2 Create / Update Sensitivity Labels for Personal Data

Extend your existing label taxonomy ([Collaboration Governance]({{ site.baseurl }}/docs/collaboration-governance#sensitivity-labels)) with a **Personal Data** sub-label.

1. Navigate to **[Microsoft Purview](https://purview.microsoft.com)** > **Information Protection** > **Labels**.

2. Click **+ Create a label** and configure:

   | Setting | Value |
   |---------|-------|
   | **Name** | `Confidential \ Personal Data (PDPA)` |
   | **Display name** | `PDPA — Personal Data` |
   | **Scope** | Files & emails, Groups & sites |
   | **Encryption** | ✅ Enabled — restrict access to internal users + specified partners |
   | **Content marking (header/footer/watermark)** | ✅ `Personal Data — Protect per PDPA 2562` |
   | **Auto-labelling (E5)** | Match any **Thailand Population Identification Code** OR **Thailand Passport Number** — minimum **1 instance**, high confidence |

   <!-- Screenshot placeholder — /assets/images/pdpa_05_label_create.png
        Caption: "Creating the PDPA — Personal Data sensitivity label" -->

3. **Publish** the label to all users (or a targeted pilot group first):
   - **Information Protection** > **Label policies** > **Publish labels**
   - Policy name: `PDPA — Personal Data Policy`

4. Verify the label appears in Outlook, Word, Excel, and SharePoint within 24 hours.

{: .warning }
**Encryption + external sharing.** Encrypted PDPA-labelled files cannot be opened by external recipients unless you explicitly allow them in the label's user/group list. Coordinate with business owners before enabling encryption on existing document libraries.

---

## 5. Step 3 — Deploy DLP Policies for PDPA Personal Data

Prevent accidental or malicious sharing of Thai personal data via email, Teams, SharePoint, OneDrive, and endpoints.

1. Navigate to **[Microsoft Purview](https://purview.microsoft.com)** > **Data loss prevention** > **Policies** > **+ Create policy**.

2. Choose template → **Custom** → **Custom policy**.

3. Configure the policy:

   | Setting | Value |
   |---------|-------|
   | **Policy name** | `PDPA — Thai Personal Data Protection` |
   | **Locations** | Exchange, SharePoint, OneDrive, Teams, **Endpoint** (requires Endpoint DLP license) |
   | **Rule — Content contains** | Any of: `Thailand Population Identification Code`, `Thailand Passport Number`, label `PDPA — Personal Data` |
   | **Rule — Instance count** | ≥ **1** (adjust to reduce false positives) |
   | **Action — External recipient** | **Block** with override + justification |
   | **Action — Internal recipient** | **Audit** + show policy tip |
   | **Incident report** | Send to `dpo@yourdomain.co.th` + `compliance@yourdomain.co.th` |
   | **Mode** | Start in **Test with policy tips** for 2 weeks → then **Enforce** |

   <!-- Screenshot placeholder — /assets/images/pdpa_06_dlp_policy.png
        Caption: "DLP policy — Thai Personal Data Protection" -->

4. **Review** the policy simulation report after 14 days. Tune false positives before switching to **Turn on** (enforce) mode.

5. Enable **Endpoint DLP** (E5 Compliance) to also block copying personal data to USB drives, unmanaged cloud storage, and print.

{: .highlight }
**Test tip:** Email yourself a dummy Thai National ID (never use a real one for testing — use `1-2345-67890-12-3` style with a non-valid check digit) from a test account to verify the DLP tip appears.

---

## 6. Step 4 — Retention Policies for PDPA (Data Minimization)

PDPA Section 23 requires that personal data is **not kept longer than necessary**. Microsoft 365 retention policies enforce this automatically.

### 6.1 Baseline Retention Policy for Personal Data

1. Navigate to **[Microsoft Purview](https://purview.microsoft.com)** > **Data lifecycle management** > **Retention policies** > **+ New retention policy**.

2. Configure:

   | Setting | Value |
   |---------|-------|
   | **Name** | `PDPA — Personal Data (3-year retention)` |
   | **Locations** | Exchange, SharePoint, OneDrive, Teams channel messages |
   | **Retention** | **Retain for 3 years, then delete** *(adjust to your lawful-basis period)* |
   | **Applied to** | Content labelled `PDPA — Personal Data`, OR content containing a Thai Population ID |

   <!-- Screenshot placeholder — /assets/images/pdpa_07_retention.png
        Caption: "Retention policy for PDPA-labelled content" -->

3. Click **Create**.

### 6.2 Retention Label for Ad-hoc Marking

Create a retention **label** (not just policy) so users / records managers can tag specific items:

- Label name: `PDPA — Personal Data — 3Y`
- Behaviour: Retain & delete after 3 years from created date
- Mark as **Record** — immutable until retention expires

{: .note }
Retention **policies** apply broadly (by location + condition). Retention **labels** apply to individual items. Use both.

---

## 7. Step 5 — Data Subject Rights (DSR) Workflow

PDPA Section 30–37 grants data subjects the right to **access, rectify, delete, port, restrict, and object** to processing of their personal data. Microsoft Purview provides a built-in workflow.

### 7.1 Deploy the DSR Portal

1. Navigate to **[Microsoft Purview](https://purview.microsoft.com)** > **Privacy** > **Subject rights requests**.

   > **Licensing:** The full Priva Subject Rights Requests feature requires **Microsoft Priva** licensing. The eDiscovery-based workflow below works with **E5** or **E3 + Compliance add-on**.

2. Click **+ New subject rights request**.

3. Configure the request type:

   | DSR Type | PDPA Section | M365 Feature |
   |----------|--------------|--------------|
   | **Access** (copy of their data) | § 30 | Priva SRR / eDiscovery export |
   | **Rectification** (correct their data) | § 36 | Manual — business process |
   | **Erasure / Right to be forgotten** | § 33 | Priva SRR — approval + delete |
   | **Restriction** (pause processing) | § 34 | Hold on account + manual flags |
   | **Portability** (export in machine-readable format) | § 31 | Priva SRR export → JSON/CSV |
   | **Objection** | § 32 | Manual — update consent record |

4. Fill in the data subject details (name, email, request type, deadline).

   <!-- Screenshot placeholder — /assets/images/pdpa_08_dsr.png
        Caption: "Creating a Subject Rights Request in Microsoft Priva" -->

5. Priva automatically searches **Exchange, SharePoint, OneDrive, Teams** for content matching the subject's identifiers. Review hits, redact third-party personal data, and export.

### 7.2 PDPA Response Timeline

| PDPA Requirement | Target |
|------------------|--------|
| Acknowledge receipt of DSR | Within **7 days** (regulatory best practice; law says "without undue delay") |
| Fulfil access / portability request | Within **30 days** (extendable to 60) |
| Fulfil erasure request | Within **30 days** |
| Notify requester of refusal with reason | Within **30 days** |

{: .warning }
Erasure is **not absolute** under PDPA — you may refuse if you have an overriding lawful basis (e.g. legal retention obligations, exercise of legal claims). Always document the reason.

---

## 8. Step 6 — 72-Hour Breach Notification Workflow

PDPA Section 37(4) requires notifying the **PDPC** within **72 hours** of becoming aware of a personal data breach. Set up detection + response automation.

### 8.1 Enable Breach Detection Alerts

1. Navigate to **[Microsoft Purview](https://purview.microsoft.com)** > **Policies** > **Alert policies**.

2. Verify these built-in alerts are **enabled** and routed to your DPO + security team:

   | Alert | Severity |
   |-------|---------|
   | Unusual volume of file deletion | **High** |
   | Unusual volume of external file sharing | **High** |
   | eDiscovery search exported | **Medium** |
   | DLP policy matched (PDPA DLP from Step 3) | **High** |
   | Malware campaign detected | **High** |
   | Elevation of Exchange admin privilege | **High** |
   | Sign-in from Tor / anonymous IP | **High** |

   <!-- Screenshot placeholder — /assets/images/pdpa_09_alerts.png
        Caption: "Breach-relevant alert policies" -->

3. Also enable **Microsoft Defender XDR** incident consolidation so related alerts group automatically.

### 8.2 Prepare the PDPC Notification Template

Create a runbook document (store in SharePoint under a restricted site) covering:

- **Decision tree:** Does the incident meet the PDPA breach threshold? (Did personal data leave the organization's control? Could it cause harm to data subjects?)
- **Pre-written PDPC notification form** (in Thai) with fields: nature of breach, categories + approximate number of data subjects affected, likely consequences, measures taken
- **Data subject notification template** (required if breach poses high risk — Section 37(4))
- **72-hour countdown tracker** (from moment of awareness, not breach occurrence)
- **Approval chain:** DPO → Legal → CEO sign-off before PDPC submission

### 8.3 Attack Simulation Training (E5)

Run quarterly phishing simulations via **Defender for Office 365 Attack Simulation Training** so the 72-hour clock never starts due to a preventable user mistake.

---

## 9. Step 7 — Audit Logs & Records of Processing (ROPA)

PDPA Section 39 requires maintaining **Records of Processing Activities (ROPA)** — Compliance Manager + Unified Audit Log cover this.

### 9.1 Ensure Unified Audit Log is Enabled

```powershell
# Prerequisites: Microsoft Graph + ExchangeOnlineManagement (see /docs/prerequisites)
Connect-ExchangeOnline

# Check audit log state
Get-AdminAuditLogConfig | Select-Object UnifiedAuditLogIngestionEnabled

# Enable if not already on (should be on by default for new tenants)
Set-AdminAuditLogConfig -UnifiedAuditLogIngestionEnabled $true

# Ensure mailbox auditing is on tenant-wide
Set-OrganizationConfig -AuditDisabled $false
```

### 9.2 Set Audit Log Retention

{: .note }
Standard retention is **90 days** (E3) or **1 year** (E5). PDPA does not mandate a specific retention period for audit logs, but **1 year minimum** is good practice; some sectors (banking, healthcare) require more.

```powershell
# Create a 1-year audit log retention policy (requires E5)
New-UnifiedAuditLogRetentionPolicy `
    -Name "PDPA — 1-year audit retention" `
    -Priority 100 `
    -RecordTypes ExchangeItem, SharePointFileOperation, AzureActiveDirectory, `
                 AzureActiveDirectoryStsLogon, MicrosoftTeams `
    -RetentionDuration TenYears `
    -Description "Retain audit events for 10 years to support PDPA ROPA + legal hold"
```

### 9.3 Export Records of Processing Activities

From **Compliance Manager** > your PDPA assessment > **Export report** to produce an auditor-ready PDF of:

- Each personal data processing activity
- Lawful basis for processing (per Section 24)
- Data retention period
- Technical + organizational measures (your implemented controls)
- Cross-border transfers (if any)

---

## 10. PowerShell — PDPA Health Check Snippet

Quick diagnostic to confirm the PDPA baseline is in place. Run monthly.

```powershell
# PDPA — Microsoft 365 Baseline Health Check
Connect-MgGraph -Scopes `
    "Policy.Read.All", `
    "InformationProtectionPolicy.Read.All", `
    "Reports.Read.All", `
    "AuditLog.Read.All"
Connect-IPPSSession

Write-Host "=== PDPA Health Check ===" -ForegroundColor Cyan

# 1. Sensitivity labels published
$labels = Get-Label | Where-Object DisplayName -Like "*PDPA*"
if ($labels) { Write-Host "✔ PDPA sensitivity label(s) found: $($labels.Count)" -ForegroundColor Green }
else         { Write-Warning "No PDPA sensitivity label published" }

# 2. DLP policy present
$dlp = Get-DlpCompliancePolicy | Where-Object Name -Like "*PDPA*"
if ($dlp) { Write-Host "✔ PDPA DLP policy found: $($dlp.Name) [Mode: $($dlp.Mode)]" -ForegroundColor Green }
else      { Write-Warning "No PDPA DLP policy" }

# 3. Retention policy present
$ret = Get-RetentionCompliancePolicy | Where-Object Name -Like "*PDPA*"
if ($ret) { Write-Host "✔ PDPA retention policy found: $($ret.Name)" -ForegroundColor Green }
else      { Write-Warning "No PDPA retention policy" }

# 4. Audit log enabled
$audit = Get-AdminAuditLogConfig
if ($audit.UnifiedAuditLogIngestionEnabled) { Write-Host "✔ Unified audit log enabled" -ForegroundColor Green }
else                                         { Write-Warning "Unified audit log is OFF — enable immediately" }

# 5. Breach-relevant alerts enabled
$alerts = Get-ProtectionAlert | Where-Object {$_.Category -in @("DataLossPrevention","ThreatManagement") -and $_.Disabled -eq $false}
Write-Host "✔ Active threat/DLP alert policies: $($alerts.Count)" -ForegroundColor Green

Disconnect-ExchangeOnline -Confirm:$false | Out-Null
Disconnect-MgGraph | Out-Null
```

---

## 11. Verification Checklist

After rollout, confirm:

- [ ] Compliance Manager **Thailand PDPA** assessment exists and scores ≥ 70%
- [ ] `PDPA — Personal Data` sensitivity label is **published** and applies to all users
- [ ] DLP policy targets Thai NatID + Passport and routes alerts to the DPO
- [ ] Retention policy enforces a defined period (e.g., 3 years) with auto-deletion
- [ ] Subject Rights Request workflow is documented and tested with a dry-run
- [ ] 72-hour breach notification runbook exists in a restricted SharePoint site
- [ ] Unified Audit Log is **enabled** and has retention ≥ 1 year
- [ ] DPO contact email is added to all alert policies
- [ ] At least one staff training session on PDPA delivered in the past 12 months
- [ ] **Microsoft Online Services DPA** is accepted (automatic for all commercial tenants)

---

## 12. References

- [พระราชบัญญัติคุ้มครองข้อมูลส่วนบุคคล พ.ศ. 2562 — PDPC Thailand](https://www.pdpc.or.th){:target="_blank"}
- [English translation of Thailand PDPA](https://www.krisdika.go.th/librarian/get?sysid=843076&ext=pdf){:target="_blank"}
- [Microsoft — Thailand PDPA compliance overview](https://learn.microsoft.com/en-us/compliance/regulatory/offering-pdpa-thailand){:target="_blank"}
- [Microsoft Purview Compliance Manager](https://learn.microsoft.com/en-us/purview/compliance-manager){:target="_blank"}
- [Microsoft Purview — Subject Rights Requests](https://learn.microsoft.com/en-us/privacy/priva/subject-rights-requests){:target="_blank"}
- [Microsoft Online Services Data Protection Addendum (DPA)](https://www.microsoft.com/licensing/docs/view/Microsoft-Products-and-Services-Data-Protection-Addendum-DPA){:target="_blank"}

---

{: .note }
**Screenshots coming soon.** Image placeholders follow the same `pdpa_NN_name.png` convention as other pages in this guide. Contributions welcome — see [SECURITY.md](https://github.com/DekBaCom/Microsoft365SetupGuide/blob/main/SECURITY.md).
