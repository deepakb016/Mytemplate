CI & Push Instructions
======================

1. Ensure your local branch is up-to-date and the `reports/` directory exists.

```bash
git checkout -b feature/ci-setup
git add .
git commit -m "Add CI workflow and Makefile targets"
git push origin feature/ci-setup
```

2. Create a Pull Request to `main`/`master`. The GitHub Actions workflow `.github/workflows/ci.yml` will run automatically and upload `reports/` artifacts.

3. Download artifacts from the workflow run's Artifacts section to inspect `reports/unit.xml`, `reports/ui.xml`, and `reports/security.json`.
