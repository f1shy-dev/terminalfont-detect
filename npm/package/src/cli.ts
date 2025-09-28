#!/usr/bin/env node
import { spawnSync } from "child_process";
import { binaryPath } from "./index.js";

const res = spawnSync(binaryPath, process.argv.slice(2), { stdio: "inherit" });
process.exit(res.status == null ? 1 : res.status);