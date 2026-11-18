# Microsoft 365 Setup Project Plan — Template

Full task breakdown for a greenfield Microsoft 365 deployment covering every solution area in the [Microsoft 365 Setup Guide](https://DekBaCom.github.io/Microsoft365SetupGuide/). ~75 tasks across 10 phases.

Durations below are **working days** for a mid-sized tenant (200–2,000 users). Scale up ~25 % per 10× user-count increase.

Phase dependencies run roughly sequentially — but Identity / Device / Data streams can partially overlap once the tenant foundation (Phase 1) is in.

---

## Phase 0 — Prepare (approx. 2 weeks)

| Task | Description | Duration | Role | Guide |
|------|-------------|---------:|------|-------|
| 0.1 Executive sponsor alignment | Secure C-level sponsor + business case sign-off | 5d | PMO | Prerequisites |
| 0.2 License procurement / verification | Confirm seats + add-ons for the right SKU | 5d | IT Procurement | Use Cases & License Mapping |
| 0.3 Project team assembly | PMO + Identity + Device + Data + Compliance leads | 3d | PMO | Prerequisites |
| 0.4 Risk assessment | Document top 10 risks + rollback plans | 5d | Security Lead | Prerequisites |
| 0.5 Communication plan | T-14 / T-7 / T-1 / T-0 cadence | 3d | Change Mgmt | Prerequisites |
| 0.6 Baseline Zero Trust assessment | Run `Get-M365SecurityPosture.ps1` BEFORE any change | 1d | Security Lead | Zero Trust |
| 0.7 Stakeholder workshop | Review baseline + roadmap | 1d | PMO | Zero Trust |
| 0.8 Kick-off meeting | Formal project kick-off | 1d | PMO | — |

---

## Phase 1 — Tenant Foundation (approx. 1 week)

| Task | Description | Duration | Role | Guide |
|------|-------------|---------:|------|-------|
| 1.1 Custom domain verification | Add domain + verify via DNS TXT | 3d | Identity Lead | Tenant Configuration — Vanity Domains |
| 1.2 DNS records (MX / CNAME / TXT) | Update at registrar | 2d | Network Lead | Tenant Configuration — Vanity Domains |
| 1.3 Organization settings | Org profile + support contacts | 1d | IT Admin | Tenant Configuration — Org Settings |
| 1.4 Password policy | Never-expire (MFA-protected) | 1d | Security Lead | Tenant Configuration — Org Settings |
| 1.5 Break-glass group creation | `Excluded from CA` security group | 1d | Security Lead | Tenant Configuration — Emergency Access |
| 1.6 Break-glass accounts (×2) | Cloud-only Global Admin break-glass | 2d | Security Lead | Tenant Configuration — Emergency Access |
| 1.7 Alert policies | Default alerts + break-glass sign-in alert | 2d | Security Lead | Tenant Configuration — Alert Policies |
| 1.8 Report Message add-in | Deploy via Integrated apps | 1d | Email Admin | Tenant Configuration — Report Message |

---

## Phase 2 — Email Security (EOP + Defender for Office 365) (approx. 1–2 weeks)

| Task | Description | Duration | Role | Guide |
|------|-------------|---------:|------|-------|
| 2.1 Anti-phishing policy | Mailbox intelligence + impersonation protection | 2d | Email Admin | Tenant Configuration — EOP & MDO |
| 2.2 Anti-spam policy | Bulk threshold 5–6 + Safety Tips | 1d | Email Admin | Tenant Configuration — EOP & MDO |
| 2.3 Anti-malware policy | Common-attachment filter + ZAP | 1d | Email Admin | Tenant Configuration — EOP & MDO |
| 2.4 Safe Attachments / Safe Links | Dynamic Delivery + Office Apps (MDO required) | 2d | Security Lead | Tenant Configuration — EOP & MDO |
| 2.5 SPF / DKIM / DMARC | DNS + DKIM signing per domain | 3d | Email Admin | Tenant Configuration — EOP & MDO |
| 2.6 Configuration Analyzer baseline | Compare to Standard / Strict; close gaps | 2d | Security Lead | Tenant Configuration — EOP & MDO |

---

## Phase 3 — Identity (Microsoft Entra ID) (approx. 2–3 weeks)

| Task | Description | Duration | Role | Guide |
|------|-------------|---------:|------|-------|
| 3.1 Combined MFA + SSPR registration | Enable combined reg for all users | 1d | Identity Lead | Entra ID — Combined Registration |
| 3.2 Self-service password reset | 2 methods + no forced registration | 2d | Identity Lead | Entra ID — SSPR |
| 3.3 User settings | Block user app registration + restrict admin portal | 1d | Identity Lead | Entra ID — User Settings |
| 3.4 Admin consent workflow | Block user consent + enable admin approvals | 2d | Identity Lead | Entra ID — Admin Consent |
| 3.5 Device settings | Require MFA to join / register | 1d | Identity Lead | Entra ID — Device Settings |
| 3.6 Disable Security Defaults | Prerequisite for CA | 1d | Identity Lead | Entra ID — CA Baseline |
| 3.7 Named Locations | Corporate IP ranges + allowed countries | 2d | Network Lead | Entra ID — CA Baseline |
| 3.8 CA — BLOCK legacy auth | Report-only → Pilot → Enforce | 3d | Identity Lead | Entra ID — CA Baseline |
| 3.9 CA — REQUIRE MFA | Report-only → Pilot → Enforce | 5d | Identity Lead | Entra ID — CA Baseline |
| 3.10 CA — BLOCK unsupported platforms | Report-only → Pilot → Enforce | 3d | Identity Lead | Entra ID — CA Baseline |
| 3.11 Identity Protection (E5) | Risk-based CA in Report-only → Enforce | 5d | Security Lead | Zero Trust on M365 |

---

## Phase 4 — Privileged Identity Management (PIM, E5 only) (approx. 2 weeks)

| Task | Description | Duration | Role | Guide |
|------|-------------|---------:|------|-------|
| 4.1 PIM discovery | Inventory all permanent role assignments | 2d | Security Lead | PIM |
| 4.2 PIM role settings — Global Admin | 4 h / MFA / approval / justification | 2d | Security Lead | PIM |
| 4.3 PIM role settings — other high-impact roles | Repeat for 9+ privileged roles | 3d | Security Lead | PIM |
| 4.4 Convert permanent → eligible (pilot) | 2–3 non-critical admins | 2d | Security Lead | PIM |
| 4.5 PIM activation test | Pilot admin workflow verified | 1d | Security Lead | PIM |
| 4.6 Convert all remaining admins | Keep only 2 break-glass permanent | 3d | Security Lead | PIM |
| 4.7 Access reviews — quarterly | Scheduled per role | 2d | Security Lead | PIM |
| 4.8 PIM alerts | Tune thresholds | 1d | Security Lead | PIM |

---

## Phase 5 — Device (Microsoft Intune) (approx. 3–4 weeks)

| Task | Description | Duration | Role | Guide |
|------|-------------|---------:|------|-------|
| 5.1 Intune setup | Run `Setup-Intune.ps1` | 1d | Device Lead | Intune — Initial Setup |
| 5.2 Enrollment restrictions | Per-platform + BYOD policy | 2d | Device Lead | Intune — Enrollment |
| 5.3 Windows Autopilot | Register HW IDs + deployment profile | 5d | Device Lead | Intune — Enrollment |
| 5.4 iOS enrollment | Apple MDM Push cert + ADE | 3d | Device Lead | Intune — Enrollment |
| 5.5 Android enrollment | Managed Google Play | 3d | Device Lead | Intune — Enrollment |
| 5.6 Compliance — Windows | BitLocker / Secure Boot / password | 2d | Device Lead | Intune — Compliance |
| 5.7 Compliance — iOS | Jailbreak block + min OS | 1d | Device Lead | Intune — Compliance |
| 5.8 Compliance — Android | Rooted block + Play Protect | 1d | Device Lead | Intune — Compliance |
| 5.9 App Protection (MAM) iOS | PIN / encryption / policy-managed apps | 2d | Device Lead | Intune — App Protection |
| 5.10 App Protection (MAM) Android | Equivalent to iOS | 2d | Device Lead | Intune — App Protection |
| 5.11 Device clean-up rules | Auto-remove stale devices | 1d | Device Lead | Intune — Clean-up |
| 5.12 CA — Require compliant device | Report-only 2 weeks → Enforce | 14d | Identity Lead | Intune — MDM |

---

## Phase 6 — Data & Collaboration (approx. 2 weeks)

| Task | Description | Duration | Role | Guide |
|------|-------------|---------:|------|-------|
| 6.1 Sensitivity labels | Public / General / Confidential / Highly Confidential | 3d | Compliance Lead | Collab Governance — Labels |
| 6.2 DLP policy — baseline | Exchange + SPO + OneDrive (Audit mode first) | 5d | Compliance Lead | Collab Governance — DLP |
| 6.3 Retention policies | 2–7 y per workload | 3d | Compliance Lead | Collab Governance — Retention |
| 6.4 SharePoint sharing settings | 'Specific people' default + Anyone-link expiry | 2d | Compliance Lead | Collab Governance — SharePoint |
| 6.5 OneDrive sharing settings | Inherit from SPO baseline | 1d | Compliance Lead | Collab Governance — SharePoint |
| 6.6 Teams external access | Allowed or domain-restricted | 1d | Collab Lead | Collab Governance — Teams |
| 6.7 Teams guest access | On with review | 1d | Collab Lead | Collab Governance — Teams |
| 6.8 Groups expiration policy | 180-day + owner notifications | 1d | Collab Lead | Collab Governance — Groups |

---

## Phase 7 — PDPA (Thailand) — optional (approx. 1–2 weeks)

| Task | Description | Duration | Role | Guide |
|------|-------------|---------:|------|-------|
| 7.1 Compliance Manager — PDPA assessment | Built-in Thailand PDPA template | 2d | DPO | PDPA Thailand Compliance |
| 7.2 Thai sensitive info types activated | Verify Thai NatID + Passport SITs | 1d | DPO | PDPA Thailand Compliance |
| 7.3 PDPA sensitivity label | 'PDPA — Personal Data' label published | 3d | DPO | PDPA Thailand Compliance |
| 7.4 PDPA DLP policy | Block external send of PDPA data | 3d | DPO | PDPA Thailand Compliance |
| 7.5 PDPA retention policy | Defined period + auto-delete | 2d | DPO | PDPA Thailand Compliance |
| 7.6 72-hour breach runbook | Document + rehearse | 3d | DPO | PDPA Thailand Compliance |

---

## Phase 8 — Zero Trust Validation (approx. 1–2 weeks)

| Task | Description | Duration | Role | Guide |
|------|-------------|---------:|------|-------|
| 8.1 Post-rollout assessment | Re-run `Get-M365SecurityPosture.ps1` | 1d | Security Lead | Zero Trust on M365 |
| 8.2 Gap remediation | Close P1/P2 gaps | 10d | Security Lead | Zero Trust on M365 |
| 8.3 Monthly recurring assessment | Scheduled task + DL | 2d | Security Lead | Zero Trust on M365 |

---

## Phase 9 — Operations (ongoing)

| Task | Description | Duration | Role | Guide |
|------|-------------|---------:|------|-------|
| 9.1 Admin Monthly Report | Schedule `Get-M365MonthlyReport.ps1` | 2d | IT Admin | Admin Monthly Report |
| 9.2 Storage quota monitoring | Alert at 85 % mailbox / 80 % SPO pool | 2d | IT Admin | Storage Quotas |
| 9.3 Incident response plan | Test IR scripts end-to-end | 3d | Security Lead | Downloads — IR |
| 9.4 Quarterly access reviews | Confirm PIM + EM reviews firing | 1d | Security Lead | PIM |
| 9.5 Project retrospective | Lessons learned + hand-off to BAU | 2d | PMO | — |

---

**Total critical-path duration:** ~12–14 weeks for a mid-sized tenant with E5. Business Premium / E3 plans skip Phases 4 + 3.11 and can complete in ~9–11 weeks.

> Source: [Microsoft 365 Setup Guide — Project Plan](https://DekBaCom.github.io/Microsoft365SetupGuide/docs/project-plan). CSV version suitable for Excel / Project / Smartsheet is on that page.
