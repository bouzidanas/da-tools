#!/usr/bin/env node

import { select, input } from "@inquirer/prompts";
import chalk from "chalk";
import { execSync } from "node:child_process";
import { readdirSync, statSync } from "node:fs";
import { resolve } from "node:path";
import { homedir } from "node:os";

const cwd = process.cwd();

// ᴄᴛʀʟ+ᴄ = Unicode small caps for a compact look
const exitLabel = "ᴄᴛʀʟ+ᴄ";

const selectTheme = {
  style: {
    keysHelpTip: (keys) =>
      keys.map(([key, action]) => `${key} ${action}`).join(", ") + `, ${exitLabel} exit`,
  },
};

try {
  const dirs = readdirSync(cwd).filter((name) => {
    if (name.startsWith(".")) return false;
    try {
      return statSync(resolve(cwd, name)).isDirectory();
    } catch {
      return false;
    }
  });

  if (dirs.length === 0) {
    console.log(chalk.red("✗ No folders found in the current directory."));
    process.exit(1);
  }

  const mode = await select({
    message: "Mode",
    choices: [
      { name: "Start", value: "start" },
      { name: "End", value: "end" },
    ],
    theme: selectTheme,
  });

  let modifier = "";
  if (mode === "end") {
    modifier = (
      await input({
        message: "Modifier (enter to skip)",
      })
    ).trim();
  }

  const repoFolder = await select({
    message: "Repo folder",
    choices: dirs.map((d) => ({ name: d, value: d })),
    theme: selectTheme,
  });

  let tarPath;
  if (mode === "start") {
    tarPath = `./${repoFolder}-start.tar`;
  } else {
    const suffix = modifier ? `-${modifier}` : "";
    tarPath = `${homedir()}/${repoFolder}-end-model${suffix}.tar`;
  }

  const cmd = `tar -cf "${tarPath}" "./${repoFolder}"`;

  console.log(chalk.dim(`\n$ ${cmd}`));
  execSync(cmd, { cwd, stdio: "inherit" });
  console.log(chalk.green(`✓ Created ${tarPath}`));
} catch (err) {
  if (err.name === "ExitPromptError") {
    process.exit(0);
  }
  console.error(chalk.red(`✗ ${err.message}`));
  process.exit(1);
}
