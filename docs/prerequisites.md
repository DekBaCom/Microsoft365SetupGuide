---
title: Prerequisites
layout: default
nav_order: 2
permalink: /docs/prerequisites
description: Licensing requirements, Microsoft Graph scopes, PowerShell modules, and tenant-readiness checks before running the Microsoft 365 Setup Guide.
---

# Prerequisites
{: .no_toc }

Everything you need **before** starting the setup — licensing, administrative access, PowerShell modules, Graph scopes, and a readiness-verification snippet.
{: .fs-6 .fw-300 }

---

## Table of Contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## 1. Administrative Access

| Requirement | Notes |
|-------------|-------|
| **Global Administrator** role | Required for initial tenant configuration, licensing, and Conditional Access deployment |
| **Security Administrator** role | Sufficient for ongoing security policy management after initial setup |
| **At least 2 break-glass (emergency access) accounts** | Cloud-only, excluded from all Conditional Access policies — see [Tenant Configuration]({{ site.baseurl }}/docs/tenant-configuration#emergency-access-accounts) |
| **Access to your DNS registrar** | Required for domain verification, SPF, DKIM, DMARC, and Autodiscover records |

{: .warning }
Do **not** proceed with Conditional Access deployment until you have verified that your break-glass accounts can sign in. A misconfigured CA policy without break-glass exclusions can lock the tenant permanently.

---

## 2. Licensing Matrix

Pick the plan that covers the features you intend to deploy. This is the minimum license per **feature**, not per user.

| Feature | Business Premium | E3 | E5 | Notes |
|---------|:---:|:---:|:---:|-------|
| Custom domain + SPF/DKIM/DMARC | ✅ | ✅ | ✅ | Included in all plans |
| Microsoft Defender for Office 365 (Plan 1) | ✅ | ➕ Add-on | ✅ | E3 requires MDO P1 add-on |
| Microsoft Defender for Office 365 (Plan 2) | ➕ | ➕ Add-on | ✅ | Required for Attack Simulation Training |
| Conditional Access (baseline) | ✅ | ✅ | ✅ | Requires **Microsoft Entra ID P1** (included) |
| Identity Protection (risk-based CA) | ❌ | ❌ | ✅ | Requires **Microsoft Entra ID P2** |
| Privileged Identity Management (PIM) | ❌ | ❌ | ✅ | Requires Entra ID P2 |
| Microsoft Intune (MDM + MAM) | ✅ | ✅ | ✅ | Included |
| Windows Autopilot | ✅ | ✅ | ✅ | Included |
| DLP (Exchange + SharePoint + OneDrive) | ✅ | ✅ | ✅ | Included |
| DLP (Teams chat + Endpoint DLP) | ❌ | ❌ | ✅ | Requires E5 Compliance |
| Sensitivity Labels (manual) | ✅ | ✅ | ✅ | Included |
| Sensitivity Labels (auto-apply) | ❌ | ❌ | ✅ | Requires E5 Compliance / E5 Information Protection |
| Retention Policies (basic) | ✅ | ✅ | ✅ | Included |
| Retention Labels (adaptive scopes, records) | ❌ | ❌ | ✅ | Requires E5 Compliance |
| Insider Risk Management | ❌ | ❌ | ✅ | Requires E5 Compliance |
| Communication Compliance | ❌ | ❌ | ✅ | Requires E5 Compliance |

> **Legend:** ✅ included · ➕ requires add-on · ❌ not available

{: .note }
Microsoft Entra ID P1/P2 can be purchased standalone for tenants on lower-tier plans. See the [official licensing comparison](https://learn.microsoft.com/en-us/entra/fundamentals/licensing){:target="_blank"}.

---

## 3. PowerShell Modules

All automation scripts in this guide have been modernized to prefer the **Microsoft Graph PowerShell SDK**.

{: .warning }
The legacy **AzureAD**, **AzureADPreview**, and **MSOnline** modules are **retired in 2026**. New scripts should use Microsoft Graph SDK. See [Microsoft's migration guidance](https://learn.microsoft.com/en-us/powershell/microsoftgraph/migration-steps){:target="_blank"}.

### Required Modules

```powershell
# Microsoft Graph SDK — primary automation module
Install-Module Microsoft.Graph             -Scope CurrentUser -MinimumVersion 2.0.0

# Exchange Online — required for mailbox / EOP / DLP automation
Install-Module ExchangeOnlineManagement    -Scope CurrentUser -MinimumVersion 3.0.0

# Microsoft Teams — required for Teams policies
Install-Module MicrosoftTeams              -Scope CurrentUser -MinimumVersion 5.0.0

# SharePoint Online (PnP.PowerShell is the modern replacement for SharePointOnline cmdlets)
Install-Module PnP.PowerShell              -Scope CurrentUser -MinimumVersion 2.0.0
```

### Optional / Legacy (for backward compatibility only)

```powershell
# Only required for a handful of scripts that haven't been migrated yet.
# Scheduled for removal in a future release.
Install-Module AzureAD                     -Scope CurrentUser
Install-Module MSOnline                    -Scope CurrentUser
```

### One-time setup

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

---

## 4. Microsoft Graph Scopes — Cheat Sheet

Scopes required to run the scripts in this guide. Call `Connect-MgGraph -Scopes ...` with the subset you need.

| Area | Scopes |
|------|--------|
| **Read users / groups / directory** | `User.Read.All`, `Group.Read.All`, `Directory.Read.All` |
| **Manage users / groups (write)** | `User.ReadWrite.All`, `Group.ReadWrite.All`, `Directory.ReadWrite.All` |
| **Conditional Access (read / write)** | `Policy.Read.All`, `Policy.ReadWrite.ConditionalAccess`, `Application.Read.All` |
| **Role assignments** | `RoleManagement.Read.Directory`, `RoleManagement.ReadWrite.Directory` |
| **Audit & sign-in logs** | `AuditLog.Read.All` |
| **Reports (license, usage)** | `Reports.Read.All`, `Organization.Read.All` |
| **Intune (read / write)** | `DeviceManagementConfiguration.ReadWrite.All`, `DeviceManagementManagedDevices.ReadWrite.All`, `DeviceManagementApps.ReadWrite.All` |
| **Information Protection / DLP** | `InformationProtectionPolicy.Read.All` |

### Sample connect block for the Monthly Report

```powershell
Connect-MgGraph -Scopes `
    "Reports.Read.All", `
    "User.Read.All", `
    "Directory.Read.All", `
    "AuditLog.Read.All", `
    "Organization.Read.All", `
    "RoleManagement.Read.Directory", `
    "Policy.Read.All"

Connect-ExchangeOnline
```

{: .note }
First-time use will prompt for admin consent. A Global Administrator must consent on behalf of the organization for application-wide scopes.

---

## 5. Verify-Your-Tenant Readiness Snippet

Run this once before starting the guide to confirm your tenant is ready. It checks license availability, Security Defaults state, module versions, and that at least one break-glass account exists.

```powershell
# ---------------------------------------------
# M365 Setup Guide — Tenant Readiness Check
# ---------------------------------------------
Connect-MgGraph -Scopes "Organization.Read.All","Policy.Read.All","User.Read.All","Directory.Read.All"

# 1. Confirm tenant identity
$org = Get-MgOrganization
Write-Host "✔ Tenant        : $($org.DisplayName)"   -ForegroundColor Green
Write-Host "✔ Tenant ID     : $($org.Id)"            -ForegroundColor Green
Write-Host "✔ Default domain: $(($org.VerifiedDomains | Where-Object IsDefault).Name)" -ForegroundColor Green

# 2. Check for available licenses
Get-MgSubscribedSku | Select-Object SkuPartNumber,
    @{n="Assigned";  e={$_.ConsumedUnits}},
    @{n="Available"; e={$_.PrepaidUnits.Enabled - $_.ConsumedUnits}} |
    Format-Table -AutoSize

# 3. Check Security Defaults state (should be OFF before CA deployment)
$sd = Get-MgPolicyIdentitySecurityDefaultEnforcementPolicy
if ($sd.IsEnabled) {
    Write-Warning "Security Defaults is ENABLED — must be disabled before deploying Conditional Access."
} else {
    Write-Host "✔ Security Defaults is OFF — OK for Conditional Access deployment." -ForegroundColor Green
}

# 4. Verify at least one break-glass account exists
$breakGlass = Get-MgUser -Filter "startsWith(displayName,'Break-glass') or startsWith(displayName,'Emergency')" -All
if ($breakGlass.Count -lt 1) {
    Write-Warning "No break-glass / emergency account found. Create at least 2 before CA deployment."
} else {
    Write-Host "✔ Break-glass accounts found: $($breakGlass.Count)" -ForegroundColor Green
}

# 5. Verify required modules installed
$required = @(
    @{Name="Microsoft.Graph";          Min="2.0.0"},
    @{Name="ExchangeOnlineManagement"; Min="3.0.0"},
    @{Name="MicrosoftTeams";           Min="5.0.0"}
)
foreach ($m in $required) {
    $inst = Get-Module -ListAvailable $m.Name | Sort-Object Version -Descending | Select-Object -First 1
    if (-not $inst) { Write-Warning "$($m.Name) not installed." }
    elseif ($inst.Version -lt [Version]$m.Min) { Write-Warning "$($m.Name) version $($inst.Version) < required $($m.Min)" }
    else { Write-Host "✔ $($m.Name) $($inst.Version)" -ForegroundColor Green }
}

Disconnect-MgGraph | Out-Null
```

---

## 6. Rollback & Safety

Before deploying anything irreversible (DLP, CA, retention policies):

- **Export existing settings first** — most sections of this guide have `Export-*.ps1` companion scripts in [Downloads]({{ site.baseurl }}/docs/downloads)
- **Deploy in Report-only mode** where supported (Conditional Access, DLP)
- **Pilot to a small security group** before targeting All Users
- **Document the rollback command** per policy (e.g., `Remove-MgIdentityConditionalAccessPolicy -ConditionalAccessPolicyId <id>`)

{: .highlight }
**Once prerequisites are met**, proceed to [Tenant Configuration]({{ site.baseurl }}/docs/tenant-configuration) and work through the guide in order.
