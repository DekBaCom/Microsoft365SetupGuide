# 🛡️ Microsoft 365 Setup Guide

<div align="center">

[![GitHub Pages](https://img.shields.io/badge/GitHub%20Pages-Live-brightgreen?logo=github)](https://DekBaCom.github.io/Microsoft365SetupGuide)
[![Jekyll](https://img.shields.io/badge/Jekyll-4.3-red?logo=jekyll)](https://jekyllrb.com/)
[![Theme](https://img.shields.io/badge/Theme-Just%20the%20Docs-blue)](https://just-the-docs.com/)
[![License](https://img.shields.io/badge/License-MIT-yellow)](LICENSE)
[![PowerShell](https://img.shields.io/badge/PowerShell-Scripts%2061+-blue?logo=powershell)](scripts/)
[![PDPA](https://img.shields.io/badge/PDPA--2562-Ready-success)](https://DekBaCom.github.io/Microsoft365SetupGuide/docs/pdpa)

**คู่มือการติดตั้งและกำหนดค่า Microsoft 365 แบบครบวงจร**
สำหรับ IT Admin และ Microsoft 365 Solution Architect

🌐 **[เข้าชมเว็บไซต์](https://DekBaCom.github.io/Microsoft365SetupGuide)** &nbsp;|&nbsp; 📥 **[ดาวน์โหลด Scripts](https://DekBaCom.github.io/Microsoft365SetupGuide/docs/downloads)** &nbsp;|&nbsp; 📋 **[Prerequisites](https://DekBaCom.github.io/Microsoft365SetupGuide/docs/prerequisites)** &nbsp;|&nbsp; 🧭 **[Use Cases](https://DekBaCom.github.io/Microsoft365SetupGuide/docs/use-cases)**

</div>

---

## ✨ ความสามารถของโปรเจกต์

| ความสามารถ | รายละเอียด |
|------------|-----------|
| 📖 **เอกสารครบถ้วน** | ขั้นตอนการตั้งค่าทุกส่วนของ Microsoft 365 พร้อมภาพประกอบ 11 หมวดหลัก |
| 🖼️ **ภาพ Screenshot** | รูปภาพจริงจากระบบกว่า 59 รูป ประกอบทุก Step |
| ⚡ **PowerShell Scripts** | Script พร้อมใช้งาน **61+ ไฟล์** ครอบคลุมทุก Workload + Tenant Migration |
| 🧭 **Use Case Mapping** | จับคู่ License Tier (Business / E3 / E5 / F / A) กับ Business Profile |
| 🛡️ **PDPA (Thailand)** | แนวทางตั้งค่า M365 ตามพระราชบัญญัติคุ้มครองข้อมูลส่วนบุคคล พ.ศ. 2562 |
| 🔐 **PIM — Zero Permanent Admin** | Just-in-Time admin role activation ด้วย Entra ID P2 |
| 🔄 **Tenant-to-Tenant Migration** | Playbook + Script สำหรับการย้าย Tenant (M&A, Rebrand) |
| 📊 **Monthly Report** | สร้างรายงาน HTML อัตโนมัติด้วย Script เดียว |
| 🔍 **ค้นหาได้** | Built-in search ค้นหาเนื้อหาได้ทุก Section |
| 📱 **Responsive** | รองรับทุกอุปกรณ์ Desktop / Tablet / Mobile + พิมพ์ (Print-friendly) |

---

## 📚 เนื้อหาในคู่มือ

### 📋 [Prerequisites](https://DekBaCom.github.io/Microsoft365SetupGuide/docs/prerequisites)
> สิ่งที่ต้องเตรียมก่อนเริ่มตั้งค่า
- Administrative access (Global Admin, Break-glass)
- Licensing Matrix (Business Premium / E3 / E5)
- PowerShell Modules (Microsoft Graph SDK, ExchangeOnlineManagement, PnP.PowerShell)
- Microsoft Graph Scopes cheat-sheet
- Tenant Readiness verification snippet

### 🧭 [Use Cases & License Mapping](https://DekBaCom.github.io/Microsoft365SetupGuide/docs/use-cases)
> เลือก License ให้เหมาะกับขนาดและ Use Case ธุรกิจ
- Business Profiles: SMB / Mid-market / Enterprise / Frontline / Education / Gov
- Use-case Groups: Identity, Device, Email, Data Protection, Compliance, Monitoring
- Deployment path แนะนำตาม License ที่เลือก

### 1️⃣ [Tenant Configuration](https://DekBaCom.github.io/Microsoft365SetupGuide/docs/tenant-configuration)
> การตั้งค่าพื้นฐานของ Microsoft 365 Tenant
- 🌐 ผูก Custom Domain (Vanity Domain)
- 🏢 Organization Settings และ Password Policy
- 🚨 Emergency Access Accounts (Break-glass)
- 🛡️ EOP & Defender for Office 365 Baseline (SPF, DKIM, DMARC)
- 📩 Report Message Add-in
- 🔔 Alert Policies

### 2️⃣ [Microsoft Entra ID](https://DekBaCom.github.io/Microsoft365SetupGuide/docs/azure-ad-configuration)
> ระบบ Identity และ Access Management *(เดิมชื่อ Azure Active Directory)*
- 🔐 Combined MFA + SSPR Registration
- 🔑 Self-Service Password Reset (SSPR)
- 👤 User Settings & External Collaboration
- ✋ Admin Consent Requests
- 📱 Device Settings & Enterprise State Roaming
- 🚧 Conditional Access Baseline Policies:
  - BLOCK: Legacy Authentication
  - GRANT: Require MFA
  - BLOCK: Unsupported Device Platforms

### 3️⃣ [Privileged Identity Management (PIM)](https://DekBaCom.github.io/Microsoft365SetupGuide/docs/privileged-identity-management) 🆕
> Just-in-Time admin access — Zero permanent Global Admin *(ต้องการ Entra ID P2)*
- Convert Permanent → Eligible assignments
- Role settings — MFA + Justification + Approval
- Access Reviews แบบ Quarterly
- Alerts สำหรับ critical PIM events
- Bulk-onboarding ด้วย Microsoft Graph PowerShell

### 4️⃣ [Microsoft Intune](https://DekBaCom.github.io/Microsoft365SetupGuide/docs/microsoft-endpoint-manager)
> การจัดการและปกป้องอุปกรณ์ *(เดิมชื่อ Microsoft Endpoint Manager)*
- ✈️ Windows Autopilot Enrollment
- 📋 Device Compliance Policies (Windows, iOS, Android)
- 📲 App Protection Policies (MAM) สำหรับ BYOD
- 🖥️ Windows 10/11 Microsoft Entra Join
- 🏢 Windows 10 Microsoft Entra Hybrid Join

### 5️⃣ [Collaboration Governance](https://DekBaCom.github.io/Microsoft365SetupGuide/docs/collaboration-governance)
> ควบคุมการทำงานร่วมกันและปกป้องข้อมูล
- 🔒 Data Loss Prevention (DLP)
- 📦 Retention Policies
- 🏷️ Sensitivity Labels (Data Classification)
- 🗂️ SharePoint & OneDrive Sharing Settings
- 👥 Microsoft Teams & Groups Governance

### 6️⃣ [PDPA (Thailand) Compliance](https://DekBaCom.github.io/Microsoft365SetupGuide/docs/pdpa) 🆕
> ตั้งค่า M365 รองรับ พ.ร.บ. คุ้มครองข้อมูลส่วนบุคคล พ.ศ. 2562
- Compliance Manager — Thailand PDPA assessment template
- Sensitive Info Types — Thai National ID, Thai Passport
- DLP + Sensitivity Label สำหรับ Personal Data
- Retention Policy (Data Minimization)
- Data Subject Rights (DSR) Workflow
- 72-hour Breach Notification Runbook
- Unified Audit Log + Records of Processing (ROPA)

### 7️⃣ [Tenant-to-Tenant Migration](https://DekBaCom.github.io/Microsoft365SetupGuide/docs/tenant-migration) 🆕
> ย้าย Tenant แบบ End-to-End (M&A, Rebrand, Spin-off)
- Phase 1–9 playbook (Discovery → Cutover → Decommission)
- Cross-Tenant Mailbox Migration (CTMM) — Native Microsoft
- OneDrive / SharePoint / Teams migration strategy
- Identity, Conditional Access, Intune device re-enrollment
- Cutover Weekend checklist + Post-migration verification

### 8️⃣ [Storage Quotas & Cost Solutions](https://DekBaCom.github.io/Microsoft365SetupGuide/docs/storage-quotas) 🆕
> เมื่อ Storage เต็ม — Solution + ราคาเปรียบเทียบ
- อีเมลเต็ม → Enable Archive (ฟรี), Auto-Expanding Archive (ฟรี, สูงสุด 1.5 TB)
- Archive เต็ม → เช็ค Auto-Expand + เลือก EOA add-on ($3/user/mo)
- SharePoint Pool เต็ม → M365 Archive ($0.05/GB/mo), Extra File Storage ($0.20/GB/mo), Azure Blob
- Decision Tree + ตัวอย่างคำนวณราคาสำหรับ Thai SMB

### 9️⃣ [Admin Monthly Report](https://DekBaCom.github.io/Microsoft365SetupGuide/docs/admin-monthly-report)
> รายงานสุขภาพระบบรายเดือนอัตโนมัติ
- 📊 License Usage & Availability
- 👥 User Status (Active / Inactive / Blocked)
- 🔐 MFA Enrollment Coverage
- 🧑‍💻 Guest User Report
- 🚧 Conditional Access Policy Status
- 📧 Mailbox Usage & Near-Quota Alerts
- 🔑 Admin Role Assignments
- ⚠️ Sign-in Failure Analysis

---

## ⚡ PowerShell Scripts

ดาวน์โหลด Script พร้อมใช้งานกว่า **61 ไฟล์** จัดหมวดหมู่ตาม Workload:

```
scripts/
├── 📁 setup-intune/          # 18 scripts — Intune import/export
├── 📁 azure-ad/              # 11 scripts — Conditional Access, MFA, Groups
├── 📁 compliance/            #  5 scripts — Sensitivity Labels, Retention
├── 📁 exchange-online/       # 11 scripts — DKIM, EOP, Forwarding, OME
├── 📁 incident-response/     # 10 scripts — Audit logs, Compromise remediation
├── 📁 windows-10/            #  4 scripts — Security Profiles, OneDrive
├── 📁 migration/             #  2 scripts — Tenant inventory + Target user creation  🆕
└── 📁 monthly-report/        #  1 script  — Full HTML Monthly Report
```

> 👉 [ดู Downloads Page พร้อม Link ทุก Script](https://DekBaCom.github.io/Microsoft365SetupGuide/docs/downloads)

### Required PowerShell Modules

```powershell
# Required — baseline automation
Install-Module Microsoft.Graph             -Scope CurrentUser -MinimumVersion 2.0.0
Install-Module ExchangeOnlineManagement    -Scope CurrentUser -MinimumVersion 3.0.0
Install-Module MicrosoftTeams              -Scope CurrentUser -MinimumVersion 5.0.0
Install-Module PnP.PowerShell              -Scope CurrentUser -MinimumVersion 2.0.0
```

> ⚠️ **หมายเหตุสำคัญ:** `AzureAD`, `AzureADPreview`, และ `MSOnline` modules จะหมดอายุ (retire) **ปี 2026** — Script ใหม่ทั้งหมดใช้ **Microsoft Graph PowerShell SDK** เป็นหลัก

---

## 📊 Admin Monthly Report

รัน Script เดียวได้รายงาน HTML ครบทุกด้านในไฟล์เดียว:

```powershell
# 1. ติดตั้ง Module ที่ต้องการ (รันครั้งเดียว)
Install-Module Microsoft.Graph             -Scope CurrentUser -MinimumVersion 2.0.0
Install-Module ExchangeOnlineManagement    -Scope CurrentUser -MinimumVersion 3.0.0

# 2. เชื่อมต่อ Microsoft Graph พร้อม Scope ที่ Script ต้องใช้
Connect-MgGraph -Scopes `
    "Reports.Read.All", `
    "User.Read.All", `
    "Directory.Read.All", `
    "AuditLog.Read.All", `
    "Organization.Read.All", `
    "RoleManagement.Read.Directory", `
    "Policy.Read.All"

# 3. เชื่อมต่อ Exchange Online (สำหรับส่วน Mailbox)
Connect-ExchangeOnline

# 4. รันรายงาน
.\scripts\monthly-report\Get-M365MonthlyReport.ps1

# 5. กำหนด Output Path (ตัวเลือก)
.\scripts\monthly-report\Get-M365MonthlyReport.ps1 -OutputPath "C:\Reports\April-2025.html"
```

---

## 🔄 Tenant-to-Tenant Migration (Quick Start)

ตัวอย่างการใช้ Script ย้าย Tenant:

```powershell
# SOURCE tenant — export inventory
.\scripts\migration\Export-TenantInventory.ps1 -OutputPath C:\T2T\source

# TARGET tenant — bulk create disabled users
.\scripts\migration\New-TargetTenantUsers.ps1 `
    -UsersCsv C:\T2T\source\users.csv `
    -TargetDomain targetco.onmicrosoft.com
```

> 📖 ดูขั้นตอนทั้งหมด 9 Phase ที่ [Tenant-to-Tenant Migration](https://DekBaCom.github.io/Microsoft365SetupGuide/docs/tenant-migration)

---

## 🚀 วิธีใช้งานเว็บไซต์

### การนำทาง

```
หน้าหลัก (Home)
├── 📋 Prerequisites
├── 🧭 Use Cases & License Mapping
├── 1️⃣ Tenant Configuration
├── 2️⃣ Microsoft Entra ID
├── 3️⃣ Privileged Identity Management (PIM)
├── 4️⃣ Microsoft Intune
├── 5️⃣ Collaboration Governance
├── 6️⃣ PDPA (Thailand) Compliance
├── 7️⃣ Tenant-to-Tenant Migration
├── 📥 Downloads — PowerShell Scripts
└── 📊 Admin Monthly Report
```

- 🔍 ใช้ **Search Bar** ด้านบนค้นหาเนื้อหาที่ต้องการ
- 📌 ใช้ **Table of Contents** ด้านขวาเพื่อ jump ไปยัง Section
- 📥 คลิก **Download** ในแต่ละ Section เพื่อดาวน์โหลด Script
- 📋 คลิก **Copy** ที่ Code Block เพื่อ copy PowerShell command

---

## 🛠️ Local Development

### ความต้องการของระบบ

- Ruby 3.0+
- Bundler

### ติดตั้งและรัน

```bash
# Clone repository
git clone https://github.com/DekBaCom/Microsoft365SetupGuide.git
cd Microsoft365SetupGuide

# ติดตั้ง dependencies
bundle install

# รัน Local Server
bundle exec jekyll serve

# เปิดเบราว์เซอร์
# http://localhost:4000/Microsoft365SetupGuide
```

### โครงสร้างโปรเจกต์

```
Microsoft365SetupGuide/
├── 📄 _config.yml              # Jekyll configuration (SEO, search, copy-code)
├── 📄 Gemfile                  # Ruby dependencies
├── 📄 index.md                 # Home page
├── 📄 README.md                # This file
├── 📄 LICENSE                  # MIT license
├── 📄 CHANGELOG.md             # Project changelog
├── 📁 docs/                    # Documentation pages
│   ├── prerequisites.md                      # 🆕 Licensing + Graph scopes
│   ├── use-cases-and-licensing.md            # 🆕 Business profile → License map
│   ├── tenant-configuration.md
│   ├── azure-ad-configuration.md
│   ├── privileged-identity-management.md     # 🆕 PIM step-by-step
│   ├── microsoft-endpoint-manager.md
│   ├── collaboration-governance.md
│   ├── pdpa.md                               # 🆕 Thailand PDPA setup
│   ├── tenant-migration.md                   # 🆕 T2T migration playbook
│   ├── downloads.md
│   └── admin-monthly-report.md
├── 📁 _sass/custom/            # 🆕 Responsive + print CSS overrides
│   └── custom.scss
├── 📁 assets/images/           # Screenshots (59 images)
├── 📁 scripts/                 # PowerShell scripts (61 files)
│   ├── setup-intune/
│   ├── azure-ad/
│   ├── compliance/
│   ├── exchange-online/
│   ├── incident-response/
│   ├── windows-10/
│   ├── migration/              # 🆕 T2T migration scripts
│   └── monthly-report/
└── 📁 .github/workflows/       # GitHub Actions auto-deploy
    └── pages.yml
```

---

## 🌐 Deployment

โปรเจกต์นี้ deploy อัตโนมัติไปยัง **GitHub Pages** ด้วย **GitHub Actions** ทุกครั้งที่มีการ push ไปยัง branch `main`

```yaml
# .github/workflows/pages.yml
on:
  push:
    branches: ["main"]   # Auto-deploy ทุกครั้งที่ push
```

---

## 📝 Changelog

ติดตามการเปลี่ยนแปลงทั้งหมดได้ที่ [CHANGELOG.md](CHANGELOG.md)

- **Unreleased** — เพิ่ม Prerequisites, Use Cases, PIM, PDPA, Tenant Migration + Responsive polish + Copy-to-clipboard button + MIT License + Security Policy
- **2026-11-18** — Rebranding (Azure AD → Microsoft Entra ID), Prerequisites page, SEO

---

## 👨‍💻 Contributor

<table>
  <tr>
    <td align="center">
      <a href="https://github.com/DekBaCom">
        <img src="https://avatars.githubusercontent.com/DekBaCom" width="80" style="border-radius:50%"/><br/>
        <b>Mr. Abdulloh Etaeluengoh</b>
      </a><br/>
      <sub>Microsoft 365 Solution Architect</sub><br/>
      <a href="mailto:Abdulloh.eg@gmail.com">📧 Abdulloh.eg@gmail.com</a><br/>
      <a href="https://www.linkedin.com/in/abdulloh-etaeluengoh">💼 LinkedIn</a> &nbsp;|&nbsp;
      <a href="https://github.com/DekBaCom">🐙 GitHub</a>
    </td>
  </tr>
</table>

---

<div align="center">

**Microsoft 365 Setup Guide** — Built with ❤️ using [Jekyll](https://jekyllrb.com/) & [Just the Docs](https://just-the-docs.com/)

⭐ ถ้าโปรเจกต์นี้มีประโยชน์ อย่าลืม Star ให้ด้วยนะครับ!

</div>
