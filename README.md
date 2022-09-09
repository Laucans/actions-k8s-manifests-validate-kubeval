# Kubeval

`kubeval` is a tool for validating a Kubernetes YAML or JSON configuration file.
It does so using schemas generated from the Kubernetes OpenAPI specification, and
therefore can validate schemas for multiple versions of Kubernetes.

[![CircleCI](https://circleci.com/gh/instrumenta/kubeval.svg?style=svg)](https://circleci.com/gh/instrumenta/kubeval)
[![Go Report
Card](https://goreportcard.com/badge/github.com/instrumenta/kubeval)](https://goreportcard.com/report/github.com/instrumenta/kubeval)
[![GoDoc](https://godoc.org/github.com/instrumenta/kubeval?status.svg)](https://godoc.org/github.com/instrumenta/kubeval)


## Usage

### Basic

```yaml
# .github/workflows/manifests-validation.yml
name: Pull Request Check

on: [pull_request]

jobs:
  validation:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: validate manifests in dir1 and dir2
        uses: Laucans/actions-k8s-manifests-validate-kubeval@v1.1.0
        with:
          files: dir1,dir2
          token: ${{ secrets.GITHUB_TOKEN }}
```

### Input parameters

| Parameter                | Description                                                      | Default  |
| ------------------------ | ---------------------------------------------------------------- | -------- |
| `files`                  | Files or directories to validate                                 | `.`      |
| `version`                | Version of Kubernetes to validate against                        | `master` |
| `strict`                 | Whether to not to check for extra properties                     | `true`   |
| `openshift`              | Whether to use the schemas from OpenShift rather than Kubernetes | `false`  |
| `ignore_missing_schemas` | Whether or not to skip custom resources                          | `true`   |
| `ignored_filename_patterns` | A comma-separated list of regular expressions specifying paths to ignore (kubeval --ignored-filename-patterns)                          | `""`   |
| `ignored_logs_words`                | A comma-separated list of black listed substring which if find in result will remove line (use grep -v)    | `""`   |
| `comment`                | Write validation details to pull request comments                | `true`   |
| `token`                  | Github token for api. This is required if `comment` is true      | `""`     |

For full usage and installation instructions see [kubeval.com](https://kubeval.com/).
