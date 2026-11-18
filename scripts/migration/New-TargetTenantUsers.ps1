<#
.SYNOPSIS
    Bulk-creates user accounts in the TARGET tenant from a source inventory CSV.

.DESCRIPTION
    Reads users.csv produced by Export-TenantInventory.ps1 and creates matching
    accounts in the target tenant. Accounts are created DISABLED by default so
    they cannot sign in until cutover. Temporary strong passwords are generated
    and written to a secrets.csv that must be stored securely.

.PARAMETER UsersCsv
    Path to the source users.csv.

.PARAMETER TargetDomain
    Target tenant primary domain for UPN construction (e.g. "targetco.onmicrosoft.com").

.PARAMETER UsageLocation
    Default two-letter country code if source has none. Default: "TH".

.PARAMETER EnableAccounts
    Enable created accounts immediately. Default: $false (recommended — enable only at cutover).

.PARAMETER SecretsOutPath
    Where to write generated temp passwords. Default: .\target-user-secrets.csv

.EXAMPLE
    .\New-TargetTenantUsers.ps1 -UsersCsv .\T2T-Inventory-20260101-0900\users.csv `
        -TargetDomain targetco.onmicrosoft.com

.NOTES
    Requires Microsoft.Graph module (>= 2.0.0).
    Required scopes: User.ReadWrite.All, Directory.ReadWrite.All
    Part of: Microsoft 365 Setup Guide — Tenant-to-Tenant migration
             https://dekbacom.github.io/Microsoft365SetupGuide/docs/tenant-migration
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)][string]$UsersCsv,
    [Parameter(Mandatory)][string]$TargetDomain,
    [string]$UsageLocation   = "TH",
    [switch]$EnableAccounts,
    [string]$SecretsOutPath  = ".\target-user-secrets.csv"
)

$ErrorActionPreference = "Stop"

function New-StrongPassword {
    # 20-char password with upper, lower, digit, symbol
    $u  = [char[]]"ABCDEFGHJKLMNPQRSTUVWXYZ"
    $l  = [char[]]"abcdefghijkmnopqrstuvwxyz"
    $d  = [char[]]"23456789"
    $s  = [char[]]'!@#$%^&*-_=+?'
    $all = $u + $l + $d + $s
    $pw = @(
        ($u | Get-Random),
        ($l | Get-Random),
        ($d | Get-Random),
        ($s | Get-Random)
    )
    $pw += 1..16 | ForEach-Object { $all | Get-Random }
    -join ($pw | Sort-Object { Get-Random })
}

if (-not (Test-Path $UsersCsv)) {
    throw "Users CSV not found: $UsersCsv"
}

Write-Host "Connecting to Microsoft Graph (TARGET tenant)…" -ForegroundColor Cyan
Connect-MgGraph -Scopes "User.ReadWrite.All","Directory.ReadWrite.All" -NoWelcome

$org = Get-MgOrganization | Select-Object -First 1
Write-Host "Target tenant: $($org.DisplayName) [$($org.Id)]" -ForegroundColor Yellow
if (-not $PSCmdlet.ShouldProcess($org.DisplayName, "Create users from $UsersCsv")) { return }

$users = Import-Csv $UsersCsv
$secrets = [System.Collections.Generic.List[object]]::new()
$created = 0
$skipped = 0
$failed  = 0

foreach ($u in $users) {
    if ([string]::IsNullOrWhiteSpace($u.UserPrincipalName)) { continue }

    $alias     = $u.UserPrincipalName.Split('@')[0]
    $targetUpn = "$alias@$TargetDomain"
    $tempPass  = New-StrongPassword

    # Skip if the UPN already exists
    $existing = Get-MgUser -Filter "userPrincipalName eq '$targetUpn'" -ErrorAction SilentlyContinue
    if ($existing) {
        Write-Host "  SKIP (exists): $targetUpn" -ForegroundColor DarkGray
        $skipped++
        continue
    }

    $body = @{
        AccountEnabled    = [bool]$EnableAccounts
        DisplayName       = $u.DisplayName
        MailNickname      = $alias
        UserPrincipalName = $targetUpn
        GivenName         = $u.GivenName
        Surname           = $u.Surname
        Department        = $u.Department
        JobTitle          = $u.JobTitle
        UsageLocation     = if ($u.UsageLocation) { $u.UsageLocation } else { $UsageLocation }
        PasswordProfile   = @{
            Password                      = $tempPass
            ForceChangePasswordNextSignIn = $true
        }
    }

    try {
        $new = New-MgUser -BodyParameter $body
        $created++
        $secrets.Add([pscustomobject]@{
            SourceUPN  = $u.UserPrincipalName
            TargetUPN  = $targetUpn
            TempPass   = $tempPass
            CreatedAt  = (Get-Date).ToString("o")
            Id         = $new.Id
        })
        Write-Host "  ✔ Created $targetUpn" -ForegroundColor Green
    } catch {
        Write-Warning "  ✗ Failed $targetUpn : $($_.Exception.Message)"
        $failed++
    }
}

$secrets | Export-Csv $SecretsOutPath -NoTypeInformation
Write-Host ""
Write-Host "Summary: Created=$created  Skipped=$skipped  Failed=$failed" -ForegroundColor Cyan
Write-Host "Secrets file: $SecretsOutPath — STORE SECURELY (encrypt or move to a secret vault)" -ForegroundColor Yellow

Disconnect-MgGraph | Out-Null
