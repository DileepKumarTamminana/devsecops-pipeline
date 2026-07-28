"""
DevSecOps Security Pipeline Demo — sample Flask application.

A minimal, intentionally simple web service used to demonstrate a complete
DevSecOps CI/CD pipeline (SAST, SCA, secret scanning, and container scanning).
The app itself contains no user-supplied input handling that touches the
filesystem, shell, or a database, keeping the attack surface small so the
pipeline's findings reflect the pipeline configuration, not app-level bugs.
"""

from __future__ import annotations

import os
from datetime import datetime, timezone

from flask import Flask, jsonify

app = Flask(__name__)

# Basic metadata, kept out of source control via environment variables.
APP_NAME = "devsecops-pipeline-demo"
APP_VERSION = os.environ.get("APP_VERSION", "1.0.0")


@app.route("/", methods=["GET"])
def home():
    """Landing route: returns a friendly greeting and basic app metadata."""
    payload = {
        "message": "Welcome to the DevSecOps Security Pipeline demo API",
        "app": APP_NAME,
        "version": APP_VERSION,
    }
    return jsonify(payload), 200


@app.route("/health", methods=["GET"])
def health():
    """Health check endpoint used by container orchestrators / CI smoke tests."""
    payload = {
        "status": "healthy",
        "timestamp": datetime.now(timezone.utc).isoformat(),
    }
    return jsonify(payload), 200


@app.route("/version", methods=["GET"])
def version():
    """Returns the running application version."""
    return jsonify({"app": APP_NAME, "version": APP_VERSION}), 200


if __name__ == "__main__":
    # debug is explicitly disabled to avoid the Werkzeug debugger/reloader
    # being exposed in non-development environments.
    port = int(os.environ.get("PORT", "5000"))
    app.run(host="0.0.0.0", port=port, debug=False)
