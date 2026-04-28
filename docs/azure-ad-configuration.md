---
title: Azure AD Configuration
layout: default
nav_order: 3
has_children: true
permalink: docs/azure-ad-configuration
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
3. Under **Users can use the combined security information registration experience**, select **All**
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

   **Properties tab:**
   - Set **Self service password reset enabled** to **All**

   **Authentication methods tab:**
   - Require **2 methods**
   - Enable: Mobile app notification, Mobile app code, Mobile phone, Email

   **Registration tab:**
   - Set **Require users to register when signing in?** to **No**
   *(Users registered via Combined Registration above)*

   **Notifications tab:**
   - **Notify users on password resets?** → Yes
   - **Notify all admins when other admins reset their password?** → Yes

3. Click **Save**

---

## User Settings

Configure default user and guest collaboration settings in Azure AD.

### Default User Settings

1. Go to **Azure AD admin center** > **Users** > **User settings**
2. Make the following recommended selections:
   - **Users can register applications** → **No**
   - **Restrict access to Azure AD administration portal** → **Yes**

### External Collaboration Settings (Guest Users)

1. Scroll down and click **Manage external collaboration settings** (under External users)  
   *(Also accessible via Azure AD > External identities > External collaboration settings)*
2. Recommended settings:
   - **Enable Email One-Time Passcode** → **Yes**  
     *Allows external guests without Microsoft accounts to authenticate*
   - **Guest user access restrictions** → Review and choose appropriate level
   - **Guests can invite** → **No** (recommended for most organizations)
   - Review remaining options based on your organization's collaboration needs

---

## Admin Consent Requests

Prevent users from independently consenting to third-party application permission requests.

### Steps

1. Navigate to **Azure AD** > **Enterprise Applications** > **User settings**
2. Set **Users can consent to apps accessing company data on their behalf** → **No**
3. Set **Users can request admin consent to apps they are unable to consent to** → **Yes**
4. Configure the admin consent request settings (workflow, expiration, etc.)
5. **Select approvers** — choose admins who will review and approve consent requests

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
3. Review other device settings (e.g., maximum number of devices per user)

### Enterprise State Roaming

1. Navigate to **Azure AD** > **Devices** > **Enterprise state roaming**
2. Under **Users may sync settings and app data across devices**, select **All**

{: .note }
Enterprise State Roaming allows users' Windows settings and app data to sync across devices via Azure AD, providing a consistent experience.

---

## Conditional Access Baseline

Create the foundational Conditional Access policies to protect your tenant.

{: .warning }
Before configuring Conditional Access policies, you **must** disable Security Defaults if it is currently enabled. Security Defaults and Conditional Access cannot be used simultaneously.

### Step 1 — Disable Security Defaults

1. Go to **Azure AD** > **Properties**
2. Click **Manage Security Defaults** at the bottom
3. Set **Enable Security Defaults** to **No**
4. Provide a reason and click **Save**

### Step 2 — Configure Named Locations (Optional but Recommended)

1. Navigate to **Azure AD** > **Security** > **Conditional Access** > **Named locations**
2. Create locations for:
   - **Corporate Offices** (IP-based)
   - **United States** or other allowed countries (country-based)

---

### Policy 1 — BLOCK: Legacy Authentication

Block legacy authentication protocols (Basic Auth, Exchange ActiveSync) that cannot enforce MFA.

1. Navigate to **Azure AD** > **Security** > **Conditional Access** > **New policy**
2. Configure:

   | Setting | Value |
   |---------|-------|
   | Name | `BLOCK - Legacy authentication` |
   | Users | All users |
   | Exclude | `Excluded from CA` group + break-glass accounts |
   | Cloud apps | All cloud apps |
   | Conditions > Client apps | Exchange ActiveSync clients + Other clients |
   | Access controls | Block access |
   | Policy state | **Enabled** |

---

### Policy 2 — GRANT: Require Multi-Factor Authentication

Require MFA for all users on all cloud apps.

1. Navigate to **Azure AD** > **Security** > **Conditional Access** > **New policy**
2. Configure:

   | Setting | Value |
   |---------|-------|
   | Name | `GRANT - Require Multi-factor authentication` |
   | Users | All users |
   | Exclude | All guests/external users (optional) + `Excluded from CA` group |
   | Cloud apps | All cloud apps |
   | Conditions > Client apps | Browsers + Modern authentication clients |
   | Access controls | Grant access — **Require multi-factor authentication** |
   | Policy state | **Enabled** (when customer is ready) |

{: .important }
Test this policy in **Report-only** mode first before enabling it to avoid locking out users.

---

### Policy 3 — BLOCK: Unsupported Device Platforms

Block access from unsupported operating systems (e.g., Linux) to prevent circumvention of device-based policies.

1. Navigate to **Azure AD** > **Security** > **Conditional Access** > **New policy**
2. Configure:

   | Setting | Value |
   |---------|-------|
   | Name | `BLOCK - Unsupported device platforms` |
   | Users | All users |
   | Exclude | `Excluded from CA` group |
   | Cloud apps | All cloud apps |
   | Conditions > Device platforms > Include | Any device |
   | Conditions > Device platforms > Exclude | Android, iOS, macOS, Windows |
   | Conditions > Client apps | Browsers + Modern authentication clients |
   | Access controls | Block access |
   | Policy state | **Enabled** |

---

### Optional Advanced Policies

{: .note }
Only enable these additional policies after completing the prerequisites listed for each:

| Policy | Prerequisite |
|--------|-------------|
| Require compliant device | Complete Endpoint Manager setup + enroll all devices |
| Require Hybrid Azure AD joined device | Complete Hybrid Azure AD Join setup + verify all devices registered |
| Require approved client app (MAM) | Complete App Protection Policies setup + deploy them |

For additional recommended policies, refer to the [Microsoft Conditional Access documentation](https://learn.microsoft.com/en-us/entra/identity/conditional-access/plan-conditional-access).
