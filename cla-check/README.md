# CLA Check Workflow

A reusable GitHub Actions workflow that verifies contributors have agreed to the
Contributor License Agreement (CLA) by checking their presence in the
`CONTRIBUTORS.md` file.

## Features

- ✅ Automatically checks if PR authors have signed the CLA
- 🏷️ Manages PR labels (`cla-signed`, `cla-required`, `cla-modified`)
- 💬 Posts helpful comments guiding contributors through the CLA process
- 🔄 Validates both base and PR branches for existing signatures
- 🛡️ Prevents unauthorised modifications to the `CONTRIBUTORS.md` file

## Usage

### Basic Usage

Add this workflow to your repository by creating
`.github/workflows/cla-check.yml`:

```yaml
name: CLA Check

on:
  pull_request_target:
    types: [opened, synchronize, reopened]

jobs:
  cla-check:
    uses: MetOffice/growss/.github/workflows/cla-check.yaml@main
```

### With Custom Configuration

```yaml
name: CLA Check

on:
  pull_request_target:
    types: [opened, synchronize, reopened]

jobs:
  cla-check:
    uses: MetOffice/growss/.github/workflows/cla-check.yaml@main
    with:
      # URL to your CLA document (any HTTPS URL)
      cla-url: "https://example.com/legal/cla"
      # Or use a documentation platform
      # cla-url: "https://docs.example.com/contributing/cla.html"
      # Or GitLab
      # cla-url: "https://gitlab.com/yourorg/yourrepo/-/blob/main/CLA.md"
      # GitHub runner to use
      runner: "ubuntu-24.04"
```

## Input Parameters

| Parameter | Description                                   | Required | Default                                                  |
| --------- | --------------------------------------------- | -------- | -------------------------------------------------------- |
| `cla-url` | URL to the CLA document (any valid HTTPS URL) | No       | `https://github.com/MetOffice/Momentum/blob/main/CLA.md` |
| `runner`  | GitHub Actions runner to use for the job      | No       | `ubuntu-24.04`                                           |

**Note:** The `cla-url` can point to any publicly accessible web page containing
your CLA terms (e.g., GitHub, GitLab, Confluence, your organization's website,
etc.). It must be an HTTPS URL.

## How It Works

1. **Check Base Branch**: Verifies if the contributor has already signed the CLA
   on the base branch
2. **Check PR Branch**: If not found on base, checks if the contributor added
   themselves in the current PR
3. **Label Management**: Automatically adds/removes appropriate labels based on
   CLA status
4. **Comment Control**: Posts helpful guidance for new contributors or warnings
   for policy violations

## Labels

The workflow manages the following labels:

- **🔵 cla-signed**: Author has signed the CLA in this PR (new contributor)
- **🔴 cla-required**: Author needs to sign the CLA before the PR can be merged
- **🟠 cla-modified**: Author modified CONTRIBUTORS.md when already signed
  (requires admin review)

## For Contributors

To sign the CLA for your first contribution:

1. Read the CLA document (link provided in the automated comment)
2. Add your details to the `CONTRIBUTORS.md` file in this PR:

   ```markdown
   | GitHub Username | Real Name | Affiliation | Date       |
   | --------------- | --------- | ----------- | ---------- |
   | username        | Your Name | Your Org    | YYYY-MM-DD |
   ```

3. Commit and push the changes
4. The workflow will automatically verify your signature

## Permissions Required

This workflow requires the following permissions:

```yaml
permissions:
  contents: read # To checkout repository code
  pull-requests: write # To add labels and post comments
```

## Security Considerations

- Uses `pull_request_target` event for security when working with PRs from forks
- Only requires `read` access to repository contents
- Validates contributor identity through GitHub username matching
- **Uses fixed-string matching** to prevent regex injection attacks
- **Validates CLA URL format** - must be a valid HTTPS URL to a public web page
  (not HTTP or file://)
- **Validates username format** to prevent malicious input
- **Never checks out untrusted code** - only inspects CONTRIBUTORS.md file
- **Scoped file checking** - only monitors the exact CONTRIBUTORS.md file

## Licence

&copy; Crown copyright Met Office. All rights reserved. See the LICENCE file for
terms under which this code may be used.
