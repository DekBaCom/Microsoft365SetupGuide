---
title: Microsoft Endpoint Manager
layout: default
nav_order: 4
has_children: true
permalink: docs/microsoft-endpoint-manager
---

# Microsoft Endpoint Manager (Intune)
{: .no_toc }

Manage and protect devices across your organization using Microsoft Intune — part of Microsoft Endpoint Manager. This section covers device enrollment, compliance policies, app protection, and platform-specific configurations.
{: .fs-6 .fw-300 }

---

## Overview

| Section | Description |
|---------|-------------|
| [Initial Setup](#initial-setup) | Import baseline policies using Setup-Intune.ps1 |
| [Device Enrollment Settings](#device-enrollment-settings) | Configure enrollment restrictions and Autopilot |
| [Device Clean-up Rules](#device-clean-up-rules) | Auto-remove stale devices |
| [Compliance Policies](#compliance-policies) | Define compliant device requirements |
| [App Protection (MAM)](#app-protection-mam) | Protect data on mobile without full MDM |
| [Mobile Devices (MDM)](#mobile-devices-mdm) | iOS and Android MDM + Conditional Access |
| [Windows 10 — Azure AD Join](#windows-10--azure-ad-join) | Cloud-native Windows device management |
| [Windows 10 — Hybrid Join](#windows-10--hybrid-join) | Domain-joined + Azure AD co-existence |

---

## Initial Setup

Download and run the provided PowerShell script to import all baseline Intune policies into your tenant.

### Steps

1. **Download** the `Setup-Intune.ps1` script from your deployment package
2. Open **PowerShell as Administrator** and run:

   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   .\Setup-Intune.ps1
   ```

   ![Setup-Intune.ps1 running in PowerShell]({{ site.baseurl }}/assets/images/mem_setup_script.png)

3. On first sign-in via PowerShell to Intune, you will be prompted to **Consent on behalf of your organization** — click Accept

   ![Intune PowerShell - Consent on behalf of organization]({{ site.baseurl }}/assets/images/mem_setup_consent.png)

{: .important }
The consent step is required to grant the PowerShell module permission to manage Intune resources. This only needs to be done once per tenant.

---

## Device Enrollment Settings

Configure how devices can enroll into Intune management.

### Enrollment Restrictions

1. Go to **Intune admin center** (intune.microsoft.com) > **Devices** > **Enrollment** > **Enrollment restrictions**
2. Review the **Default** restriction policy and configure:
   - **Allowed platforms**: Windows, iOS/iPadOS, Android, macOS
   - **Block personally owned devices**: Configure based on your BYOD policy
   - **Device limit**: Set maximum devices per user (recommended: 5–10)

### Windows Autopilot

1. Navigate to **Devices** > **Windows** > **Windows enrollment** > **Devices**
2. Import device hardware IDs via CSV file (obtained from device vendor or using `Get-WindowsAutoPilotInfo` script)
3. Create an **Autopilot deployment profile**:
   - Deployment mode: **User-driven**
   - Join to Azure AD as: **Azure AD joined**
   - User account type: **Standard User** (recommended)
4. Assign the profile to a device group

### Apple Device Enrollment (iOS/macOS)

1. Navigate to **Devices** > **iOS/iPadOS** > **iOS/iPadOS enrollment** > **Apple MDM Push certificate**
2. Follow the wizard to create and upload an Apple MDM Push Certificate
3. For corporate-owned devices, configure **Apple Automated Device Enrollment (ADE)** via Apple Business Manager

### Android Device Enrollment

1. Navigate to **Devices** > **Android** > **Android enrollment**
2. Connect to **Managed Google Play** for Android Enterprise enrollment
3. Configure enrollment profiles for **Android Enterprise — Fully managed** or **Work Profile** as appropriate

---

## Device Clean-up Rules

Automatically remove stale/inactive devices from Intune to keep your device inventory accurate.

### Steps

1. Navigate to **Devices** > **Device clean-up rules**
2. Configure:
   - **Delete devices that haven't checked in for this many days**: **90** (recommended)
3. Click **Save**

{: .note }
This rule removes devices from Intune management only. It does not delete the device from Azure AD automatically. Consider enabling the Azure AD device cleanup setting separately.

---

## Compliance Policies

Define what makes a device "compliant" and configure actions for non-compliant devices.

### Creating Compliance Policies

#### Windows 10/11 Compliance Policy

1. Navigate to **Devices** > **Compliance policies** > **Create policy**
2. Platform: **Windows 10 and later**
3. Recommended settings:

   **Device Health:**
   - Require BitLocker: **Require**
   - Require Secure Boot: **Require**
   - Require code integrity: **Require**

   **System Security:**
   - Require a password: **Require**
   - Simple passwords: **Block**
   - Password type: **Alphanumeric**
   - Minimum password length: **8**
   - Firewall: **Require**
   - Antivirus: **Require**
   - Microsoft Defender Antimalware: **Require**

#### iOS/iPadOS Compliance Policy

1. Create a compliance policy for **iOS/iPadOS**
2. Recommended settings:
   - Minimum OS version: Set to a recent supported version
   - Jailbroken devices: **Block**
   - Require a password: **Require**
   - Minimum password length: **6**

#### Android Compliance Policy

1. Create a compliance policy for **Android Enterprise**
2. Recommended settings:
   - Rooted devices: **Block**
   - Require a password: **Require**
   - Minimum password length: **6**
   - Google Play Protect: **Require**

### Actions for Noncompliance

For each compliance policy, configure actions:

| Action | Schedule |
|--------|----------|
| Mark device noncompliant | Immediately (0 days) |
| Send email to end user | 1 day |
| Retire the noncompliant device | 30 days |

---

## App Protection (MAM)

Protect corporate data on mobile devices using App Protection Policies — works on personal (BYOD) devices without requiring full device enrollment.

### Creating App Protection Policies

#### iOS App Protection Policy

1. Navigate to **Apps** > **App protection policies** > **Create policy** > **iOS/iPadOS**
2. Configure:

   **Data protection:**
   - Backup org data to iTunes and iCloud: **Block**
   - Send org data to other apps: **Policy managed apps**
   - Receive data from other apps: **Policy managed apps**
   - Save copies of org data: **Block**

   **Access requirements:**
   - PIN for access: **Require**
   - PIN length: **6**

   **Conditional launch:**
   - Max PIN attempts: **5** (action: Reset PIN)
   - Offline grace period: **720 minutes** (action: Block access)
   - Jailbroken/rooted devices: (action: Block access)

3. **Assign** to: All users (or a targeted group)

#### Android App Protection Policy

1. Create a similar policy for **Android**
2. Apply equivalent settings for data protection and access requirements

---

## Mobile Devices (MDM)

Assign compliance policies and configure Conditional Access for enrolled iOS and Android devices.

### Steps

1. **Assign compliance policies** created above to the appropriate device groups
2. **Create Conditional Access policies** that require compliant devices:
   - Use the **Require device to be marked as compliant** grant control
   - See [Azure AD Configuration — Conditional Access](../azure-ad-configuration/#conditional-access-baseline)
3. **Test** with a pilot group before rolling out broadly

{: .warning }
Ensure all targeted devices are enrolled and marked compliant BEFORE enabling any Conditional Access policy that requires device compliance. Otherwise, users will be blocked from accessing resources.

---

## Windows 10 — Azure AD Join

For organizations deploying cloud-native Windows 10/11 devices (no on-premises domain join required).

### Steps

1. **Import apps** into Intune:
   - Navigate to **Apps** > **Windows** > **Add**
   - Add Microsoft 365 Apps and required line-of-business apps

2. **Assign configuration profiles** imported via Setup-Intune.ps1:
   - Navigate to **Devices** > **Configuration profiles**
   - Assign each profile to the appropriate device groups

3. **Assign compliance policy** to the Azure AD Join device group

4. **Verify Autopilot profile** is assigned (see Device Enrollment Settings above)

5. **Test the end-to-end Autopilot flow**:
   - Power on a registered device
   - The device should automatically enroll and apply all policies

---

## Windows 10 — Hybrid Join

{: .note }
This configuration is only required if your organization has traditional domain-joined (on-premises Active Directory) computers and requires long-term co-existence with cloud management.

### Prerequisites

- Active Directory Domain Services (AD DS) on-premises
- Azure AD Connect configured and syncing
- Network line of sight to domain controllers during OOBE

### Steps

1. **Configure Hybrid Azure AD Join** in Azure AD Connect:
   - Run Azure AD Connect configuration wizard
   - Select **Configure device options** > **Configure Hybrid Azure AD join**
   - Select your operating system (Windows 10 current or downlevel)

2. **Verify** devices are registered:
   - Run `dsregcmd /status` on a domain-joined device
   - Confirm `AzureAdJoined: YES` and `DomainJoined: YES`

3. **Enroll devices into Intune** using Group Policy:
   - Computer Configuration > Policies > Administrative Templates > Windows Components > MDM
   - Enable **Enable automatic MDM enrollment using default Azure AD credentials**

4. **Assign configuration profiles and compliance policies** to the hybrid device group

5. **Verify co-management** status in Intune admin center > **Devices** > **Co-management**
