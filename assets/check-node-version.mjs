import { pathToFileURL } from "node:url";

export const minimumNodeVersion = { major: 22, minor: 13 };

export function parseNodeVersion(version) {
  const match = String(version).trim().replace(/^v/, "").match(/^(\d+)\.(\d+)\.(\d+)/);
  if (!match) return null;

  return {
    major: Number.parseInt(match[1], 10),
    minor: Number.parseInt(match[2], 10),
    patch: Number.parseInt(match[3], 10),
  };
}

export function isSupportedNodeVersion(version) {
  const parsed = parseNodeVersion(version);
  if (!parsed) return false;

  return (
    parsed.major > minimumNodeVersion.major ||
    (parsed.major === minimumNodeVersion.major &&
      parsed.minor >= minimumNodeVersion.minor)
  );
}

function checkCurrentNodeVersion() {
  if (isSupportedNodeVersion(process.versions.node)) return;

  console.error(
    `This app needs Node.js 22.13.0 or newer; this terminal is using v${process.versions.node}.`,
  );
  console.error(`Selected Node executable: ${process.execPath}`);
  console.error(
    "Node.js 24 is recommended. Switch the terminal to Node 24, open a fresh login shell, then retry.",
  );
  console.error(
    "npm install installs project packages; it cannot install or switch the Node.js runtime selected by this terminal.",
  );
  process.exitCode = 1;
}

const entrypoint = process.argv[1]
  ? pathToFileURL(process.argv[1]).href
  : undefined;

if (entrypoint === import.meta.url) checkCurrentNodeVersion();
