---
title: Home
layout: home
nav_order: 1
---

# Microsoft 365 Setup Guide

A comprehensive, step-by-step guide for deploying and configuring Microsoft 365 for your organization. This guide covers all critical areas from initial tenant setup to advanced security policies.

---

## What's in this guide?

{: .highlight }
This guide is organized into four main areas. Follow them in order for a complete deployment.

### 1. [Tenant Configuration](docs/tenant-configuration/)
Set up your foundational Microsoft 365 tenant settings:
- Custom domain (vanity domain) association
- Organization and password policy settings
- Emergency Access accounts
- EOP & ATP baseline security
- Alert policies

### 2. [Azure AD Configuration](docs/azure-ad-configuration/)
Secure your identity and access management:
- Combined MFA + SSPR registration
- Self-service password reset
- User and guest settings
- Admin consent controls
- Conditional Access baseline policies

### 3. [Microsoft Endpoint Manager](docs/microsoft-endpoint-manager/)
Manage and protect devices across your organization:
- Device enrollment (Autopilot, MDM)
- Compliance policies
- App Protection (MAM) for mobile
- Windows 10 Azure AD Join / Hybrid Join

### 4. [Collaboration Governance](docs/collaboration-governance/)
Control how users collaborate and protect sensitive data:
- Data Loss Prevention (DLP)
- Retention policies
- Sensitivity labels
- SharePoint & OneDrive sharing settings
- Teams & Groups governance

### [Downloads — PowerShell Scripts](docs/downloads/)
59 ready-to-use automation scripts covering all areas of this guide:
- Setup Intune, Azure AD Conditional Access, Compliance, Exchange Online
- Windows 10 security profiles, and Incident Response tools

---

## Prerequisites

Before you begin, ensure you have:
- A Microsoft 365 Business Premium or Enterprise license
- Global Administrator access to your tenant
- Your custom domain(s) ready for verification
- Access to your DNS registrar

---

{: .note }
This guide was prepared based on Microsoft 365 best practices. Settings should be reviewed and adapted to your organization's specific risk tolerance and compliance requirements.
