<#
.SYNOPSIS
    Exports a full inventory of the current (source) Microsoft 365 tenant to CSV + JSON
    files, ready to drive a tenant-to-tenant (T2T) migration.

.DESCRIPTION
    Captures users, groups, licenses, Conditional Access policies, mailbox sizes,
    shared mailboxes, and distribution groups into timestamped files under -OutputPath.
    Intended to be run against the SOURCE tenant during Phase 1 of a T2T migration.

.PARAMETER OutputPath
    Folder where CSV / JSON files are written. Created if it doesn't exist.
    Default: .\T2T-Inventory-yyyyMMdd-HHmm

.PARAMETER SkipMailboxStats
    Skip the (slow) per-mailbox size calculation.

.EXAMPLE
    .\Export-TenantInventory.ps1

.EXAMPLE
    .\Export-TenantInventory.ps1 -OutputPath C:\T2T\source -SkipMailboxStats

.NOTES
    Requires modules:
      - Microsoft.Graph             >= 2.0.0
      - ExchangeOnlineManagement    >= 3.0.0
    Required Microsoft Graph scopes:
      User.Read.All, Group.Read.All, Directory.Read.All,
      Policy.Read.All, Application.Read.All, Organization.Read.All
    Part of: Microsoft 365 Setup Guide — Tenant-to-Tenant migration
             https://dekbacom.github.io/Microsoft365SetupGuide/docs/tenant-migration
#>
[CmdletBinding()]
param(
    [string]$OutputPath = ".\T2T-Inventory-$(Get-Date -Format 'yyyyMMdd-HHmm')",
    [switch]$SkipMailboxStats
)

$ErrorActionPreference = "Stop"

function Write-Step($msg) { Write-Host "→ $msg" -ForegroundColor Cyan }
function Write-Ok  ($msg) { Write-Host "✔ $msg"  -ForegroundColor Green }

New-Item -ItemType Directory -Force -Path $OutputPath | Out-Null
Write-Step "Output folder: $OutputPath"

# --- Connect ---------------------------------------------------------------
Write-Step "Connecting to Microsoft Graph"
Connect-MgGraph -Scopes @(
    "User.Read.All",
    "Group.Read.All",
    "Directory.Read.All",
    "Policy.Read.All",
    "Application.Read.All",
    "Organization.Read.All"
) -NoWelcome

Write-Step "Connecting to Exchange Online"
Connect-ExchangeOnline -ShowBanner:$false

# --- Tenant overview -------------------------------------------------------
$org = Get-MgOrganization
$org | Select-Object Id, DisplayName, `
    @{n="DefaultDomain"; e={($_.VerifiedDomains | Where-Object IsDefault).Name}}, `
    @{n="AllDomains";    e={($_.VerifiedDomains.Name) -join ';'}} |
    Export-Csv "$OutputPath\tenant.csv" -NoTypeInformation
Write-Ok "tenant.csv"

# --- Users -----------------------------------------------------------------
Write-Step "Exporting users…"
Get-MgUser -All -Property Id, UserPrincipalName, DisplayName, Mail, AccountEnabled,
    UsageLocation, AssignedLicenses, Department, JobTitle, GivenName, Surname |
    Select-Object Id, UserPrincipalName, DisplayName, Mail, AccountEnabled,
        UsageLocation, Department, JobTitle, GivenName, Surname,
        @{n="LicenseSkus"; e={($_.AssignedLicenses.SkuId) -join ';'}} |
    Export-Csv "$OutputPath\users.csv" -NoTypeInformation
Write-Ok "users.csv"

# --- Groups ----------------------------------------------------------------
Write-Step "Exporting groups…"
Get-MgGroup -All -Property Id, DisplayName, Mail, MailEnabled, SecurityEnabled,
    GroupTypes, Description |
    Select-Object Id, DisplayName, Mail, MailEnabled, SecurityEnabled,
        @{n="GroupTypes"; e={($_.GroupTypes) -join ';'}}, Description |
    Export-Csv "$OutputPath\groups.csv" -NoTypeInformation
Write-Ok "groups.csv"

# --- SKUs ------------------------------------------------------------------
Write-Step "Exporting license SKUs…"
Get-MgSubscribedSku |
    Select-Object SkuPartNumber, ConsumedUnits,
        @{n="EnabledSeats";   e={$_.PrepaidUnits.Enabled}},
        @{n="AvailableSeats"; e={$_.PrepaidUnits.Enabled - $_.ConsumedUnits}} |
    Export-Csv "$OutputPath\skus.csv" -NoTypeInformation
Write-Ok "skus.csv"

# --- Conditional Access ----------------------------------------------------
Write-Step "Exporting Conditional Access policies…"
Get-MgIdentityConditionalAccessPolicy -All |
    ConvertTo-Json -Depth 20 | Out-File "$OutputPath\ca-policies.json" -Encoding UTF8
Write-Ok "ca-policies.json"

# --- Mailboxes + sizes -----------------------------------------------------
Write-Step "Enumerating mailboxes…"
$mailboxes = Get-EXOMailbox -ResultSize Unlimited
$mailboxes | Select-Object DisplayName, PrimarySmtpAddress, RecipientTypeDetails, Alias |
    Export-Csv "$OutputPath\mailboxes.csv" -NoTypeInformation
Write-Ok "mailboxes.csv ($($mailboxes.Count) mailboxes)"

if (-not $SkipMailboxStats) {
    Write-Step "Collecting mailbox sizes (may take several minutes)…"
    $stats = foreach ($m in $mailboxes) {
        try {
            $s = Get-EXOMailboxStatistics -Identity $m.PrimarySmtpAddress -ErrorAction Stop
            [pscustomobject]@{
                DisplayName        = $m.DisplayName
                PrimarySmtpAddress = $m.PrimarySmtpAddress
                ItemCount          = $s.ItemCount
                SizeMB             = [math]::Round(
                    ($s.TotalItemSize.Value.ToString().Split("(")[1].Split(" ")[0].Replace(",","") / 1MB), 2)
            }
        } catch {
            Write-Warning "Mailbox stats failed for $($m.PrimarySmtpAddress): $($_.Exception.Message)"
        }
    }
    $stats | Export-Csv "$OutputPath\mailbox-sizes.csv" -NoTypeInformation
    Write-Ok "mailbox-sizes.csv"
}

# --- Shared mailboxes + DLs ------------------------------------------------
Get-EXOMailbox -RecipientTypeDetails SharedMailbox -ResultSize Unlimited |
    Select-Object DisplayName, PrimarySmtpAddress, Alias |
    Export-Csv "$OutputPath\shared-mailboxes.csv" -NoTypeInformation
Write-Ok "shared-mailboxes.csv"

Get-DistributionGroup -ResultSize Unlimited |
    Select-Object DisplayName, PrimarySmtpAddress, GroupType, RecipientTypeDetails |
    Export-Csv "$OutputPath\distribution-groups.csv" -NoTypeInformation
Write-Ok "distribution-groups.csv"

# --- Disconnect ------------------------------------------------------------
Disconnect-ExchangeOnline -Confirm:$false | Out-Null
Disconnect-MgGraph | Out-Null

Write-Host ""
Write-Host "Inventory complete → $OutputPath" -ForegroundColor Green
