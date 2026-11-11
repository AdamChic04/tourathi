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

The app now sends **all matching destinations from the 61-place catalog**, including attractions with unknown admission prices. An unverified price is serialized as `null` with `costStatus: "unknown"` and can **never** count as zero or an affordable booking. Only published ticket/activity references contribute to the known-cost subtotal. If the chosen itinerary includes an unpriced stop, the trip's total cost remains **unknown** even when the known subtotal is below the budget.

The app reads source-attributed admission and opening-hours research from Supabase after authentication, with offline source-based references if needed. Opening hours, fees, route times and closures are not live; the five UNESCO property points are **area references**, not usable entrance pins. There is no live traffic, route graph, transit, hotel, weather, or guaranteed-access feed in this repository. Confirm details with official venues/operators.

**Important:** If this Worker was deployed before the catalog change, redeploy it (`npx wrangler deploy`) because the request schema now accepts null prices. The old deployed Worker will reject requests containing unknown prices; Flutter then uses the local planner automatically.

The AI output is schema-checked against supplied catalog IDs. The client budgets only published amounts and explicitly marks unpriced destinations. Neither the AI nor the local algorithm guarantees an overall affordable itinerary if unknown prices remain. Treat output as planning assistance, not a booking or accessibility guarantee.
