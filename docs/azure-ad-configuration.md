---
title: Azure AD Configuration
layout: default
nav_order: 3
has_children: true
permalink: /docs/azure-ad-configuration
---

# Azure AD Configuration
{: .no_toc }

Secure your identity and access management layer by enabling combined registration, self-service password reset, configuring user settings, and deploying Conditional Access baseline policies.
{: .fs-6 .fw-300 }

---

## Overview

| Section | Description |
|---------|-------------|
| [Combined Registration](#combined-registration) | Enable simultaneous MFA + SSPR registration |
| [Self-Service Password Reset](#self-service-password-reset) | Allow users to reset passwords via second factor |
| [User Settings](#user-settings) | Edit default user and guest collaboration settings |
| [Admin Consent Requests](#admin-consent-requests) | Prevent users from consenting to external app requests |
| [Device Settings](#device-settings) | Enforce MFA for device join and enable Enterprise State Roaming |
| [Conditional Access Baseline](#conditional-access-baseline) | Block legacy auth and require MFA |

---

## Combined Registration

Enable the combined security information registration experience so users can register for both MFA and SSPR in a single flow.

### Steps

1. Go to **Azure AD admin center** > **Users** > **User settings**
2. Click **Manage user feature preview settings**

![Azure AD User Settings - Manage user feature preview settings]({{ site.baseurl }}/assets/images/azure-ad_combined-reg_step1.png)

3. Under **Users can use the combined security information registration experience**, select **All**

![Combined Registration - Select All]({{ site.baseurl }}/assets/images/azure-ad_combined-reg_step2.png)

4. Click **Save**

{: .note }
This unified registration experience reduces friction for end users and is the recommended approach for new deployments.

---

## Self-Service Password Reset

Allow users to reset their own passwords using their registered second factor of authentication.

{: .important }
SSPR as configured here applies to **cloud-only accounts**. For synced (hybrid) accounts, you must also configure **password writeback** in Azure AD Connect.

### Steps

1. Go to **Azure AD admin center** > **Users** > **Password reset**
2. Configure the following:

   **Properties tab** — Set **Self service password reset enabled** to **All**

   ![SSPR Properties - Enable for All]({{ site.baseurl }}/assets/images/azure-ad_sspr_properties.png)

   **Authentication methods tab** — Require **2 methods**, enable: Mobile app notification, Mobile app code, Mobile phone, Email

   ![SSPR Authentication Methods]({{ site.baseurl }}/assets/images/azure-ad_sspr_auth-methods.png)

   **Registration tab** — Set **Require users to register when signing in?** to **No**

   ![SSPR Registration Settings]({{ site.baseurl }}/assets/images/azure-ad_sspr_registration.png)

   **Notifications tab** — Set both user and admin notifications to **Yes**

   ![SSPR Notifications]({{ site.baseurl }}/assets/images/azure-ad_sspr_notifications.png)

3. Click **Save**

---

## User Settings

Configure default user and guest collaboration settings in Azure AD.

### Default User Settings

1. Go to **Azure AD admin center** > **Users** > **User settings**
2. Make the following recommended selections:
   - **Users can register applications** → **No**
   - **Restrict access to Azure AD administration portal** → **Yes**

![Azure AD User Settings]({{ site.baseurl }}/assets/images/azure-ad_user-settings.png)

### External Collaboration Settings (Guest Users)

1. Scroll down and click **Manage external collaboration settings**  
   *(Also accessible via Azure AD > External identities > External collaboration settings)*
2. Recommended settings:
   - **Enable Email One-Time Passcode** → **Yes**
   - **Guests can invite** → **No** (recommended for most organizations)

![External Collaboration Settings - Guest Users]({{ site.baseurl }}/assets/images/azure-ad_guest-settings.png)

---

## Admin Consent Requests

Prevent users from independently consenting to third-party application permission requests.

### Steps

1. Navigate to **Azure AD** > **Enterprise Applications** > **User settings**
2. Set **Users can consent to apps accessing company data on their behalf** → **No**
3. Set **Users can request admin consent to apps they are unable to consent to** → **Yes**

![Admin Consent - Block user consent]({{ site.baseurl }}/assets/images/azure-ad_admin-consent_step1.png)

4. Configure the admin consent request settings and expiration

![Admin Consent - Request admin consent enabled]({{ site.baseurl }}/assets/images/azure-ad_admin-consent_step2.png)

5. **Select approvers** — choose admins who will review and approve consent requests

![Admin Consent - Select Approvers]({{ site.baseurl }}/assets/images/azure-ad_admin-consent_approvers.png)

### Delegating to Non-Admin Approvers

If you need to delegate consent approval to non-admin users:
1. Navigate to **Azure Active Directory** > **Roles and administrators**
2. Assign the **Application administrator** role to the designated approvers

---

## Device Settings

Configure how devices can join Azure AD and enable Enterprise State Roaming.

### Default Device Settings

1. Go to **Azure AD admin center** > **Users** > **Device settings**
2. Set **Require Multi-factor Auth to join devices** → **Yes**

![Device Settings - Require MFA to join]({{ site.baseurl }}/assets/images/azure-ad_device-settings.png)

### Enterprise State Roaming

1. Navigate to **Azure AD** > **Devices** > **Enterprise state roaming**
2. Under **Users may sync settings and app data across devices**, select **All**

![Enterprise State Roaming - Enable for All]({{ site.baseurl }}/assets/images/azure-ad_enterprise-state-roaming.png)

---

## Conditional Access Baseline

Create the foundational Conditional Access policies to protect your tenant.

{: .warning }
Before configuring Conditional Access policies, you **must** disable Security Defaults if it is currently enabled. Security Defaults and Conditional Access cannot be used simultaneously.

### Step 1 — Disable Security Defaults

1. Go to **Azure AD** > **Properties**
2. Click **Manage Security Defaults** at the bottom
3. Set **Enable Security Defaults** to **No** and click **Save**

![Security Defaults - Turn Off]({{ site.baseurl }}/assets/images/azure-ad_security-defaults-off.png)

### Step 2 — Configure Named Locations (Optional but Recommended)

1. Navigate to **Azure AD** > **Security** > **Conditional Access** > **Named locations**
2. Create locations for Corporate Offices (IP-based) and allowed countries (country-based)

![Conditional Access - Named Locations]({{ site.baseurl }}/assets/images/azure-ad_named-locations.png)

---

{: .highlight }
Automate Conditional Access deployment with PowerShell — [Install-BaselineCAPolicies.ps1]({{ site.baseurl }}/scripts/azure-ad/Install-BaselineCAPolicies.ps1){:download} &nbsp;|&nbsp; [Install-DataProtectionCAPolicies.ps1]({{ site.baseurl }}/scripts/azure-ad/Install-DataProtectionCAPolicies.ps1){:download} &nbsp;|&nbsp; [Install-GuestCAPolicies.ps1]({{ site.baseurl }}/scripts/azure-ad/Install-GuestCAPolicies.ps1){:download}

### Policy 1 — BLOCK: Legacy Authentication

Block legacy authentication protocols (Basic Auth, Exchange ActiveSync) that cannot enforce MFA.

1. Navigate to **Azure AD** > **Security** > **Conditional Access** > **New policy**
2. Configure Assignments — name the policy and include All users, exclude `Excluded from CA` group

   ![Block Legacy Auth - Assignments]({{ site.baseurl }}/assets/images/azure-ad_ca-block-legacy_assignments.png)

3. Cloud apps or actions — select **All cloud apps**

   ![Block Legacy Auth - Cloud Apps]({{ site.baseurl }}/assets/images/azure-ad_ca-block-legacy_cloud-apps.png)

4. Conditions > Client apps — select **Exchange ActiveSync clients** and **Other clients**

   ![Block Legacy Auth - Conditions]({{ site.baseurl }}/assets/images/azure-ad_ca-block-legacy_conditions.png)

5. Access controls — select **Block access**, then Save and Enable

   ![Block Legacy Auth - Block Access]({{ site.baseurl }}/assets/images/azure-ad_ca-block-legacy_block.png)

---

### Policy 2 — GRANT: Require Multi-Factor Authentication

Require MFA for all users on all cloud apps.

1. Navigate to **Azure AD** > **Security** > **Conditional Access** > **New policy**
2. Configure Assignments — include All users, exclude guests and `Excluded from CA` group

   ![Require MFA - Assignments]({{ site.baseurl }}/assets/images/azure-ad_ca-require-mfa_assignments.png)

3. Cloud apps or actions — select **All cloud apps**

   ![Require MFA - Cloud Apps]({{ site.baseurl }}/assets/images/azure-ad_ca-require-mfa_cloud-apps.png)

4. Conditions > Client apps — select **Browsers** and **Modern authentication clients**

   ![Require MFA - Conditions]({{ site.baseurl }}/assets/images/azure-ad_ca-require-mfa_conditions.png)

5. Access controls — Grant access, tick **Require multi-factor authentication**

   ![Require MFA - Grant Access]({{ site.baseurl }}/assets/images/azure-ad_ca-require-mfa_grant.png)

{: .important }
Test this policy in **Report-only** mode first before enabling it to avoid locking out users.

---

### Policy 3 — BLOCK: Unsupported Device Platforms

Block access from unsupported operating systems (e.g., Linux) to prevent circumvention of device-based policies.

1. Navigate to **Azure AD** > **Security** > **Conditional Access** > **New policy**
2. Configure Assignments and Cloud apps as above, then under Conditions:
   - Device platforms > Include: **Any device** / Exclude: **Android, iOS, macOS, Windows**

   ![Block Unsupported Platforms - Conditions]({{ site.baseurl }}/assets/images/azure-ad_ca-block-platforms_conditions.png)

   - Client apps: **Browsers** and **Modern authentication clients**

   ![Block Unsupported Platforms - Client Apps]({{ site.baseurl }}/assets/images/azure-ad_ca-block-platforms_conditions2.png)

3. Access controls — **Block access**, then Save and Enable

   ![Block Unsupported Platforms - Block Access]({{ site.baseurl }}/assets/images/azure-ad_ca-block-platforms_block.png)

---

### Optional Advanced Policies

{: .note }
Only enable these additional policies after completing the prerequisites listed for each:

| Policy | Prerequisite |
|--------|-------------|
| Require compliant device | Complete Endpoint Manager setup + enroll all devices |
| Require Hybrid Azure AD joined device | Complete Hybrid Azure AD Join setup + verify all devices registered |
| Require approved client app (MAM) | Complete App Protection Policies setup + deploy them |
