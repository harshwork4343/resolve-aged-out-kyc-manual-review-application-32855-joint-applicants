#!/usr/bin/env bash
set -euo pipefail
# /solution is docker-cp'd owned by the uploading uid, so --write-back can't
# rewrite golden_trajectory.json in place. Work from a private copy.
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
cp -R /solution "$WORK/solution"
python3 "$WORK/solution/solve.py" --task-dir "$WORK" --write-back "$@"
# Writes /logs/agent/trajectory.json so trajectory verifiers see oracle's replay.
SOLUTION_DIR="$WORK/solution" python3 "$WORK/solution/emit_oracle_trajectory.py"
