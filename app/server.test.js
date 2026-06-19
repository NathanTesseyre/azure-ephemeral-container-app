const assert = require("node:assert/strict");
const test = require("node:test");
const { buildResponse, createServer } = require("./server");

test("health endpoint reports an operational service", () => {
  assert.deepEqual(buildResponse("/health"), {
    status: 200,
    body: { status: "ok" }
  });
});

test("unknown endpoint returns 404", () => {
  assert.equal(buildResponse("/missing").status, 404);
});

test("HTTP server returns JSON", async (context) => {
  const server = createServer();
  await new Promise((resolve) => server.listen(0, "127.0.0.1", resolve));
  context.after(() => server.close());

  const address = server.address();
  const response = await fetch(`http://127.0.0.1:${address.port}/api/info`);
  const body = await response.json();

  assert.equal(response.status, 200);
  assert.equal(body.platform, "Azure Container Apps");
});

