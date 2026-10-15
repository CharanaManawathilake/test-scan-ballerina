# test-scan-ballerina

Test cases for the [scan-ballerina](https://github.com/CharanaManawathilake/scan-ballerina) action, to see how each case looks to users in the GitHub UI. The jobs have no assertions: a case that should fail fails, and a case that should pass passes.

Each job is one case, so its result, annotations and job summary show on their own.

Every scan saves its SARIF file as a workflow artifact (`artifacts: true`) named after its `category`, so the SARIF file can be downloaded from the run's summary page, even when the scan fails. Artifact names are unique within a workflow run, so each scan has its own `category`.

## Inputs workflow

| Job | Expected |
| --- | --- |
| 1. Compatible Ballerina and scan tool versions | Passes |
| 2. Scan tool version incompatible with Ballerina | Fails while installing the scan tool |
| 3. Upload to GitHub code scanning | Passes; findings appear under Security > Code scanning |
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
| 17. Default Ballerina and scan tool versions | Passes with the latest Ballerina and the scan tool pinned by the action |
| 18. Several invalid inputs | Fails, with one error for each of `ballerina-version`, `tool-version`, `platforms`, `fail-on-severity`, `max-findings`, `annotations` and `job-summary` |

## SonarQube workflow

Every job uses its job ID as the category. The jobs with invalid settings point to a dummy server, `https://sonarqube.example.invalid`, and fail before anything is downloaded. The jobs with valid settings download the plugin, run SonarScanner and report to a real SonarQube server.

### Setting up the SonarQube server

The jobs with valid settings read the server URL from a repository variable and the token from a repository secret. Set both in the repository's **Settings > Secrets and variables > Actions**:

| Name | Where | Value |
| --- | --- | --- |
| `SONAR_HOST_URL` | **Variables** tab > **New repository variable** | The server's https URL, such as `https://sonarqube.mycompany.com` |
| `SONAR_TOKEN` | **Secrets** tab > **New repository secret** | A SonarQube token |

Or set them with the GitHub CLI:

```sh
gh variable set SONAR_HOST_URL --body "https://sonarqube.mycompany.com"
gh secret set SONAR_TOKEN
```

The server needs the Ballerina plugin installed. Create the token in SonarQube under **My Account > Security**, for a user that has the **Execute Analysis** and **Create Projects** permissions, so that each project key is created on its first analysis. The jobs create the projects `remote-plugin`, `orders`, `properties-key`, `override-key` and `platform-key`.

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
| Plugin version 0.2.0 | Passes; downloads plugin 0.2.0 and reports to `orders` |
| Key and name from sonar-project.properties | Passes; reports to `properties-key`, named `Properties Name`, from the file |
| project-key overriding sonar-project.properties | Passes; reports to `override-key`, with the file's name |
| Platform-level project key for the one package left after exclude-paths | Passes; 1 package scanned, reports to `platform-key`, named `Platform Key` from its packages item |

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

The packages in `test/sonarqube` each set up one SonarQube case, with a `Scan.toml` or a `sonar-project.properties` file.
