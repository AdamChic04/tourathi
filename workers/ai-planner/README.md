# Tourathi AI Planner Worker

This Worker keeps model calls outside the Flutter client. The mobile app sends traveler preferences, a bounded conversation transcript, the current itinerary IDs, and only price/catalog metadata already included in the app. Do not put Cloudflare credentials or provider secrets in Flutter or source control.

## Deploy

1. Install Node.js, then from this directory run `npx wrangler login` and complete Cloudflare's sign-in in the browser.
2. Set `ALLOWED_ORIGINS` in `wrangler.toml` to the exact HTTPS origin of the deployed web app. Keep localhost origins only for development.
3. Run `npx wrangler deploy` to publish `tourathi-ai-planner`.
4. Build/run Flutter with the deployed route:

   ```powershell
   flutter run --dart-define=AI_PLANNER_API_URL=https://tourathi-ai-planner.<your-subdomain>.workers.dev/api/plan
   ```

   For Android, use the HTTPS Worker URL reachable from the device, not `localhost`. The public Worker URL is configuration, not a secret.

Without `AI_PLANNER_API_URL`, the planner uses its on-device, catalog-constrained fallback. Chat edits require the live Worker and will leave the current plan unchanged if the service is unavailable.

## Free-tier and model notes (checked 2026-11-07)

- Model: `@cf/google/gemma-4-26b-a4b-it` through the Workers AI binding.
- Cloudflare Workers AI Free allocation: 10,000 Neurons/day, reset at 00:00 UTC. On Workers Paid, usage beyond that allowance is billed at $0.011 per 1,000 Neurons. It is not unlimited.
- Workers Free includes 100,000 requests/day. This Worker also applies a best-effort 8 requests/minute per installation rate limit.
- Current model availability and pricing: https://developers.cloudflare.com/workers-ai/platform/pricing/ and https://developers.cloudflare.com/changelog/post/2026-07-28-models-require-workers-paid/
- Workers AI data use: https://developers.cloudflare.com/workers-ai/platform/data-usage/

## Travel data limits

The app sends only places with a source-backed, checked price to the model. Each saved estimate records its source URL and check date. Petra's seasonal opening hours come from the Petra Authority's published schedule; other hours and live closures are marked unverified. The place seed has no geocoordinates or route graph, so the Worker must not claim drive durations or shortest routes. There is no connected live closure, traffic, public-transit, hotel, or accessibility feed in this repository. Confirm these details with official venues/providers before booking.

The AI output is schema-checked against supplied catalog IDs and the client rechecks cost against the source-backed price catalog. Treat output as planning assistance, not a booking or accessibility guarantee.
