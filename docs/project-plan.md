---
title: Project Plan Template
layout: default
nav_order: 2.5
has_children: false
permalink: /docs/project-plan
description: Downloadable Microsoft 365 setup project plan — ~75 tasks across 10 phases covering tenant, identity, PIM, device, data, PDPA, Zero Trust validation, and ongoing ops. CSV + Markdown formats.
---

# Project Plan Template
{: .no_toc }

A ready-to-use **Microsoft 365 setup project plan** covering every solution in this guide — tenant foundation, email security, identity (Entra ID + PIM), device (Intune), data & collaboration, PDPA compliance, Zero Trust validation, and ongoing operations.
{: .fs-6 .fw-300 }

{: .highlight }
**Download formats** (open in Excel / Project / Smartsheet / any text editor):
- 📊 **[M365-Setup-Project-Plan.csv]({{ site.baseurl }}/assets/templates/M365-Setup-Project-Plan.csv){:download}** — spreadsheet-friendly, ~75 rows
- 📝 **[M365-Setup-Project-Plan.md]({{ site.baseurl }}/assets/templates/M365-Setup-Project-Plan.md){:download}** — Markdown version (same content, reads well in any editor)

---

## Table of Contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## How to Use

1. Download the **CSV** and open in Excel, Microsoft Project, Smartsheet, Jira, or Asana — the columns map cleanly to any task manager.
2. Set your **start date** and let the duration + dependency fields drive the Gantt.
3. Replace generic roles (IT Admin, Security Lead, Compliance Lead) with named owners.
4. Mark each task **Status** as it progresses: `Not Started` → `In Progress` → `Done`.
5. Re-run the [Zero Trust assessment script]({{ site.baseurl }}/docs/zero-trust#3-step-1--baseline-assessment-run-the-script-first) at the end of each phase to track posture improvement.

{: .note }
**Durations** are **working days** for a mid-sized tenant (200–2,000 users). Scale up ~25 % per 10× user-count increase. The critical path is roughly **12–14 weeks for E5** or **9–11 weeks for Business Premium / E3** (skip Phase 4 and 3.11).

---

## Phase Summary

| # | Phase | Approx duration | Tasks | Key output |
|---|-------|----------------:|------:|-----------|
| **0** | **Prepare** | 2 weeks | 8 | Charter + baseline Zero Trust score |
| **1** | **Tenant Foundation** | 1 week | 8 | Domain verified + break-glass + alerts |
| **2** | **Email Security (EOP + MDO)** | 1–2 weeks | 6 | Anti-phish / anti-spam / SPF-DKIM-DMARC |
| **3** | **Identity (Microsoft Entra ID)** | 2–3 weeks | 11 | CA baseline enforced, Identity Protection (E5) |
| **4** | **PIM** *(E5)* | 2 weeks | 8 | 0 permanent Global Admins besides break-glass |
| **5** | **Device (Microsoft Intune)** | 3–4 weeks | 12 | ≥ 90 % compliant devices + "Require compliant" CA |
| **6** | **Data & Collaboration** | 2 weeks | 8 | Sensitivity labels + baseline DLP + retention |
| **7** | **PDPA (Thailand)** *(optional)* | 1–2 weeks | 6 | Compliance Manager assessment + breach runbook |
| **8** | **Zero Trust Validation** | 1–2 weeks | 3 | Score improved vs. baseline |
| **9** | **Operations (ongoing)** | continuous | 5 | Monthly report + quarterly access reviews |
| | **TOTAL** | **12–14 weeks** | **~75** | |

---

## Role Glossary

| Role | Who is this typically? |
|------|-----------------------|
| **PMO** | Project manager — owns schedule, scope, stakeholders |
| **Identity Lead** | Microsoft Entra ID administrator |
| **Security Lead** | Security engineer / SOC analyst — drives PIM, CA, Zero Trust |
| **Device Lead** | Intune / endpoint administrator |
| **Email Admin** | Exchange Online administrator |
| **Compliance Lead** | Data/compliance officer — drives labels, DLP, retention |
| **DPO** | Data Protection Officer (required for PDPA sections) |
| **Collab Lead** | Teams / SharePoint administrator |
| **IT Admin** | General IT operations |
| **Network Lead** | DNS + corporate network admin |
| **IT Procurement** | Licensing + contracts |
| **Change Mgmt** | Communications + end-user adoption |

---

## Critical-Path Dependency Highlights

A few non-obvious dependencies worth calling out — these are the moments where **getting ahead is impossible without the predecessor**:

- **3.6 (Disable Security Defaults)** → required before **any** Conditional Access policy can be created.
- **3.9 (CA Require MFA)** → prerequisite for **PIM** (Phase 4) because PIM activation forces MFA.
- **5.1 (Intune setup)** → gates every device task. Run `Setup-Intune.ps1` early.
- **5.12 (Require compliant device CA)** → **last** device task. Enable only after ≥ 90 % of devices are enrolled and compliant — otherwise users get locked out.
- **6.2 (DLP baseline)** → always start in **Audit mode** for 2 weeks before enforce.
- **7.x (PDPA tasks)** → can run in parallel with Phase 6 once sensitivity labels exist.
- **8.1 (Post-rollout Zero Trust assessment)** → blocks project closure (it's the evidence the project delivered value).

---

## Lightweight Gantt Overview

```
Week:   01 02 03 04 05 06 07 08 09 10 11 12 13 14
P0 ████████
P1       ██████
P2          ████████
P3             ████████████████
P4                   ████████████
P5                      ████████████████████████
P6                                  ████████████
P7                                        ████████
P8                                              ██████
P9                                                    ─ ongoing →
```

---

## Downloads

- 📊 [M365-Setup-Project-Plan.csv]({{ site.baseurl }}/assets/templates/M365-Setup-Project-Plan.csv){:download} — open in Excel, Microsoft Project, Smartsheet, Monday, Asana, Jira, Trello, etc.
- 📝 [M365-Setup-Project-Plan.md]({{ site.baseurl }}/assets/templates/M365-Setup-Project-Plan.md){:download} — Markdown source, same task list

{: .note }
Need a project plan for a **specific profile** (Business Premium SMB, E3 mid-market, E5 enterprise, F-tier frontline)? Combine this template with the [Use Cases & License Mapping]({{ site.baseurl }}/docs/use-cases) decision tree — delete the phases that don't apply to your licenses and roll forward with the rest.

---

## References

- [Microsoft 365 adoption framework](https://adoption.microsoft.com/en-us/){:target="_blank"}
- [Microsoft Zero Trust deployment plan](https://learn.microsoft.com/en-us/security/zero-trust/deploy/overview){:target="_blank"}
- [Microsoft 365 FastTrack](https://www.microsoft.com/en-us/fasttrack){:target="_blank"}
- See also: [Prerequisites]({{ site.baseurl }}/docs/prerequisites) · [Use Cases]({{ site.baseurl }}/docs/use-cases) · [Zero Trust playbook]({{ site.baseurl }}/docs/zero-trust)
