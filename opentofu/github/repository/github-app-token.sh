#!/usr/bin/env bash
set -euo pipefail

for variable in \
  GITHUB_APP_ID \
  GITHUB_APP_INSTALLATION_ID \
  GITHUB_APP_PEM_FILE; do
  if [[ -z "${!variable:-}" ]]; then
    echo "required environment variable is unset: ${variable}" >&2
    exit 1
  fi
done

base64url() {
  openssl base64 -A | tr '+/' '-_' | tr -d '='
}

issued_at="$(($(date +%s) - 60))"
expires_at="$((issued_at + 600))"
header="$(printf '{"alg":"RS256","typ":"JWT"}' | base64url)"
payload="$(
  printf '{"iat":%s,"exp":%s,"iss":"%s"}' \
    "${issued_at}" "${expires_at}" "${GITHUB_APP_ID}" |
    base64url
)"
unsigned_token="${header}.${payload}"

private_key="$(mktemp)"
trap 'rm -f "${private_key}"' EXIT
chmod 600 "${private_key}"
printf '%b' "${GITHUB_APP_PEM_FILE}" >"${private_key}"

signature="$(
  printf '%s' "${unsigned_token}" |
    openssl dgst -sha256 -sign "${private_key}" |
    base64url
)"
app_token="${unsigned_token}.${signature}"

curl --fail --silent --show-error \
  --request POST \
  --header "Accept: application/vnd.github+json" \
  --header "Authorization: Bearer ${app_token}" \
  --header "X-GitHub-Api-Version: 2022-11-28" \
  "https://api.github.com/app/installations/${GITHUB_APP_INSTALLATION_ID}/access_tokens" |
  jq --exit-status --raw-output '.token'
