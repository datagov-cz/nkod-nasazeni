import { spawn } from "node:child_process";
import fileSystem from "node:fs";

import express from "express";

const __dirname = import.meta.dirname;

const configuration = {
  ldf: {
    // HTTP port for Linked Data Fragments server
    port: parseInt(process.env.LDF_PORT ?? 3000),
    workers: parseInt(process.env.LDF_WORKERS ?? 4),
    config: filterKeysWithPrefix(process.env, "LDF_"),
  },
  host: {
    port: parseInt(process.env.PORT ?? 5000),
    token: process.env.RELOAD_TOKEN ?? "",
  },
};

function filterKeysWithPrefix(object, prefix) {
  const filtered = {};
  for (const [key, value] of Object.entries(object)) {
    if (key.startsWith(prefix)) {
      filtered[key] = value;
    }
  }
  return filtered;
}

(async function main() {
  const configurationFilePath = await prepareConfiguration(configuration.ldf);
  const ldfProcess = startLinkedDataFragmentServer(
    configurationFilePath,
    configuration.ldf.port,
    configuration.ldf.workers,
  );
  startHttpServer(ldfProcess);
})();

async function prepareConfiguration(ldf) {
  console.log("Preparing configuration.");
  // We can do sync operation here.
  const sourcePath = __dirname + "/configuration.template.json";
  const template = JSON.parse(fileSystem.readFileSync(sourcePath, "utf8"));
  // Update
  const instance = replaceTemplates(template, ldf.config);
  console.log(instance);
  // Write
  const targetPath = __dirname + "/configuration.json";
  fileSystem.writeFileSync(
    targetPath,
    JSON.stringify(instance, null, 2),
    { encoding: "utf8" },
  );
  return targetPath;
}

function replaceTemplates(value, replacements) {
  if (value == null || undefined) {
    return value;
  } else if (Array.isArray(value)) {
    return value.map(item => replaceTemplates(item, replacements));
  } else if (typeof value === 'object') {
    const result = {};
    for (const [key, keyValue] of Object.entries(value)) {
      result[key] = replaceTemplates(keyValue, replacements);
    }
    return result;
  } else if (typeof value === 'string') {
    let result = value;
    // Replace all occurrences of {KEY} with corresponding values
    for (const [key, value] of Object.entries(replacements)) {
      const pattern = new RegExp(`\\{${key}\\}`, "g");
      result = result.replace(pattern, value);
    }
    return result;
  } else {
    // Other primitive values.
    return value;
  }
}

function startLinkedDataFragmentServer(
  configurationFilePath, port, workerCount,
) {
  console.log("Starting LDF server");
  const ldfProcess = spawn("node", [
    "./node_modules/@ldf/server/bin/ldf-server",
    configurationFilePath,
    port,
    workerCount,
  ], {
    cwd: __dirname,
  });

  ldfProcess.stdout.on("data", (data) => {
    console.log(`ldf:stdout: ${data.toString().trim()}`);
  });

  ldfProcess.stderr.on("data", (data) => {
    console.error(`ldf:stderr: ${data.toString().trim()}`);
  });

  ldfProcess.on("close", (code) => {
    console.log(`ldf:child process exited with code '${code}', terminating main.`);
    process.exit(code);
  });

  return ldfProcess;
};

function startHttpServer(ldfProcess) {
  const app = express();

  app.post("/reload", (req, res) => {
    const token = req.query.token ?? "";
    if (token !== configuration.host.token) {
      const unauthorized_code = 401;
      res.status(unauthorized_code).send();
      return;
    }
    console.log("Sending SIGHUP to ldf");
    ldfProcess.kill("SIGHUP");
    res.send();
  });

  app.listen(configuration.host.port, () => {
    console.log(`Control HTTP server listening on port ${configuration.host.port}.`)
  });

}
