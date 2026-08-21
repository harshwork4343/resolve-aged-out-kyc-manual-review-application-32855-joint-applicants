#!/bin/sh
set -eu

mkdir -p /logs/agent
PROXY_LOG_FILE="${PROXY_LOG_FILE:-/logs/agent/harbor-mcp-proxy.log}"
GYMS_LOG_FILE="/logs/agent/supervisord.log"
ENV_DUMP_FILE="/logs/agent/entrypoint-env.log"
PROXY_PYTHON="${PROXY_PYTHON:-python3}"

# /etc/hosts is read-only at build time; set gym-name aliases here instead.
grep -q ' slack-gym ' /etc/hosts 2>/dev/null || \
    echo "127.0.0.1 slack-gym jira-gym zeta3-sql-gym confluence-gym google-drive-gym freshdesk-gym email-gym" >> /etc/hosts

{
    echo "=== entrypoint env (filtered) ==="
    env | grep -E "HARBOR_MCP_MODE|MCP_REMOTE_URL|TASK_DIR|PROXY_" | sort
    echo "=== entrypoint args ==="
    echo "$@"
    echo "=== task.toml mcp_servers_extended (secrets redacted) ==="
    # /logs/agent is agent-readable; a leaked access_token lets the agent hit
    # a gym directly, bypassing the proxy.
    test -f "${TASK_DIR:-/app}/task.toml" && \
        sed -n '/\[\[metadata\.mcp_servers_extended\]\]/,/^$/p' \
            "${TASK_DIR:-/app}/task.toml" \
        | sed -E 's/^(access_token[[:space:]]*=[[:space:]]*).*/\1"<redacted>"/' \
        || echo '(no task.toml)'
} > "${ENV_DUMP_FILE}" 2>&1

/usr/bin/supervisord -n -c /etc/supervisor/conf.d/supervisord.conf >>"${GYMS_LOG_FILE}" 2>&1 &
SUPERVISORD_PID=$!

echo "waiting for gyms to answer /health..." >> "${ENV_DUMP_FILE}"
for port in 8004 8005 8006 8007 8008 8010 8011; do
    tries=0
    until curl -fsS "http://127.0.0.1:${port}/health" >/dev/null 2>&1; do
        tries=$((tries + 1))
        if [ "${tries}" -ge 60 ]; then
            echo "gym on port ${port} never became healthy after 120s" >&2
            exit 1
        fi
        sleep 2
    done
done
echo "all gyms healthy" >> "${ENV_DUMP_FILE}"

"${PROXY_PYTHON}" /opt/proxy/server.py >>"${PROXY_LOG_FILE}" 2>&1 &
PROXY_PID=$!

cleanup() {
    kill -TERM "${PROXY_PID}" 2>/dev/null || true
    kill -TERM "${SUPERVISORD_PID}" 2>/dev/null || true
    wait "${PROXY_PID}" 2>/dev/null || true
    wait "${SUPERVISORD_PID}" 2>/dev/null || true
}
trap cleanup TERM INT EXIT

# Daytona passes no command and overrides CMD; without this the script ends,
# the EXIT trap fires and the container dies before the proxy binds :7000.
if [ "$#" -eq 0 ]; then
    set -- sleep infinity
fi

exec "$@"
