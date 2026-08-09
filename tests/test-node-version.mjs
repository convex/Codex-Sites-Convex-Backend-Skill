import assert from "node:assert/strict";
import test from "node:test";

import {
  isSupportedNodeVersion,
  parseNodeVersion,
} from "../assets/check-node-version.mjs";

test("accepts Node 24 and the minimum Node 22 release", () => {
  assert.equal(isSupportedNodeVersion("24.19.0"), true);
  assert.equal(isSupportedNodeVersion("22.13.0"), true);
});

test("rejects Node 20 and versions below the minimum", () => {
  assert.equal(isSupportedNodeVersion("20.20.1"), false);
  assert.equal(isSupportedNodeVersion("22.12.0"), false);
  assert.equal(isSupportedNodeVersion("not-a-version"), false);
});

test("parses a leading v", () => {
  assert.deepEqual(parseNodeVersion("v24.19.0"), {
    major: 24,
    minor: 19,
    patch: 0,
  });
});
