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

3. Click **Microsoft Entra roles** > **Assignments**.
4. Review the full list of **Eligible** and **Active** role holders. Make a note of:
   - How many accounts hold **Global Administrator** permanently (target: `<= 2` break-glass only)
   - Any role held by **more than 5 people** (target: reduce or require activation)

![Microsoft Entra PIM — Assignments tab showing multiple permanent Global Administrator assignments flagged for conversion]({{ site.baseurl }}/assets/images/pim_step1_discover.svg)
*Figure 1 — PIM > Microsoft Entra roles > Assignments. Rows highlighted in yellow are permanent (Active) assignments that exceed the ≤ 2 break-glass target. The red-dashed box marks accounts to convert in Step 3.*

{: .warning }
Do not remove permanent assignments yet — you will **convert** them to Eligible in Step 3. Removing first would lock your admins out.

---

## Step 2 — Configure Role Settings (Per-Role Policy)

For each privileged role, define how activation behaves. **Global Administrator** is the most important to lock down first.

1. In PIM, go to **Microsoft Entra roles** > **Settings**.
2. Select **Global Administrator** from the role list.
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

4. Click **Update** to save the policy.
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

![PIM Role Settings — Edit policy for Global Administrator showing activation duration 4 hours, justification On, ticket On, approval On, MFA On, notifications On]({{ site.baseurl }}/assets/images/pim_step2_policy.svg)
*Figure 2 — PIM > Microsoft Entra roles > Settings > Edit (Global Administrator). All baseline controls enabled: 4-hour max duration, justification, ticket info, approval, MFA, and full notification coverage.*

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
5. The admin receives an email notification that they are now Eligible.

![PIM — Side-by-side view: removing a permanent Active assignment (left) and adding the same user as Eligible (right)]({{ site.baseurl }}/assets/images/pim_step3_convert.svg)
*Figure 3 — Convert flow: Remove the permanent Active assignment (left panel), then immediately Add an Eligible assignment (right panel) for the same user and role.*

{: .warning }
**Keep 2 break-glass accounts as permanent Active Global Administrators**, excluded from Conditional Access. PIM itself must never lock you out of your own tenant.

---

## Step 4 — Test Activation as an Admin

Verify the end-user experience with a non-critical account first.

1. Sign in as the test admin and open **[Microsoft Entra admin center](https://entra.microsoft.com)** > **PIM** > **My roles**.
2. Under **Eligible assignments**, find the role and click **Activate**.
3. Fill in:
   - **Duration** (hours)
   - **Justification** (e.g. "Change ticket CHG0012345 — enable new CA policy")
   - **Ticket information** (if required by policy)
4. Click **Activate**. One of these happens:
   - **Auto-approved** → role is live within ~1 minute
   - **Pending approval** → approver receives an email with Approve/Deny link
5. The admin is now Active in the role for the requested duration. When it expires, access is removed automatically.

![PIM My roles — Eligible assignments list with Activate button, and the activation flyout showing Duration, Justification, and Ticket fields]({{ site.baseurl }}/assets/images/pim_step4_activate.svg)
*Figure 4 — PIM > My roles: an Eligible Global Administrator assignment with the Activate flyout open. The admin fills in duration (4 h), a justification, and their ITSM ticket number before submitting.*

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

3. Click **Start**.
4. Repeat for each of the high-impact roles configured in Step 2.

![PIM New access review form — Quarterly frequency, 14-day duration, auto-apply results, Remove access if reviewer doesn't respond]({{ site.baseurl }}/assets/images/pim_step5_accessreview.svg)
*Figure 5 — PIM > Access reviews > New access review. Set frequency to Quarterly, duration 14 days, and "Remove access" as the default when reviewers don't respond — this enforces use-it-or-lose-it.*

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

3. Also configure **Microsoft Purview** alert policies for:
   - `Added member to Role` (for roles that should be PIM-only)
   - `Activated eligible role` → notify SIEM / SOC

![PIM Alerts page — thresholds tuned with zero-tolerance MFA/justification alerts highlighted, plus a Purview callout for SIEM integration]({{ site.baseurl }}/assets/images/pim_step6_alerts.svg)
*Figure 6 — PIM > Alerts. Set permanent-owner threshold to 2 (break-glass only). The red-boxed zero-tolerance alerts (MFA and justification) must remain On. Complement with Purview alert policies that forward role-activation events to your SIEM or SOC mailbox.*

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
