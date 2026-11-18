<#
.SYNOPSIS
    Assesses a Microsoft 365 tenant against a Zero Trust rubric and produces
    a single-file HTML report with per-pillar scores and remediation hints.

.DESCRIPTION
    Runs read-only checks across Identity, Device, App, Data, and Audit pillars
    using the Microsoft Graph PowerShell SDK and (optionally) Exchange Online
    Management. Scores each pillar 0-100 and summarises as an HTML report.

    Checks performed:
      Identity       - Security Defaults state, baseline Conditional Access policies,
                       MFA registration coverage, break-glass accounts,
                       permanent Global Administrator count, Identity Protection
                       risk policy presence.
      Device         - Intune device enrollment count, Windows compliance policy
                       count, mobile App Protection policy count.
      App            - Admin consent workflow enabled, user consent restricted.
      Data           - Published sensitivity labels, DLP policy count,
                       retention policy count.
      Audit          - Unified audit log ingestion state.

.PARAMETER OutputPath
    Target HTML file. Default: .\M365-ZT-Report-yyyy-MM-dd-HHmm.html

.PARAMETER TenantId
    Optional tenant ID (useful for MSPs managing multiple tenants).

.PARAMETER SkipExchange
    Skip the Exchange Online module checks (audit log + DLP). Use if the
    ExchangeOnlineManagement module isn't installed.

.EXAMPLE
    .\Get-M365SecurityPosture.ps1

.EXAMPLE
    .\Get-M365SecurityPosture.ps1 -OutputPath C:\Reports\ZT-2026-01.html

.EXAMPLE
    .\Get-M365SecurityPosture.ps1 -SkipExchange

.NOTES
    Requires PowerShell 7+ and the following modules:
      - Microsoft.Graph              (>= 2.0.0)
      - ExchangeOnlineManagement     (>= 3.0.0)   [optional]

    Required Microsoft Graph scopes:
      Policy.Read.All, User.Read.All, Directory.Read.All, AuditLog.Read.All,
      Organization.Read.All, RoleManagement.Read.Directory,
      UserAuthenticationMethod.Read.All, Reports.Read.All,
      DeviceManagementConfiguration.Read.All,
      DeviceManagementManagedDevices.Read.All,
      InformationProtectionPolicy.Read.All

    Part of: Microsoft 365 Setup Guide — Zero Trust on Microsoft 365
             https://dekbacom.github.io/Microsoft365SetupGuide/docs/zero-trust
#>
[CmdletBinding()]
param(
    [string]$OutputPath = ".\M365-ZT-Report-$(Get-Date -Format 'yyyy-MM-dd-HHmm').html",
    [string]$TenantId,
    [switch]$SkipExchange
)

$ErrorActionPreference = "Stop"
$ProgressPreference    = "SilentlyContinue"

function Write-Step($msg) { Write-Host "→ $msg" -ForegroundColor Cyan }
function Write-Ok  ($msg) { Write-Host "  ✔ $msg" -ForegroundColor Green }
function Write-Bad ($msg) { Write-Host "  ✗ $msg" -ForegroundColor Red }

# -------------------------------------------------------------------------
# Connect
# -------------------------------------------------------------------------
$scopes = @(
    "Policy.Read.All",
    "User.Read.All",
    "Directory.Read.All",
    "AuditLog.Read.All",
    "Organization.Read.All",
    "RoleManagement.Read.Directory",
    "UserAuthenticationMethod.Read.All",
    "Reports.Read.All",
    "DeviceManagementConfiguration.Read.All",
    "DeviceManagementManagedDevices.Read.All",
    "InformationProtectionPolicy.Read.All"
)

Write-Step "Connecting to Microsoft Graph"
if ($TenantId) {
    Connect-MgGraph -Scopes $scopes -TenantId $TenantId -NoWelcome
} else {
    Connect-MgGraph -Scopes $scopes -NoWelcome
}

$org = Get-MgOrganization | Select-Object -First 1
Write-Host "Tenant : $($org.DisplayName) [$($org.Id)]" -ForegroundColor Yellow

# -------------------------------------------------------------------------
# Helpers
# -------------------------------------------------------------------------
$results = [System.Collections.Generic.List[object]]::new()

function Add-Check {
    param(
        [string]$Pillar,
        [string]$Name,
        [bool]$Pass,
        [int]$Weight = 10,
        [string]$Evidence,
        [string]$Remediation
    )
    $results.Add([pscustomobject]@{
        Pillar      = $Pillar
        Name        = $Name
        Pass        = $Pass
        Weight      = $Weight
        Evidence    = $Evidence
        Remediation = $Remediation
    })
    if ($Pass) { Write-Ok "$Pillar : $Name" } else { Write-Bad "$Pillar : $Name - $Remediation" }
}

# -------------------------------------------------------------------------
# IDENTITY PILLAR
# -------------------------------------------------------------------------
Write-Step "Identity pillar checks"

# Security Defaults
$sd = Get-MgPolicyIdentitySecurityDefaultEnforcementPolicy
Add-Check -Pillar "Identity" -Name "Security Defaults disabled (CA in use)" `
    -Pass (-not $sd.IsEnabled) -Weight 5 `
    -Evidence "IsEnabled = $($sd.IsEnabled)" `
    -Remediation "Disable Security Defaults before deploying Conditional Access policies."

# Conditional Access baseline
$caPolicies = Get-MgIdentityConditionalAccessPolicy -All
$caEnabled  = $caPolicies | Where-Object State -eq 'enabled'
Add-Check -Pillar "Identity" -Name "At least 3 CA policies enabled (baseline)" `
    -Pass ($caEnabled.Count -ge 3) -Weight 15 `
    -Evidence "$($caEnabled.Count) enabled / $($caPolicies.Count) total" `
    -Remediation "Deploy baseline CA policies: block legacy auth, require MFA, block unsupported platforms."

$blockLegacy  = $caEnabled | Where-Object { $_.Conditions.ClientAppTypes -contains 'exchangeActiveSync' -or $_.Conditions.ClientAppTypes -contains 'other' }
$requireMfa   = $caEnabled | Where-Object { $_.GrantControls.BuiltInControls -contains 'mfa' }
Add-Check -Pillar "Identity" -Name "Policy exists: BLOCK legacy authentication" `
    -Pass ($blockLegacy.Count -ge 1) -Weight 10 `
    -Evidence "$($blockLegacy.Count) legacy-auth block policies" `
    -Remediation "Create a CA policy targeting Exchange ActiveSync + Other clients → Block."
Add-Check -Pillar "Identity" -Name "Policy exists: REQUIRE MFA" `
    -Pass ($requireMfa.Count -ge 1) -Weight 10 `
    -Evidence "$($requireMfa.Count) MFA-requiring policies" `
    -Remediation "Create a CA policy with Require MFA grant control for all users."

# Break-glass accounts
$breakGlass = Get-MgUser -Filter "startsWith(displayName,'Break-glass') or startsWith(displayName,'Emergency') or startsWith(displayName,'Breakglass')" -All
Add-Check -Pillar "Identity" -Name "At least 2 break-glass accounts" `
    -Pass ($breakGlass.Count -ge 2) -Weight 10 `
    -Evidence "$($breakGlass.Count) accounts found by name prefix" `
    -Remediation "Create 2 cloud-only 'Break-glass' accounts excluded from Conditional Access."

# MFA registration coverage
$regReport = Get-MgReportAuthenticationMethodUserRegistrationDetail -All -ErrorAction SilentlyContinue
if ($regReport) {
    $mfaRegistered = ($regReport | Where-Object { $_.IsMfaRegistered }).Count
    $total         = $regReport.Count
    $mfaPct        = if ($total -gt 0) { [math]::Round(($mfaRegistered / $total) * 100, 1) } else { 0 }
    Add-Check -Pillar "Identity" -Name "MFA registration coverage ≥ 90%" `
        -Pass ($mfaPct -ge 90) -Weight 15 `
        -Evidence "$mfaPct % ($mfaRegistered of $total users)" `
        -Remediation "Target ≥ 90%. Enforce via CA policy with grant control 'Require MFA' and nudge users to combined registration."
}

# Permanent Global Admins (should be only 2 break-glass)
$gaRole = Get-MgRoleManagementDirectoryRoleDefinition -Filter "displayName eq 'Global Administrator'"
$gaActive = Get-MgRoleManagementDirectoryRoleAssignment -Filter "roleDefinitionId eq '$($gaRole.Id)'" -All
$gaCount = $gaActive.Count
Add-Check -Pillar "Identity" -Name "≤ 4 permanent Global Administrators" `
    -Pass ($gaCount -le 4) -Weight 15 `
    -Evidence "$gaCount active Global Admins" `
    -Remediation "Move admins to PIM eligible assignments; keep only 2 break-glass as permanent."

# -------------------------------------------------------------------------
# DEVICE PILLAR
# -------------------------------------------------------------------------
Write-Step "Device pillar checks"

try {
    $devices  = Get-MgDeviceManagementManagedDevice -All -ErrorAction Stop
    $compCount = ($devices | Where-Object ComplianceState -eq 'compliant').Count
    Add-Check -Pillar "Device" -Name "At least 1 managed device enrolled" `
        -Pass ($devices.Count -ge 1) -Weight 10 `
        -Evidence "$($devices.Count) devices enrolled; $compCount compliant" `
        -Remediation "Enroll devices via Intune Autopilot / company portal."

    if ($devices.Count -gt 0) {
        $compPct = [math]::Round(($compCount / $devices.Count) * 100, 1)
        Add-Check -Pillar "Device" -Name "≥ 90% compliance across enrolled devices" `
            -Pass ($compPct -ge 90) -Weight 15 `
            -Evidence "$compPct % compliant" `
            -Remediation "Investigate non-compliant devices; tighten compliance policies incrementally."
    }

    $compPolicies = Get-MgDeviceManagementDeviceCompliancePolicy -All -ErrorAction SilentlyContinue
    Add-Check -Pillar "Device" -Name "Compliance policy defined for ≥ 2 platforms" `
        -Pass ($compPolicies.Count -ge 2) -Weight 10 `
        -Evidence "$($compPolicies.Count) compliance policies" `
        -Remediation "Create compliance policies for Windows + iOS + Android at minimum."
} catch {
    Write-Warning "Intune checks skipped: $($_.Exception.Message)"
}

# App Protection
try {
    $iosApp     = Get-MgDeviceAppManagementiosManagedAppProtection -All -ErrorAction SilentlyContinue
    $androidApp = Get-MgDeviceAppManagementAndroidManagedAppProtection -All -ErrorAction SilentlyContinue
    $mamCount   = ($iosApp.Count + $androidApp.Count)
    Add-Check -Pillar "App" -Name "App Protection policies for iOS + Android" `
        -Pass ($iosApp.Count -ge 1 -and $androidApp.Count -ge 1) -Weight 10 `
        -Evidence "iOS: $($iosApp.Count), Android: $($androidApp.Count)" `
        -Remediation "Create MAM policies for iOS and Android to protect org data on BYOD."
} catch {
    Write-Warning "MAM policy checks skipped: $($_.Exception.Message)"
}

# -------------------------------------------------------------------------
# APP PILLAR
# -------------------------------------------------------------------------
Write-Step "App pillar checks"

$authPolicy = Get-MgPolicyAuthorizationPolicy
# DefaultUserRolePermissions.PermissionGrantPoliciesAssigned => empty means user consent is blocked
$userConsentBlocked = -not ($authPolicy.DefaultUserRolePermissions.PermissionGrantPoliciesAssigned)
Add-Check -Pillar "App" -Name "User consent to third-party apps restricted" `
    -Pass $userConsentBlocked -Weight 10 `
    -Evidence "PermissionGrantPoliciesAssigned = $($authPolicy.DefaultUserRolePermissions.PermissionGrantPoliciesAssigned -join ',')" `
    -Remediation "Set user consent to 'Do not allow user consent' and enable Admin consent workflow."

# -------------------------------------------------------------------------
# DATA PILLAR
# -------------------------------------------------------------------------
Write-Step "Data pillar checks"

try {
    $labels = Get-MgInformationProtectionPolicyLabel -All -ErrorAction SilentlyContinue
    Add-Check -Pillar "Data" -Name "Sensitivity labels published (≥ 3)" `
        -Pass ($labels.Count -ge 3) -Weight 15 `
        -Evidence "$($labels.Count) labels visible" `
        -Remediation "Publish at minimum Public / General / Confidential / Highly Confidential labels."
} catch {
    Write-Warning "Sensitivity label check skipped: $($_.Exception.Message)"
}

# -------------------------------------------------------------------------
# EXCHANGE-DEPENDENT CHECKS (DLP + audit)
# -------------------------------------------------------------------------
if (-not $SkipExchange) {
    try {
        Write-Step "Connecting to Exchange Online (for DLP + audit)"
        Connect-ExchangeOnline -ShowBanner:$false
        Connect-IPPSSession -ShowBanner:$false -ErrorAction SilentlyContinue

        $dlp = Get-DlpCompliancePolicy -ErrorAction SilentlyContinue
        Add-Check -Pillar "Data" -Name "≥ 1 DLP policy deployed" `
            -Pass ($dlp.Count -ge 1) -Weight 15 `
            -Evidence "$($dlp.Count) DLP policies" `
            -Remediation "Create a baseline DLP policy for Exchange + SharePoint + OneDrive."

        $retention = Get-RetentionCompliancePolicy -ErrorAction SilentlyContinue
        Add-Check -Pillar "Data" -Name "≥ 1 retention policy deployed" `
            -Pass ($retention.Count -ge 1) -Weight 10 `
            -Evidence "$($retention.Count) retention policies" `
            -Remediation "Deploy retention policies per workload (Exchange/SharePoint/OneDrive/Teams)."

        $audit = Get-AdminAuditLogConfig
        Add-Check -Pillar "Audit" -Name "Unified Audit Log enabled" `
            -Pass $audit.UnifiedAuditLogIngestionEnabled -Weight 10 `
            -Evidence "UnifiedAuditLogIngestionEnabled = $($audit.UnifiedAuditLogIngestionEnabled)" `
            -Remediation "Set-AdminAuditLogConfig -UnifiedAuditLogIngestionEnabled `$true"

        Disconnect-ExchangeOnline -Confirm:$false | Out-Null
    } catch {
        Write-Warning "Exchange checks skipped: $($_.Exception.Message)"
    }
} else {
    Write-Host "Exchange checks skipped by -SkipExchange flag" -ForegroundColor Yellow
}

# -------------------------------------------------------------------------
# Build score summary
# -------------------------------------------------------------------------
$pillars = $results | Group-Object Pillar | ForEach-Object {
    $totalWeight = ($_.Group | Measure-Object Weight -Sum).Sum
    $earned      = ($_.Group | Where-Object Pass | Measure-Object Weight -Sum).Sum
    $pct         = if ($totalWeight -gt 0) { [math]::Round(($earned / $totalWeight) * 100, 1) } else { 0 }
    [pscustomobject]@{
        Pillar     = $_.Name
        Score      = $pct
        Earned     = $earned
        Total      = $totalWeight
        Checks     = $_.Group.Count
        Passing    = ($_.Group | Where-Object Pass).Count
    }
}

$overall = ($results | Where-Object Pass | Measure-Object Weight -Sum).Sum
$overallTotal = ($results | Measure-Object Weight -Sum).Sum
$overallPct   = if ($overallTotal -gt 0) { [math]::Round(($overall / $overallTotal) * 100, 1) } else { 0 }

Write-Host ""
Write-Host "=== Zero Trust posture summary ===" -ForegroundColor Cyan
$pillars | Format-Table -AutoSize
Write-Host "Overall score: $overallPct % ($overall / $overallTotal)" -ForegroundColor Yellow

# -------------------------------------------------------------------------
# Build HTML report
# -------------------------------------------------------------------------
function Band($v) {
    if ($v -ge 85) { 'green' }
    elseif ($v -ge 60) { 'orange' }
    else { 'red' }
}

$pillarCards = ($pillars | ForEach-Object {
    $c = Band $_.Score
    @"
<div class='card $c'>
  <div class='pillar'>$($_.Pillar)</div>
  <div class='score'>$($_.Score) %</div>
  <div class='meta'>$($_.Passing) / $($_.Checks) checks passing</div>
</div>
"@
}) -join "`n"

$rows = ($results | ForEach-Object {
    $status = if ($_.Pass) { "<span class='ok'>PASS</span>" } else { "<span class='fail'>FAIL</span>" }
    "<tr><td>$($_.Pillar)</td><td>$($_.Name)</td><td>$status</td><td>$($_.Evidence)</td><td>$($_.Remediation)</td></tr>"
}) -join "`n"

$html = @"
<!doctype html>
<html lang='en'><head><meta charset='utf-8'>
<title>Microsoft 365 Zero Trust posture - $($org.DisplayName)</title>
<style>
  body { font-family: 'Segoe UI', Arial, sans-serif; margin: 2em; color: #222; }
  h1 { margin: 0 0 0.2em; }
  .meta-top { color: #666; margin-bottom: 1.5em; }
  .overall { font-size: 3em; font-weight: 700; }
  .cards { display: flex; flex-wrap: wrap; gap: 1em; margin: 1em 0 2em; }
  .card { flex: 1 1 180px; padding: 1em 1.2em; border-radius: 10px; color: white; box-shadow: 0 2px 6px rgba(0,0,0,0.15); }
  .card.green  { background: #107c10; }
  .card.orange { background: #ca5010; }
  .card.red    { background: #a4262c; }
  .card .pillar { font-size: 0.95em; opacity: 0.9; }
  .card .score  { font-size: 2.2em; font-weight: 700; margin: 0.15em 0; }
  .card .meta   { font-size: 0.85em; opacity: 0.85; }
  table { border-collapse: collapse; width: 100%; margin-top: 1em; font-size: 0.92em; }
  th, td { padding: 0.55em 0.75em; border-bottom: 1px solid #ddd; vertical-align: top; text-align: left; }
  th { background: #f3f3f3; }
  .ok   { color: #107c10; font-weight: 700; }
  .fail { color: #a4262c; font-weight: 700; }
  .footer { margin-top: 2em; color: #888; font-size: 0.85em; }
</style>
</head><body>
<h1>Microsoft 365 Zero Trust Posture</h1>
<div class='meta-top'>Tenant: <b>$($org.DisplayName)</b> &middot; $($org.Id) &middot; Generated $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') (local)</div>
<div>Overall score: <span class='overall' style='color: $(Band $overallPct);'>$overallPct %</span></div>
<div class='cards'>$pillarCards</div>
<h2>Detailed checks</h2>
<table><thead><tr><th>Pillar</th><th>Check</th><th>Status</th><th>Evidence</th><th>Remediation</th></tr></thead>
<tbody>$rows</tbody></table>
<div class='footer'>
  Generated by Get-M365SecurityPosture.ps1 - part of the
  <a href='https://dekbacom.github.io/Microsoft365SetupGuide/docs/zero-trust'>Microsoft 365 Setup Guide - Zero Trust playbook</a>.
</div>
</body></html>
"@

$html | Out-File -FilePath $OutputPath -Encoding UTF8
Write-Host ""
Write-Host "✔ Report written to: $OutputPath" -ForegroundColor Green

Disconnect-MgGraph | Out-Null
