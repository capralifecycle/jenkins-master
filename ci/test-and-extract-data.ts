import {
  createNetwork,
  createTestExecutor,
  curl,
  startContainer,
  TestExecutor,
  waitForHttpOk,
} from "@capraconsulting/cals-cli"
import { execa } from "execa"
import * as fs from "fs"

type ThenArg<T> = T extends PromiseLike<infer U> ? U : T

// TODO: Export in cals-cli.
type Container = ThenArg<ReturnType<typeof startContainer>>

/*
async function getExpectedVersion() {
  return (await fs.promises.readFile("Dockerfile", "utf-8"))
    .split("\n")
    .filter((it) => it.includes("ARG NEXUS_VERSION="))[0]
    .replace(/.*=([^\s]+)$/, "$1")
}
*/

// TODO: Consider moving to cals-cli.
async function dockerExecGetStdout({
  executor,
  service,
  args,
}: {
  executor: TestExecutor
  service: Container
  args: string[]
}): Promise<string> {
  executor.checkCanContinue()
  const process = execa("docker", ["exec", "-i", service.id, ...args])

  // TODO: Pipe stderr to process.stderr

  const result = await process
  return result.stdout
}

async function main(executor: TestExecutor) {
  if (process.argv.length !== 3) {
    throw new Error(`Syntax: ${process.argv[0]} ${process.argv[1]} <image-id>`)
  }

  const imageId = process.argv[2]
  const network = await createNetwork(executor)

  const service = await startContainer({
    executor,
    network,
    imageId,
    alias: "service",
  })

  await waitForHttpOk({
    container: service,
    url: "service:8080/login",
  })

  const adminPassword = await dockerExecGetStdout({
    executor,
    service,
    args: ["cat", "/var/jenkins_home/secrets/initialAdminPassword"],
  })

  const pluginsOutput = await curl(
    executor,
    network,
    "-fsS",
    "-u",
    `admin:${adminPassword}`,
    "service:8080/pluginManager/api/xml?depth=1&xpath=/*/*/shortName|/*/*/version&wrapper=plugins",
  )

  const plugins = pluginsOutput
    .replace(
      /.*?<shortName>([\w-]+).*?<version>([^<]+)()(<\/\w+>)+/g,
      "$1:$2\n",
    )
    .split("\n")
    .filter((it) => it !== "")
    .sort()

  if (!plugins.some((it) => it.includes("blueocean"))) {
    console.log(plugins)
    throw new Error("Failed to extract plugin list - see log output")
  }

  fs.writeFileSync(
    "plugin-history/plugin-list-build.txt",
    plugins.join("\n") + "\n",
    "utf-8",
  )
  console.log("Plugins extracted")

  // Extract the version and store as a file
  console.log("Extracting version")

  const apiOutput = await curl(
    executor,
    network,
    "-fsS",
    "-i",
    "-u",
    `admin:${adminPassword}`,
    "service:8080/api/",
  )

  const version = apiOutput
    .split("\n")
    .filter((it) => it.startsWith("X-Jenkins"))[0]
    .trim()
    .split(" ")[1]

  if (!version) {
    throw new Error("Failed to extract version")
  }

  const lastVersionText =
    "This is the last built version and is kept\n" +
    "automatically updated when building in Jenkins.\n" +
    "\n" +
    `Version: ${version}\n`

  fs.writeFileSync("last-version.txt", lastVersionText, "utf-8")
}

createTestExecutor().runWithCleanupTasks(main)
