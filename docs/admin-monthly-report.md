---
title: Admin Monthly Report
layout: default
nav_order: 7
permalink: /docs/admin-monthly-report
---

# Admin Monthly Report
{: .no_toc }

A PowerShell script that generates a comprehensive, single-file HTML report covering all critical Microsoft 365 health metrics — designed to be run by administrators at the end of each month.
{: .fs-6 .fw-300 }

{: .highlight }
[Download Get-M365MonthlyReport.ps1]({{ site.baseurl }}/scripts/monthly-report/Get-M365MonthlyReport.ps1){:download}

---

## Table of Contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## What the Report Covers

The HTML report includes **8 sections**, all in a single portable file:

| Section | What It Shows |
|---------|---------------|
| License Usage | Assigned vs. available seats, usage %, near-capacity warnings |
| User Account Status | Active, inactive, never-signed-in, and blocked accounts |
| MFA Enrollment | MFA coverage %, list of users without MFA |
| Guest Users | Total guests, active vs. blocked, guests older than 90 days |
| Conditional Access | All CA policies with state and grant controls |
| Mailbox Usage | Total storage, top 10 largest mailboxes, near-quota mailboxes |
| Admin Role Assignments | All admin role holders across the tenant |
| Sign-in Failures | Top accounts with failed sign-ins in the past 30 days |

---

## Prerequisites

### PowerShell Modules

```powershell
# Microsoft Graph (required)
Install-Module Microsoft.Graph -Scope CurrentUser

# Exchange Online (required for mailbox section)
Install-Module ExchangeOnlineManagement -Scope CurrentUser
```

### Required Graph API Permissions

The script uses delegated permissions (runs as signed-in admin):

| Permission | Used For |
|-----------|----------|
| `Reports.Read.All` | Usage reports |
| `User.Read.All` | User account and sign-in data |
| `Directory.Read.All` | Groups, roles, policies |
| `AuditLog.Read.All` | Sign-in failure logs |
| `Organization.Read.All` | Tenant overview |
| `RoleManagement.Read.Directory` | Admin role assignments |
| `Policy.Read.All` | Conditional Access policies |

---

## Quick Start

```powershell
# 1. Set execution policy (run once)
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

# 2. Run the report (basic)
.\Get-M365MonthlyReport.ps1

# 3. Run with custom output path
.\Get-M365MonthlyReport.ps1 -OutputPath "C:\Reports\M365-April-2025.html"

# 4. Change inactive user threshold (default: 30 days)
.\Get-M365MonthlyReport.ps1 -InactiveDaysThreshold 60

# 5. Specify tenant (useful for MSPs managing multiple tenants)
.\Get-M365MonthlyReport.ps1 -TenantId "your-tenant-id-here"
```

The report opens automatically in your default browser when complete.

---

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `-TenantId` | String | *(current)* | Target tenant ID — useful for multi-tenant |
| `-InactiveDaysThreshold` | Int | `30` | Days without sign-in before marking as inactive |
| `-OutputPath` | String | `.\M365-Monthly-Report-YYYY-MM.html` | Output file path |

---

## Sample Output

The report generates a single HTML file with color-coded KPI cards and sortable tables:

- **Green** = Healthy (MFA coverage ≥ 90%, license usage normal)
- **Orange** = Warning (MFA coverage 70–89%, license usage ≥ 75%)
- **Red** = Action needed (No MFA, license near full, blocked accounts)

---

## Community Scripts from GitHub

The following open-source repositories provide additional specialized reports that complement the monthly report:

### AdminDroid Community Scripts
**[github.com/admindroid-community/powershell-scripts](https://github.com/admindroid-community/powershell-scripts)**
> 100+ production-ready M365 reporting scripts, actively maintained.

| Script | Description |
|--------|-------------|
| `GetMFAStatus.ps1` | Detailed MFA status per user |
| `GuestUserReport.ps1` | Guest users with group membership |
| `AdminActivityReport.ps1` | Audit M365 admin activities |
| `O365LicenseReportingAndManagement.ps1` | License cost and usage |

---

### Office365itpros (Tony Redmond)
**[github.com/12Knocksinna/Office365itpros](https://github.com/12Knocksinna/Office365itpros)**
> Companion scripts for *Automating Microsoft 365 with PowerShell* — well-documented and production-proven.

| Script | Description |
|--------|-------------|
| `Report-UserSignIns.PS1` | User sign-in activity and app usage |
| `Report-GroupsTeamsActivity.PS1` | Teams and Groups activity |
| `Report-NonMFASignIns.PS1` | Sign-ins without MFA |
| `Report-RoleAssignments.PS1` | Entra ID role assignments |
| `ReportSPOSiteStorageUsage.PS1` | SharePoint site storage |
| `FindOldGuestUsers.ps1` | Stale guest account detection |

---

### M365.Report.Tools Module
**[github.com/djust270/M365.Report.Tools](https://github.com/djust270/M365.Report.Tools)**
> PowerShell module available from the PowerShell Gallery — install once, run anywhere.

```powershell
# Install
Install-Module M365.Report.Tools -Scope CurrentUser

# Example usage
Get-M365UserReport | Export-Excel -Path "Users.xlsx"
Get-M365LicenseReport | Export-Excel -Path "Licenses.xlsx"
```

---

### M365 Identity Posture (Security Focus)
**[github.com/Noble-Effeciency13/M365IdentityPosture](https://github.com/Noble-Effeciency13/M365IdentityPosture)**
> Advanced security posture reports — Conditional Access mapping, PIM analysis, sensitivity label coverage. Outputs interactive HTML.

---

### SharePoint Online Script Samples
**[github.com/PowershellScripts/SharePointOnline-ScriptSamples](https://github.com/PowershellScripts/SharePointOnline-ScriptSamples)**
> 260+ scripts for SharePoint Online, OneDrive, and SharePoint Server reporting.

---

## Recommended Monthly Checklist

Run these checks at the end of each month:

```
[ ] Run Get-M365MonthlyReport.ps1 and save the HTML file
[ ] Review users with no MFA — follow up or block accounts
[ ] Review inactive users > 30 days — disable if no longer needed
[ ] Review guest users > 90 days — confirm still required
[ ] Check licenses near capacity — request new seats if needed
[ ] Verify all Conditional Access policies are Enabled (not disabled)
[ ] Review admin role holders — remove any unnecessary assignments
[ ] Check mailboxes near quota (> 45 GB) — apply archive or cleanup
[ ] Review top sign-in failures — investigate potential attacks
```

---

## Scheduling Monthly Reports (Task Scheduler)

Run the report automatically on the first day of each month:

```powershell
# Create a scheduled task to run monthly
$action  = New-ScheduledTaskAction -Execute "pwsh.exe" `
           -Argument "-NonInteractive -File C:\Scripts\Get-M365MonthlyReport.ps1 -OutputPath C:\Reports\M365-Report-$(Get-Date -Format 'yyyy-MM').html"
$trigger = New-ScheduledTaskTrigger -Monthly -DaysOfMonth 1 -At "08:00"
$settings = New-ScheduledTaskSettingsSet -RunOnlyIfNetworkAvailable

Register-ScheduledTask -TaskName "M365 Monthly Report" `
    -Action $action -Trigger $trigger -Settings $settings `
    -RunLevel Highest
```

{: .note }
For unattended scheduled runs, use a **Service Principal** with a **Client Secret or Certificate** instead of interactive sign-in. See [Microsoft Graph authentication documentation](https://learn.microsoft.com/en-us/graph/auth-overview).
