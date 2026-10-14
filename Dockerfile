# syntax=docker/dockerfile:1

# ---- Build stage: install dependencies into an isolated prefix ----
FROM python:3.14.8-slim AS builder

WORKDIR /build

# Keep pip quiet/deterministic and avoid writing .pyc files during install
ENV PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PYTHONDONTWRITEBYTECODE=1

COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# ---- Runtime stage: minimal image with only what's needed to run ----
FROM python:3.14.8-slim AS runtime

# Metadata
LABEL org.opencontainers.image.title="devsecops-pipeline-demo" \
      org.opencontainers.image.description="Sample Flask app for a DevSecOps GitHub Actions pipeline demo" \
      org.opencontainers.image.authors="Dileep Kumar Tamminana"

# Create a dedicated, unprivileged, non-login user/group to run the app
RUN groupadd --system --gid 1001 appgroup \
    && useradd --system --uid 1001 --gid appgroup --no-create-home --shell /usr/sbin/nologin appuser

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH=/usr/local/bin:$PATH \
    PORT=5000

# Bring in the dependencies installed in the build stage
COPY --from=builder /install /usr/local

# Copy only the application source needed at runtime
COPY app.py .

# Ensure application files are owned by the non-root user
RUN chown -R appuser:appgroup /app

USER appuser

EXPOSE 5000

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:5000/health')" || exit 1

CMD ["python", "app.py"]
