<#
.SYNOPSIS
    Microsoft 365 Admin Monthly Report
.DESCRIPTION
    Generates a comprehensive HTML monthly report covering:
    - Tenant Overview
    - License Usage
    - User Account Status (Active / Inactive / Blocked)
    - MFA Enrollment Status
    - Guest Users
    - Conditional Access Policies Status
    - Mailbox Usage
    - SharePoint & OneDrive Storage
    - Teams Activity
    - Sign-in Failures & Risky Sign-ins
    - Admin Role Assignments

.NOTES
    Author  : Mr. Abdulloh Etaeluengoh
    Role    : Microsoft 365 Solution Architect
    Email   : Abdulloh.eg@gmail.com
    GitHub  : https://github.com/DekBaCom

    Requirements:
    - PowerShell 5.1 or later
    - Microsoft Graph PowerShell SDK
        Install-Module Microsoft.Graph -Scope CurrentUser
    - ExchangeOnlineManagement module (for mailbox reports)
        Install-Module ExchangeOnlineManagement -Scope CurrentUser
    - Permissions required (Graph):
        Reports.Read.All, User.Read.All, Directory.Read.All,
        AuditLog.Read.All, Organization.Read.All,
        MailboxSettings.Read, Sites.Read.All
#>

[CmdletBinding()]
param(
    [Parameter()]
    [string]$TenantId,

    [Parameter()]
    [int]$InactiveDaysThreshold = 30,

    [Parameter()]
    [string]$OutputPath = ".\M365-Monthly-Report-$(Get-Date -Format 'yyyy-MM').html"
)

#region --- Functions ---

function Connect-M365Services {
    Write-Host "[*] Connecting to Microsoft Graph..." -ForegroundColor Cyan
    $scopes = @(
        "Reports.Read.All",
        "User.Read.All",
        "Directory.Read.All",
        "AuditLog.Read.All",
        "Organization.Read.All",
        "RoleManagement.Read.Directory",
        "Policy.Read.All"
    )
    $connectParams = @{ Scopes = $scopes }
    if ($TenantId) { $connectParams.TenantId = $TenantId }
    Connect-MgGraph @connectParams -NoWelcome

    Write-Host "[*] Connecting to Exchange Online..." -ForegroundColor Cyan
    Connect-ExchangeOnline -ShowBanner:$false
}

function Get-TenantOverview {
    Write-Host "[*] Collecting tenant overview..." -ForegroundColor Yellow
    $org = Get-MgOrganization | Select-Object -First 1
    return [PSCustomObject]@{
        TenantName    = $org.DisplayName
        TenantId      = $org.Id
        Country       = $org.CountryLetterCode
        CreatedDate   = $org.CreatedDateTime
        ReportMonth   = (Get-Date -Format "MMMM yyyy")
        GeneratedDate = (Get-Date -Format "dd/MM/yyyy HH:mm")
    }
}

function Get-LicenseReport {
    Write-Host "[*] Collecting license usage..." -ForegroundColor Yellow
    $skus = Get-MgSubscribedSku | Where-Object { $_.CapabilityStatus -eq "Enabled" }
    $result = foreach ($sku in $skus) {
        $consumed = $sku.ConsumedUnits
        $total    = $sku.PrepaidUnits.Enabled
        $available = $total - $consumed
        $pct = if ($total -gt 0) { [math]::Round(($consumed / $total) * 100, 1) } else { 0 }
        [PSCustomObject]@{
            License   = $sku.SkuPartNumber
            Total     = $total
            Assigned  = $consumed
            Available = $available
            UsagePct  = "$pct%"
            Status    = if ($pct -ge 90) { "Critical" } elseif ($pct -ge 75) { "Warning" } else { "OK" }
        }
    }
    return $result | Sort-Object UsagePct -Descending
}

function Get-UserStatusReport {
    Write-Host "[*] Collecting user account status..." -ForegroundColor Yellow
    $cutoff = (Get-Date).AddDays(-$InactiveDaysThreshold)
    $users  = Get-MgUser -All -Property DisplayName,UserPrincipalName,AccountEnabled,SignInActivity,UserType,CreatedDateTime `
                | Where-Object { $_.UserType -eq "Member" }

    $active   = 0; $inactive = 0; $blocked = 0; $never = 0
    $inactiveList = @()

    foreach ($u in $users) {
        if (-not $u.AccountEnabled) { $blocked++; continue }
        $lastSignIn = $u.SignInActivity.LastSignInDateTime
        if (-not $lastSignIn) { $never++; $inactiveList += $u; continue }
        if ($lastSignIn -lt $cutoff) { $inactive++; $inactiveList += $u } else { $active++ }
    }

    return [PSCustomObject]@{
        TotalMembers   = $users.Count
        Active         = $active
        Inactive       = $inactive
        NeverSignedIn  = $never
        Blocked        = $blocked
        InactiveUsers  = ($inactiveList | Select-Object DisplayName, UserPrincipalName,
                            @{N="LastSignIn";E={ $_.SignInActivity.LastSignInDateTime }} |
                            Sort-Object LastSignIn | Select-Object -First 10)
    }
}

function Get-MFAStatusReport {
    Write-Host "[*] Collecting MFA status..." -ForegroundColor Yellow
    $users = Get-MgUser -All -Property DisplayName,UserPrincipalName,AccountEnabled,UserType `
             | Where-Object { $_.UserType -eq "Member" -and $_.AccountEnabled }

    $mfaEnabled = 0; $mfaDisabled = 0; $noMfaList = @()

    foreach ($u in $users) {
        $methods = Get-MgUserAuthenticationMethod -UserId $u.Id
        $hasMfa  = $methods | Where-Object {
            $_.AdditionalProperties["@odata.type"] -notin @(
                "#microsoft.graph.passwordAuthenticationMethod"
            )
        }
        if ($hasMfa) { $mfaEnabled++ } else {
            $mfaDisabled++
            $noMfaList += $u
        }
    }

    return [PSCustomObject]@{
        TotalEnabled  = $users.Count
        MFAEnabled    = $mfaEnabled
        MFADisabled   = $mfaDisabled
        MFAPct        = if ($users.Count -gt 0) { [math]::Round(($mfaEnabled / $users.Count) * 100, 1) } else { 0 }
        UsersWithoutMFA = ($noMfaList | Select-Object DisplayName, UserPrincipalName | Select-Object -First 10)
    }
}

function Get-GuestUserReport {
    Write-Host "[*] Collecting guest user data..." -ForegroundColor Yellow
    $guests  = Get-MgUser -All -Filter "userType eq 'Guest'" -Property DisplayName,UserPrincipalName,Mail,CreatedDateTime,AccountEnabled
    $active  = ($guests | Where-Object { $_.AccountEnabled }).Count
    $blocked = ($guests | Where-Object { -not $_.AccountEnabled }).Count
    $cutoff  = (Get-Date).AddDays(-90)
    $old     = $guests | Where-Object { $_.CreatedDateTime -lt $cutoff }

    return [PSCustomObject]@{
        TotalGuests  = $guests.Count
        ActiveGuests = $active
        BlockedGuests= $blocked
        OldGuests    = $old.Count
        OldGuestList = ($old | Select-Object DisplayName, UserPrincipalName,
                            @{N="CreatedDate";E={ $_.CreatedDateTime.ToString("dd/MM/yyyy") }} |
                            Sort-Object CreatedDate | Select-Object -First 10)
    }
}

function Get-AdminRoleReport {
    Write-Host "[*] Collecting admin role assignments..." -ForegroundColor Yellow
    $roles       = Get-MgDirectoryRole -All
    $assignments = @()
    foreach ($role in $roles) {
        $members = Get-MgDirectoryRoleMember -DirectoryRoleId $role.Id
        foreach ($m in $members) {
            $assignments += [PSCustomObject]@{
                Role = $role.DisplayName
                Member = $m.AdditionalProperties["displayName"]
                UPN    = $m.AdditionalProperties["userPrincipalName"]
            }
        }
    }
    return $assignments | Sort-Object Role
}

function Get-CAPolciesReport {
    Write-Host "[*] Collecting Conditional Access policies..." -ForegroundColor Yellow
    $policies = Get-MgIdentityConditionalAccessPolicy -All
    return $policies | Select-Object DisplayName,
        @{N="State";E={ $_.State }},
        @{N="Users";E={ if ($_.Conditions.Users.IncludeUsers -contains "All") { "All Users" } else { "Specific Users/Groups" } }},
        @{N="Apps";E={ if ($_.Conditions.Applications.IncludeApplications -contains "All") { "All Apps" } else { "Specific Apps" } }},
        @{N="Grant";E={ ($_.GrantControls.BuiltInControls -join ", ") }} |
        Sort-Object State, DisplayName
}

function Get-MailboxUsageReport {
    Write-Host "[*] Collecting mailbox usage..." -ForegroundColor Yellow
    $report = Get-EXOMailbox -ResultSize Unlimited -PropertySets Minimum |
              Get-EXOMailboxStatistics |
              Select-Object DisplayName,
                  @{N="SizeGB";E={ [math]::Round($_.TotalItemSize.Value.ToBytes() / 1GB, 2) }},
                  ItemCount,
                  @{N="QuotaGB";E={ 50 }}  # default M365 quota

    $total     = ($report | Measure-Object SizeGB -Sum).Sum
    $topBoxes  = $report | Sort-Object SizeGB -Descending | Select-Object -First 10
    $overQuota = $report | Where-Object { $_.SizeGB -ge 45 }

    return [PSCustomObject]@{
        TotalMailboxes = $report.Count
        TotalUsedGB    = [math]::Round($total, 2)
        TopMailboxes   = $topBoxes
        NearQuota      = $overQuota
    }
}

function Get-SignInFailureReport {
    Write-Host "[*] Collecting sign-in failures (last 30 days)..." -ForegroundColor Yellow
    $start = (Get-Date).AddDays(-30).ToString("yyyy-MM-ddTHH:mm:ssZ")
    $filter = "createdDateTime ge $start and status/errorCode ne 0"

    try {
        $failures = Get-MgAuditLogSignIn -Filter $filter -Top 999 |
                    Group-Object { $_.UserPrincipalName } |
                    Select-Object @{N="User";E={ $_.Name }}, @{N="Failures";E={ $_.Count }} |
                    Sort-Object Failures -Descending |
                    Select-Object -First 10
        return $failures
    } catch {
        return @([PSCustomObject]@{ User = "Requires AuditLog.Read.All permission"; Failures = 0 })
    }
}

#endregion

#region --- HTML Report Builder ---

function Build-HTMLReport {
    param(
        $Overview, $Licenses, $Users, $MFA, $Guests,
        $AdminRoles, $CAPolicies, $Mailboxes, $SignInFailures
    )

    function StatusBadge($status) {
        $color = switch ($status) {
            "Critical" { "#dc3545" }
            "Warning"  { "#fd7e14" }
            "OK"       { "#198754" }
            "Enabled"  { "#198754" }
            "disabled" { "#6c757d" }
            "enabledForReportingButNotEnforced" { "#fd7e14" }
            default    { "#0dcaf0" }
        }
        return "<span style='background:$color;color:#fff;padding:2px 8px;border-radius:4px;font-size:0.8em;'>$status</span>"
    }

    function TableRows($data, $props) {
        if (-not $data) { return "<tr><td colspan='$($props.Count)' style='text-align:center;color:#888;'>No data</td></tr>" }
        ($data | ForEach-Object {
            $row = $_
            "<tr>" + ($props | ForEach-Object { "<td>$($row.$_)</td>" }) -join "" + "</tr>"
        }) -join ""
    }

    $mfaColor = if ($MFA.MFAPct -ge 90) { "#198754" } elseif ($MFA.MFAPct -ge 70) { "#fd7e14" } else { "#dc3545" }

    $licenseRows = ($Licenses | ForEach-Object {
        $badge = StatusBadge $_.Status
        "<tr><td>$($_.License)</td><td>$($_.Total)</td><td>$($_.Assigned)</td><td>$($_.Available)</td><td>$($_.UsagePct)</td><td>$badge</td></tr>"
    }) -join ""

    $caRows = ($CAPolicies | ForEach-Object {
        $badge = StatusBadge $_.State
        "<tr><td>$($_.DisplayName)</td><td>$badge</td><td>$($_.Users)</td><td>$($_.Apps)</td><td>$($_.Grant)</td></tr>"
    }) -join ""

    $roleRows = ($AdminRoles | ForEach-Object {
        "<tr><td>$($_.Role)</td><td>$($_.Member)</td><td>$($_.UPN)</td></tr>"
    }) -join ""

    $mailboxRows = ($Mailboxes.TopMailboxes | ForEach-Object {
        "<tr><td>$($_.DisplayName)</td><td>$($_.SizeGB) GB</td><td>$($_.ItemCount)</td></tr>"
    }) -join ""

    $signInRows = ($SignInFailures | ForEach-Object {
        "<tr><td>$($_.User)</td><td>$($_.Failures)</td></tr>"
    }) -join ""

    $inactiveRows = ($Users.InactiveUsers | ForEach-Object {
        "<tr><td>$($_.DisplayName)</td><td>$($_.UserPrincipalName)</td><td>$($_.LastSignIn)</td></tr>"
    }) -join ""

    $noMfaRows = ($MFA.UsersWithoutMFA | ForEach-Object {
        "<tr><td>$($_.DisplayName)</td><td>$($_.UserPrincipalName)</td></tr>"
    }) -join ""

    $guestRows = ($Guests.OldGuestList | ForEach-Object {
        "<tr><td>$($_.DisplayName)</td><td>$($_.UserPrincipalName)</td><td>$($_.CreatedDate)</td></tr>"
    }) -join ""

    $html = @"
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>M365 Admin Monthly Report - $($Overview.ReportMonth)</title>
<style>
  * { box-sizing:border-box; margin:0; padding:0; }
  body { font-family:'Segoe UI',Arial,sans-serif; background:#f4f6f9; color:#212529; }
  .header { background:linear-gradient(135deg,#0078d4,#005a9e); color:#fff; padding:32px 40px; }
  .header h1 { font-size:1.8em; font-weight:700; }
  .header p  { opacity:.85; margin-top:4px; }
  .meta { display:flex; gap:24px; margin-top:16px; flex-wrap:wrap; }
  .meta span { background:rgba(255,255,255,.15); padding:4px 12px; border-radius:20px; font-size:.85em; }
  .container { max-width:1200px; margin:0 auto; padding:24px 20px; }
  .section { background:#fff; border-radius:8px; box-shadow:0 1px 4px rgba(0,0,0,.08); margin-bottom:24px; overflow:hidden; }
  .section-header { background:#f8f9fa; border-bottom:1px solid #e9ecef; padding:14px 20px; display:flex; align-items:center; gap:10px; }
  .section-header h2 { font-size:1em; font-weight:600; color:#495057; }
  .section-icon { font-size:1.3em; }
  .section-body { padding:20px; }
  .kpi-grid { display:grid; grid-template-columns:repeat(auto-fit,minmax(140px,1fr)); gap:16px; }
  .kpi { text-align:center; padding:16px 8px; border-radius:6px; background:#f8f9fa; }
  .kpi .val { font-size:2em; font-weight:700; color:#0078d4; }
  .kpi .lbl { font-size:.75em; color:#6c757d; margin-top:4px; text-transform:uppercase; letter-spacing:.5px; }
  .kpi.warn .val { color:#fd7e14; }
  .kpi.danger .val { color:#dc3545; }
  .kpi.success .val { color:#198754; }
  table { width:100%; border-collapse:collapse; font-size:.9em; }
  th { background:#f8f9fa; padding:9px 12px; text-align:left; font-weight:600; color:#495057; border-bottom:2px solid #dee2e6; }
  td { padding:8px 12px; border-bottom:1px solid #f1f3f5; }
  tr:last-child td { border-bottom:none; }
  tr:hover td { background:#f8f9fa; }
  .mfa-bar-wrap { background:#e9ecef; border-radius:4px; height:20px; overflow:hidden; margin-top:8px; }
  .mfa-bar { height:100%; background:$mfaColor; border-radius:4px; transition:width .6s; display:flex; align-items:center; justify-content:center; color:#fff; font-size:.8em; font-weight:600; }
  .footer { text-align:center; color:#adb5bd; font-size:.8em; padding:20px; }
  .footer a { color:#0078d4; text-decoration:none; }
  @media(max-width:600px){.meta{flex-direction:column}.kpi-grid{grid-template-columns:repeat(2,1fr)}}
</style>
</head>
<body>

<div class="header">
  <h1>&#x1F4CA; Microsoft 365 Admin Monthly Report</h1>
  <p>$($Overview.TenantName) &nbsp;&bull;&nbsp; $($Overview.ReportMonth)</p>
  <div class="meta">
    <span>&#x1F3E2; Tenant: $($Overview.TenantId)</span>
    <span>&#x1F30D; Country: $($Overview.Country)</span>
    <span>&#x1F4C5; Generated: $($Overview.GeneratedDate)</span>
  </div>
</div>

<div class="container">

  <!-- License Usage -->
  <div class="section">
    <div class="section-header"><span class="section-icon">&#x1F4B3;</span><h2>License Usage</h2></div>
    <div class="section-body">
      <table>
        <thead><tr><th>License</th><th>Total</th><th>Assigned</th><th>Available</th><th>Usage</th><th>Status</th></tr></thead>
        <tbody>$licenseRows</tbody>
      </table>
    </div>
  </div>

  <!-- User Account Status -->
  <div class="section">
    <div class="section-header"><span class="section-icon">&#x1F465;</span><h2>User Account Status</h2></div>
    <div class="section-body">
      <div class="kpi-grid" style="margin-bottom:20px;">
        <div class="kpi success"><div class="val">$($Users.Active)</div><div class="lbl">Active</div></div>
        <div class="kpi warn"><div class="val">$($Users.Inactive)</div><div class="lbl">Inactive (&gt;$InactiveDaysThreshold days)</div></div>
        <div class="kpi warn"><div class="val">$($Users.NeverSignedIn)</div><div class="lbl">Never Signed In</div></div>
        <div class="kpi danger"><div class="val">$($Users.Blocked)</div><div class="lbl">Blocked</div></div>
        <div class="kpi"><div class="val">$($Users.TotalMembers)</div><div class="lbl">Total Members</div></div>
      </div>
      <h3 style="font-size:.9em;color:#495057;margin-bottom:10px;">Top 10 Inactive Users</h3>
      <table>
        <thead><tr><th>Display Name</th><th>UPN</th><th>Last Sign-In</th></tr></thead>
        <tbody>$inactiveRows</tbody>
      </table>
    </div>
  </div>

  <!-- MFA Status -->
  <div class="section">
    <div class="section-header"><span class="section-icon">&#x1F510;</span><h2>MFA Enrollment Status</h2></div>
    <div class="section-body">
      <div class="kpi-grid" style="margin-bottom:20px;">
        <div class="kpi success"><div class="val">$($MFA.MFAEnabled)</div><div class="lbl">MFA Enabled</div></div>
        <div class="kpi danger"><div class="val">$($MFA.MFADisabled)</div><div class="lbl">No MFA</div></div>
        <div class="kpi"><div class="val">$($MFA.MFAPct)%</div><div class="lbl">Coverage</div></div>
      </div>
      <div class="mfa-bar-wrap"><div class="mfa-bar" style="width:$($MFA.MFAPct)%;">$($MFA.MFAPct)%</div></div>
      <h3 style="font-size:.9em;color:#495057;margin:16px 0 10px;">Users Without MFA (first 10)</h3>
      <table>
        <thead><tr><th>Display Name</th><th>UPN</th></tr></thead>
        <tbody>$noMfaRows</tbody>
      </table>
    </div>
  </div>

  <!-- Guest Users -->
  <div class="section">
    <div class="section-header"><span class="section-icon">&#x1F9D1;&#x200D;&#x1F4BB;</span><h2>Guest Users</h2></div>
    <div class="section-body">
      <div class="kpi-grid" style="margin-bottom:20px;">
        <div class="kpi"><div class="val">$($Guests.TotalGuests)</div><div class="lbl">Total Guests</div></div>
        <div class="kpi success"><div class="val">$($Guests.ActiveGuests)</div><div class="lbl">Active</div></div>
        <div class="kpi danger"><div class="val">$($Guests.BlockedGuests)</div><div class="lbl">Blocked</div></div>
        <div class="kpi warn"><div class="val">$($Guests.OldGuests)</div><div class="lbl">Older than 90 days</div></div>
      </div>
      <h3 style="font-size:.9em;color:#495057;margin-bottom:10px;">Guests Older Than 90 Days (first 10)</h3>
      <table>
        <thead><tr><th>Display Name</th><th>UPN</th><th>Invited Date</th></tr></thead>
        <tbody>$guestRows</tbody>
      </table>
    </div>
  </div>

  <!-- Conditional Access Policies -->
  <div class="section">
    <div class="section-header"><span class="section-icon">&#x1F6E1;&#xFE0F;</span><h2>Conditional Access Policies</h2></div>
    <div class="section-body">
      <table>
        <thead><tr><th>Policy Name</th><th>State</th><th>Users</th><th>Apps</th><th>Grant Controls</th></tr></thead>
        <tbody>$caRows</tbody>
      </table>
    </div>
  </div>

  <!-- Mailbox Usage -->
  <div class="section">
    <div class="section-header"><span class="section-icon">&#x1F4E7;</span><h2>Mailbox Usage</h2></div>
    <div class="section-body">
      <div class="kpi-grid" style="margin-bottom:20px;">
        <div class="kpi"><div class="val">$($Mailboxes.TotalMailboxes)</div><div class="lbl">Total Mailboxes</div></div>
        <div class="kpi warn"><div class="val">$($Mailboxes.TotalUsedGB) GB</div><div class="lbl">Total Storage Used</div></div>
        <div class="kpi danger"><div class="val">$($Mailboxes.NearQuota.Count)</div><div class="lbl">Near Quota (&gt;45 GB)</div></div>
      </div>
      <h3 style="font-size:.9em;color:#495057;margin-bottom:10px;">Top 10 Largest Mailboxes</h3>
      <table>
        <thead><tr><th>Display Name</th><th>Size (GB)</th><th>Item Count</th></tr></thead>
        <tbody>$mailboxRows</tbody>
      </table>
    </div>
  </div>

  <!-- Admin Role Assignments -->
  <div class="section">
    <div class="section-header"><span class="section-icon">&#x1F511;</span><h2>Admin Role Assignments</h2></div>
    <div class="section-body">
      <table>
        <thead><tr><th>Role</th><th>Member</th><th>UPN</th></tr></thead>
        <tbody>$roleRows</tbody>
      </table>
    </div>
  </div>

  <!-- Sign-in Failures -->
  <div class="section">
    <div class="section-header"><span class="section-icon">&#x26A0;&#xFE0F;</span><h2>Top Sign-in Failures (Last 30 Days)</h2></div>
    <div class="section-body">
      <table>
        <thead><tr><th>User</th><th>Failed Attempts</th></tr></thead>
        <tbody>$signInRows</tbody>
      </table>
    </div>
  </div>

</div>

<div class="footer">
  Generated by <strong>Microsoft 365 Admin Monthly Report</strong> &nbsp;&bull;&nbsp;
  Developed by <a href="https://www.linkedin.com/in/abdulloh-etaeluengoh" target="_blank">Mr. Abdulloh Etaeluengoh</a>
  &nbsp;&bull;&nbsp; <a href="https://github.com/DekBaCom" target="_blank">GitHub: DekBaCom</a>
</div>

</body>
</html>
"@
    return $html
}

#endregion

#region --- Main ---

Write-Host "`n=== Microsoft 365 Admin Monthly Report ===" -ForegroundColor Cyan
Write-Host "Report Month : $(Get-Date -Format 'MMMM yyyy')" -ForegroundColor White
Write-Host "Output File  : $OutputPath`n" -ForegroundColor White

# Connect
Connect-M365Services

# Collect data
$overview     = Get-TenantOverview
$licenses     = Get-LicenseReport
$users        = Get-UserStatusReport
$mfa          = Get-MFAStatusReport
$guests       = Get-GuestUserReport
$adminRoles   = Get-AdminRoleReport
$caPolicies   = Get-CAPolciesReport
$mailboxes    = Get-MailboxUsageReport
$signInFails  = Get-SignInFailureReport

# Build report
Write-Host "`n[*] Building HTML report..." -ForegroundColor Yellow
$html = Build-HTMLReport -Overview $overview -Licenses $licenses -Users $users `
        -MFA $mfa -Guests $guests -AdminRoles $adminRoles -CAPolicies $caPolicies `
        -Mailboxes $mailboxes -SignInFailures $signInFails

$html | Out-File -FilePath $OutputPath -Encoding UTF8
Write-Host "[+] Report saved to: $OutputPath" -ForegroundColor Green

# Open in browser
Start-Process $OutputPath

# Disconnect
Disconnect-MgGraph | Out-Null
Disconnect-ExchangeOnline -Confirm:$false | Out-Null
Write-Host "[+] Done. Sessions disconnected." -ForegroundColor Green

#endregion
