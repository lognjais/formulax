/**
 * Cloudflare Worker for revision.altrusian.com (Revision)
 */

interface Env {
  ASSETS: {
    fetch: (request: Request) => Promise<Response>;
  };
}

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const url = new URL(request.url);

    // Enforce HTTPS redirect
    const proto = request.headers.get('x-forwarded-proto');
    const cfVisitor = request.headers.get('cf-visitor');
    const isHttp = url.protocol === 'http:' || proto === 'http' || (cfVisitor && cfVisitor.includes('"scheme":"http"'));
    if (isHttp) {
      url.protocol = 'https:';
      return Response.redirect(url.toString(), 301);
    }

    // Health check endpoint
    if (url.pathname === '/healthz') {
      return new Response('OK', { status: 200 });
    }

    // First-party talent mastery telemetry endpoint
    if (url.pathname === '/api/telemetry') {
      if (request.method === 'OPTIONS') {
        return new Response(null, {
          status: 204,
          headers: {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'POST, OPTIONS',
            'Access-Control-Allow-Headers': 'Content-Type',
          },
        });
      }
      if (request.method === 'POST') {
        try {
          const payload = await request.json();
          console.log('[STUDENT_TELEMETRY]', JSON.stringify({
            ip: request.headers.get('cf-connecting-ip'),
            country: request.headers.get('cf-ipcountry'),
            city: request.headers.get('cf-ipcity'),
            timestamp: Date.now(),
            ...payload,
          }));
          return new Response(JSON.stringify({ status: 'ok' }), {
            status: 200,
            headers: {
              'Content-Type': 'application/json',
              'Access-Control-Allow-Origin': '*',
            },
          });
        } catch {
          return new Response(JSON.stringify({ error: 'invalid payload' }), { status: 400 });
        }
      }
    }

    const response = await env.ASSETS.fetch(request);
    const headers = new Headers(response.headers);

    // Security & HTTPS HSTS headers
    headers.set('Strict-Transport-Security', 'max-age=31536000; includeSubDomains; preload');
    headers.set('X-Content-Type-Options', 'nosniff');
    headers.set('X-Frame-Options', 'DENY');

    // Caching headers for static data and assets
    if (
      url.pathname.startsWith('/data/') ||
      url.pathname.startsWith('/assets/')
    ) {
      headers.set('Cache-Control', 'public, max-age=31536000, immutable');
    }

    return new Response(response.body, {
      status: response.status,
      statusText: response.statusText,
      headers,
    });
  },
};
