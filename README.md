# 🛡️ Microsoft 365 Setup Guide

<div align="center">

[![GitHub Pages](https://img.shields.io/badge/GitHub%20Pages-Live-brightgreen?logo=github)](https://DekBaCom.github.io/Microsoft365SetupGuide)
[![Jekyll](https://img.shields.io/badge/Jekyll-4.3-red?logo=jekyll)](https://jekyllrb.com/)
[![Theme](https://img.shields.io/badge/Theme-Just%20the%20Docs-blue)](https://just-the-docs.com/)
[![License](https://img.shields.io/badge/License-MIT-yellow)](LICENSE)
[![PowerShell](https://img.shields.io/badge/PowerShell-Scripts%2059+-blue?logo=powershell)](scripts/)

**คู่มือการติดตั้งและกำหนดค่า Microsoft 365 แบบครบวงจร**
สำหรับ IT Admin และ Microsoft 365 Solution Architect

🌐 **[เข้าชมเว็บไซต์](https://DekBaCom.github.io/Microsoft365SetupGuide)** | 📥 **[ดาวน์โหลด Scripts](https://DekBaCom.github.io/Microsoft365SetupGuide/docs/downloads)**

</div>

---

## ✨ ความสามารถของโปรเจกต์

| ความสามารถ | รายละเอียด |
|------------|-----------|
| 📖 **เอกสารครบถ้วน** | ขั้นตอนการตั้งค่าทุกส่วนของ Microsoft 365 พร้อมภาพประกอบ |
| 🖼️ **ภาพ Screenshot** | รูปภาพจริงจากระบบกว่า 59 รูป ประกอบทุก Step |
| ⚡ **PowerShell Scripts** | Script พร้อมใช้งาน 59+ ไฟล์ ครอบคลุมทุก Workload |
| 📊 **Monthly Report** | สร้างรายงาน HTML อัตโนมัติด้วย Script เดียว |
| 🔍 **ค้นหาได้** | Built-in search ค้นหาเนื้อหาได้ทุก Section |
| 📱 **Responsive** | รองรับทุกอุปกรณ์ ทั้ง Desktop และ Mobile |

---

## 📚 เนื้อหาในคู่มือ

### 1️⃣ Tenant Configuration
> การตั้งค่าพื้นฐานของ Microsoft 365 Tenant

- 🌐 ผูก Custom Domain (Vanity Domain)
- 🏢 Organization Settings และ Password Policy
- 🚨 Emergency Access Accounts (Break-glass)
- 🛡️ EOP & Defender for Office 365 Baseline (SPF, DKIM, DMARC)
- 📩 Report Message Add-in
- 🔔 Alert Policies

### 2️⃣ Azure AD Configuration
> ระบบ Identity และ Access Management

- 🔐 Combined MFA + SSPR Registration
- 🔑 Self-Service Password Reset (SSPR)
- 👤 User Settings & External Collaboration
- ✋ Admin Consent Requests
- 📱 Device Settings & Enterprise State Roaming
- 🚧 Conditional Access Baseline Policies:
  - BLOCK: Legacy Authentication
  - GRANT: Require MFA
  - BLOCK: Unsupported Device Platforms

### 3️⃣ Microsoft Endpoint Manager (Intune)
> การจัดการและปกป้องอุปกรณ์

- ✈️ Windows Autopilot Enrollment
- 📋 Device Compliance Policies (Windows, iOS, Android)
- 📲 App Protection Policies (MAM) สำหรับ BYOD
- 🖥️ Windows 10/11 Azure AD Join
- 🏢 Windows 10 Hybrid Azure AD Join

### 4️⃣ Collaboration Governance
> ควบคุมการทำงานร่วมกันและปกป้องข้อมูล

- 🔒 Data Loss Prevention (DLP)
- 📦 Retention Policies
- 🏷️ Sensitivity Labels (Data Classification)
- 🗂️ SharePoint & OneDrive Sharing Settings
- 👥 Microsoft Teams & Groups Governance

### 5️⃣ Admin Monthly Report
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

ดาวน์โหลด Script พร้อมใช้งานกว่า **59 ไฟล์** จัดหมวดหมู่ตาม Workload:

```
scripts/
├── 📁 setup-intune/          # 18 scripts — Intune import/export
├── 📁 azure-ad/              # 11 scripts — Conditional Access, MFA, Groups
├── 📁 compliance/            #  5 scripts — Sensitivity Labels, Retention
├── 📁 exchange-online/       # 11 scripts — DKIM, EOP, Forwarding, OME
├── 📁 incident-response/     # 10 scripts — Audit logs, Compromise remediation
├── 📁 windows-10/            #  4 scripts — Security Profiles, OneDrive
└── 📁 monthly-report/        #  1 script  — Full HTML Monthly Report
```

> 👉 [ดู Downloads Page พร้อม Link ทุก Script](https://DekBaCom.github.io/Microsoft365SetupGuide/docs/downloads)

---

## 📊 Admin Monthly Report

รัน Script เดียวได้รายงาน HTML ครบทุกด้านในไฟล์เดียว:

```powershell
# ติดตั้ง Module ที่ต้องการ
Install-Module Microsoft.Graph -Scope CurrentUser
Install-Module ExchangeOnlineManagement -Scope CurrentUser

# รันรายงาน
.\scripts\monthly-report\Get-M365MonthlyReport.ps1

# กำหนด Output Path
.\scripts\monthly-report\Get-M365MonthlyReport.ps1 -OutputPath "C:\Reports\April-2025.html"
```

---

## 🚀 วิธีใช้งานเว็บไซต์

### การนำทาง

```
หน้าหลัก (Home)
├── Tenant Configuration
├── Azure AD Configuration
├── Microsoft Endpoint Manager
├── Collaboration Governance
├── Admin Monthly Report
└── Downloads — PowerShell Scripts
```

- 🔍 ใช้ **Search Bar** ด้านบนค้นหาเนื้อหาที่ต้องการ
- 📌 ใช้ **Table of Contents** ด้านขวาเพื่อ jump ไปยัง Section
- 📥 คลิก **Download** ในแต่ละ Section เพื่อดาวน์โหลด Script

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
├── 📄 _config.yml              # Jekyll configuration
├── 📄 Gemfile                  # Ruby dependencies
├── 📄 index.md                 # Home page
├── 📁 docs/                    # Documentation pages
│   ├── tenant-configuration.md
│   ├── azure-ad-configuration.md
│   ├── microsoft-endpoint-manager.md
│   ├── collaboration-governance.md
│   ├── admin-monthly-report.md
│   └── downloads.md
├── 📁 assets/images/           # Screenshots (59 images)
├── 📁 scripts/                 # PowerShell scripts (59 files)
│   ├── setup-intune/
│   ├── azure-ad/
│   ├── compliance/
│   ├── exchange-online/
│   ├── incident-response/
│   ├── windows-10/
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
