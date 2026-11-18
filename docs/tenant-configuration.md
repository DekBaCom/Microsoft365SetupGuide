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

---

## Vanity Domains

Associate your organization's custom domain(s) with Microsoft 365.

### Steps

1. Go to **Microsoft 365 Admin Center** > **Settings** > **Domains**

   <!-- Screenshot placeholder — /assets/images/tenant_01_domains_landing.png
        Caption: "Microsoft 365 Admin Center — Settings > Domains landing page" -->

2. Click **Add domain** and enter your custom domain name

   <!-- Screenshot placeholder — /assets/images/tenant_02_domains_add.png
        Caption: "Add domain wizard — enter the custom domain name" -->

3. Follow the wizard to verify domain ownership via DNS TXT record

   <!-- Screenshot placeholder — /assets/images/tenant_03_domains_verify.png
        Caption: "Verify domain ownership — DNS TXT record values" -->

4. Update MX, CNAME, and TXT records at your DNS registrar as instructed

   <!-- Screenshot placeholder — /assets/images/tenant_04_domains_records.png
        Caption: "DNS records to add at your registrar (MX, CNAME, TXT)" -->

5. Set the custom domain as the **default domain** if desired

   <!-- Screenshot placeholder — /assets/images/tenant_05_domains_default.png
        Caption: "Set the newly verified domain as the tenant default" -->

{: .note }
Allow up to 48 hours for DNS propagation after updating records.

---

## Organization Settings

Customize your tenant's general organization settings.

### Steps

1. Navigate to **Microsoft 365 Admin Center** > **Settings** > **Org settings**

   <!-- Screenshot placeholder — /assets/images/tenant_06_orgsettings_landing.png
        Caption: "Org settings landing page with the Organization profile / Security & privacy / Services tabs" -->

2. Under the **Organization profile** tab, update:
   - Organization name
   - Technical contact email
   - Support contact details (phone, website, URL)

   <!-- Screenshot placeholder — /assets/images/tenant_07_orgsettings_profile.png
        Caption: "Organization profile tab — org name, technical contact, support details" -->

3. Under the **Security & privacy** tab, configure the **Password expiration policy**:
   - Recommended: Set passwords to **never expire** if using MFA

   <!-- Screenshot placeholder — /assets/images/tenant_08_orgsettings_password_policy.png
        Caption: "Password expiration policy — set to never expire when MFA is enforced" -->

4. Review and update **Release preferences** (targeted/standard release)

   <!-- Screenshot placeholder — /assets/images/tenant_09_orgsettings_release_pref.png
        Caption: "Release preferences — Standard vs Targeted release" -->

---

## Emergency Access Accounts

Create at least one break-glass (emergency) account that is excluded from all Conditional Access policies.

### Why It Matters

{: .warning }
Without emergency access accounts, a misconfigured Conditional Access policy can lock all administrators out of the tenant.

### Steps

1. **Create a dedicated security group** named something like `Excluded from CA`

   <!-- Screenshot placeholder — /assets/images/tenant_10_breakglass_group_create.png
        Caption: "Create the 'Excluded from CA' security group in Microsoft Entra ID" -->

2. **Create 2 emergency access accounts** with:
   - Cloud-only accounts (not synced from on-premises AD)
   - Strong, randomly generated passwords (20+ characters)
   - No MFA requirements (these accounts are excluded from CA)
   - Permanent Global Administrator role assignment

   <!-- Screenshot placeholder — /assets/images/tenant_11_breakglass_user_create.png
        Caption: "Create a cloud-only break-glass user with a long random password" -->

   <!-- Screenshot placeholder — /assets/images/tenant_12_breakglass_role_assign.png
        Caption: "Assign permanent Global Administrator role to the break-glass account" -->

3. **Store credentials securely** — use a physical safe or offline password vault

   <!-- Screenshot placeholder — /assets/images/tenant_13_breakglass_secure_storage.png
        Caption: "Example of sealed-envelope offline credential storage" -->

4. **Add accounts to the `Excluded from CA` security group**

   <!-- Screenshot placeholder — /assets/images/tenant_14_breakglass_group_members.png
        Caption: "Add both break-glass accounts as members of the 'Excluded from CA' group" -->

5. **Monitor sign-in activity** for these accounts via Microsoft Entra sign-in logs

   <!-- Screenshot placeholder — /assets/images/tenant_15_breakglass_signin_logs.png
        Caption: "Microsoft Entra sign-in logs filtered to break-glass UPNs" -->

{: .important }
These accounts should NEVER be used for day-to-day administration. Set up alerts (see Alert Policies) to notify you immediately if they are used.

---

## EOP & Defender for Office 365 Baseline

Apply baseline security policies for **Exchange Online Protection (EOP)** and **Microsoft Defender for Office 365** (formerly known as "Office 365 ATP").

### Steps

1. Navigate to **security.microsoft.com** > **Email & Collaboration** > **Policies & Rules** > **Threat policies**

   <!-- Screenshot placeholder — /assets/images/tenant_16_mdo_threat_policies.png
        Caption: "Microsoft Defender portal — Email & Collaboration > Threat policies" -->

2. **Anti-phishing policy** — configure:
   - Enable mailbox intelligence
   - Enable impersonation protection for key users and domains
   - Set action for impersonation detections to **Quarantine message**

   <!-- Screenshot placeholder — /assets/images/tenant_17_mdo_antiphishing.png
        Caption: "Anti-phishing policy — mailbox intelligence + impersonation protection" -->

3. **Anti-spam policy** — configure:
   - Review and tighten bulk email threshold (recommended: 5–6)
   - Enable **Safety Tips**

   <!-- Screenshot placeholder — /assets/images/tenant_18_mdo_antispam.png
        Caption: "Anti-spam policy — bulk threshold and Safety Tips" -->

4. **Anti-malware policy** — configure:
   - Enable common attachment filter
   - Enable zero-hour auto purge (ZAP)

   <!-- Screenshot placeholder — /assets/images/tenant_19_mdo_antimalware.png
        Caption: "Anti-malware policy — common attachment filter and ZAP enabled" -->

5. **Safe Attachments** (requires Defender for Office 365):
   - Enable for all users
   - Set action to **Dynamic Delivery** (reduces delay)

   <!-- Screenshot placeholder — /assets/images/tenant_20_mdo_safe_attachments.png
        Caption: "Safe Attachments policy — Dynamic Delivery action, all users targeted" -->

6. **Safe Links** (requires Defender for Office 365):
   - Enable for Office 365 Apps
   - Enable **Do not rewrite URLs** option for trusted domains if needed

   <!-- Screenshot placeholder — /assets/images/tenant_21_mdo_safe_links.png
        Caption: "Safe Links policy — enabled for Office 365 Apps, trusted-domain exclusions" -->

7. **Configure SPF, DKIM, and DMARC** at your DNS registrar:

   | Record | Purpose |
   |--------|---------|
   | SPF TXT | Authorizes which servers can send email for your domain |
   | DKIM CNAME | Cryptographically signs outbound email |
   | DMARC TXT | Instructs receivers what to do with failed SPF/DKIM |

   <!-- Screenshot placeholder — /assets/images/tenant_22_mdo_dkim_portal.png
        Caption: "Enable DKIM signing from the Defender portal > Email authentication settings" -->

   <!-- Screenshot placeholder — /assets/images/tenant_23_mdo_dns_records.png
        Caption: "Example SPF / DKIM CNAME / DMARC TXT record values at the DNS registrar" -->

{: .highlight }
Run the **Configuration Analyzer** (security.microsoft.com > Email & Collaboration > Configuration analyzer) to compare your settings against Microsoft's Standard and Strict recommendations.

<!-- Screenshot placeholder — /assets/images/tenant_24_mdo_config_analyzer.png
     Caption: "Configuration Analyzer — your settings compared to Standard / Strict baselines" -->

---

## Report Message Add-in

Enable end users to report suspicious emails directly to Microsoft from Outlook.

### Steps

1. Go to **Microsoft 365 Admin Center** > **Settings** > **Integrated apps**

   <!-- Screenshot placeholder — /assets/images/tenant_25_report_message_integrated_apps.png
        Caption: "Integrated apps — search for 'Report Message'" -->

2. Search for and deploy the **Report Message** add-in to all users

   <!-- Screenshot placeholder — /assets/images/tenant_26_report_message_deploy.png
        Caption: "Deploy Report Message add-in — target: Everyone" -->

3. Alternatively, deploy via **Exchange Admin Center** > **Organization** > **Add-ins**

Users will then see a **Report Message** button in Outlook (desktop and web) allowing them to flag emails as **Junk**, **Phishing**, or **Not Junk**.

<!-- Screenshot placeholder — /assets/images/tenant_27_report_message_outlook_ribbon.png
     Caption: "End-user experience — Report Message button in the Outlook ribbon" -->

---

## Alert Policies

Configure default alert policies in the Microsoft 365 Security & Compliance center.

### Steps

1. Navigate to **compliance.microsoft.com** > **Policies** > **Alert policy**

   <!-- Screenshot placeholder — /assets/images/tenant_28_alerts_policy_landing.png
        Caption: "Microsoft Purview — Policies > Alert policy landing page" -->

2. Review the **default alert policies** and ensure notifications go to the right email addresses

   <!-- Screenshot placeholder — /assets/images/tenant_29_alerts_default_list.png
        Caption: "Built-in alert policies — verify severity and recipient list for each" -->

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

   <!-- Screenshot placeholder — /assets/images/tenant_30_alerts_custom_breakglass.png
        Caption: "Custom alert — sign-in by break-glass account, severity High" -->

---

{: .note }
**Screenshots coming soon.** The 30 image placeholders use the `tenant_NN_name.png` convention under `/assets/images/`. Drop the actual screenshots into that folder with matching filenames (and remove the surrounding `<!-- ... -->` comment markers) and they will render inline. Contributions welcome — see [SECURITY.md](https://github.com/DekBaCom/Microsoft365SetupGuide/blob/main/SECURITY.md).
