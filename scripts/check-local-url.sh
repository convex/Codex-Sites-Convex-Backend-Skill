#!/usr/bin/env bash
set -u

if [[ "$#" -ne 2 ]]; then
  echo "Usage: $0 <exact-local-url> <expected-port>"
  exit 2
fi

local_url="$1"
expected_port="$2"

if [[ ! "$expected_port" =~ ^[0-9]+$ ]] || (( expected_port < 1 || expected_port > 65535 )); then
  echo "ERROR: expected port must be an integer from 1 to 65535"
  exit 2
fi

if [[ ! "$local_url" =~ ^http://(localhost|127\.0\.0\.1):${expected_port}(/|$) ]] &&
  [[ ! "$local_url" =~ ^http://\[::1\]:${expected_port}(/|$) ]]; then
  echo "FAILED: $local_url is not the expected localhost URL on port $expected_port"
  echo "Do not accept a fallback port. Resolve the expected-port conflict and start one Sites server again."
  exit 1
fi

if ! command -v curl >/dev/null 2>&1; then
  echo "FAILED: curl is required to verify the local HTTP response"
  exit 1
fi

if ! curl --noproxy '*' --fail --silent --show-error --location --max-time 60 "$local_url" >/dev/null; then
  echo "FAILED: no successful HTTP response from $local_url"
  exit 1
fi

echo "PASSED: $local_url returned a successful HTTP response on expected port $expected_port"
