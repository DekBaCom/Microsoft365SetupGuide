---
title: Tenant Configuration
layout: default
nav_order: 2
has_children: true
permalink: /docs/tenant-configuration
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
| [EOP & ATP Baseline](#eop--atp-baseline) | Apply email security baseline policies |
| [Report Message Add-in](#report-message-add-in) | Enable users to report spam/phishing |
| [Alert Policies](#alert-policies) | Configure security & compliance alerts |

---

## Vanity Domains

Associate your organization's custom domain(s) with Microsoft 365.

### Steps

1. Go to **Microsoft 365 Admin Center** > **Settings** > **Domains**
2. Click **Add domain** and enter your custom domain name
3. Follow the wizard to verify domain ownership via DNS TXT record
4. Update MX, CNAME, and TXT records at your DNS registrar as instructed
5. Set the custom domain as the **default domain** if desired

{: .note }
Allow up to 48 hours for DNS propagation after updating records.

---

## Organization Settings

Customize your tenant's general organization settings.

### Steps

1. Navigate to **Microsoft 365 Admin Center** > **Settings** > **Org settings**
2. Under the **Organization profile** tab, update:
   - Organization name
   - Technical contact email
   - Support contact details (phone, website, URL)
3. Under the **Security & privacy** tab, configure the **Password expiration policy**:
   - Recommended: Set passwords to **never expire** if using MFA
4. Review and update **Release preferences** (targeted/standard release)

---

## Emergency Access Accounts

Create at least one break-glass (emergency) account that is excluded from all Conditional Access policies.

### Why It Matters

{: .warning }
Without emergency access accounts, a misconfigured Conditional Access policy can lock all administrators out of the tenant.

### Steps

1. **Create a dedicated security group** named something like `Excluded from CA`
2. **Create 2 emergency access accounts** with:
   - Cloud-only accounts (not synced from on-premises AD)
   - Strong, randomly generated passwords (20+ characters)
   - No MFA requirements (these accounts are excluded from CA)
   - Permanent Global Administrator role assignment
3. **Store credentials securely** — use a physical safe or offline password vault
4. **Add accounts to the `Excluded from CA` security group**
5. **Monitor sign-in activity** for these accounts via Azure AD sign-in logs

{: .important }
These accounts should NEVER be used for day-to-day administration. Set up alerts (see Alert Policies) to notify you immediately if they are used.

---

## EOP & ATP Baseline

Apply baseline security policies for Exchange Online Protection (EOP) and Microsoft Defender for Office 365 (formerly Office 365 ATP).

### Steps

1. Navigate to **security.microsoft.com** > **Email & Collaboration** > **Policies & Rules** > **Threat policies**

2. **Anti-phishing policy** — configure:
   - Enable mailbox intelligence
   - Enable impersonation protection for key users and domains
   - Set action for impersonation detections to **Quarantine message**

3. **Anti-spam policy** — configure:
   - Review and tighten bulk email threshold (recommended: 5–6)
   - Enable **Safety Tips**

4. **Anti-malware policy** — configure:
   - Enable common attachment filter
   - Enable zero-hour auto purge (ZAP)

5. **Safe Attachments** (requires Defender for Office 365):
   - Enable for all users
   - Set action to **Dynamic Delivery** (reduces delay)

6. **Safe Links** (requires Defender for Office 365):
   - Enable for Office 365 Apps
   - Enable **Do not rewrite URLs** option for trusted domains if needed

7. **Configure SPF, DKIM, and DMARC** at your DNS registrar:

   | Record | Purpose |
   |--------|---------|
   | SPF TXT | Authorizes which servers can send email for your domain |
   | DKIM CNAME | Cryptographically signs outbound email |
   | DMARC TXT | Instructs receivers what to do with failed SPF/DKIM |

{: .highlight }
Run the **Configuration Analyzer** (security.microsoft.com > Email & Collaboration > Configuration analyzer) to compare your settings against Microsoft's Standard and Strict recommendations.

---

## Report Message Add-in

Enable end users to report suspicious emails directly to Microsoft from Outlook.

### Steps

1. Go to **Microsoft 365 Admin Center** > **Settings** > **Integrated apps**
2. Search for and deploy the **Report Message** add-in to all users
3. Alternatively, deploy via **Exchange Admin Center** > **Organization** > **Add-ins**

Users will then see a **Report Message** button in Outlook (desktop and web) allowing them to flag emails as **Junk**, **Phishing**, or **Not Junk**.

---

## Alert Policies

Configure default alert policies in the Microsoft 365 Security & Compliance center.

### Steps

1. Navigate to **compliance.microsoft.com** > **Policies** > **Alert policy**
2. Review the **default alert policies** and ensure notifications go to the right email addresses
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
