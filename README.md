# 🔐 DevSecOps Security Pipeline

A small Flask application wired end-to-end with a **complete DevSecOps CI/CD pipeline** on GitHub Actions — Static Application Security Testing (SAST), Software Composition Analysis (SCA), secret scanning, dependency review, and container image scanning. The app itself is intentionally minimal; the point of this repo is the pipeline in [`.github/workflows/devsecops.yml`](.github/workflows/devsecops.yml).

[![Python](https://img.shields.io/badge/Python-3.12-3776AB?style=flat&logo=python&logoColor=white)](https://www.python.org/)
[![GitHub Actions](https://img.shields.io/badge/GitHub%20Actions-CI%2FCD-2088FF?style=flat&logo=githubactions&logoColor=white)](https://github.com/features/actions)
[![CodeQL](https://img.shields.io/badge/SAST-CodeQL-4B32C3?style=flat&logo=github&logoColor=white)](https://codeql.github.com/)
[![Trivy](https://img.shields.io/badge/SCA%20%2F%20Container-Trivy-1904DA?style=flat&logo=aqua&logoColor=white)](https://aquasecurity.github.io/trivy/)
[![Gitleaks](https://img.shields.io/badge/Secret%20Scanning-Gitleaks-FFB600?style=flat&logo=git&logoColor=white)](https://github.com/gitleaks/gitleaks)
[![Docker](https://img.shields.io/badge/Container-Docker-2496ED?style=flat&logo=docker&logoColor=white)](https://www.docker.com/)

---

## Overview

`devsecops-pipeline-demo` pairs a tiny, deliberately simple Flask API with a security-first GitHub Actions pipeline that runs on every push, every pull request into `main`, and on a weekly schedule. The goal is to show what "shift-left" security looks like in practice: code, dependencies, secrets, and the final container image are all checked automatically, before anything reaches production.

This is a portfolio project by **Dileep Kumar Tamminana**, built to demonstrate practical DevSecOps engineering: pipeline design, tool integration, and secure-by-default configuration (non-root containers, pinned base images, fail-the-build security gates).

## What This Demonstrates

| Control | Tool | Where it runs |
|---|---|---|
| **SAST** (source code analysis) | [GitHub CodeQL](https://codeql.github.com/) | `codeql` job — analyzes `app.py` for the `python` language |
| **SCA** (dependency vulnerabilities) | [Trivy](https://aquasecurity.github.io/trivy/) filesystem scan + [Dependabot](https://docs.github.com/en/code-security/dependabot) | `trivy-filesystem-scan` job + [`.github/dependabot.yml`](.github/dependabot.yml) |
| **Secret scanning** | [Gitleaks](https://github.com/gitleaks/gitleaks) | `gitleaks` job — scans full git history on every run |
| **Dependency review** | [GitHub Dependency Review Action](https://github.com/actions/dependency-review-action) | `dependency-review` job — runs on pull requests |
| **Container image scanning** | Trivy image scan | `trivy-image-scan` job — builds [`Dockerfile`](Dockerfile), then scans the resulting image |

All scan results (CodeQL, Trivy filesystem, Trivy image) are uploaded as SARIF to GitHub's **Security** tab, so findings show up alongside native code scanning alerts. Filesystem and image scans fail the build on `HIGH` or `CRITICAL` severity findings.

## Architecture

```
                              ┌──────────────────────┐
                              │   push / pull_request │
                              │   to main, or weekly   │
                              │   cron (Mon 03:00 UTC) │
                              └───────────┬───────────┘
                                          │
                    ┌─────────────────────┼─────────────────────┐
                    │                     │                     │
                    ▼                     ▼                     ▼
          ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐
          │   SAST: CodeQL   │  │  SCA: Trivy (fs)  │  │  Secret Scanning │
          │  init + analyze  │  │  HIGH,CRITICAL     │  │     Gitleaks     │
          │   (app.py)       │  │   fails the build  │  │  full git history│
          └────────┬─────────┘  └─────────┬─────────┘  └─────────┬────────┘
                   │                      │                      │
                   │                      ▼                      │
                   │           ┌─────────────────────┐            │
                   │           │  Dependency Review   │            │
                   │           │  (pull_request only) │            │
                   │           └──────────┬──────────┘            │
                   │                      │                       │
                   │                      ▼                       │
                   │           ┌─────────────────────┐            │
                   │           │  docker build .      │            │
                   │           │  (Dockerfile)         │            │
                   │           └──────────┬──────────┘            │
                   │                      │                       │
                   │                      ▼                       │
                   │           ┌─────────────────────┐            │
                   │           │ Trivy Image Scan      │            │
                   │           │ HIGH,CRITICAL         │            │
                   │           │ fails the build       │            │
                   │           └──────────┬──────────┘            │
                   │                      │                       │
                   └──────────────────────┼───────────────────────┘
                                          ▼
                          ┌──────────────────────────────┐
                          │  SARIF results → GitHub       │
                          │  Security tab (Code scanning) │
                          └──────────────────────────────┘
```

## How to Run Locally

### Prerequisites

- Python 3.12+
- Docker (optional, for the container workflow)

### Run with Python

```bash
# Clone the repository
git clone https://github.com/DileepKumarTamminana/devsecops-pipeline-demo.git
cd devsecops-pipeline-demo

# Create and activate a virtual environment
python -m venv venv
source venv/bin/activate      # Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Run the app
python app.py
```

The app starts on `http://localhost:5000`. Try it out:

```bash
curl http://localhost:5000/
curl http://localhost:5000/health
curl http://localhost:5000/version
```

### Run with Docker

```bash
# Build the image (non-root user, pinned slim base image)
docker build -t devsecops-pipeline-demo:local .

# Run the container
docker run --rm -p 5000:5000 devsecops-pipeline-demo:local
```

### Run the Security Scans Locally (optional)

```bash
# Trivy filesystem scan
trivy fs --severity HIGH,CRITICAL .

# Trivy image scan
trivy image devsecops-pipeline-demo:local

# Gitleaks secret scan
gitleaks detect --source . -v
```

## Tools Used

- **[Python](https://www.python.org/)** — application language (Flask API)
- **[GitHub Actions](https://github.com/features/actions)** — CI/CD orchestration for all pipeline stages
- **[CodeQL](https://codeql.github.com/)** — static application security testing (SAST)
- **[Trivy](https://aquasecurity.github.io/trivy/)** — software composition analysis (SCA) and container image scanning
- **[Gitleaks](https://github.com/gitleaks/gitleaks)** — secret scanning across git history
- **[Docker](https://www.docker.com/)** — containerization, built and scanned in CI

## Project Structure

```
devsecops-pipeline-demo/
├── .github/
│   ├── workflows/
│   │   └── devsecops.yml     # CodeQL, Trivy (fs + image), Gitleaks, dependency review
│   └── dependabot.yml        # Weekly updates for pip, github-actions, docker
├── app.py                    # Flask app: /, /health, /version
├── requirements.txt          # Pinned Python dependencies
├── Dockerfile                # Non-root, pinned slim base image
├── .gitignore
├── LICENSE
└── README.md
```

## Security

This project follows a "fail closed" approach: any `HIGH` or `CRITICAL` finding from the SCA or container scan stages fails the pipeline, blocking the merge/deploy. The container image runs as a dedicated non-root user (`appuser`), uses a pinned base image tag (`python:3.12.4-slim`) rather than a floating tag, and installs dependencies from a pinned `requirements.txt`.

If you discover a security issue in this repository, please open an issue or reach out directly rather than filing a public exploit — this is a demo/portfolio project, not a production system, but responsible disclosure is still appreciated.

---

**Author:** [Dileep Kumar Tamminana](https://github.com/DileepKumarTamminana)
