# Security Policy

We take the security of this guide — and especially the PowerShell scripts shipped with it — seriously. If you believe you have found a vulnerability or an insecure default in any part of this repository, please follow the responsible-disclosure process below.

## Scope

This policy covers:

- PowerShell scripts under `scripts/`
- Jekyll site configuration (`_config.yml`, workflows, includes)
- Documentation that could lead an administrator to misconfigure a Microsoft 365 tenant in a way that reduces security posture

Out of scope:

- Issues in Microsoft products themselves — report to [Microsoft Security Response Center (MSRC)](https://msrc.microsoft.com/)
- Issues in the `just-the-docs` theme — report to [`just-the-docs/just-the-docs`](https://github.com/just-the-docs/just-the-docs/security)

## Reporting a Vulnerability

Please **do not open a public GitHub issue** for security reports.

Instead, use one of the private channels below:

1. **GitHub Private Vulnerability Reporting** — preferred
   Go to the [Security tab](https://github.com/DekBaCom/Microsoft365SetupGuide/security) of this repository and click **Report a vulnerability**.

2. **Email** — fallback
   Send details to: **Abdulloh.eg@gmail.com**
   Use the subject line: `[SECURITY] Microsoft365SetupGuide — <short description>`

## What to Include

- A clear description of the issue and its impact
- Steps to reproduce (or the specific script/line that is unsafe)
- Your assessment of severity (informational / low / medium / high / critical)
- Any suggested remediation
- Whether you want to be credited in the changelog once fixed

## Response Timeline

| Stage | Target |
|-------|--------|
| Acknowledgement of report | Within **3 business days** |
| Initial assessment + severity rating | Within **7 business days** |
| Fix or mitigation published | Within **30 days** for high/critical issues |
| Public disclosure in [CHANGELOG](CHANGELOG.md) | After the fix ships |

## Safe Harbor

Good-faith security research is welcomed. We will not pursue legal action against researchers who:

- Make a reasonable effort to avoid privacy violations, destruction of data, or interruption of service
- Only interact with accounts they own or have explicit permission to access
- Give us a reasonable window to respond before public disclosure (default: 90 days)

## Supported Versions

This repository tracks the **`main`** branch. Security fixes are only backported to tagged release branches if explicitly noted in the CHANGELOG.

| Branch | Supported |
|--------|-----------|
| `main` | ✅ |
| Tagged releases | Fixes only for the latest tag |
| Forks | Please open an issue in your own fork |
