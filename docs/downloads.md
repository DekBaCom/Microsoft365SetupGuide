---
title: Downloads
layout: default
nav_order: 6
permalink: /docs/downloads
---

# Downloads — PowerShell Scripts
{: .no_toc }

All scripts are ready-to-use PowerShell automation tools that correspond to the steps documented in this guide. Download individual scripts or browse by category.
{: .fs-6 .fw-300 }

{: .highlight }
**Prerequisites:** PowerShell 5.1 or later. Most scripts require the **Microsoft Graph PowerShell SDK** or legacy **AzureAD / ExchangeOnlineManagement** modules. Run `Set-ExecutionPolicy RemoteSigned` before running any script.

---

## Table of Contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## Admin Monthly Report

Generate a comprehensive HTML report covering all key M365 health metrics in a single run.

| Script | Description |
|--------|-------------|
| [Get-M365MonthlyReport.ps1]({{ site.baseurl }}/scripts/monthly-report/Get-M365MonthlyReport.ps1){:download} | **Main script** — generates full HTML report (licenses, MFA, users, guests, CA, mailboxes, admin roles, sign-in failures) |

[View full documentation and usage guide &rarr;]({{ site.baseurl }}/docs/admin-monthly-report)

---

## Setup Intune

The core Intune deployment scripts. Start with `Setup-Intune.ps1` to import all baseline policies in one step.

| Script | Description |
|--------|-------------|
| [Setup-Intune.ps1]({{ site.baseurl }}/scripts/setup-intune/Setup-Intune.ps1){:download} | **Main script** — imports all Intune baseline policies into the tenant |
| [Import-AppConfiguration.ps1]({{ site.baseurl }}/scripts/setup-intune/Import-AppConfiguration.ps1){:download} | Import App Configuration profiles |
| [Import-AppProtection.ps1]({{ site.baseurl }}/scripts/setup-intune/Import-AppProtection.ps1){:download} | Import App Protection (MAM) policies |
| [Import-Applications.ps1]({{ site.baseurl }}/scripts/setup-intune/Import-Applications.ps1){:download} | Import Applications |
| [Import-Compliance.ps1]({{ site.baseurl }}/scripts/setup-intune/Import-Compliance.ps1){:download} | Import Compliance policies |
| [Import-DeviceConfiguration.ps1]({{ site.baseurl }}/scripts/setup-intune/Import-DeviceConfiguration.ps1){:download} | Import Device Configuration profiles |
| [Import-EndpointSecurity.ps1]({{ site.baseurl }}/scripts/setup-intune/Import-EndpointSecurity.ps1){:download} | Import Endpoint Security policies |
| [Install-BYODMobileDeviceProfiles.ps1]({{ site.baseurl }}/scripts/setup-intune/Install-BYODMobileDeviceProfiles.ps1){:download} | Install BYOD mobile device profiles |
| [Set-MDMAuthority.ps1]({{ site.baseurl }}/scripts/setup-intune/Set-MDMAuthority.ps1){:download} | Set MDM authority to Intune |
| [Set-DeviceEnrollmentRestrictions.ps1]({{ site.baseurl }}/scripts/setup-intune/Set-DeviceEnrollmentRestrictions.ps1){:download} | Configure device enrollment restrictions |
| [Get-DeviceEnrollmentRestrictions.ps1]({{ site.baseurl }}/scripts/setup-intune/Get-DeviceEnrollmentRestrictions.ps1){:download} | Export current enrollment restrictions |

### Export Scripts (Backup)

Use these to back up existing Intune configurations before making changes.

| Script | Description |
|--------|-------------|
| [Export-AppConfiguration.ps1]({{ site.baseurl }}/scripts/setup-intune/Export-AppConfiguration.ps1){:download} | Export App Configuration profiles |
| [Export-AppProtection.ps1]({{ site.baseurl }}/scripts/setup-intune/Export-AppProtection.ps1){:download} | Export App Protection (MAM) policies |
| [Export-Applications.ps1]({{ site.baseurl }}/scripts/setup-intune/Export-Applications.ps1){:download} | Export Applications |
| [Export-Compliance.ps1]({{ site.baseurl }}/scripts/setup-intune/Export-Compliance.ps1){:download} | Export Compliance policies |
| [Export-DeviceConfiguration.ps1]({{ site.baseurl }}/scripts/setup-intune/Export-DeviceConfiguration.ps1){:download} | Export Device Configuration profiles |
| [Export-EndpointSecurity.ps1]({{ site.baseurl }}/scripts/setup-intune/Export-EndpointSecurity.ps1){:download} | Export Endpoint Security policies |
| [Export-ADMX.ps1]({{ site.baseurl }}/scripts/setup-intune/Export-ADMX.ps1){:download} | Export ADMX (Administrative Template) profiles |

---

## Azure AD

Scripts for Conditional Access, MFA, and Group management automation.

| Script | Description |
|--------|-------------|
| [Install-BaselineCAPolicies.ps1]({{ site.baseurl }}/scripts/azure-ad/Install-BaselineCAPolicies.ps1){:download} | Install baseline Conditional Access policies (Block legacy auth + Require MFA) |
| [Install-DataProtectionCAPolicies.ps1]({{ site.baseurl }}/scripts/azure-ad/Install-DataProtectionCAPolicies.ps1){:download} | Install data protection Conditional Access policies |
| [Install-GuestCAPolicies.ps1]({{ site.baseurl }}/scripts/azure-ad/Install-GuestCAPolicies.ps1){:download} | Install guest-specific Conditional Access policies |
| [Install-ITPMBaselineCAPolicies.ps1]({{ site.baseurl }}/scripts/azure-ad/Install-ITPMBaselineCAPolicies.ps1){:download} | Install ITPM baseline Conditional Access policies |
| [Baseline-ConditionalAccessPolicies.ps1]({{ site.baseurl }}/scripts/azure-ad/Baseline-ConditionalAccessPolicies.ps1){:download} | Baseline CA policy definitions reference |
| [Enable-MfaForLicensedUsers.ps1]({{ site.baseurl }}/scripts/azure-ad/Enable-MfaForLicensedUsers.ps1){:download} | Enable per-user MFA for all licensed users |
| [Disable-MfaForLicensedUsers.ps1]({{ site.baseurl }}/scripts/azure-ad/Disable-MfaForLicensedUsers.ps1){:download} | Disable per-user MFA (when migrating to Conditional Access) |
| [Set-GroupExpirationPolicy.ps1]({{ site.baseurl }}/scripts/azure-ad/Set-GroupExpirationPolicy.ps1){:download} | Configure Microsoft 365 Groups expiration policy |
| [Limit-GroupsCreation.ps1]({{ site.baseurl }}/scripts/azure-ad/Limit-GroupsCreation.ps1){:download} | Restrict Groups/Teams creation to a specific security group |
| [Enable-GroupsCreationForAllUsers.ps1]({{ site.baseurl }}/scripts/azure-ad/Enable-GroupsCreationForAllUsers.ps1){:download} | Re-enable Groups/Teams creation for all users |
| [Enable-SensitivityLabelsForGroups.ps1]({{ site.baseurl }}/scripts/azure-ad/Enable-SensitivityLabelsForGroups.ps1){:download} | Enable sensitivity labels for Microsoft 365 Groups |

---

## Compliance

Scripts for deploying retention policies and sensitivity labels.

| Script | Description |
|--------|-------------|
| [Install-SensitivityLabels.ps1]({{ site.baseurl }}/scripts/compliance/Install-SensitivityLabels.ps1){:download} | Deploy default sensitivity labels to the tenant |
| [Install-DataRetentionPolicies.ps1]({{ site.baseurl }}/scripts/compliance/Install-DataRetentionPolicies.ps1){:download} | Install baseline data retention policies |
| [Install-EmailRetentionPolicy.ps1]({{ site.baseurl }}/scripts/compliance/Install-EmailRetentionPolicy.ps1){:download} | Install Exchange Online email retention policy |
| [Install-TeamsRetentionPolicies.ps1]({{ site.baseurl }}/scripts/compliance/Install-TeamsRetentionPolicies.ps1){:download} | Install Teams retention policies |
| [Limit-GroupsCreation.ps1]({{ site.baseurl }}/scripts/compliance/Limit-GroupsCreation.ps1){:download} | Limit Groups creation (compliance variant) |

---

## Exchange Online

Scripts for hardening Exchange Online and configuring email security.

| Script | Description |
|--------|-------------|
| [Install-EXOStandardProtection.ps1]({{ site.baseurl }}/scripts/exchange-online/Install-EXOStandardProtection.ps1){:download} | Apply standard Exchange Online Protection baseline |
| [Setup-DKIM.ps1]({{ site.baseurl }}/scripts/exchange-online/Setup-DKIM.ps1){:download} | Enable and configure DKIM signing |
| [Setup-OME.ps1]({{ site.baseurl }}/scripts/exchange-online/Setup-OME.ps1){:download} | Configure Office Message Encryption (OME) |
| [Advanced-TenantConfig.ps1]({{ site.baseurl }}/scripts/exchange-online/Advanced-TenantConfig.ps1){:download} | Advanced tenant configuration for Exchange Online |
| [Configure-Auditing.ps1]({{ site.baseurl }}/scripts/exchange-online/Configure-Auditing.ps1){:download} | Enable and configure mailbox auditing |
| [Disable-Forwarding.ps1]({{ site.baseurl }}/scripts/exchange-online/Disable-Forwarding.ps1){:download} | Block automatic external email forwarding |
| [Disable-SharedMbxSignOn.ps1]({{ site.baseurl }}/scripts/exchange-online/Disable-SharedMbxSignOn.ps1){:download} | Disable sign-in for shared mailbox accounts |
| [Block-ConsumerStorageOWA.ps1]({{ site.baseurl }}/scripts/exchange-online/Block-ConsumerStorageOWA.ps1){:download} | Block consumer storage (Dropbox, Google Drive) in OWA |
| [Block-UnmanagedDownload.ps1]({{ site.baseurl }}/scripts/exchange-online/Block-UnmanagedDownload.ps1){:download} | Block downloads on unmanaged devices via OWA |
| [Setup-ArchiveLegalHold.ps1]({{ site.baseurl }}/scripts/exchange-online/Setup-ArchiveLegalHold.ps1){:download} | Configure archive mailbox and litigation hold |
| [Set-DeletedItemsRetention.ps1]({{ site.baseurl }}/scripts/exchange-online/Set-DeletedItemsRetention.ps1){:download} | Set deleted items retention period |

---

## Incident Response

Scripts for investigating security incidents, exporting audit logs, and remediating compromised accounts.

{: .warning }
These scripts are intended for use by security administrators during active investigations. Use with care in production environments.

| Script | Description |
|--------|-------------|
| [Remediate-CompromisedUser.ps1]({{ site.baseurl }}/scripts/incident-response/Remediate-CompromisedUser.ps1){:download} | Remediate a compromised user account (revoke sessions, reset password) |
| [Install-AzureADProtectionAlerts.ps1]({{ site.baseurl }}/scripts/incident-response/Install-AzureADProtectionAlerts.ps1){:download} | Install Azure AD Identity Protection alert rules |
| [Start-AzureADIRCollection.ps1]({{ site.baseurl }}/scripts/incident-response/Start-AzureADIRCollection.ps1){:download} | Collect Azure AD IR forensic data |
| [Start-UnifiedAuditLogIRCollection.ps1]({{ site.baseurl }}/scripts/incident-response/Start-UnifiedAuditLogIRCollection.ps1){:download} | Collect Unified Audit Log data for IR |
| [Export-ActivityByUser.ps1]({{ site.baseurl }}/scripts/incident-response/Export-ActivityByUser.ps1){:download} | Export all activity for a specific user |
| [Export-ActivityByIPAddress.ps1]({{ site.baseurl }}/scripts/incident-response/Export-ActivityByIPAddress.ps1){:download} | Export all activity from a specific IP address |
| [Export-SignInByUser.ps1]({{ site.baseurl }}/scripts/incident-response/Export-SignInByUser.ps1){:download} | Export sign-in logs for a specific user |
| [Export-SignInByIPAddress.ps1]({{ site.baseurl }}/scripts/incident-response/Export-SignInByIPAddress.ps1){:download} | Export sign-in logs from a specific IP address |
| [Export-PrivilegedUserActions.ps1]({{ site.baseurl }}/scripts/incident-response/Export-PrivilegedUserActions.ps1){:download} | Export admin/privileged user actions from audit log |
| [Export-PrivilegedUserSignIn.ps1]({{ site.baseurl }}/scripts/incident-response/Export-PrivilegedUserSignIn.ps1){:download} | Export sign-in logs for privileged accounts |

---

## Windows 10

Scripts for deploying Intune device configuration and security profiles for Windows 10/11 devices.

| Script | Description |
|--------|-------------|
| [Install-WindowsSecurityProfiles.ps1]({{ site.baseurl }}/scripts/windows-10/Install-WindowsSecurityProfiles.ps1){:download} | Install Windows security baseline profiles |
| [Install-Windows10SecurityProfiles.ps1]({{ site.baseurl }}/scripts/windows-10/Install-Windows10SecurityProfiles.ps1){:download} | Install Windows 10 specific security profiles |
| [Install-OneDriveProfile.ps1]({{ site.baseurl }}/scripts/windows-10/Install-OneDriveProfile.ps1){:download} | Deploy OneDrive Known Folder Move configuration profile |
| [Install-LegacyProfiles.ps1]({{ site.baseurl }}/scripts/windows-10/Install-LegacyProfiles.ps1){:download} | Install legacy device configuration profiles |
