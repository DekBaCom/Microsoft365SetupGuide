# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
and this project loosely follows [Semantic Versioning](https://semver.org/).

---

## [Unreleased]

### Added
- `LICENSE` file (MIT) and `SECURITY.md` responsible-disclosure policy
- `CHANGELOG.md` (this file)
- New **Privileged Identity Management (PIM)** step-by-step page at `/docs/privileged-identity-management`
- New **PDPA (Thailand) Compliance Setup** page at `/docs/pdpa` — maps PDPA 2562 obligations to Microsoft Purview, Information Protection, DLP, retention, DSR, and 72-hour breach workflow
- New **Use Cases & License Mapping** page at `/docs/use-cases` — groups M365 solutions by business use case and maps license tiers (Business Basic/Standard/Premium, E3/E5, F1/F3, A1/A3/A5, Nonprofit, Gov)
- New **Tenant-to-Tenant Migration** page at `/docs/tenant-migration` — end-to-end T2T playbook for mailbox CTMM, OneDrive, SharePoint, Teams, identity, Intune, and cutover weekend
- New **Storage Quotas & Cost Solutions** page at `/docs/storage-quotas` — mailbox full / archive full / SharePoint pool full scenarios with pricing comparison, PowerShell health checks, and Thai-SMB cost examples
- New **`scripts/migration/`** folder with `Export-TenantInventory.ps1` and `New-TargetTenantUsers.ps1`
- Copy-to-clipboard button on all code blocks (via `just-the-docs` built-in setting)
- Custom SCSS (`_sass/custom/custom.scss`) for responsive polish — horizontal-scrolling tables on mobile, larger touch targets, print-friendly styles, ultra-wide-desktop max-width

### Changed
- Site navigation: Prereq(2) · Use Cases(2.5) · Tenant(3) · Entra ID(4) · PIM(5) · Intune(6) · Collab(7) · PDPA(8) · T2T Migration(9) · Downloads(10) · Monthly Report(11)
- Home page (`index.md`) now links to Prerequisites, Use Cases, and PDPA from the top of the page

---

## [2026-11-18] — Branding, Prerequisites & SEO

### Added
- New **Prerequisites** page with licensing matrix (Business Premium / E3 / E5),
  Microsoft Graph scopes cheat-sheet, and a tenant-readiness PowerShell snippet
- SEO metadata: `author`, `social`, `lang`, per-page `description:` front matter

### Changed
- Rebranded references across all documentation:
  - **Azure AD → Microsoft Entra ID**
  - **Microsoft Endpoint Manager → Microsoft Intune**
  - **ATP → Microsoft Defender for Office 365**
  - **Azure AD Connect → Microsoft Entra Connect**
  - **Hybrid Azure AD Join → Microsoft Entra hybrid join**
- Permalinks and script folder paths were preserved — no broken links
- README monthly-report snippet now includes explicit `Connect-MgGraph -Scopes ...`
  and `Connect-ExchangeOnline` calls
- Modernized the inline `Connect-AzureAD` sample to use Microsoft Graph SDK
- Added prominent warning that **AzureAD**, **AzureADPreview**, and **MSOnline**
  PowerShell modules retire in 2026
- Renumbered `nav_order` across docs to insert Prerequisites at position 2

### Fixed
- Strengthened one weak image alt text (SharePoint Admin Center)

---

## [2026-04-28] — Initial Public Release

### Added
- Jekyll site using `just-the-docs` remote theme
- Six documentation pages — Tenant Configuration, Azure AD Configuration,
  Microsoft Endpoint Manager, Collaboration Governance, Admin Monthly Report,
  Downloads
- 59 ready-to-use PowerShell scripts across 7 categories
- 59 inline screenshots illustrating each setup step
- `Get-M365MonthlyReport.ps1` — single-file HTML report script
- GitHub Actions workflow for automatic GitHub Pages deployment
- Footer attribution and GitHub profile link
- Fixed home page 404s and broken auth link; expanded Service Principal section

---

[Unreleased]: https://github.com/DekBaCom/Microsoft365SetupGuide/compare/main...HEAD
