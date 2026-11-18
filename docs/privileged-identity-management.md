---
title: Privileged Identity Management (PIM)
layout: default
nav_order: 5
has_children: false
permalink: /docs/privileged-identity-management
description: Deploy Microsoft Entra Privileged Identity Management (PIM) — just-in-time admin role activation, MFA on elevation, approvals, access reviews, and alerts for Global Administrator and other privileged roles.
---

# Privileged Identity Management (PIM)
{: .no_toc }

**Privileged Identity Management (PIM)** is Microsoft Entra ID's just-in-time (JIT) privileged access feature. Instead of permanent admin assignments, administrators request temporary role activation — approved, time-bound, MFA-enforced, and auditable.
{: .fs-6 .fw-300 }

{: .important }
**Requires Microsoft Entra ID P2** (included in Microsoft 365 E5, Enterprise Mobility + Security E5, or standalone). See [Prerequisites — Licensing]({{ site.baseurl }}/docs/prerequisites#2-licensing-matrix).

---

## Table of Contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## Why PIM Matters

| Without PIM | With PIM |
|-------------|----------|
| Admins hold **permanent** Global Admin rights | Admins activate roles **just-in-time** |
| Compromised admin credential = full tenant takeover | Attacker must also bypass MFA + approval + time window |
| No native audit of **why** an admin acted | Every activation records a business justification |
| Role sprawl — admins never lose access | Access reviews enforce "use it or lose it" |

{: .highlight }
Target: **zero permanent Global Administrators** other than two break-glass (emergency access) accounts.

---

## Prerequisites Checklist

- [ ] At least **one Microsoft Entra ID P2** license available
- [ ] **2 break-glass accounts** already configured — see [Tenant Configuration]({{ site.baseurl }}/docs/tenant-configuration#emergency-access-accounts)
- [ ] All target admins have **MFA registered** — see [Microsoft Entra ID — Combined Registration]({{ site.baseurl }}/docs/azure-ad-configuration#combined-registration)
- [ ] You know **who** should be approver, reviewer, and notified of activations

---

## Step 1 — Enable PIM and Discover Current Role Assignments

1. Sign in to the **[Microsoft Entra admin center](https://entra.microsoft.com)** as a **Privileged Role Administrator** or Global Administrator.

2. Navigate to **Identity governance** > **Privileged Identity Management**.

   > 💡 On first visit, Entra ID auto-provisions PIM for your tenant. This can take a few minutes.

   <!-- Screenshot placeholder — add /assets/images/pim_01_open.png
        Caption: "PIM landing page — Microsoft Entra admin center" -->

3. Click **Microsoft Entra roles** > **Assignments**.

4. Review the full list of **Eligible** and **Active** role holders. Make a note of:
   - How many accounts hold **Global Administrator** permanently (target: `<= 2` break-glass only)
   - Any role held by **more than 5 people** (target: reduce or require activation)

   <!-- Screenshot placeholder — add /assets/images/pim_02_discover.png
        Caption: "Current role assignments before PIM onboarding" -->

{: .warning }
Do not remove permanent assignments yet — you will **convert** them to Eligible in Step 3. Removing first would lock your admins out.

---

## Step 2 — Configure Role Settings (Per-Role Policy)

For each privileged role, define how activation behaves. **Global Administrator** is the most important to lock down first.

1. In PIM, go to **Microsoft Entra roles** > **Settings**.

2. Select **Global Administrator** from the role list.

   <!-- Screenshot placeholder — add /assets/images/pim_03_role_settings.png
        Caption: "Role list in PIM Settings" -->

3. Click **Edit** on the current policy and apply the baseline below:

   | Setting | Recommended Value | Why |
   |---------|-------------------|-----|
   | **Activation maximum duration** | **4 hours** | Shortest window that fits normal admin work |
   | **Require justification on activation** | ✅ **Yes** | Creates audit trail |
   | **Require ticket information on activation** | ✅ **Yes** (if you have ITSM) | Links activation to change-management ticket |
   | **Require approval to activate** | ✅ **Yes** | Second person must approve each activation |
   | **Approvers** | A dedicated **security team** group (≥ 2 members) | Avoid single-approver bottlenecks |
   | **Require Microsoft Entra Conditional Access authentication context** | Advanced — optional | Enforce phishing-resistant MFA on elevation |
   | **Require MFA on activation** | ✅ **Yes** (if no auth context) | Baseline floor |
   | **Notification — Activation alert → Admins** | ✅ **Yes** | Real-time awareness |
   | **Notification — Activation alert → Approvers** | ✅ **Yes** | Approvers know when their decision was used |
   | **Notification — Activation alert → Assignee** | ✅ **Yes** | Detects unauthorized use of their account |

   <!-- Screenshot placeholder — add /assets/images/pim_04_policy_edit.png
        Caption: "Role activation policy — Global Administrator" -->

4. Click **Update**.

5. **Repeat** for these high-impact roles:
   - Privileged Role Administrator
   - Privileged Authentication Administrator
   - Security Administrator
   - User Administrator
   - Exchange Administrator
   - SharePoint Administrator
   - Intune Administrator
   - Application Administrator
   - Cloud Application Administrator

{: .note }
For **lower-risk roles** (e.g. Reports Reader, Message Center Reader) you can keep activation friction lower — no approval, shorter justification.

---

## Step 3 — Convert Permanent Assignments to Eligible

This is the core operation: move each admin from **permanent (Active) assignment** to **Eligible assignment** so they must activate.

1. Go to **Microsoft Entra roles** > **Assignments** > **Active assignments**.

2. For each admin (other than the two break-glass accounts):
   - Select the user
   - Click **Remove**

3. Then go to **Eligible assignments** > **Add assignments**.

4. Re-add the same user as **Eligible**:
   - **Role**: same role
   - **Assignment type**: **Eligible**
   - **Assignment duration**: *Permanently eligible* (or set an expiry if contractor)

   <!-- Screenshot placeholder — add /assets/images/pim_05_make_eligible.png
        Caption: "Adding an Eligible role assignment" -->

5. The admin receives an email notification that they are now Eligible.

{: .warning }
**Keep 2 break-glass accounts as permanent Active Global Administrators**, excluded from Conditional Access. PIM itself must never lock you out of your own tenant.

---

## Step 4 — Test Activation as an Admin

Verify the end-user experience with a non-critical account first.

1. Sign in as the test admin and open **[Microsoft Entra admin center](https://entra.microsoft.com)** > **PIM** > **My roles**.

2. Under **Eligible assignments**, find the role and click **Activate**.

   <!-- Screenshot placeholder — add /assets/images/pim_06_activate.png
        Caption: "Activating an eligible role from My roles" -->

3. Fill in:
   - **Duration** (hours)
   - **Justification** (e.g. "Change ticket CHG0012345 — enable new CA policy")
   - **Ticket information** (if required by policy)

4. Click **Activate**. One of these happens:
   - **Auto-approved** → role is live within ~1 minute
   - **Pending approval** → approver receives an email with Approve/Deny link

5. The admin is now Active in the role for the requested duration. When it expires, access is removed automatically.

---

## Step 5 — Access Reviews (Ongoing Governance)

Even Eligible assignments drift over time. Configure recurring reviews.

1. In PIM, go to **Microsoft Entra roles** > **Access reviews** > **New access review**.

2. Configure:

   | Setting | Recommended Value |
   |---------|-------------------|
   | **Review name** | `Quarterly PIM — <Role>` |
   | **Start date** | First day of next quarter |
   | **Frequency** | **Quarterly** |
   | **Duration** | 14 days |
   | **Users to review** | **Members (users) of this role** (Eligible + Active) |
   | **Reviewers** | Role holder's manager **or** a security group |
   | **Upon completion — apply results** | ✅ **Auto-remove access** if not reviewed |
   | **If reviewers don't respond** | **Remove access** |
   | **Require reason on approval** | ✅ **Yes** |

   <!-- Screenshot placeholder — add /assets/images/pim_07_access_review.png
        Caption: "Creating a quarterly access review for a privileged role" -->

3. Click **Start**.

4. Repeat for each of the high-impact roles configured in Step 2.

---

## Step 6 — Alert on Critical PIM Events

1. In PIM, go to **Microsoft Entra roles** > **Alerts**.

2. Review the default alerts and tune them:

   | Alert | Recommended Action |
   |-------|---------------------|
   | **Too many owners assigned to a role** | Threshold: **5** |
   | **Too many permanent owners assigned to a role** | Threshold: **2** (break-glass only) |
   | **Roles are being activated too frequently** | Threshold: **2 activations / 24 hours** per user |
   | **Roles don't require MFA for activation** | Enabled — zero-tolerance |
   | **Roles don't require justification for activation** | Enabled |

   <!-- Screenshot placeholder — add /assets/images/pim_08_alerts.png
        Caption: "PIM alert configuration page" -->

3. Also configure **Microsoft 365 Security & Compliance** alert for:
   - `Added member to Role` (for roles that should be PIM-only)
   - `Activated eligible role` → notify SIEM / SOC

---

## Bulk Onboarding with PowerShell

For tenants with many role holders, convert assignments in bulk using the Microsoft Graph SDK.

```powershell
# Prerequisites:
#   - Microsoft.Graph module (>= 2.0.0) — see /docs/prerequisites
#   - Running as Privileged Role Administrator or Global Administrator
#   - A test group of users BEFORE applying tenant-wide

Connect-MgGraph -Scopes `
    "RoleManagement.ReadWrite.Directory", `
    "Directory.Read.All"

# 1. Define the role you want to migrate (Global Admin here)
$roleName = "Global Administrator"
$role     = Get-MgRoleManagementDirectoryRoleDefinition -Filter "displayName eq '$roleName'"

# 2. Get CURRENT active (permanent) assignments
$activeAssignments = Get-MgRoleManagementDirectoryRoleAssignment `
    -Filter "roleDefinitionId eq '$($role.Id)'" -All

Write-Host "Found $($activeAssignments.Count) active '$roleName' assignments."

# 3. For each principal (SKIP break-glass!), create an Eligible assignment
$breakGlassUpns = @(
    "breakglass1@contoso.onmicrosoft.com",
    "breakglass2@contoso.onmicrosoft.com"
)

foreach ($a in $activeAssignments) {
    $user = Get-MgUser -UserId $a.PrincipalId -ErrorAction SilentlyContinue
    if (-not $user) { continue }
    if ($breakGlassUpns -contains $user.UserPrincipalName) {
        Write-Host "SKIP break-glass: $($user.UserPrincipalName)" -ForegroundColor Yellow
        continue
    }

    $params = @{
        Action           = "adminAssign"
        PrincipalId      = $user.Id
        RoleDefinitionId = $role.Id
        DirectoryScopeId = "/"
        ScheduleInfo     = @{
            StartDateTime = (Get-Date).ToString("o")
            Expiration    = @{ Type = "noExpiration" }
        }
        Justification    = "Bulk PIM onboarding — see change ticket CHG0012345"
    }

    New-MgRoleManagementDirectoryRoleEligibilityScheduleRequest -BodyParameter $params
    Write-Host "Made eligible: $($user.UserPrincipalName)" -ForegroundColor Green
}

# 4. MANUAL STEP — after verifying eligibility works end-to-end for every user,
#    remove the original permanent assignments from the UI or via:
#    Remove-MgRoleManagementDirectoryRoleAssignment -UnifiedRoleAssignmentId <id>
```

{: .warning }
Always test the workflow with **one** non-essential admin before running this loop. Removing permanent assignments without a working Eligible path will prevent that admin from signing in with elevated rights.

---

## Verification Checklist

After rollout, confirm:

- [ ] Only **2 break-glass accounts** remain as permanent Global Administrators
- [ ] Every other admin has to **activate** before performing privileged tasks
- [ ] Activation requires **MFA + justification + approval** (for Global Admin and above)
- [ ] **Quarterly access reviews** are scheduled for every privileged role
- [ ] **Alerts** notify the security team on activation of Global/Security/Privileged Role Administrator
- [ ] **Entra sign-in logs** show role activations under **"Service Principal sign-ins → PIM"**

---

## References

- [What is Microsoft Entra Privileged Identity Management?](https://learn.microsoft.com/en-us/entra/id-governance/privileged-identity-management/pim-configure){:target="_blank"}
- [PIM licensing — Microsoft Entra ID Governance licensing fundamentals](https://learn.microsoft.com/en-us/entra/id-governance/licensing-fundamentals){:target="_blank"}
- [Deploy PIM — Microsoft Learn](https://learn.microsoft.com/en-us/entra/id-governance/privileged-identity-management/pim-deployment-plan){:target="_blank"}
- [Microsoft Graph PIM API](https://learn.microsoft.com/en-us/graph/api/resources/privilegedidentitymanagementv3-overview){:target="_blank"}

---

{: .note }
**Screenshots coming soon.** This page ships with the full step-by-step procedure; portal screenshots will be added in the next content pass. If you'd like to contribute them, see [SECURITY.md](https://github.com/DekBaCom/Microsoft365SetupGuide/blob/main/SECURITY.md) and open a pull request.
