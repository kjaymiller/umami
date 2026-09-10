#!/bin/sh
# Fetches the Aiven project CA certificate at container startup so Node trusts
# the TLS chain presented by an Aiven-managed Postgres service. The CA is
# project-scoped (shared by every service in the project), so we only need
# AIVEN_PROJECT_NAME + AIVEN_API_TOKEN; AIVEN_SERVICE_NAME is accepted for
# logging/context but isn't required to fetch the cert.
set -e

CA_PATH="/tmp/aiven-ca.pem"

if [ -n "$AIVEN_API_TOKEN" ] && [ -n "$AIVEN_PROJECT_NAME" ]; then
  echo "Fetching Aiven CA certificate for project '${AIVEN_PROJECT_NAME}'${AIVEN_SERVICE_NAME:+ (service '${AIVEN_SERVICE_NAME}')}..."

  curl -sf \
    -H "Authorization: Bearer ${AIVEN_API_TOKEN}" \
    "https://api.aiven.io/v1/project/${AIVEN_PROJECT_NAME}/kms/ca" \
    | node -e "
        let d = '';
        process.stdin.on('data', c => (d += c));
        process.stdin.on('end', () => process.stdout.write(JSON.parse(d).certificate));
      " > "$CA_PATH"

  if [ -s "$CA_PATH" ]; then
    export NODE_EXTRA_CA_CERTS="$CA_PATH"
    echo "Aiven CA certificate written to ${CA_PATH}"
  else
    echo "Warning: fetched Aiven CA certificate was empty, continuing without it" >&2
    rm -f "$CA_PATH"
  fi
else
  echo "AIVEN_API_TOKEN / AIVEN_PROJECT_NAME not set, skipping Aiven CA fetch"
fi

exec docker-entrypoint.sh "$@"
