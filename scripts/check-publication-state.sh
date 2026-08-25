#!/usr/bin/env bash
set -u

state_file="${1:-}"

if [[ -z "$state_file" || ! -f "$state_file" ]]; then
  echo "ERROR: provide a normalized Sites state JSON file"
  exit 2
fi

if ! command -v node >/dev/null 2>&1; then
  echo "ERROR: node is required to classify publication state"
  exit 2
fi

node - "$state_file" <<'NODE'
const fs = require("node:fs");

const path = process.argv[2];
let state;
try {
  state = JSON.parse(fs.readFileSync(path, "utf8"));
} catch {
  console.error("ERROR: publication state file is not valid JSON");
  process.exit(2);
}

const projectId = typeof state.project_id === "string" ? state.project_id.trim() : "";
const access = typeof state.access_level === "string"
  ? state.access_level.trim().toLowerCase()
  : "unknown";
const version = Number.isInteger(state.latest_version_number)
  ? state.latest_version_number
  : null;
const liveUrl = typeof state.current_live_url === "string"
  ? state.current_live_url.trim()
  : "";
const environment = Array.isArray(state.sites_environment_variables)
  ? state.sites_environment_variables
  : [];
const frontendUrl = typeof state.frontend_convex_url === "string"
  ? state.frontend_convex_url.trim()
  : "";
const hasSitesConvexUrl = environment.some((entry) => {
  if (typeof entry === "string") return entry === "NEXT_PUBLIC_CONVEX_URL";
  return entry && entry.name === "NEXT_PUBLIC_CONVEX_URL";
});
const localBackend = /^(https?:\/\/)?(localhost|127\.0\.0\.1)(:|\/|$)/i.test(frontendUrl);

if (!projectId) {
  console.log("PUBLICATION STATE: UNREGISTERED");
  console.log("NEXT ACTION: register the ChatGPT Site once and persist project_id");
  process.exit(1);
}

console.log("SITE REGISTRATION: CONFIRMED");
console.log(`ACCESS POLICY: ${access.toUpperCase()}`);
if (access === "public") {
  console.log("ACCESS ACTION: preserve public; do not request the same access change again");
}

if (liveUrl) {
  console.log("PUBLICATION STATE: PUBLISHED");
  console.log(`LIVE URL: ${liveUrl}`);
  process.exit(0);
}

console.log("PUBLICATION STATE: UNPUBLISHED");
console.log(`LATEST SAVED VERSION: ${version === null ? "UNKNOWN" : version}`);
console.log(`SITES NEXT_PUBLIC_CONVEX_URL: ${hasSitesConvexUrl ? "PRESENT" : "MISSING"}`);
console.log(`FRONTEND BACKEND: ${localBackend ? "ACCOUNTLESS LOCAL OR LOCALHOST" : "NONLOCAL OR UNKNOWN"}`);
console.log("RECOVERY REQUIRED:");
console.log("1. Link or confirm the intended Convex Cloud project and production deployment.");
console.log("2. Announce the exact production target and obtain fresh deployment consent.");
console.log("3. Deploy Convex production and capture its exact public URL.");
console.log("4. Set NEXT_PUBLIC_CONVEX_URL in Sites as non-secret public configuration.");
console.log("5. Rebuild and fail if the bundle contains localhost, the development URL, or a deploy key.");
console.log("6. Push the exact validated source commit, save a Sites version, and deploy it.");
console.log("7. Poll to success, require get_site.current_live_url, and run live HTTPS/read/write/realtime QA.");
process.exit(1);
NODE
