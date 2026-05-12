# CI/CD & Automation

Focus: Pipelines, release automation, GitHub Actions.

## Key Concepts
- **CI/CD**: Continuous Integration/Deployment. Automate build, test, deploy.
- **GitHub Actions**: YAML-based workflows for automation.
- **Release Automation**: Versioning, rollbacks.

## GitHub Actions Example
```yaml
name: CI/CD Pipeline
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - name: Build
      run: docker build -t app .
    - name: Test
      run: docker run app pytest
    - name: Deploy
      run: kubectl apply -f deployment.yaml
```

## Real-Time Scenarios
- **Scenario 1**: Build failure. Check logs, fix dependencies.
- **Scenario 2**: Deployment rollback. Use `kubectl rollout undo`.
- **Scenario 3**: Parallel jobs. Run tests and builds concurrently.
- **Scenario 4**: Release tagging. Automate versioning with Git tags.