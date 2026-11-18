---
title: Storage Quotas & Cost Solutions
layout: default
nav_order: 9.5
has_children: false
permalink: /docs/storage-quotas
description: Solutions and pricing when Microsoft 365 storage runs out — mailbox full, archive exceeded, SharePoint over quota. Covers Exchange Online Archiving, Auto-expanding Archive, Microsoft 365 Archive, Extra File Storage, and third-party options.
---

# Storage Quotas & Cost Solutions
{: .no_toc }

**เมื่อ Microsoft 365 Storage เต็ม** — ทางเลือกและราคาที่ต้องรู้
Practical solutions when mailboxes, archive, or SharePoint run out of space — including cost comparison and the PowerShell commands to fix it today.
{: .fs-6 .fw-300 }

> **ภาษาไทย:** หน้านี้รวบรวมวิธีแก้ปัญหา 3 สถานการณ์ที่ Admin เจอบ่อย — อีเมลเต็ม, Archive mailbox เต็ม, และ SharePoint/OneDrive เกินโควตา — พร้อมเปรียบเทียบราคาและ Script สำเร็จรูป

{: .warning }
**Pricing shown is USD list price** from Microsoft public pricing pages at time of writing. Enterprise Agreement (EA) / CSP / Volume Licensing prices are usually 10–30% lower. Always verify with your reseller before purchasing.

---

## Table of Contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## 1. Default Storage by License Tier

| Workload | Business Basic / Standard | **Business Premium** | **E3 / A3** | **E5 / A5** | F1 / F3 |
|----------|:---:|:---:|:---:|:---:|:---:|
| **Mailbox (Primary)** | 50 GB | 50 GB | **100 GB** | **100 GB** | 2 GB |
| **Archive Mailbox** | 50 GB | 50 GB | **100 GB** (auto-expands to 1.5 TB) | **100 GB** (auto-expands to 1.5 TB) | ❌ |
| **OneDrive for Business** | 1 TB | 1 TB | **1 TB** (expandable to 5 TB per user; up to unlimited with support ticket at ≥ 5 users on E3) | Same as E3 | 2 GB |
| **SharePoint Pool** | 1 TB + 10 GB × licensed users | Same | Same | Same | Same |
| **SharePoint Site (max per site)** | 25 TB | 25 TB | 25 TB | 25 TB | 25 TB |
| **Teams Shared Channels / Teams Files** | Counts against SharePoint pool | Same | Same | Same | Same |

### SharePoint Pool Formula

```
Total SPO storage = 1 TB base + (10 GB × number of licensed users)
```

ตัวอย่าง: 100 users × E3 licenses → **1 TB + 1 TB = 2 TB** รวมทั้ง Tenant

---

## 2. Scenario A — Mailbox Primary เต็ม (เกิน Quota)

### 2.1 What Happens When a Mailbox Fills Up

Exchange Online applies **3 warning levels** before blocking:

| Quota State | Threshold (E3/E5 = 100 GB) | User Impact |
|-------------|--------------------------|-------------|
| **IssueWarningQuota** | ~98.5 GB | Warning email: "Your mailbox is almost full" |
| **ProhibitSendQuota** | ~99.5 GB | **Cannot send** new email; can still receive |
| **ProhibitSendReceiveQuota** | 100 GB | **Cannot send or receive**; senders get NDR |

### 2.2 Solutions (จากถูกไปแพง)

#### ✅ Option 1 — Enable Archive Mailbox (Free in most SKUs)

Archive mailbox is a **separate 100 GB mailbox** that auto-moves old items from the primary. **No additional cost** for E3/E5/Business Premium.

```powershell
Connect-ExchangeOnline

# Enable archive for a single user
Enable-Mailbox -Identity "user@contoso.com" -Archive

# Enable for all licensed mailboxes (BULK)
Get-EXOMailbox -ResultSize Unlimited -Filter "ArchiveStatus -eq 'None'" |
    Where-Object { $_.PersistedCapabilities -contains "BPOS_S_EnterpriseArchive" } |
    ForEach-Object {
        Enable-Mailbox -Identity $_.UserPrincipalName -Archive
        Write-Host "✔ Archive enabled: $($_.UserPrincipalName)" -ForegroundColor Green
    }
```

After enabling, **assign a retention policy** that auto-moves old items to archive — see [Step 3 below](#23-auto-move-old-items-primary--archive).

#### ✅ Option 2 — Auto-Expanding Archive (Free, up to 1.5 TB)

For users who archive a lot (legal, finance, execs), enable **auto-expanding archive** — Microsoft adds storage in 50 GB increments up to **1.5 TB**, free with E3/E5.

```powershell
# Enable org-wide (tenant setting)
Set-OrganizationConfig -AutoExpandingArchive

# Verify
Get-OrganizationConfig | Select-Object AutoExpandingArchiveEnabled

# Optional: enable per-mailbox (if not using org-wide setting)
Enable-Mailbox -Identity "user@contoso.com" -AutoExpandingArchive
```

{: .note }
Auto-expand can take **up to 30 days** to kick in after the archive crosses 90 GB. Plan ahead for executives.

#### ✅ Option 3 — Clean Up Large Items

Find and remove/archive the biggest items first:

```powershell
# Top 20 largest folders per mailbox
Get-EXOMailboxFolderStatistics -Identity "user@contoso.com" |
    Sort-Object FolderSize -Descending |
    Select-Object -First 20 Name,
        @{n='SizeGB'; e={[math]::Round($_.FolderAndSubfolderSize.ToBytes()/1GB,2)}},
        ItemsInFolder

# Items older than 2 years (candidates to delete or archive)
Search-Mailbox -Identity "user@contoso.com" `
    -SearchQuery 'received<="2024-01-01"' `
    -TargetMailbox "admin@contoso.com" -TargetFolder "Archive-2024" `
    -DeleteContent:$false
```

#### 💰 Option 4 — Upgrade License (only if on Business plan or F-tier)

Jumping from a **50 GB** SKU to a **100 GB** SKU:

| From → To | Approx USD / user / month | Storage gain |
|-----------|---------------------------|--------------|
| Business Basic → Business Standard | +$6.00 | No mailbox change (still 50 GB) |
| Business Standard → Business Premium | +$9.50 | No mailbox change (still 50 GB) |
| Business Premium → E3 | +$13.75 | **+50 GB** mailbox (50 → 100) |
| E3 → E5 | +$21.00 | No storage change; adds security/compliance |

{: .highlight }
**Enabling the free Archive is always cheaper than a license upgrade** when the goal is pure storage. Only upgrade if you also need the extra features.

### 2.3 Auto-move old items (Primary → Archive)

Deploy a **Default MRM Policy** so old items move automatically — no end-user effort required.

```powershell
# Create tag: "2 Years Move to Archive"
New-RetentionPolicyTag "Move to Archive — 2 years" `
    -Type All `
    -RetentionEnabled $true `
    -AgeLimitForRetention 730 `
    -RetentionAction MoveToArchive

# Create policy and add the tag
New-RetentionPolicy "Default MRM Policy (Archive)" `
    -RetentionPolicyTagLinks "Move to Archive — 2 years"

# Assign to all mailboxes
Get-EXOMailbox -ResultSize Unlimited |
    Set-Mailbox -RetentionPolicy "Default MRM Policy (Archive)"
```

---

## 3. Scenario B — Archive Mailbox เต็ม

### 3.1 How Big Can Archive Actually Get?

| Plan | Base Archive | After Auto-Expand |
|------|--------------|-------------------|
| Business Basic / Standard / Premium | 50 GB | 1.5 TB (auto-expand) |
| **E3 / A3 / G3** | **100 GB** | **1.5 TB** (auto-expand) |
| **E5 / A5 / G5** | **100 GB** | **1.5 TB** (auto-expand) |
| F3 / F1 / Kiosk | ❌ No archive | — |

### 3.2 Solutions when Archive Approaches Limit

#### ✅ Step 1 — Confirm Auto-Expand is Actually Enabled

Most "archive full" complaints are because auto-expand was **never enabled** at the org level.

```powershell
# Check org setting
Get-OrganizationConfig | Select-Object AutoExpandingArchiveEnabled

# Check per-mailbox
Get-EXOMailbox -Identity "user@contoso.com" |
    Select-Object UserPrincipalName,
        ArchiveStatus, ArchiveQuota, ArchiveWarningQuota, AutoExpandingArchiveEnabled

# Enable it (Takes effect within 30 days; existing archives trigger at > 90 GB used)
Set-OrganizationConfig -AutoExpandingArchive
```

#### ✅ Step 2 — Run an In-Place Archive Report

```powershell
# Archive sizes across all mailboxes
Get-EXOMailbox -Archive -ResultSize Unlimited |
    Get-EXOMailboxStatistics -Archive |
    Select-Object DisplayName,
        @{n='ArchiveGB'; e={[math]::Round($_.TotalItemSize.Value.ToBytes()/1GB,2)}},
        ItemCount |
    Sort-Object ArchiveGB -Descending |
    Export-Csv ".\archive-usage.csv" -NoTypeInformation
```

#### 💰 Step 3 — Exchange Online Archiving Add-on ($3/user/month)

If a user does NOT have E3/E5 but needs archiving (e.g. Business Basic / F-tier):

- **Product name:** *Exchange Online Archiving* (EOA)
- **Price:** ~**$3.00 / user / month** (USD list)
- **Includes:** 100 GB archive + auto-expand to 1.5 TB
- **Add via:** Microsoft 365 admin center → Billing → Purchase services → Add-ons

#### 💰 Step 4 — If 1.5 TB Really Isn't Enough

Options for the (rare) user who exceeds 1.5 TB archive:

| Solution | Approx Cost | Best For |
|----------|-------------|----------|
| **Third-party cloud archiving** (Mimecast, Barracuda, Proofpoint) | $4–8 / user / month | Compliance-driven (financial services) |
| **In-place eDiscovery export + delete** | Free (your time) | Occasional compliance pulls |
| **Microsoft Compliance Archive** (eDiscovery + legal hold) | Included in E5 | Legal holds without quota impact |

---

## 4. Scenario C — SharePoint / OneDrive เต็ม

### 4.1 How SharePoint Quota Actually Works

SharePoint storage is **pooled at the tenant level**, not per-site:

```
Tenant SPO Pool = 1 TB (base) + 10 GB × (licensed users)
```

- Each site can consume **up to 25 TB** (but limited by the pool)
- OneDrive is separate: each user gets 1 TB (expandable)
- When the pool is full, **all SharePoint sites become read-only**

### 4.2 Check Current Usage

```powershell
# Install PnP module if needed
Install-Module PnP.PowerShell -Scope CurrentUser -MinimumVersion 2.0.0

# Connect as SharePoint Admin
Connect-PnPOnline -Url "https://contoso-admin.sharepoint.com" -Interactive

# Tenant-level pool usage
Get-PnPTenant |
    Select-Object StorageQuota, StorageQuotaAllocated,
        @{n='StorageUsedTB';      e={[math]::Round($_.StorageQuotaAllocated/1TB,2)}},
        @{n='StorageTotalTB';     e={[math]::Round($_.StorageQuota/1TB,2)}},
        @{n='StorageFreeTB';      e={[math]::Round(($_.StorageQuota-$_.StorageQuotaAllocated)/1TB,2)}},
        @{n='UsagePercent';       e={[math]::Round(($_.StorageQuotaAllocated/$_.StorageQuota)*100,1)}}

# Top 20 heaviest sites
Get-PnPTenantSite -IncludeOneDriveSites |
    Sort-Object StorageUsageCurrent -Descending |
    Select-Object -First 20 Url, Template,
        @{n='UsedGB'; e={[math]::Round($_.StorageUsageCurrent/1024,2)}}
```

### 4.3 Solutions (from free → paid)

#### ✅ Option 1 — Clean up versioning and recycle bins (free, often recovers 20–40%)

SharePoint keeps **500 versions by default** of every document. Reducing to 50 can recover hundreds of GB.

```powershell
# Find sites with huge version storage
Get-PnPTenantSite -IncludeOneDriveSites |
    Where-Object StorageUsageCurrent -gt 10000 |
    ForEach-Object {
        Connect-PnPOnline -Url $_.Url -Interactive
        $lists = Get-PnPList | Where-Object BaseTemplate -eq 101 # Document libraries
        foreach ($l in $lists) {
            Write-Host "$($_.Url) — $($l.Title): MajorVersions=$($l.MajorVersionLimit)"
        }
    }

# Reduce version limit on a specific library
Set-PnPList -Identity "Documents" -MajorVersions 50
```

Also empty the **tenant-level recycle bins** — deleted items occupy pool storage for 93 days.

#### ✅ Option 2 — Microsoft 365 Archive (New product — 2024+)

Microsoft's own cold storage for **inactive SharePoint sites**. Keeps sites searchable (eDiscovery) but off the active pool.

- **Price:** ~**$0.05 / GB / month** (cold storage)
- **Retrieval:** ~$0.60 / GB (first-time reactivation)
- **Best for:** Project sites that are "done" but have to be kept for legal/compliance

> ตัวอย่าง: ไซต์โครงการ 500 GB เก็บไว้ 1 ปี → $0.05 × 500 × 12 = **$300 / year** (เทียบกับ $0.20 × 500 × 12 = **$1,200 / year** ถ้าซื้อ Extra File Storage)

```powershell
# Archive a site (requires Microsoft 365 Archive license)
# Via SharePoint Admin Center → Archived sites → Archive a site
# Or via Graph API / Microsoft 365 Archive portal
```

[Microsoft 365 Archive product page](https://www.microsoft.com/en-us/microsoft-365/enterprise/microsoft-365-archive){:target="_blank"}

#### 💰 Option 3 — Office 365 Extra File Storage ($0.20/GB/month)

The classic solution — **buy more pool storage directly**. Billed per GB per month.

- **Price:** **$0.20 / GB / month** (USD list)
- **Add via:** Microsoft 365 admin center → Billing → Purchase services → Add-ons → "Office 365 Extra File Storage"
- **Granularity:** Billed in exact GB, no minimum commitment
- **Applies to:** SharePoint pool only (not OneDrive per-user)

ตัวอย่างการคำนวณ:
```
ต้องการเพิ่ม 500 GB → 500 × $0.20 = $100 / เดือน ($1,200 / ปี)
ต้องการเพิ่ม 2 TB  → 2,048 × $0.20 = $409.60 / เดือน ($4,915 / ปี)
```

#### 💰 Option 4 — Microsoft 365 Backup (New — 2024+)

Not a quota solution per se, but relevant: Microsoft's own **immutable backup** for OneDrive/SharePoint/Exchange — a ransomware recovery tool, not a cheaper archive.

- **Price:** ~**$0.15 / GB / month** of protected data
- **Best for:** Ransomware protection on top of retention policies

#### 💰 Option 5 — OneDrive per-user storage increase

For OneDrive-heavy users, OneDrive **starts at 1 TB** per user and can expand:

| Threshold | Action |
|-----------|--------|
| 1 TB → 5 TB | Automatic via SharePoint admin center: set default to 5 TB |
| 5 TB → 25 TB (per user) | Open a Microsoft support ticket; requires ≥ 5 E3/E5 users and the user to be already using > 90% of 5 TB |
| 25 TB+ | Microsoft provides a dedicated 25 TB SharePoint site shell |

```powershell
# Increase default OneDrive quota tenant-wide
Set-SPOTenant -OneDriveStorageQuota 5120000   # 5 TB in MB
```

#### 💰 Option 6 — Third-party Archiving / Tiering to Azure

- **AvePoint Cloud Backup** — $3–5 / user / month
- **ShareGate / Metalogix** — content migration to Azure Blob Storage ($0.01–0.02/GB/month cool tier)
- **Rubrik / Druva / Barracuda** — enterprise backup with SharePoint archive tiering

Best for: regulated enterprises wanting multi-year retention at lowest cost per GB.

---

## 5. Pricing Cheat Sheet — Side-by-Side

| Solution | Cost (USD list) | What You Get | Best For |
|----------|-----------------|--------------|----------|
| **Enable Archive Mailbox** | **$0** (included E3/E5/Business Premium) | +100 GB per user, auto-expand to 1.5 TB | Default first move for mailbox-full |
| **Enable Auto-Expanding Archive** | **$0** (included E3/E5) | Archive up to 1.5 TB | Heavy email users |
| **Exchange Online Archiving add-on** | **$3 / user / mo** | 100 GB archive + auto-expand for non-E3 users | Business Basic / F-tier users |
| **Office 365 Extra File Storage** | **$0.20 / GB / mo** | Pure SharePoint pool extension | SharePoint-pool exhaustion |
| **Microsoft 365 Archive** | **$0.05 / GB / mo** + $0.60/GB retrieval | Cold-tier SharePoint site archive | Inactive project sites |
| **Microsoft 365 Backup** | **$0.15 / GB / mo** | Immutable backup | Ransomware protection |
| **OneDrive 1 TB → 5 TB** | **$0** (tenant setting on E3+) | 5× per-user OneDrive | File-heavy users |
| **OneDrive 5 TB → 25 TB** | **$0** (via support ticket) | Per-user above 5 TB | Media / engineering teams |
| **License upgrade Business Premium → E3** | **+$13.75 / user / mo** | +50 GB mailbox + 50 GB more archive | When you also need more features |
| **Third-party archive (Mimecast / Barracuda)** | **$4–8 / user / mo** | Separate cloud archive, compliance-grade | Regulated industries |
| **Azure Blob Storage (cold tier)** | **$0.01–0.02 / GB / mo** + egress | Cheapest cold storage; requires migration tool | DIY long-term archive |

---

## 6. Decision Tree — "ควรเลือกทางไหน?"

```
Q: อีเมลเต็มใช่ไหม?
   ├─ ใช่ → เปิด Archive Mailbox (ฟรี) → ยังไม่พอ? → Set-OrganizationConfig -AutoExpandingArchive (ฟรี)
   │        → ยังไม่พอ? → ลบของเก่า / Upgrade ไป E3
   │
Q: Archive เต็มหรือใกล้เต็ม (>90 GB)?
   ├─ ใช่ → เช็ค Get-OrganizationConfig | Select AutoExpandingArchiveEnabled
   │        ├─ False → เปิด Set-OrganizationConfig -AutoExpandingArchive (ฟรี; รอ 30 วัน)
   │        └─ True  → เกิน 1.5 TB แล้ว → eDiscovery export + delete, หรือ third-party archive
   │
Q: SharePoint Pool เต็ม?
   ├─ เช็ค Get-PnPTenant | Select Storage*  →  ใช้ไปเท่าไร?
   │        ├─ < 70% → Clean up versions + recycle bins  →  free
   │        ├─ 70–90% → Archive inactive sites → Microsoft 365 Archive ($0.05/GB)
   │        └─ > 90% → ซื้อ Extra File Storage ($0.20/GB) หรือ Azure Blob (ถูกกว่า)
```

---

## 7. ตัวอย่างคำนวณราคา (Thai SMB)

**สมมติ:** บริษัท 50 คน ใช้ E3 ทั้งหมด
- Mailbox รวม: 50 × 100 GB = 5 TB (ได้ฟรี)
- Archive รวม: 50 × 100 GB = 5 TB (ได้ฟรี — ถ้าเปิดใช้)
- SharePoint Pool: 1 TB + (10 GB × 50) = **1.5 TB รวม**

**หลังจากใช้ไป 2 ปี** — SharePoint pool ใกล้เต็มที่ 1.3 TB (87%)

| Solution | ค่าใช้จ่าย 1 ปี | หมายเหตุ |
|----------|----------------|---------|
| Clean up versioning (ลด 500 → 50) | $0 | มักกู้คืนได้ 20–30% = ประหยัดทันที ~300 GB |
| ซื้อ Extra File Storage 500 GB | $0.20 × 500 × 12 = **$1,200** | เพิ่มทันที, จ่ายตามจริง |
| ย้ายไซต์โปรเจกต์เก่า 500 GB ไป M365 Archive | $0.05 × 500 × 12 = **$300** | ช้ากว่านิดนึง + จ่ายค่า retrieval ถ้าดึงคืน |
| ย้าย 500 GB ไป Azure Blob Cool | $0.015 × 500 × 12 = **$90** | ต้องใช้ migration tool, ไม่มีการค้นหาผ่าน eDiscovery |

---

## 8. Monitor & Prevent (ก่อนเต็ม)

ต่อยอดจาก [Admin Monthly Report]({{ site.baseurl }}/docs/admin-monthly-report) — เพิ่ม Alert ล่วงหน้า:

```powershell
# แจ้งเตือนถ้า Mailbox > 85%
$threshold = 0.85
$mbxs = Get-EXOMailbox -ResultSize Unlimited |
    Get-EXOMailboxStatistics |
    Where-Object {
        $used  = $_.TotalItemSize.Value.ToBytes()
        $quota = (Get-EXOMailbox $_.DisplayName).ProhibitSendReceiveQuota.Value.ToBytes()
        ($used / $quota) -gt $threshold
    }
$mbxs | Select-Object DisplayName,
    @{n='UsedGB'; e={[math]::Round($_.TotalItemSize.Value.ToBytes()/1GB,2)}}

# แจ้งเตือน SharePoint pool > 80%
$sp = Get-PnPTenant
$usage = $sp.StorageQuotaAllocated / $sp.StorageQuota
if ($usage -gt 0.80) {
    Write-Warning "SharePoint pool at $([math]::Round($usage*100,1))% — plan expansion"
}
```

ตั้ง Scheduled Task รันรายสัปดาห์แล้วส่งอีเมลหา IT admin.

---

## 9. References

- [Exchange Online — Mailbox size and limits](https://learn.microsoft.com/en-us/office365/servicedescriptions/exchange-online-service-description/exchange-online-limits#mailbox-storage-limits){:target="_blank"}
- [Enable archive mailboxes in Microsoft 365](https://learn.microsoft.com/en-us/purview/enable-archive-mailboxes){:target="_blank"}
- [Enable auto-expanding archiving](https://learn.microsoft.com/en-us/purview/enable-autoexpanding-archiving){:target="_blank"}
- [SharePoint Online limits](https://learn.microsoft.com/en-us/office365/servicedescriptions/sharepoint-online-service-description/sharepoint-online-limits){:target="_blank"}
- [Microsoft 365 Archive](https://www.microsoft.com/en-us/microsoft-365/enterprise/microsoft-365-archive){:target="_blank"}
- [Microsoft 365 Backup](https://www.microsoft.com/en-us/microsoft-365/enterprise/microsoft-365-backup){:target="_blank"}
- [Office 365 Extra File Storage pricing](https://www.microsoft.com/en-us/microsoft-365/business/office-365-extra-file-storage){:target="_blank"}
- [Azure Blob Storage pricing — Cool / Archive tiers](https://azure.microsoft.com/en-us/pricing/details/storage/blobs/){:target="_blank"}
