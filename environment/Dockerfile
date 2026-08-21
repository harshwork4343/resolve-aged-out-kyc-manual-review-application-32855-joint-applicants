FROM us-central1-docker.pkg.dev/delivery-g-obi/data-obi-rl-gym/benchmark-base@sha256:ccc08929160ba6a33ba86c070a240f0865c75f83a20b981e6e571998b8b41c83
# Own venv so these pins can't shift a version out from under the gym servers,
# which run on this image's system python3.
RUN python3 -m venv /opt/proxy-venv && \
    /opt/proxy-venv/bin/pip install --no-cache-dir \
        pytest \
        mcp==1.26.0 \
        httpx==0.28.1 \
        "uvicorn[standard]==0.41.0" \
        starlette==0.52.1 \
        litellm==1.82.0

WORKDIR /app

# Build context is environment/ (some remote builders upload only that), so
# these come from the _app/ mirror — keep in sync via sync_app_mirror.sh.
COPY _app/task.toml _app/instruction.md /app/
COPY _app/tests/ /app/tests/

COPY mcp/proxy/ /opt/proxy/
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# /app root-only so the agent reaches gym state through MCP, not off disk.
RUN id rlgymagent >/dev/null 2>&1 || useradd --create-home --shell /bin/bash rlgymagent; \
    chmod -R go-rwx /app; \
    mkdir -p /workspace && chown rlgymagent:rlgymagent /workspace

ENV TASK_DIR=/app \
    HARBOR_MCP_MODE=docker \
    PROXY_HOST=0.0.0.0 \
    PROXY_PORT=7000 \
    SNAPSHOT_DIR=/logs/verifier/snapshots \
    PROXY_PYTHON=/opt/proxy-venv/bin/python3 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /workspace

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["sleep", "infinity"]
