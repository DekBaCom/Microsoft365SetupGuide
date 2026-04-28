---
title: Collaboration Governance
layout: default
nav_order: 5
has_children: true
permalink: /docs/collaboration-governance
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

| Checklist Item | Lower Risk | Recommended for Higher Risk |
|----------------|-----------|----------------------------|
| **DLP policy** | Default (None) | Enabled for GLBA, HIPAA sensitive data types |
| **Retention policies** | Default (None) | General (1–2 years) + compliance labels (6–7 years) |
| **Sensitivity labels** | Default (None) | Public, General, Confidential, Highly Confidential |
| **Teams: Groups creation** | Allow all | Restrict to specific individuals + Expiration policy |
| **Teams: Guest access** | Enabled | Disable only if external collaboration never needed |
| **Teams: External chat** | Allow | Restrict by domain for specific partner orgs |
| **Teams: 3rd party storage** | Allow | Disable all third-party storage providers |
| **SharePoint/OneDrive sharing** | Allow Anyone links | Require login (New & Existing guests) |
| **Guest sharing links** | Allow | Disable guests from generating sharing links |

---

## Data Loss Prevention

Prevent exfiltration or accidental oversharing of sensitive information.

{: .highlight }
Automate with PowerShell — [Install-SensitivityLabels.ps1]({{ site.baseurl }}/scripts/compliance/Install-SensitivityLabels.ps1){:download} &nbsp;|&nbsp; [Install-DataRetentionPolicies.ps1]({{ site.baseurl }}/scripts/compliance/Install-DataRetentionPolicies.ps1){:download} &nbsp;|&nbsp; [Install-TeamsRetentionPolicies.ps1]({{ site.baseurl }}/scripts/compliance/Install-TeamsRetentionPolicies.ps1){:download} &nbsp;|&nbsp; [Set-GroupExpirationPolicy.ps1]({{ site.baseurl }}/scripts/azure-ad/Set-GroupExpirationPolicy.ps1){:download}

### Step 1 — Deploy the Recommended DLP Policy

1. Go to **Microsoft 365 Admin Center** > **Setup** and search for **DLP**

   ![M365 Admin Center - Search for DLP]({{ site.baseurl }}/assets/images/collab_dlp_step1.png)

2. Click **Get Started** and review the policy options
   - Recommendation: **Deselect** "Show a policy tip" initially

   ![DLP - Get Started and configure]({{ site.baseurl }}/assets/images/collab_dlp_step2.png)

3. Click **Create policy** to deploy the baseline recommended policy

### Step 2 — Customize DLP Policies

1. Navigate to **compliance.microsoft.com** > **Data loss prevention** > **Policy**

   ![DLP - Navigate to Policy in compliance center]({{ site.baseurl }}/assets/images/collab_dlp_customize.png)

2. Customize the recommended policy or click **Create a policy** for custom outcomes

   ![DLP - Create custom policy]({{ site.baseurl }}/assets/images/collab_dlp_custom-policy.png)

**Recommended customizations:**
- Configure **policy tips** and **email notifications** in plain language for end users
- Set up **incident reports** to go to a compliance administrator or monitored shared mailbox
- For high-risk environments: configure **auto-encryption for email** containing sensitive data

{: .note }
Start with **Audit/Incident Report** mode to understand your sharing patterns before implementing block or encryption controls.

---

## Retention Policies

Preserve data for compliance and legal hold purposes, and optionally auto-delete data that is no longer needed.

### Steps

1. Navigate to **compliance.microsoft.com** > **Information governance** > **Retention**

   ![Retention - Navigate to Information Governance]({{ site.baseurl }}/assets/images/collab_retention_nav.png)

2. Click **New retention policy** — create individual policies per service

   ![Retention - Individual blanket policies per service]({{ site.baseurl }}/assets/images/collab_retention_step1.png)

3. Choose retention duration and optional auto-deletion

   ![Retention - Duration and deletion options]({{ site.baseurl }}/assets/images/collab_retention_options.png)

4. Select the location (Exchange, SharePoint, OneDrive, Teams, etc.)

   ![Retention - Select location]({{ site.baseurl }}/assets/images/collab_retention_location.png)

5. Review settings and **Create the policy**

   ![Retention - Review and create]({{ site.baseurl }}/assets/images/collab_retention_review.png)

### Recommended Retention Periods

| Service | Recommended Retention |
|---------|----------------------|
| Exchange Online | 2–7 years |
| SharePoint Online | 2–7 years |
| OneDrive accounts | 2–7 years |
| Teams channel messages | 2–7 years |
| Teams private chats | 2–7 years |

{: .warning }
Retained data still counts against your storage quotas.

{: .note }
New retention policies can take up to **24 hours** to take effect.

---

## Sensitivity Labels

Define data classification labels with special protections such as encryption, watermarking, and access restrictions.

### Step 1 — Navigate to Sensitivity Labels

1. Navigate to **security.microsoft.com** > **Classification** > **Sensitivity labels**

   ![Sensitivity Labels - Navigate to security center]({{ site.baseurl }}/assets/images/collab_sensitivity_nav.png)

2. Click **Go to Azure Information Protection** to migrate labels (if available)

   ![Sensitivity Labels - Azure Information Protection]({{ site.baseurl }}/assets/images/collab_sensitivity_aip.png)

3. Verify that **Unified labeling is activated**

   ![Sensitivity Labels - Unified labeling activated]({{ site.baseurl }}/assets/images/collab_sensitivity_unified.png)

### Step 2 — Generate Default Labels

1. Click **Labels** > **Generate default labels**

   ![Sensitivity Labels - Generate default labels]({{ site.baseurl }}/assets/images/collab_sensitivity_generate.png)

### Step 3 — Enable in Office Web Apps

1. Return to the Microsoft 365 security center
2. Click **Turn on now** if the option is available

   ![Sensitivity Labels - Turn on for Office web apps]({{ site.baseurl }}/assets/images/collab_sensitivity_turn-on.png)

### Step 4 — Publish Sensitivity Labels

1. Click **Publish labels**

   ![Sensitivity Labels - Publish labels]({{ site.baseurl }}/assets/images/collab_sensitivity_publish.png)

2. Select all default labels you wish to publish

   ![Sensitivity Labels - Select labels to publish]({{ site.baseurl }}/assets/images/collab_sensitivity_select-labels.png)

   {: .note }
   Many organizations **exclude the "Personal" label** as they do not want to imply that personal (non-business) data is protected by the organization.

3. Target **All users** (recommended) or specific groups

   ![Sensitivity Labels - Target users]({{ site.baseurl }}/assets/images/collab_sensitivity_target.png)

4. Configure **policy settings**:
   - Default label: Often **General** or **Internal**
   - Require justification to remove or downgrade: **Yes** (recommended)

   ![Sensitivity Labels - Policy settings]({{ site.baseurl }}/assets/images/collab_sensitivity_policy-settings.png)

5. Name the policy (e.g., "Default classification policy")

   ![Sensitivity Labels - Name the policy]({{ site.baseurl }}/assets/images/collab_sensitivity_name-policy.png)

6. Review and **Submit**

   ![Sensitivity Labels - Review and submit]({{ site.baseurl }}/assets/images/collab_sensitivity_submit.png)

{: .note }
Sensitivity labels appear in Office applications within **24 hours** of publishing.

---

## SharePoint and OneDrive

Configure sharing settings to balance collaboration needs with data security.

### Step 1 — Configure External Collaboration Settings in Azure AD

1. Navigate to **Azure AD admin center** > **External identities** > **External collaboration settings**
2. Recommended: Enable **Email One-Time Passcode** → **Yes**

   ![SharePoint - External collaboration settings in Azure AD]({{ site.baseurl }}/assets/images/collab_sharepoint_external-collab.png)

### Step 2 — Configure Sharing Settings

1. Navigate to the **SharePoint admin center**

   ![SharePoint Admin Center]({{ site.baseurl }}/assets/images/collab_sharepoint_admin-center.png)

2. Click **Policies** > **Sharing** and configure the sharing sliders

   ![SharePoint - Sharing settings]({{ site.baseurl }}/assets/images/collab_sharepoint_sharing.png)

   | Sharing Level | Use Case |
   |---------------|----------|
   | Anyone (no sign-in) | Most permissive — anonymous links |
   | New and existing guests | Requires sign-in — **recommended for most orgs** |
   | Existing guests only | Only pre-invited guests |
   | Only people in org | No external sharing |

3. Scroll down for additional settings:
   - **Default link type**: Change from "Anyone" to **Specific people**
   - **Anyone link expiration**: Set an expiration (e.g., 30 days) if Anyone links are enabled
   - **Allow guests to share items they don't own**: **Disable** (recommended)

   ![SharePoint - Link type and expiration settings]({{ site.baseurl }}/assets/images/collab_sharepoint_link-settings.png)

---

## Groups and Teams

Govern Microsoft Teams and Microsoft 365 Groups settings.

### External Access (Federated Chat)

1. Navigate to **Teams admin center** > **Org-wide settings** > **External access**
2. Keep **Allow users to communicate with other Teams users** → **On**

   ![Teams - External access settings]({{ site.baseurl }}/assets/images/collab_teams_external-access.png)

### Guest Access

1. Navigate to **Teams admin center** > **Org-wide settings** > **Guest access**
2. Set **Allow guest access in Teams** → **On**

   ![Teams - Guest access settings]({{ site.baseurl }}/assets/images/collab_teams_guest-access.png)

### Third-Party File Storage

1. Navigate to **Teams admin center** > **Org-wide settings** > **Teams settings** > **Files**
2. Set all third-party storage providers to **Off**

   ![Teams - Third-party file storage settings]({{ site.baseurl }}/assets/images/collab_teams_file-sharing.png)

{: .highlight }
Disabling third-party storage encourages users to store files in OneDrive and SharePoint, where they are governed by your Microsoft 365 policies.

### Meetings Policy

1. Navigate to **Teams admin center** > **Meetings** > **Meeting policies**
2. Modify the **Global (Org-wide default)** policy:
   - **Allow guests to give or request control**: **On**

   ![Teams - Global meetings policy]({{ site.baseurl }}/assets/images/collab_teams_meetings-policy.png)

### Meeting Settings

1. Navigate to **Teams admin center** > **Meetings** > **Meeting settings**
2. Review **Anonymous users can join a meeting**:
   - **Disabled** = more secure (all external participants must sign in)
   - **Enabled** = more convenient (anyone with a link can join)

   ![Teams - Meeting settings]({{ site.baseurl }}/assets/images/collab_teams_meeting-settings.png)

### Groups Expiration Policy

Automatically expire and delete stale, inactive Groups to keep your tenant clean.

1. Navigate to **Azure AD admin center** > **Groups** > **Expiration**
2. Configure:
   - **Group lifetime**: **180 days**
   - **Email contact for groups with no owners**: Enter a monitored email address
   - **Enable expiration for**: **All**
3. Click **Save**

   ![Azure AD - Groups expiration policy]({{ site.baseurl }}/assets/images/collab_groups_expiration.png)

### Restrict Who Can Create Groups/Teams (Optional)

{: .warning }
This is an advanced option that significantly impacts user experience. Only implement in strict environments.

![Groups - Restrict who can create groups]({{ site.baseurl }}/assets/images/collab_groups_creators.png)

If required, limit Teams/Groups creation using PowerShell:

```powershell
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
