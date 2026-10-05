/**
 * Cloudflare Worker for revision.altrusian.com (Revision)
 * Serves static assets, processes telemetry into TELEMETRY_KV,
 * and hosts the /jai Live Talent & Ecosystem Watch Command Center.
 */

import { JAI_DASHBOARD_HTML } from './dashboard_html';
import { processTelemetry, getFeedData, KVNamespaceLike } from './telemetry/engine';

interface Env {
  ASSETS: {
    fetch: (request: Request) => Promise<Response>;
  };
  TELEMETRY_KV?: KVNamespaceLike;
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

    // Secret Door: Jai Analytics & Talent Command Center
    if (url.pathname === '/jai' || url.pathname === '/jai/') {
      return new Response(JAI_DASHBOARD_HTML, {
        status: 200,
        headers: {
          'Content-Type': 'text/html; charset=utf-8',
          'Cache-Control': 'no-cache, no-store, must-revalidate',
        },
      });
    }

    // API feed for /jai dashboard
    if (url.pathname === '/api/jai/feed') {
      const feed = await getFeedData(env.TELEMETRY_KV);
      return new Response(JSON.stringify(feed), {
        status: 200,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
          'Cache-Control': 'no-cache',
        },
      });
    }

    // Export endpoint for candidate roster
    if (url.pathname === '/api/jai/export') {
      const feed = await getFeedData(env.TELEMETRY_KV);
      const candidates = feed.candidates || [];
      return new Response(JSON.stringify(candidates, null, 2), {
        status: 200,
        headers: {
          'Content-Type': 'application/json',
          'Content-Disposition': 'attachment; filename="scouted_candidates.json"',
          'Access-Control-Allow-Origin': '*',
        },
      });
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
          const ip = request.headers.get('cf-connecting-ip') || '';
          const city = request.headers.get('cf-ipcity') || '';
          const country = request.headers.get('cf-ipcountry') || '';

          // Log for wrangler tail stream
          console.log('[STUDENT_TELEMETRY]', JSON.stringify({
            ip,
            country,
            city,
            timestamp: Date.now(),
            ...payload,
          }));

          // Process into Edge KV
          if (env.TELEMETRY_KV) {
            await processTelemetry(env.TELEMETRY_KV, payload, ip, city, country);
          }

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
