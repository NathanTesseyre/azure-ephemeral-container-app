const http = require("node:http");

const port = Number(process.env.PORT || 3000);
const version = process.env.APP_VERSION || "local";

function buildResponse(pathname) {
  if (pathname === "/health") {
    return { status: 200, body: { status: "ok" } };
  }

  if (pathname === "/api/info") {
    return {
      status: 200,
      body: {
        application: "azure-ephemeral-container-app",
        version,
        platform: "Azure Container Apps"
      }
    };
  }

  if (pathname === "/") {
    return {
      status: 200,
      body: {
        message: "Hello from an ephemeral Azure deployment!",
        health: "/health",
        info: "/api/info"
      }
    };
  }

  return { status: 404, body: { error: "not_found" } };
}

function createServer() {
  return http.createServer((request, response) => {
    const pathname = new URL(request.url, "http://localhost").pathname;
    const result = buildResponse(pathname);

    response.writeHead(result.status, {
      "content-type": "application/json; charset=utf-8"
    });
    response.end(JSON.stringify(result.body));
  });
}

if (require.main === module) {
  createServer().listen(port, "0.0.0.0", () => {
    console.log(`API listening on port ${port}`);
  });
}

module.exports = { buildResponse, createServer };

