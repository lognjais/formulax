/**
 * Cloudflare Worker for revision.altrusian.com (Sutra)
 */

interface Env {
  ASSETS: {
    fetch: (request: Request) => Promise<Response>;
  };
}

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const url = new URL(request.url);

    // Health check endpoint
    if (url.pathname === '/healthz') {
      return new Response('OK', { status: 200 });
    }

    const response = await env.ASSETS.fetch(request);

    // Caching headers for static data and assets
    if (
      url.pathname.startsWith('/data/') ||
      url.pathname.startsWith('/assets/')
    ) {
      const headers = new Headers(response.headers);
      headers.set('Cache-Control', 'public, max-age=31536000, immutable');
      return new Response(response.body, {
        status: response.status,
        statusText: response.statusText,
        headers,
      });
    }

    return response;
  },
};
