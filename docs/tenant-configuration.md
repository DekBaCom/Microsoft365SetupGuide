---
title: Tenant Configuration
layout: default
nav_order: 3
has_children: true
permalink: /docs/tenant-configuration
description: Foundational Microsoft 365 tenant setup — custom domains, organization settings, break-glass accounts, EOP + Defender for Office 365 baseline, and alert policies.
---

# Tenant Configuration
{: .no_toc }

Configure your Microsoft 365 tenant's foundational settings including custom domains, organization settings, emergency access accounts, email security baseline, and alert policies.
{: .fs-6 .fw-300 }

---

## Overview

| Section | Description |
|---------|-------------|
| [Vanity Domains](#vanity-domains) | Associate custom domains to Microsoft 365 |
| [Organization Settings](#organization-settings) | Customize password policy, org info, and support details |
| [Emergency Access Accounts](#emergency-access-accounts) | Create break-glass accounts and security group |
| [EOP & Defender for Office 365 Baseline](#eop--defender-for-office-365-baseline) | Apply email security baseline policies |
| [Report Message Add-in](#report-message-add-in) | Enable users to report spam/phishing |
| [Alert Policies](#alert-policies) | Configure security & compliance alerts |

{: .note }
🖼️ **About the images on this page.** Each step shows a generic placeholder graphic until real screenshots are contributed. The **caption below every image names the exact portal screen** it illustrates and the **target filename** (`tenant_NN_name.png`) under `/assets/images/`. To swap in a real screenshot: drop the PNG into that folder with the matching filename and change the `placeholder.svg` reference in `docs/tenant-configuration.md` to the new filename.

---

## Vanity Domains

Associate your organization's custom domain(s) with Microsoft 365.

### Steps

1. Go to **Microsoft 365 Admin Center** > **Settings** > **Domains**

   ![Microsoft 365 Admin Center — Settings > Domains landing page]({{ site.baseurl }}/assets/images/placeholder.svg)
   *Figure 1.1 — Microsoft 365 Admin Center: Settings > Domains landing page.* **Target:** `tenant_01_domains_landing.png`

2. Click **Add domain** and enter your custom domain name

   ![Add domain wizard — enter the custom domain name]({{ site.baseurl }}/assets/images/placeholder.svg)
   *Figure 1.2 — Add domain wizard: enter the custom domain name.* **Target:** `tenant_02_domains_add.png`

3. Follow the wizard to verify domain ownership via DNS TXT record

   ![Verify domain ownership — DNS TXT record values]({{ site.baseurl }}/assets/images/placeholder.svg)
   *Figure 1.3 — Verify domain ownership: DNS TXT record values shown by the wizard.* **Target:** `tenant_03_domains_verify.png`

4. Update MX, CNAME, and TXT records at your DNS registrar as instructed

   ![DNS records to add at your registrar — MX, CNAME, TXT]({{ site.baseurl }}/assets/images/placeholder.svg)
   *Figure 1.4 — DNS records to add at your registrar (MX, CNAME, TXT).* **Target:** `tenant_04_domains_records.png`

5. Set the custom domain as the **default domain** if desired

   ![Set the newly verified domain as tenant default]({{ site.baseurl }}/assets/images/placeholder.svg)
   *Figure 1.5 — Set the newly verified domain as the tenant default.* **Target:** `tenant_05_domains_default.png`

{: .note }
Allow up to 48 hours for DNS propagation after updating records.

---

## Organization Settings

Customize your tenant's general organization settings.

### Steps

1. Navigate to **Microsoft 365 Admin Center** > **Settings** > **Org settings**

   ![Org settings landing — Organization profile / Security & privacy / Services tabs]({{ site.baseurl }}/assets/images/placeholder.svg)
   *Figure 2.1 — Org settings landing page with the Organization profile / Security & privacy / Services tabs.* **Target:** `tenant_06_orgsettings_landing.png`

2. Under the **Organization profile** tab, update:
   - Organization name
   - Technical contact email
   - Support contact details (phone, website, URL)

   ![Organization profile tab — org name, technical contact, support details]({{ site.baseurl }}/assets/images/placeholder.svg)
   *Figure 2.2 — Organization profile tab: org name, technical contact, support details.* **Target:** `tenant_07_orgsettings_profile.png`

3. Under the **Security & privacy** tab, configure the **Password expiration policy**:
   - Recommended: Set passwords to **never expire** if using MFA

   ![Password expiration policy — set to never-expire when MFA is enforced]({{ site.baseurl }}/assets/images/placeholder.svg)
   *Figure 2.3 — Password expiration policy: set to Never expire when MFA is enforced.* **Target:** `tenant_08_orgsettings_password_policy.png`

4. Review and update **Release preferences** (targeted/standard release)

   ![Release preferences — Standard vs Targeted release]({{ site.baseurl }}/assets/images/placeholder.svg)
   *Figure 2.4 — Release preferences: Standard vs Targeted release.* **Target:** `tenant_09_orgsettings_release_pref.png`

---

## Emergency Access Accounts

Create at least one break-glass (emergency) account that is excluded from all Conditional Access policies.

### Why It Matters

{: .warning }
Without emergency access accounts, a misconfigured Conditional Access policy can lock all administrators out of the tenant.

### Steps

1. **Create a dedicated security group** named something like `Excluded from CA`

   ![Create 'Excluded from CA' security group in Microsoft Entra ID]({{ site.baseurl }}/assets/images/placeholder.svg)
   *Figure 3.1 — Create the 'Excluded from CA' security group in Microsoft Entra ID.* **Target:** `tenant_10_breakglass_group_create.png`

2. **Create 2 emergency access accounts** with:
   - Cloud-only accounts (not synced from on-premises AD)
   - Strong, randomly generated passwords (20+ characters)
   - No MFA requirements (these accounts are excluded from CA)
   - Permanent Global Administrator role assignment

   ![Create cloud-only break-glass user with a long random password]({{ site.baseurl }}/assets/images/placeholder.svg)
   *Figure 3.2 — Create a cloud-only break-glass user with a long random password.* **Target:** `tenant_11_breakglass_user_create.png`

   ![Assign permanent Global Administrator role to the break-glass account]({{ site.baseurl }}/assets/images/placeholder.svg)
   *Figure 3.3 — Assign permanent Global Administrator role to the break-glass account.* **Target:** `tenant_12_breakglass_role_assign.png`

3. **Store credentials securely** — use a physical safe or offline password vault

   ![Example of sealed-envelope offline credential storage]({{ site.baseurl }}/assets/images/placeholder.svg)
   *Figure 3.4 — Example of sealed-envelope offline credential storage for break-glass secrets.* **Target:** `tenant_13_breakglass_secure_storage.png`

4. **Add accounts to the `Excluded from CA` security group**

   ![Add both break-glass accounts as members of the 'Excluded from CA' group]({{ site.baseurl }}/assets/images/placeholder.svg)
   *Figure 3.5 — Add both break-glass accounts as members of the 'Excluded from CA' group.* **Target:** `tenant_14_breakglass_group_members.png`

5. **Monitor sign-in activity** for these accounts via Microsoft Entra sign-in logs

   ![Microsoft Entra sign-in logs filtered to break-glass UPNs]({{ site.baseurl }}/assets/images/placeholder.svg)
   *Figure 3.6 — Microsoft Entra sign-in logs filtered to break-glass UPNs.* **Target:** `tenant_15_breakglass_signin_logs.png`

{: .important }
These accounts should NEVER be used for day-to-day administration. Set up alerts (see Alert Policies) to notify you immediately if they are used.

---

## EOP & Defender for Office 365 Baseline

Apply baseline security policies for **Exchange Online Protection (EOP)** and **Microsoft Defender for Office 365** (formerly known as "Office 365 ATP").

### Steps

1. Navigate to **security.microsoft.com** > **Email & Collaboration** > **Policies & Rules** > **Threat policies**

   ![Microsoft Defender portal — Email & Collaboration > Threat policies]({{ site.baseurl }}/assets/images/placeholder.svg)
   *Figure 4.1 — Microsoft Defender portal: Email & Collaboration > Threat policies.* **Target:** `tenant_16_mdo_threat_policies.png`

2. **Anti-phishing policy** — configure:
   - Enable mailbox intelligence
   - Enable impersonation protection for key users and domains
   - Set action for impersonation detections to **Quarantine message**

   ![Anti-phishing policy — mailbox intelligence + impersonation protection]({{ site.baseurl }}/assets/images/placeholder.svg)
   *Figure 4.2 — Anti-phishing policy: mailbox intelligence + impersonation protection.* **Target:** `tenant_17_mdo_antiphishing.png`

3. **Anti-spam policy** — configure:
   - Review and tighten bulk email threshold (recommended: 5–6)
   - Enable **Safety Tips**

   ![Anti-spam policy — bulk threshold and Safety Tips]({{ site.baseurl }}/assets/images/placeholder.svg)
   *Figure 4.3 — Anti-spam policy: bulk threshold and Safety Tips.* **Target:** `tenant_18_mdo_antispam.png`

4. **Anti-malware policy** — configure:
   - Enable common attachment filter
   - Enable zero-hour auto purge (ZAP)

   ![Anti-malware policy — common attachment filter and ZAP enabled]({{ site.baseurl }}/assets/images/placeholder.svg)
   *Figure 4.4 — Anti-malware policy: common attachment filter and ZAP enabled.* **Target:** `tenant_19_mdo_antimalware.png`

5. **Safe Attachments** (requires Defender for Office 365):
   - Enable for all users
   - Set action to **Dynamic Delivery** (reduces delay)

   ![Safe Attachments policy — Dynamic Delivery action, all users targeted]({{ site.baseurl }}/assets/images/placeholder.svg)
   *Figure 4.5 — Safe Attachments policy: Dynamic Delivery action, all users targeted.* **Target:** `tenant_20_mdo_safe_attachments.png`

6. **Safe Links** (requires Defender for Office 365):
   - Enable for Office 365 Apps
   - Enable **Do not rewrite URLs** option for trusted domains if needed

   ![Safe Links policy — enabled for Office 365 Apps, trusted-domain exclusions]({{ site.baseurl }}/assets/images/placeholder.svg)
   *Figure 4.6 — Safe Links policy: enabled for Office 365 Apps, trusted-domain exclusions.* **Target:** `tenant_21_mdo_safe_links.png`

7. **Configure SPF, DKIM, and DMARC** at your DNS registrar:

   | Record | Purpose |
   |--------|---------|
   | SPF TXT | Authorizes which servers can send email for your domain |
   | DKIM CNAME | Cryptographically signs outbound email |
   | DMARC TXT | Instructs receivers what to do with failed SPF/DKIM |

   ![Enable DKIM signing in the Defender portal — Email authentication settings]({{ site.baseurl }}/assets/images/placeholder.svg)
   *Figure 4.7 — Enable DKIM signing from the Defender portal > Email authentication settings.* **Target:** `tenant_22_mdo_dkim_portal.png`

   ![Example SPF / DKIM CNAME / DMARC TXT record values at the DNS registrar]({{ site.baseurl }}/assets/images/placeholder.svg)
   *Figure 4.8 — Example SPF / DKIM CNAME / DMARC TXT record values at the DNS registrar.* **Target:** `tenant_23_mdo_dns_records.png`

{: .highlight }
Run the **Configuration Analyzer** (security.microsoft.com > Email & Collaboration > Configuration analyzer) to compare your settings against Microsoft's Standard and Strict recommendations.

![Configuration Analyzer — your settings vs Standard / Strict baselines]({{ site.baseurl }}/assets/images/placeholder.svg)
*Figure 4.9 — Configuration Analyzer: your settings compared to Standard / Strict baselines.* **Target:** `tenant_24_mdo_config_analyzer.png`

---

## Report Message Add-in

Enable end users to report suspicious emails directly to Microsoft from Outlook.

### Steps

1. Go to **Microsoft 365 Admin Center** > **Settings** > **Integrated apps**

   ![Integrated apps — search for 'Report Message']({{ site.baseurl }}/assets/images/placeholder.svg)
   *Figure 5.1 — Integrated apps: search for 'Report Message'.* **Target:** `tenant_25_report_message_integrated_apps.png`

2. Search for and deploy the **Report Message** add-in to all users

   ![Deploy Report Message add-in — target: Everyone]({{ site.baseurl }}/assets/images/placeholder.svg)
   *Figure 5.2 — Deploy Report Message add-in: target Everyone.* **Target:** `tenant_26_report_message_deploy.png`

3. Alternatively, deploy via **Exchange Admin Center** > **Organization** > **Add-ins**

Users will then see a **Report Message** button in Outlook (desktop and web) allowing them to flag emails as **Junk**, **Phishing**, or **Not Junk**.

![End-user experience — Report Message button in the Outlook ribbon]({{ site.baseurl }}/assets/images/placeholder.svg)
*Figure 5.3 — End-user experience: Report Message button in the Outlook ribbon.* **Target:** `tenant_27_report_message_outlook_ribbon.png`

---

## Alert Policies

Configure default alert policies in the Microsoft 365 Security & Compliance center.

### Steps

1. Navigate to **compliance.microsoft.com** > **Policies** > **Alert policy**

   ![Microsoft Purview — Policies > Alert policy landing page]({{ site.baseurl }}/assets/images/placeholder.svg)
   *Figure 6.1 — Microsoft Purview: Policies > Alert policy landing page.* **Target:** `tenant_28_alerts_policy_landing.png`

2. Review the **default alert policies** and ensure notifications go to the right email addresses

   ![Built-in alert policies — verify severity and recipient list]({{ site.baseurl }}/assets/images/placeholder.svg)
   *Figure 6.2 — Built-in alert policies: verify severity and recipient list for each.* **Target:** `tenant_29_alerts_default_list.png`

3. Recommended alerts to verify/enable:

   | Alert | Severity | Description |
   |-------|----------|-------------|
   | Elevation of Exchange admin privilege | High | Detects privilege escalation |
   | eDiscovery search started or exported | Medium | Tracks eDiscovery activity |
   | Unusual external user file activity | Medium | Detects anomalous sharing |
   | Malware campaign detected | High | Email-borne malware alerts |
   | Unusual volume of file deletion | Medium | Ransomware early detection |

4. **Create a custom alert** for Emergency Access account sign-ins:
   - Go to **Alert policy** > **New alert policy**
   - Activity: **User signed in**
   - Filter by the emergency access account UPNs
   - Set severity to **High**
   - Notify Global Admins immediately

   ![Custom alert — sign-in by break-glass account, severity High]({{ site.baseurl }}/assets/images/placeholder.svg)
   *Figure 6.3 — Custom alert: sign-in by break-glass account, severity High.* **Target:** `tenant_30_alerts_custom_breakglass.png`

---

{: .note }
🖼️ **Replacing a placeholder with a real screenshot.** Save the PNG into `/assets/images/` with the exact target filename shown under each figure, then in this page open `docs/tenant-configuration.md` and change `placeholder.svg` to the matching `tenant_NN_name.png` on that one line. Alt text and caption can stay as-is. Contributions welcome — see [SECURITY.md](https://github.com/DekBaCom/Microsoft365SetupGuide/blob/main/SECURITY.md).
