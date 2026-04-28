---
title: Collaboration Governance
layout: default
nav_order: 5
has_children: true
permalink: docs/collaboration-governance
---

# Collaboration Governance
{: .no_toc }

Control how users share and collaborate while protecting sensitive data through Data Loss Prevention, Retention policies, Sensitivity labels, and Teams/SharePoint governance settings.
{: .fs-6 .fw-300 }

---

## Overview

| Section | Description |
|---------|-------------|
| [Data Loss Prevention](#data-loss-prevention) | Prevent exfiltration or accidental oversharing of sensitive data |
| [Retention Policies](#retention-policies) | Preserve data for exactly as long as required |
| [Sensitivity Labels](#sensitivity-labels) | Data classification with encryption and access controls |
| [SharePoint and OneDrive](#sharepoint-and-onedrive) | Configure default sharing options |
| [Groups and Teams](#groups-and-teams) | Govern Microsoft 365 Groups and Teams settings |

---

## Governance Risk Matrix

Use the table below to determine which settings are appropriate for your organization's risk tolerance:

| Checklist Item | Lower Risk Concern | Recommended for Higher Risk |
|----------------|-------------------|----------------------------|
| **DLP policy** | Default (None) | Enabled for sensitive data types (GLBA, HIPAA, etc.); start with Incident Reports and monitor before implementing block controls |
| **Retention policies** | Default (None) | General policy (1–2 years) + compliance-specific labels (6–7 years) |
| **Sensitivity labels** | Default (None) | Enable default labels: Public, General, Confidential, Highly Confidential |
| **Teams: Groups creation** | Allow all users | Restrict to specific individuals; add Expiration policy |
| **Teams: Guest access** | Enabled | Disable only if external collaboration is never needed |
| **Teams: External chat** | Allow (default) | Restrict by domain for specific partner orgs |
| **Teams: 3rd party storage** | Allow (default) | Disable all third-party storage providers |
| **SharePoint/OneDrive sharing** | Allow Anyone links | Require login (New & Existing guests) |
| **Guest sharing links** | Allow (default) | Disable guests from generating sharing links |

---

## Data Loss Prevention

Prevent exfiltration or accidental oversharing of sensitive information.

### Step 1 — Deploy the Recommended DLP Policy

1. Go to **Microsoft 365 Admin Center** > **Setup**
2. Search for **DLP** and locate **Set up data loss prevention (DLP)**
3. Click **Get Started** and review the policy options
4. Recommendation: **Deselect** "Show a policy tip" initially (can be customized later)
5. Click **Create policy** to deploy the baseline recommended policy

### Step 2 — Customize DLP Policies

1. Navigate to **compliance.microsoft.com** > **Data loss prevention** > **Policies**
2. Customize the recommended policy or click **Create a policy** for custom outcomes

**Recommended customizations:**
- Configure **policy tips** and **email notifications** in plain language for end users
- Set up **incident reports** to go to a compliance administrator or monitored shared mailbox
- For high-risk environments: configure **auto-encryption for email** containing sensitive data

**Common sensitive information types to protect:**
- Credit card numbers
- Social Security numbers
- HIPAA-related health data (if applicable)
- GLBA financial information (if applicable)
- Passport numbers and government IDs

{: .note }
Start with **Audit/Incident Report** mode to understand your sharing patterns before implementing block or encryption controls. This prevents disruption to legitimate workflows.

---

## Retention Policies

Preserve data for compliance and legal hold purposes, and optionally auto-delete data that is no longer needed.

### Creating Retention Policies

1. Navigate to **compliance.microsoft.com**
2. Click **Show all** in the left navigation
3. Under **Solutions**, go to **Information governance** > **Retention**
4. Click **New retention policy**

### Recommended Approach

Create **individual policies per service** for granular control:

| Service | Recommended Retention |
|---------|----------------------|
| Exchange Online (email) | 2–7 years (based on compliance needs) |
| SharePoint Online | 2–7 years |
| OneDrive accounts | 2–7 years |
| Microsoft 365 Groups | 2–7 years |
| Teams channel messages | 2–7 years |
| Teams private chats | 2–7 years |

**Configuration options:**
- **Retention duration**: Choose a fixed period
- **Auto-deletion**: Optionally delete content after the retention period (with or without disposition review)
- **Mark as a record**: For compliance-critical content that must not be modified

{: .warning }
Retained data still counts against your storage quotas. Plan your retention durations accordingly.

{: .note }
New retention policies can take up to **24 hours** to take effect after creation.

---

## Sensitivity Labels

Define data classification labels with special protections such as encryption, watermarking, and access restrictions.

### Step 1 — Generate Default Labels

1. Navigate to **security.microsoft.com** > **Classification** > **Sensitivity labels**
2. If prompted, click **Go to Azure Information Protection** to migrate labels
3. In Azure Information Protection, verify that **Unified labeling is activated**
4. Click **Labels** > **Generate default labels**

**Default label set:**

| Label | Description |
|-------|-------------|
| Personal | Non-business content |
| Public | Content approved for public release |
| General | General internal business content |
| Confidential | Business-sensitive content |
| Highly Confidential | Most sensitive content (encryption enforced) |

{: .note }
Many organizations **exclude the "Personal" label** as they do not want to imply that personal (non-business) data is protected by the organization.

### Step 2 — Enable Unified Labeling in Office Web Apps

1. Return to the **Microsoft 365 security center**
2. If the option **Turn on now** is available, click it to enable classified content in Office web apps

### Step 3 — Publish Sensitivity Labels

1. Click **Publish labels**
2. Select all default labels you wish to publish
3. Target **All users** (recommended) or specific groups
4. Configure **policy settings**:
   - **Default label**: Often set to "General" or "Internal"
   - **Require justification to remove or downgrade a label**: **Yes** (recommended)
   - **Require users to apply a label to emails and documents**: Configure based on org policy
5. Name the policy (e.g., "Default classification policy")
6. Review settings and **Submit**

{: .note }
Sensitivity labels appear in Office applications within **24 hours** of publishing.

---

## SharePoint and OneDrive

Configure sharing settings to balance collaboration needs with data security.

### Step 1 — Configure External Collaboration Settings in Azure AD

1. Navigate to **Azure AD admin center** > **External identities** > **External collaboration settings**
2. Recommended settings:
   - **Enable Email One-Time Passcode** → **Yes** (allows guests without Microsoft accounts to authenticate)
   - Review other guest invitation and access settings

### Step 2 — Configure Sharing Settings

1. Navigate to the **SharePoint admin center** (admin.microsoft.com > Show all > SharePoint)
2. Click **Policies** > **Sharing**
3. Configure the **SharePoint** and **OneDrive** sharing sliders:

   | Sharing Level | Use Case |
   |---------------|----------|
   | Anyone (no sign-in required) | Most permissive — anonymous links allowed |
   | New and existing guests | Requires guest sign-in — **recommended for most orgs** |
   | Existing guests only | Only pre-invited guests can access |
   | Only people in your organization | No external sharing at all |

4. **Additional recommended settings** (scroll down):
   - **Default link type**: Change from "Anyone" to **Specific people** (Secure links)
   - **Anyone link expiration**: Set an expiration (e.g., 30 days) if Anyone links are enabled
   - **Allow guests to share items they don't own**: **Disable** (recommended)

{: .note }
SharePoint and OneDrive must be configured at the same or more restrictive level — you cannot set OneDrive to be less restrictive than SharePoint.

---

## Groups and Teams

Govern Microsoft Teams and Microsoft 365 Groups settings.

### External Access (Federated Chat)

1. Navigate to **Teams admin center** (admin.teams.microsoft.com)
2. Expand **Org-wide settings** > **External access**
3. Keep **Allow users to communicate with other Teams users** → **On**
   *(Unless you need to limit to internal users only, or restrict to specific domains)*

### Guest Access

1. Navigate to **Teams admin center** > **Org-wide settings** > **Guest access**
2. Set **Allow guest access in Teams** → **On** (recommended for most organizations)

### Third-Party File Storage

1. Navigate to **Teams admin center** > **Org-wide settings** > **Teams settings**
2. Scroll to **Files**
3. Set all third-party storage providers (Citrix Files, DropBox, Box, Google Drive, ShareFile) to **Off**

{: .highlight }
Disabling third-party storage encourages users to store files in OneDrive and SharePoint, where they are governed by your Microsoft 365 policies.

### Meetings Policy

1. Navigate to **Teams admin center** > **Meetings** > **Meeting policies**
2. Modify the **Global (Org-wide default)** policy:
   - **Allow guests to give or request control**: **On** (common request for external collaboration)
   - Review anonymous join settings based on your organization's privacy requirements

### Meeting Settings

1. Navigate to **Teams admin center** > **Meetings** > **Meeting settings**
2. Review **Anonymous users can join a meeting**:
   - **Disabled** = more secure (all external participants must sign in)
   - **Enabled** = more convenient (anyone with a link can join without signing in)

### Groups Expiration Policy

Automatically expire and delete stale, inactive Groups to keep your tenant clean.

1. Navigate to **Azure AD admin center** > **Groups** > **Expiration**
2. Configure:
   - **Group lifetime**: **180 days** (recommended)
   - **Email contact for groups with no owners**: Enter a monitored email address
   - **Enable expiration for these Microsoft 365 groups**: **All**
3. Click **Save**

{: .note }
Group owners will receive email notifications before their group expires. If there is no owner, notifications go to the email address you configured above.

### Restrict Who Can Create Groups/Teams (Optional)

{: .warning }
This is an advanced option that can significantly impact user experience. Only implement this in strict environments.

If required, you can limit Teams/Groups creation to a specific security group using PowerShell:

```powershell
# Install the Azure AD module if needed
Install-Module AzureAD

# Connect to Azure AD
Connect-AzureAD

# Fetch the unified group template
$Template = Get-AzureADDirectorySettingTemplate | Where-Object {$_.DisplayName -eq "Group.Unified"}
$Settings = $Template.CreateDirectorySetting()

# Set the group creators group
$Settings["EnableGroupCreation"] = "false"
$Settings["GroupCreationAllowedGroupId"] = "<Security Group Object ID>"

# Apply settings
New-AzureADDirectorySetting -DirectorySetting $Settings
```

{: .note }
Microsoft does not recommend restricting Group creation for most organizations. Open creation with expiration policies is the preferred approach.
