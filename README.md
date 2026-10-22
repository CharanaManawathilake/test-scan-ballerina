# test-scan-ballerina

Test cases for the [scan-ballerina](https://github.com/CharanaManawathilake/scan-ballerina) action, to see how each case looks to users in the GitHub UI. The jobs have no assertions: a case that should fail fails, and a case that should pass passes.

The test workflows use the action from the [`support-scan-tool-0.11.0`](https://github.com/CharanaManawathilake/scan-ballerina/tree/support-scan-tool-0.11.0) branch, which adds support for `bal scan` 0.11.0 on Ballerina 2201.12.

| Workflow | What it runs |
| --- | --- |
| [`inputs.yml`](.github/workflows/inputs.yml) | One job per input case, on `main` and on pull requests that change `test/` |
| [`code-scanning.yml`](.github/workflows/code-scanning.yml) | Case 3, the upload to code scanning, on `main` and on every pull request |
| [`sonarqube-settings.yml`](.github/workflows/sonarqube-settings.yml) | One job per SonarQube settings case, on `main` and on pull requests that change `test/` |
| [`scan.yml`](.github/workflows/scan.yml) | The order service scan on Ballerina 2201.12.0, uploaded to code scanning, on `main` and on every pull request to `main` |
| [`sonarqube.yml`](.github/workflows/sonarqube.yml) | The package in [`marketplace`](marketplace), reported to SonarQube with the Marketplace release `ballerina-platform/scan-ballerina@v0`. It is not at the repository root, since Ballerina 2201.12 does not load a package inside another package |

Each job is one case, so its result, annotations and job summary show on their own.

Every scan saves its SARIF file as a workflow artifact (`artifacts: true`) named after its `category`, so the SARIF file can be downloaded from the run's summary page, even when the scan fails. Artifact names are unique within a workflow run, so each scan has its own `category`.

## Inputs workflow

| Job | Expected |
| --- | --- |
| 1. Compatible Ballerina and scan tool versions | Passes |
| 2. Scan tool version incompatible with Ballerina | Fails with the inputs: `bal scan 0.12.0 needs Ballerina 2201.13.0 or later`, before anything is installed |
| 3. Upload to GitHub code scanning | Passes; findings appear under Security > Code scanning. In `code-scanning.yml` |
| 4. One path with several packages | Passes; 2 packages scanned |
| 5. Several paths with a package excluded | Passes; 3 packages scanned |
| 6. Two categories in one job | Passes; one summary per category |
| 7a. Fail on medium, low findings only | Passes |
| 7b. Fail on medium, one medium finding | Fails at the gate |
| 7c. Fail on high, one medium finding | Passes |
| 7d. Fail on MEDIUM in upper case, one medium finding | Fails at the gate |
| 8. Max findings without fail-on-severity | Passes |
| 9a. Fail on low with max findings at the limit | Passes |
| 9b. Fail on low with max findings over the limit | Fails at the gate |
| 10a. Annotations on | Passes; findings annotated on the files |
| 10b. Annotations off | Passes; no finding annotations |
| 11a. Job summary on | Passes; job summary written |
| 11b. Job summary off | Passes; no job summary |
| 12a. Save the SARIF file | Passes; the `artifacts-true` artifact holds `artifacts-true.sarif` only |
| 12b. Artifacts false | Passes; no artifact saved |
| 12c. Artifacts left out | Passes; no artifact saved, since `artifacts` defaults to `false` |
| 12d. Artifacts not true or false | Fails: `artifacts must be 'true' or 'false', got 'sarif'`; no artifact saved |
| 13a. Include rules | Passes; 2 of 6 findings, `ballerina:1` and `ballerina:10` |
| 13b. Exclude rules | Passes; 4 of 6 findings, without `ballerina:1` and `ballerina:10` |
| 13c. Exclude the rule behind the medium finding | Passes; no findings, where 7b fails |
| 13d. Include a rule no finding matches | Passes; no findings |
| 13e. Include and exclude rules together | Fails: cannot be used together |
| 13f. Rule name instead of a rule ID | Fails: `checkpanic` is not a rule ID |
| 14a. Exclude tests by default | Passes; the finding in `tests/` is dropped, 1 finding |
| 14b. Keep the findings in tests | Fails at the gate; 2 findings |
| 14c. exclude-tests that is not true or false | Fails: must be `true` or `false` |
| 15a. Exclude with `*` that stays within one directory | Passes; `legacy` is not excluded, 2 packages scanned |
| 15b. Exclude with `**` that crosses directories | Passes; 1 package scanned |
| 15c. Exclude the files of a package | Passes; 2 packages scanned, the findings in `payments` dropped, 1 finding |
| 15d. Exclude every package | Passes with a warning; no package found, result `skipped` |
| 15e. Absolute path in exclude-paths | Fails: globs must be relative to the repository root |
| 16a. Comma separated paths | Passes; 2 packages scanned |
| 16b. Path without a package | Passes with a warning; no package found, result `skipped` |
| 16c. Path that does not exist | Fails: path does not exist |
| 16d. Path to a file | Fails: not a directory |
| 16e. Path outside the repository | Fails: outside the repository |
| 17. Default Ballerina and scan tool versions | Passes with the latest Ballerina and the latest scan tool compatible with it |
| 18. Several invalid inputs | Fails, with one error for each of `ballerina-version`, `tool-version`, `platforms`, `fail-on-severity`, `max-findings`, `annotations` and `job-summary` |

### Ballerina 2201.12 and bal scan 0.11.0

| Job | Expected |
| --- | --- |
| 19a. Ballerina 2201.12.0 with the latest compatible scan tool | Passes with `bal scan` 0.11.0; 1 low finding. Each rule in the SARIF file has a `ruleKind`, taken from its level |
| 19b. Ballerina 2201.12.0 with tool-version 0.11.0 | Passes |
| 19c. Ballerina 2201.13.5 with tool-version 0.11.0 | Passes; 6 findings |
| 19d. Ballerina version below the minimum | Fails with the inputs: `bal scan 0.11.0 and later need Ballerina 2201.12.0 or later` |
| 19e. Scan tool version below the minimum | Fails with the inputs: the oldest supported version is `0.11.0` |
| 20a. Ballerina 2201.12.0 already on the path | Passes; uses that Ballerina, installs nothing else, and scans with `bal scan` 0.11.0 |
| 20b. Ballerina 2201.12.0 on the path with tool-version 0.12.0 | Passes; `bal scan 0.12.0 needs 2201.13.0 or later`, so the latest Ballerina is installed |

### Workspaces

| Job | Expected |
| --- | --- |
| 21a. Workspace with the latest Ballerina | Passes; 2 packages scanned |
| 21b. Workspace on Ballerina 2201.12.0 | Fails before anything is scanned: `'test/projects/workspace' is a workspace, which Ballerina 2201.12.0 does not support` and `This run uses Ballerina 2201.12.0, which does not support workspaces` |
| 21c. Workspace with bal scan 0.11.0 on Ballerina 2201.13.5 | Fails before anything is scanned, with the same errors naming `bal scan 0.11.0` |
| 21d. Workspace left out with exclude-paths on Ballerina 2201.12.0 | Passes; 1 package scanned |

## SonarQube settings workflow

Every job uses its job ID as the category. The jobs with invalid settings point to a dummy server, `https://sonarqube.example.invalid`, and fail before anything is downloaded. The jobs with valid settings download the plugin, run SonarScanner and report to a real SonarQube server.

### Setting up the SonarQube server

The jobs with valid settings, and the `marketplace` package's SonarQube workflow, read the server URL from a repository variable and the token from a repository secret. Set both in the repository's **Settings > Secrets and variables > Actions**:

| Name | Where | Value |
| --- | --- | --- |
| `SONAR_HOST_URL` | **Variables** tab > **New repository variable** | The server's https URL, such as `https://sonarqube.mycompany.com` |
| `SONAR_TOKEN` | **Secrets** tab > **New repository secret** | A SonarQube token |

Or set them with the GitHub CLI:

```sh
gh variable set SONAR_HOST_URL --body "https://sonarqube.mycompany.com"
gh secret set SONAR_TOKEN
```

The server needs the Ballerina plugin installed. Create the token in SonarQube under **My Account > Security**, for a user that has the **Execute Analysis** and **Create Projects** permissions, so that each project key is created on its first analysis. The jobs create the projects `remote-plugin`, `orders`, `properties-key`, `override-key`, `platform-key` and `oldest-tool`, and the `marketplace` package's workflow creates `test-scan-ballerina`.

Do not set `UNSET_SONAR_TOKEN`: the "Token from a secret that is not set" job needs it to be empty.

GitHub does not pass secrets to workflows run from pull requests opened from forks. On those runs, the action skips SonarQube with a warning in the jobs with valid settings and in the "No token" and "Token from a secret that is not set" jobs, so all of them pass.

| Job | Expected |
| --- | --- |
| Absolute plugin path in Scan.toml | Fails: absolute path |
| http plugin URL in Scan.toml | Fails: not an https URL |
| No token | Fails: no token |
| Token from a secret that is not set | Fails: empty token |
| Two packages with the same project key | Fails: duplicate project key |
| Platform-level project key for two packages | Fails: platform-level project key with 2 packages scanned |
| Platform-level project key with one package keyed under packages | Fails: platform-level project key with 2 packages scanned, though only one package has no key |
| Platform-level project name for two keyed packages | Fails: platform-level project name with 2 packages scanned |
| Project key at the platform level and in the package's item | Fails: project key set in two places |
| http server URL | Fails: not an https URL |
| Package settings that match no package | Fails: no matching package |
| Plugin from an https URL in Scan.toml | Passes; downloads the plugin from the URL and reports to `remote-plugin` |
| Plugin version 0.3.0 | Passes; downloads plugin 0.3.0 and reports to `orders` |
| Key and name from sonar-project.properties | Passes; reports to `properties-key`, named `Properties Name`, from the file |
| project-key overriding sonar-project.properties | Passes; reports to `override-key`, with the file's name |
| Platform-level project key for the one package left after exclude-paths | Passes; 1 package scanned, reports to `platform-key`, named `Platform Key` from its packages item |
| Plugin version 0.2.0 | Fails with the inputs: the oldest supported version is `0.3.0` |
| Plugin 0.3.0 with bal scan 0.11.0 on Ballerina 2201.12.0 | Passes; the default plugin, 0.3.0, runs with `bal scan` 0.11.0 and reports to `oldest-tool` |
| Workspace with SonarQube on Ballerina 2201.12.0 | Fails with the SonarQube settings, before Ballerina is installed: SonarQube is not supported for workspaces |

## Order service and pull requests

[`order-service`](order-service) is the order service of [demo-scan-ballerina](https://github.com/CharanaManawathilake/demo-scan-ballerina), set to Ballerina 2201.12.0. [`scan.yml`](.github/workflows/scan.yml) scans it with `bal scan` 0.11.0, which Ballerina Central picks for Ballerina 2201.12.0, and uploads the findings to code scanning with the category `order-service`. On `main`, the gate fails the job when more than 10 medium findings are counted, and `main` has 18. On pull requests the gate is off, and the **Block new code scanning alerts** ruleset blocks the merge when code scanning reports new alerts, or no results.

`bal scan` 0.11.0 has no rule severities, so a bug is high, a vulnerability is medium and a code smell is low. It reports 31 findings, 0 high, 18 medium and 13 low. It has no `ballerina:13`, `ballerina:14` or `ballerina/log:2` rule, so it reports 3 fewer findings than `bal scan` 0.12.0 in the demo repository:

| File | Severity | Rule | Issue |
| --- | --- | --- | --- |
| `auth.bal` | Medium | `ballerina/jwt:1` | Customer tokens are issued with the `none` algorithm |
| `auth.bal` | Medium | `ballerina/jwt:2` | Customer tokens are validated without a signature configuration |
| `auth.bal` | Medium | `ballerina/jwt:3` | Customer tokens are validated without checking the issuer and audience |
| `auth.bal` | Medium | `ballerina/jwt:4` | Customer tokens expire after 30 days |
| `auth.bal` | Medium | `ballerina/jwt:5` | A clock skew of one hour |
| `auth.bal` | Medium | `ballerina/jwt:6` | TLS validation is turned off for the partner JWKS endpoint |
| `auth.bal` | Medium | `ballerina/jwt:7` | A token is decoded without being verified |
| `auth.bal` | Low | `ballerina:3` | `issueToken` is public but not isolated |
| `payments.bal` | Medium | `ballerina/crypto:1` | Card numbers are encrypted with AES in ECB mode |
| `payments.bal` | Medium | `ballerina/crypto:2` | Passwords are hashed with a BCrypt work factor of 4 |
| `payments.bal` | Medium | `ballerina/crypto:3` | Receipts are encrypted with a fixed AES-GCM initialization vector |
| `payments.bal` | Medium | `ballerina/io:2` | The payment gateway key is printed to the console |
| `payments.bal` | Medium | `ballerina/log:1` | The payment gateway key is logged |
| `reports.bal` | Medium | `ballerina/os:3` | A report is generated through `sh -c` |
| `reports.bal` | Medium | `ballerina/os:4` | `sh` and `tar` are resolved through `PATH` (2 findings) |
| `service.bal` | Medium | `ballerina/http:1` | A `default` resource accepts every method and path |
| `service.bal` | Medium | `ballerina/http:2` | CORS allows every origin with credentials |
| `service.bal` | Medium | `ballerina/http:4` | Checkout redirects to a URL taken from the request |
| `pricing.bal` | Low | `ballerina:1` | `checkpanic` instead of `check` |
| `pricing.bal` | Low | `ballerina:2` | The `currency` parameter is not used |
| `pricing.bal` | Low | `ballerina:3` | `orderTotal` is public but not isolated |
| `pricing.bal` | Low | `ballerina:4` | Public methods of `DiscountCalculator` are not isolated (2 findings) |
| `pricing.bal` | Low | `ballerina:5` | `DiscountCalculator` is public but not isolated |
| `pricing.bal` | Low | `ballerina:6` | The `PaymentGateway` object type is public but not isolated |
| `pricing.bal` | Low | `ballerina:7` | A condition that is always true |
| `pricing.bal` | Low | `ballerina:8` | A condition that is always false |
| `pricing.bal` | Low | `ballerina:10` | A variable assigned to itself |
| `pricing.bal` | Low | `ballerina:11` | The private field `campaignCode` is never used |
| `pricing.bal` | Low | `ballerina:12` | The range `7 ... 1` is empty |

The pull requests show each case:

| Branch | Change | Result |
| --- | --- | --- |
| `demo-1` | New findings, with annotations and no upload | Blocked: code scanning waits for results that never come |
| `demo-2` | No new findings | Passes |
| `demo-3` | New findings, uploaded | Fails: the new alerts fail the **Ballerina Scan Tool** check |

## Test packages

| Package | Findings |
| --- | --- |
| `test/projects/single` | 6 low |
| `test/projects/multi/orders` | 1 low |
| `test/projects/multi/payments` | 2 low |
| `test/projects/services/api` | 1 low |
| `test/projects/services/internal/legacy` | 2 low |
| `test/projects/secrets` | 1 medium |
| `test/projects/with-tests` | 2 low, 1 of them in `tests/` |
| `test/projects/oldest` | 1 low, for Ballerina 2201.12.0 |
| `test/projects/workspace` | A workspace of `billing` and `shipping`, 1 low each |
| `marketplace` | 6 low |

The packages in `test/sonarqube` each set up one SonarQube case, with a `Scan.toml` or a `sonar-project.properties` file.
