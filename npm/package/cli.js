#!/usr/bin/env node
const { spawnSync } = require("child_process");
const { binaryPath } = require("./index");

const res = spawnSync(binaryPath, process.argv.slice(2), { stdio: "inherit" });
process.exit(res.status == null ? 1 : res.status);
