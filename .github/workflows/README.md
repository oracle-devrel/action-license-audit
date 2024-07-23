# License File Auditor

## Introduction
This is designed to be used in GitHub Actions.  It indicates whether any unapproved licenses are found.  This simply examines the file output from running ScanCode-Toolkit, providing a way to get a "is there a problem?" in the GitHub Workflow itself...

## Inputs
| Input | Type | Description |
|-------|------|-------------|
| `licenses_file` | string | The file output from ScanCode-Toolkit - typically the full (absolute) path is best to use. |

## Outputs
| Output | Type | Description |
|-------|------|-------------|
| `unapproved_liceses` | bool | Whether or not unapproved licenses were found. |

## Usage
Here's a sample:

```
name: License Audit
on:
  pull_request_target:
  
jobs:
  examine_licenses:
    name: Look for unapproved licenses
    runs-on: ubuntu-latest
    steps:
      - name: Look for non-approved licenses
        uses: oracle-devrel/action-license-audit@v0.1.1
        id: analysis
        with:
          licenses_file: '/github/workspace/licenses.json'
```

## Copyright Notice
Copyright (c) 2024 Oracle and/or its affiliates.