---
title: Tenant-to-Tenant Migration
layout: default
nav_order: 9
has_children: false
permalink: /docs/tenant-migration
description: Microsoft 365 tenant-to-tenant (T2T) migration — plan, cutover, and execute cross-tenant mailbox migration, OneDrive, SharePoint, Teams, identity, Intune. Native Microsoft tooling + PowerShell scripts.
---

# Tenant-to-Tenant Migration (T2T)
{: .no_toc }

Plan and execute a Microsoft 365 **tenant-to-tenant (T2T) migration** — mailboxes, OneDrive, SharePoint, Teams, identities, and devices — using native Microsoft tooling where possible, PowerShell for automation, and third-party tools when scope requires.
{: .fs-6 .fw-300 }

> **ภาษาไทย:** การย้าย Microsoft 365 จาก Tenant หนึ่งไปอีก Tenant หนึ่ง (เช่น M&A, Rebrand, แยกบริษัท) ครอบคลุม Mailbox, OneDrive, SharePoint, Teams, Users และ Intune ด้วยเครื่องมือ Microsoft แบบ Native และ PowerShell Script

{: .warning }
**Tenant migrations are high-risk and schedule-sensitive.** This page is a technical reference. Always run a **pilot batch (5–10 users)** end-to-end before production. Keep **both tenants licensed** during the overlap window.

---

## Table of Contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## 1. When to Migrate T2T

Common scenarios:

| Scenario | Scope | Typical Duration |
|----------|-------|------------------|
| **Merger / Acquisition** | Consolidate 2 tenants into 1 | 4–12 weeks |
| **Divestiture / Spin-off** | Split 1 tenant into 2 | 6–16 weeks |
| **Rebrand / domain change** | Move users to new tenant with new domain | 2–6 weeks |
| **Cloud consolidation** | Move from reseller / CSP tenant to direct | 2–4 weeks |
| **Compliance / data residency** | Move to a tenant in a different region | 4–8 weeks |

---

## 2. Decision Matrix — Native Tooling vs Third-Party

| Workload | Native Microsoft Tool | Third-Party (ShareGate / Quest / BitTitan / AvePoint) |
|----------|-----------------------|-------------------------------------------------------|
| **Mailboxes (Exchange Online)** | ✅ **Cross-Tenant Mailbox Migration (CTMM)** — free | Good for very large (>10,000) mailboxes or delta sync |
| **OneDrive for Business** | ⚠️ Limited native — SharePoint Migration Tool (SPMT) via user re-sign-in | ✅ Recommended for scale (ShareGate, BitTitan) |
| **SharePoint sites** | ⚠️ **Cross-tenant SharePoint migration** (preview in some regions) | ✅ Recommended (ShareGate, AvePoint) |
| **Teams (chats + channels)** | ⚠️ Native tool very limited | ✅ Required for Teams chat migration |
| **Users / Groups / Licenses** | ✅ Microsoft Graph PowerShell SDK (export → import) | Available but usually overkill |
| **Intune devices** | ⚠️ Re-enrollment usually required | Limited — most devices must re-enroll |
| **Entra ID objects (apps, CA, policies)** | ✅ Graph SDK — export/import | Usually not supported |

{: .highlight }
**Rule of thumb:** Use **Microsoft native tools** for mailboxes and identity. Use **third-party** for SharePoint/OneDrive/Teams at scale. Everything else, PowerShell.

---

## 3. Overall Migration Phases

```
┌─────────────────────────────────────────────────────────────────┐
│  Phase 1  Discovery & Planning          (2–4 weeks)             │
│  Phase 2  Target Tenant Preparation     (1–2 weeks)             │
│  Phase 3  Pilot Migration               (1–2 weeks)             │
│  Phase 4  Production Waves              (2–8 weeks)             │
│  Phase 5  Cutover + DNS Flip            (1 weekend)             │
│  Phase 6  Decommission Source Tenant    (30–90 days later)      │
└─────────────────────────────────────────────────────────────────┘
```

---

## 4. Phase 1 — Discovery & Planning

### 4.1 Inventory Source Tenant

Run this once against the **source** tenant to capture everything you need to re-create in the target.

```powershell
# Prerequisites: Microsoft.Graph + ExchangeOnlineManagement (see /docs/prerequisites)
Connect-MgGraph -Scopes `
    "User.Read.All","Group.Read.All","Directory.Read.All", `
    "Policy.Read.All","Application.Read.All","Organization.Read.All"
Connect-ExchangeOnline

$out = "C:\T2T\source-inventory"
New-Item -ItemType Directory -Force -Path $out | Out-Null

# Users
Get-MgUser -All -Property Id,UserPrincipalName,DisplayName,Mail,AccountEnabled,`
    UsageLocation,AssignedLicenses,Department,JobTitle |
    Export-Csv "$out\users.csv" -NoTypeInformation

# Groups (including Microsoft 365 groups + Security groups)
Get-MgGroup -All -Property Id,DisplayName,Mail,MailEnabled,SecurityEnabled,GroupTypes |
    Export-Csv "$out\groups.csv" -NoTypeInformation

# Licensed SKUs
Get-MgSubscribedSku | Select-Object SkuPartNumber,ConsumedUnits,`
    @{n="Enabled";e={$_.PrepaidUnits.Enabled}} |
    Export-Csv "$out\skus.csv" -NoTypeInformation

# Conditional Access policies (export as JSON for re-import)
Get-MgIdentityConditionalAccessPolicy -All |
    ConvertTo-Json -Depth 10 | Out-File "$out\ca-policies.json"

# Mailbox sizes (for migration batching)
Get-EXOMailbox -ResultSize Unlimited |
    Get-EXOMailboxStatistics |
    Select-Object DisplayName,ItemCount,
        @{n="SizeGB";e={[math]::Round(($_.TotalItemSize.Value.ToString().Split("(")[1].Split(" ")[0].Replace(",","") / 1GB), 2)}} |
    Export-Csv "$out\mailbox-sizes.csv" -NoTypeInformation

# Shared mailboxes + distribution lists
Get-EXOMailbox -RecipientTypeDetails SharedMailbox -ResultSize Unlimited |
    Export-Csv "$out\shared-mailboxes.csv" -NoTypeInformation
Get-DistributionGroup -ResultSize Unlimited |
    Export-Csv "$out\distribution-groups.csv" -NoTypeInformation

Write-Host "✔ Inventory exported to $out" -ForegroundColor Green
```

### 4.2 Plan the UPN Strategy

Users in the target tenant need a UPN. Three options:

| Strategy | When to Use | Impact |
|----------|-------------|--------|
| **Keep same UPN** (`user@contoso.com`) | Domain moves with the user | Only one tenant at a time can own the domain |
| **New UPN** (`user@newco.com`) | New company name / domain | Users must learn new sign-in; email aliases bridge the gap |
| **Temporary UPN** (`user@target.onmicrosoft.com`) | Cutover with planned domain-flip later | Fastest to pilot; disruptive if long-lived |

### 4.3 Migration Wave Planning

Group users into **waves of 50–200 mailboxes** to limit cutover blast radius:

- **Wave 0 — Pilot** (5–10 volunteers, mixed roles)
- **Wave 1 — IT department** (dogfood before business users)
- **Wave 2–N — Business units**, grouped so collaborators move together (same wave for same team)
- **Wave LAST — Executives + shared/service mailboxes**

---

## 5. Phase 2 — Target Tenant Preparation

Pre-build the target tenant to accept migrated content. Follow the main guide pages in order:

1. [Tenant Configuration]({{ site.baseurl }}/docs/tenant-configuration) — verify domains (do **not** yet remove from source), baseline security
2. [Microsoft Entra ID]({{ site.baseurl }}/docs/azure-ad-configuration) — Conditional Access **in report-only mode** (don't enforce until after migration)
3. [Microsoft Intune]({{ site.baseurl }}/docs/microsoft-endpoint-manager) — import device configuration + compliance policies
4. [Collaboration Governance]({{ site.baseurl }}/docs/collaboration-governance) — labels, retention, DLP (copy from source using Graph export)
5. Pre-create: all user accounts, security groups, DLs, M365 groups, SharePoint site shells

{: .warning }
**Do NOT verify the migrated domain in the target tenant until Phase 5 cutover.** The domain can only be verified in one tenant at a time; verifying prematurely locks out source-tenant users.

### Script: bulk-create users in target from source inventory

```powershell
# TARGET tenant — run after Connect-MgGraph to the TARGET
$users = Import-Csv "C:\T2T\source-inventory\users.csv"

foreach ($u in $users) {
    # Build target UPN — strategy here is "temporary onmicrosoft.com"
    $alias       = $u.UserPrincipalName.Split('@')[0]
    $targetUpn   = "$alias@targetco.onmicrosoft.com"
    $tempPass    = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 20 | % {[char]$_})

    $body = @{
        AccountEnabled    = $false     # Enable only at cutover
        DisplayName       = $u.DisplayName
        MailNickname      = $alias
        UserPrincipalName = $targetUpn
        PasswordProfile   = @{
            Password                      = $tempPass
            ForceChangePasswordNextSignIn = $true
        }
        UsageLocation     = ($u.UsageLocation -as [string]) -or "TH"
        Department        = $u.Department
        JobTitle          = $u.JobTitle
    }

    try {
        New-MgUser -BodyParameter $body | Out-Null
        Write-Host "✔ Created $targetUpn" -ForegroundColor Green
    } catch {
        Write-Warning "Failed $targetUpn : $($_.Exception.Message)"
    }
}
```

Store the generated passwords **securely** (Key Vault or password manager) — users will set their own at first sign-in.

---

## 6. Phase 3 — Cross-Tenant Mailbox Migration (CTMM)

Microsoft's **free, native, cross-tenant mailbox migration** uses a one-time **organization relationship** + **migration endpoint** between the two tenants.

### 6.1 One-Time Trust Setup (both tenants)

Follow Microsoft's prerequisites carefully — mailbox move fails without correct consent + app grants.

**Target tenant (destination):**

1. In the **target** tenant, create a mail-enabled security group `MigrationTarget` to hold users during migration.
2. Register a **cross-tenant migration application** — follow the official consent URL from [Microsoft's CTMM doc](https://learn.microsoft.com/en-us/microsoft-365/migration/cross-tenant-mailbox-migration){:target="_blank"}.
3. Consent the app on **both** tenants.

**Source tenant:**

1. Create an **organization relationship** pointing to the target tenant with `MailboxMoveEnabled = $true`.
2. Create a **migration endpoint** of type `ExchangeRemoteMove` targeting the target tenant.

```powershell
# SOURCE tenant — Exchange Online Management
Connect-ExchangeOnline

New-OrganizationRelationship `
    -Name "T2T-TargetTenant" `
    -DomainNames "targetco.onmicrosoft.com" `
    -MailboxMoveEnabled $true `
    -MailboxMoveCapability Inbound
```

### 6.2 Create a Migration Batch

```powershell
# TARGET tenant — Exchange Online Management
Connect-ExchangeOnline

# Prepare CSV with columns: EmailAddress
# EmailAddress = source UPN (user@sourceco.com)
$csvPath = "C:\T2T\migration-batches\wave1.csv"

New-MigrationBatch `
    -Name "T2T-Wave1" `
    -SourceEndpoint "T2T-SourceEndpoint" `
    -CSVData ([System.IO.File]::ReadAllBytes($csvPath)) `
    -AutoStart `
    -TargetDeliveryDomain "targetco.onmicrosoft.com" `
    -NotificationEmails @("migrations@targetco.onmicrosoft.com")
```

### 6.3 Monitor Progress

```powershell
# TARGET tenant
Get-MigrationBatch "T2T-Wave1" | Select-Object Identity,Status,`
    TotalCount,ActiveCount,CompletedCount,FailedCount

Get-MigrationUser -BatchId "T2T-Wave1" |
    Where-Object Status -in "Failed","Stopped" |
    Get-MigrationUserStatistics | Format-Table -AutoSize
```

### 6.4 Complete the Batch

Mailboxes stay in a **95% synced** state until you explicitly complete, allowing you to cut over per-user.

```powershell
Complete-MigrationBatch -Identity "T2T-Wave1"
```

Post-cutover: the user's primary mailbox now lives in the target tenant. The source tenant mailbox becomes a stub that auto-forwards.

---

## 7. Phase 4 — OneDrive for Business

OneDrive content doesn't move automatically with the mailbox. Two options:

### Option A — User-driven re-sync (free, up to ~500 users)

1. Ask each user to **unlink OneDrive** on their current device.
2. Sign in with the **target** UPN. OneDrive creates a new local folder.
3. User copies files from old (now archived) OneDrive folder → new OneDrive folder.

**Pro:** Zero licensing cost.
**Con:** Slow, error-prone, doesn't preserve "Shared with me" links.

### Option B — SharePoint Migration Tool (SPMT) + PnP.PowerShell

Automate server-side copy from source OneDrive URLs to target.

```powershell
# TARGET tenant admin
Install-Module PnP.PowerShell -Scope CurrentUser -MinimumVersion 2.0.0

Import-Module PnP.PowerShell

# Loop over inventory CSV (built in Phase 1)
$users = Import-Csv "C:\T2T\source-inventory\users.csv"

foreach ($u in $users) {
    $sourceOdUrl = "https://sourceco-my.sharepoint.com/personal/" +
                   ($u.UserPrincipalName -replace '[@.]','_')
    $targetOdUrl = "https://targetco-my.sharepoint.com/personal/" +
                   (($u.UserPrincipalName -replace '@sourceco\.com','@targetco.onmicrosoft.com') -replace '[@.]','_')

    Write-Host "Queueing OneDrive copy: $sourceOdUrl → $targetOdUrl"
    # Actual migration uses SPMT CSV or Add-PnPMigrationCopyJob — see PnP docs.
}
```

{: .note }
For >500 users or preservation of version history, use a third-party tool (ShareGate, BitTitan MigrationWiz) — Microsoft's native cross-tenant OneDrive migration is still maturing.

---

## 8. Phase 5 — SharePoint Sites & Teams

### 8.1 SharePoint

- **Cross-tenant SharePoint migration** (Microsoft native, preview/GA by region) handles classic + modern team sites.
- Alternative: **PnP.PowerShell** `Add-PnPMigrationCopyJob` loop over site inventory.
- Third-party tools (ShareGate / AvePoint) remain the most feature-complete for complex permissions + metadata preservation.

### 8.2 Teams

**Teams chats (1:1 and group chats) cannot be migrated between tenants** using native Microsoft tools. Options:

- Accept the loss — export critical chat history via **eDiscovery** to PST/CSV
- Use **BitTitan MigrationWiz for Teams** or **ShareGate for Teams**

**Teams channels + files** migrate with the underlying SharePoint site + Microsoft 365 group:

```powershell
# TARGET tenant — recreate M365 groups + Teams shells
Connect-MgGraph -Scopes "Group.ReadWrite.All","TeamsAppInstallation.ReadWriteForTeam.All"

$sourceGroups = Import-Csv "C:\T2T\source-inventory\groups.csv" |
    Where-Object GroupTypes -eq "Unified"

foreach ($g in $sourceGroups) {
    New-MgGroup -BodyParameter @{
        DisplayName  = $g.DisplayName
        MailEnabled  = $true
        MailNickname = $g.Mail.Split('@')[0]
        SecurityEnabled = $false
        GroupTypes   = @("Unified")
    } | Out-Null
}
# Then convert each group to a Team: New-MgTeam ...
```

---

## 9. Phase 6 — Identity, Groups, and Policies

### 9.1 Import Conditional Access Policies

```powershell
# TARGET tenant
Connect-MgGraph -Scopes "Policy.ReadWrite.ConditionalAccess"

$policies = Get-Content "C:\T2T\source-inventory\ca-policies.json" |
    ConvertFrom-Json -Depth 10

foreach ($p in $policies) {
    # Strip source-tenant IDs; rebuild objectIds in target
    $p.Id = $null
    $p.State = "disabled"   # Import disabled; enable after review

    New-MgIdentityConditionalAccessPolicy -BodyParameter $p
}
```

### 9.2 Assign Licenses in Target

```powershell
$licensedUsers = Import-Csv "C:\T2T\source-inventory\users.csv"
$sku = Get-MgSubscribedSku | Where-Object SkuPartNumber -eq "SPE_E3"

foreach ($u in $licensedUsers) {
    $targetUpn = "$($u.UserPrincipalName.Split('@')[0])@targetco.onmicrosoft.com"
    $user = Get-MgUser -Filter "userPrincipalName eq '$targetUpn'"
    if ($user) {
        Set-MgUserLicense -UserId $user.Id -AddLicenses @(@{SkuId = $sku.SkuId}) -RemoveLicenses @()
    }
}
```

---

## 10. Phase 7 — Device (Intune) Migration

Most endpoint-managed devices must **re-enroll** into the target tenant. Options:

| Device State | Migration Path |
|--------------|---------------|
| **Entra-joined Windows (no data on device)** | Microsoft Entra Leave → Entra Join target tenant → auto-enroll |
| **Entra-joined Windows with user data** | Backup user profile → re-join → restore → Known Folder Move via OneDrive |
| **Hybrid-joined Windows** | Breakglass path: unjoin, re-image with Autopilot in target tenant |
| **iOS / Android (MAM)** | Re-sign-in with target UPN re-triggers App Protection policies |
| **iOS / Android (MDM)** | **Must unenroll + re-enroll** (user wipe for personal, full wipe for corporate) |
| **macOS (JAMF Connect / Intune)** | Unenroll + re-enroll |

Script to **export** existing Intune policies from source to re-import into target:

```powershell
# SOURCE tenant — uses existing scripts in this repo
.\scripts\setup-intune\Export-Compliance.ps1           -OutputPath C:\T2T\intune
.\scripts\setup-intune\Export-DeviceConfiguration.ps1  -OutputPath C:\T2T\intune
.\scripts\setup-intune\Export-AppProtection.ps1        -OutputPath C:\T2T\intune
.\scripts\setup-intune\Export-EndpointSecurity.ps1     -OutputPath C:\T2T\intune
.\scripts\setup-intune\Export-Applications.ps1         -OutputPath C:\T2T\intune

# TARGET tenant — re-import
.\scripts\setup-intune\Import-Compliance.ps1           -InputPath C:\T2T\intune
.\scripts\setup-intune\Import-DeviceConfiguration.ps1  -InputPath C:\T2T\intune
.\scripts\setup-intune\Import-AppProtection.ps1        -InputPath C:\T2T\intune
.\scripts\setup-intune\Import-EndpointSecurity.ps1     -InputPath C:\T2T\intune
.\scripts\setup-intune\Import-Applications.ps1         -InputPath C:\T2T\intune
```

See [Downloads — Setup Intune]({{ site.baseurl }}/docs/downloads#setup-intune) for the full script list.

---

## 11. Phase 8 — Cutover Weekend

Ideal cutover window: **Friday 18:00 → Monday 06:00** (local).

### Pre-cutover (T-7 days)

- [ ] Freeze changes in source tenant (stop new mailbox provisioning, group creation)
- [ ] Final delta mailbox sync (CTMM re-sync)
- [ ] Final OneDrive delta sync
- [ ] Send end-user communication with new UPN + first-sign-in instructions
- [ ] Verify break-glass accounts exist in **target** tenant

### Cutover window (Friday night → Saturday)

- [ ] Stop mail flow to source
- [ ] **Remove** `contoso.com` domain from **source** tenant
- [ ] **Verify** `contoso.com` in **target** tenant
- [ ] Set MX record to point at target tenant's `contoso-com.mail.protection.outlook.com`
- [ ] Update Autodiscover CNAME
- [ ] Enable target-tenant user accounts; force password reset at next sign-in
- [ ] Complete all pending CTMM migration batches
- [ ] Flip Conditional Access policies from **Report-only** to **On** in target

### Post-cutover verification (Sunday → Monday)

- [ ] Send test email internal + external to confirm mail flow
- [ ] Have 2–3 pilot users log in and open Outlook / Teams / OneDrive
- [ ] Confirm sign-in logs show green in target Entra ID
- [ ] Check Mailbox delivery queue is draining (not backing up)
- [ ] Run the [Admin Monthly Report]({{ site.baseurl }}/docs/admin-monthly-report) baseline on the target

---

## 12. Phase 9 — Decommission Source Tenant

Wait at least **30 days** (ideally 90) before decommissioning:

1. Export **unified audit log** from source — needed for PDPA Records of Processing
2. Export **mailbox archives** of any ex-employees via eDiscovery → PST
3. Cancel licenses in source tenant → downgrades to free trial
4. Keep source tenant alive (free trial) for **1 year** to recover any missed data
5. Close tenant only after legal / compliance sign-off

---

## 13. Pre-Migration Readiness Checklist

- [ ] **Executive sponsor** identified + business case signed off
- [ ] **Migration window** agreed with business (avoid month-end, quarter-close)
- [ ] **Change-advisory board (CAB)** has approved the cutover weekend
- [ ] **Both tenants** have active Microsoft 365 licenses covering the overlap period
- [ ] **Source tenant** fully inventoried (Phase 1 scripts run)
- [ ] **Target tenant** baseline-configured (all guide pages followed)
- [ ] **CTMM organization relationship + endpoint** tested with pilot batch
- [ ] **Rollback plan** documented — what if cutover fails?
- [ ] **End-user communication** scheduled T-14, T-7, T-1, T-0
- [ ] **24x7 on-call rota** for cutover weekend
- [ ] **Microsoft Premier / Unified Support ticket** opened as pre-emptive engagement

---

## 14. References

- [Cross-tenant mailbox migration (Microsoft)](https://learn.microsoft.com/en-us/microsoft-365/migration/cross-tenant-mailbox-migration){:target="_blank"}
- [Cross-tenant OneDrive migration](https://learn.microsoft.com/en-us/microsoft-365/migration/cross-tenant-onedrive-migration){:target="_blank"} · [Cross-tenant SharePoint migration](https://learn.microsoft.com/en-us/microsoft-365/migration/cross-tenant-sharepoint-migration){:target="_blank"}
- [Plan for multitenant organizations in Microsoft 365 (MTO)](https://learn.microsoft.com/en-us/microsoft-365/enterprise/plan-multi-tenant-org-overview){:target="_blank"} · [What is a multitenant organization in Microsoft Entra ID?](https://learn.microsoft.com/en-us/entra/identity/multi-tenant-organizations/multi-tenant-organization-overview){:target="_blank"}
- [Microsoft Entra cross-tenant sync](https://learn.microsoft.com/en-us/entra/identity/multi-tenant-organizations/cross-tenant-synchronization-overview){:target="_blank"}
- [PnP.PowerShell — SharePoint migration](https://pnp.github.io/powershell/cmdlets/Add-PnPMigrationCopyJob.html){:target="_blank"}
- [BitTitan MigrationWiz](https://www.bittitan.com){:target="_blank"} · [ShareGate](https://sharegate.com){:target="_blank"} · [Quest On Demand Migration](https://www.quest.com/products/on-demand-migration/){:target="_blank"} · [AvePoint](https://www.avepoint.com){:target="_blank"}

---

## 15. Related Automation Scripts

Scripts in this repo useful for T2T:

- [`scripts/setup-intune/Export-*.ps1`]({{ site.baseurl }}/docs/downloads#export-scripts-backup) — backup Intune config from source
- [`scripts/setup-intune/Import-*.ps1`]({{ site.baseurl }}/docs/downloads#setup-intune) — restore into target
- [`scripts/azure-ad/Install-BaselineCAPolicies.ps1`]({{ site.baseurl }}/scripts/azure-ad/Install-BaselineCAPolicies.ps1){:download} — bootstrap CA in target
- [`scripts/exchange-online/Configure-Auditing.ps1`]({{ site.baseurl }}/scripts/exchange-online/Configure-Auditing.ps1){:download} — enable audit in target
- [`scripts/monthly-report/Get-M365MonthlyReport.ps1`]({{ site.baseurl }}/scripts/monthly-report/Get-M365MonthlyReport.ps1){:download} — baseline health on target before and after cutover

A dedicated **`scripts/migration/`** folder is planned with:

- `Export-TenantInventory.ps1` — bundles Phase 1 inventory into a single ZIP
- `New-TargetTenantUsers.ps1` — bulk-create users in target from source CSV
- `Start-CrossTenantMailboxBatch.ps1` — wrap `New-MigrationBatch` with pre-flight checks
- `Test-TenantCutoverReadiness.ps1` — final cutover gate: DNS, licenses, pilot sign-ins
