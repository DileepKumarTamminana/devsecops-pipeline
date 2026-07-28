# ▶️ How to Run — DevSecOps Security Pipeline

A small Flask app wrapped in a complete DevSecOps CI pipeline (SAST + SCA + secret scanning + container scanning).

## Prerequisites
- Python 3.11+
- (Optional) Docker

## Run the app locally
```bash
python -m venv venv
# Windows PowerShell:
venv\Scripts\Activate.ps1
# macOS/Linux:
# source venv/bin/activate

pip install -r requirements.txt
python app.py
```
Open **http://localhost:5000**

**Routes:**
- `/` — home
- `/health` — health check
- `/version` — build/version info

Set a custom port with `PORT=8000 python app.py`.

## Run as a container
```bash
docker build -t devsecops-demo .
docker run -p 5000:5000 devsecops-demo
```
The image runs as a non-root user with a pinned base image.

## The security pipeline (CI)
Runs automatically on every push/PR to `main` (and weekly). See the **Actions** tab:
1. **CodeQL** — SAST on Python code
2. **Trivy (filesystem)** — dependency/SCA scan, fails on HIGH/CRITICAL
3. **Gitleaks** — secret scanning across history
4. **Dependency Review** — flags risky dependency changes on PRs
5. **Trivy (image)** — builds the Docker image and scans it

Findings appear under **Security → Code scanning**. Dependabot (`.github/dependabot.yml`) keeps pip, Docker, and Actions dependencies patched.
