#!/usr/bin/env bash
set -euo pipefail

base_url="${1:?Usage: functional-test.sh <base-url>}"
max_attempts="${MAX_ATTEMPTS:-30}"

for attempt in $(seq 1 "${max_attempts}"); do
  echo "Health check ${attempt}/${max_attempts}: ${base_url}/health"

  if body="$(curl --silent --show-error --fail --max-time 10 "${base_url}/health")"; then
    if [[ "${body}" == *'"status":"ok"'* ]]; then
      echo "Functional test passed: ${body}"
      exit 0
    fi
  fi

  sleep 10
done

echo "Functional test failed after ${max_attempts} attempts." >&2
exit 1

