# test-scan-ballerina

Scans the Ballerina package in this repository with the [scan-ballerina](https://github.com/marketplace/actions/scan-ballerina) action and reports the findings to SonarQube. `main.bal` has 6 low findings.

## Setting up the SonarQube server

The workflow reads the server URL from a repository variable and the token from a repository secret. Set both in the repository's **Settings > Secrets and variables > Actions**, or with the GitHub CLI:

```sh
gh variable set SONAR_HOST_URL --body "https://sonarqube.mycompany.com"
gh secret set SONAR_TOKEN
```

The server needs the Ballerina plugin installed. Create the token in SonarQube under **My Account > Security**, for a user that has the **Execute Analysis** and **Create Projects** permissions, so that the `test-scan-ballerina` project is created on its first analysis.

GitHub does not pass secrets to workflows run from pull requests opened from forks. On those runs, the action skips SonarQube with a warning.
