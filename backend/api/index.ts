import type { Express } from 'express';
import type { IncomingMessage, ServerResponse } from 'http';
import { createNestApp } from '../src/bootstrap';

let cachedServer: Express | undefined;

async function getServer() {
  if (!cachedServer) {
    const app = await createNestApp();
    await app.init();
    cachedServer = app.getHttpAdapter().getInstance() as Express;
  }

  return cachedServer;
}

export default async function handler(
  request: IncomingMessage,
  response: ServerResponse,
) {
  const server = await getServer();
  return server(request, response);
}
