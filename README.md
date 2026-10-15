# test-scan-ballerina

Test cases for the [scan-ballerina](https://github.com/CharanaManawathilake/scan-ballerina) action, to see how each case looks to users in the GitHub UI. The jobs have no assertions: a case that should fail fails, and a case that should pass passes.

Each job is one case, so its result, annotations and job summary show on their own.

Every scan saves its SARIF file as a workflow artifact (`artifacts: sarif`) named after its `category`, so the SARIF file can be downloaded from the run's summary page, even when the scan fails. Artifact names are unique within a workflow run, so each scan has its own `category`.

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
| 8. Max findings without fail-on-severity | Passes |
| 9a. Fail on low with max findings at the limit | Passes |
| 9b. Fail on low with max findings over the limit | Fails at the gate |
| 10a. Annotations on | Passes; findings annotated on the files |
| 10b. Annotations off | Passes; no finding annotations |
| 11a. Job summary on | Passes; job summary written |
| 11b. Job summary off | Passes; no job summary |
| 12a. Save the SARIF file and the Ballerina reports | Passes; the `artifacts-both` artifact holds `artifacts-both.sarif` and a `scan_results.json` for each of the 2 packages |
| 12b. Empty artifacts | Passes; no artifact saved |
| 12c. Unknown report in artifacts | Fails: unknown report `html`; no artifact saved |

## SonarQube workflow

Every job reports to a dummy server, `https://sonarqube.example.invalid`, and uses its job ID as the category. The jobs with invalid settings fail before anything is downloaded. The jobs with valid settings download the plugin and run SonarScanner, then fail because the server does not exist.

| Job | Expected |
| --- | --- |
| Absolute plugin path in Scan.toml | Fails: absolute path |
| http plugin URL in Scan.toml | Fails: not an https URL |
| No token | Fails: no token |
| Token from a secret that is not set | Fails: empty token |
| Two packages with the same project key | Fails: duplicate project key |
| Platform-level project key for two packages | Fails: project key applies to two packages |
| http server URL | Fails: not an https URL |
| Package settings that match no package | Fails: no matching package |
| Plugin from an https URL in Scan.toml | Downloads the plugin from the URL, then fails at the server |
| Plugin version 0.2.0 | Downloads plugin 0.2.0, then fails at the server |
| Key and name from sonar-project.properties | Resolves the key and name from the file, then fails at the server |
| project-key overriding sonar-project.properties | Uses the given key and the file's name, then fails at the server |

## Test packages

| Package | Findings |
| --- | --- |
| `test/projects/single` | 6 low |
| `test/projects/multi/orders` | 1 low |
| `test/projects/multi/payments` | 2 low |
| `test/projects/services/api` | 1 low |
| `test/projects/services/internal/legacy` | 2 low |
| `test/projects/secrets` | 1 medium |

The packages in `test/sonarqube` each set up one SonarQube case, with a `Scan.toml` or a `sonar-project.properties` file.
