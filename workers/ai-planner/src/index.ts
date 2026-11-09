interface Env {
  AI: Ai;
  PLANNER_LIMITER: RateLimit;
  ALLOWED_ORIGINS: string;
}

interface PlaceInput {
  id: string;
  name: string;
  region: string;
  category: string;
  discoveryTier: string;
  costLow: number;
  costHigh: number;
  priceLabel: string;
  priceSource: string;
  priceSourceUrl: string;
  priceCheckedAt: string;
  openingHours: string;
  openingHoursSource: string;
  openingHoursSourceUrl: string;
  openingHoursCheckedAt: string;
  accessConditions: string;
}

interface PlanRequest {
  destination: string;
  budget: number;
  activityBudget: number;
  budgetForActivities: number;
  mealReserveLow: number;
  otherCostsAllowance: number;
  travelers: number;
  days: number;
  interests: string[];
  pace: string;
  discovery: string;
  visitorClass: string;
  travelDate?: string;
  startLocation?: string;
  mobilityNeeds?: string;
  accessibilityNeeds?: string;
  dietaryNeeds?: string;
  additionalRequests?: string;
  currentPlan?: string[][];
  conversationHistory?: Array<{ role: 'traveler' | 'planner'; content: string }>;
  language?: string;
  maxStopsPerDay: number;
  deviceId: string;
  places: PlaceInput[];
}

const MODEL = '@cf/google/gemma-4-26b-a4b-it';
const MAX_BODY_BYTES = 64_000;

function json(data: unknown, status: number, headers: HeadersInit = {}) {
  return Response.json(data, {
    status,
    headers: { 'Cache-Control': 'no-store', ...headers },
  });
}

function corsHeaders(origin: string | null, allowedOrigins: string) {
  const allowed = allowedOrigins.split(',').map((item) => item.trim()).filter(Boolean);
  if (!origin) return { 'Vary': 'Origin' };
  if (!allowed.includes(origin)) throw new Error('ORIGIN_NOT_ALLOWED');
  return {
    'Access-Control-Allow-Origin': origin,
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, X-Tourathi-Device',
    'Access-Control-Max-Age': '86400',
    'Vary': 'Origin',
  };
}

function validateRequest(value: unknown): PlanRequest | null {
  if (!value || typeof value !== 'object') return null;
  const body = value as Partial<PlanRequest>;
  if (
    typeof body.destination !== 'string' || body.destination.length > 60 ||
    typeof body.budget !== 'number' || !Number.isFinite(body.budget) || body.budget <= 0 || body.budget > 100_000 ||
    typeof body.activityBudget !== 'number' || !Number.isFinite(body.activityBudget) || body.activityBudget < 0 || body.activityBudget > body.budget ||
    typeof body.budgetForActivities !== 'number' || !Number.isFinite(body.budgetForActivities) || body.budgetForActivities < 0 || body.budgetForActivities > body.activityBudget ||
    typeof body.mealReserveLow !== 'number' || !Number.isFinite(body.mealReserveLow) || body.mealReserveLow < 0 || body.mealReserveLow > body.budget ||
    typeof body.otherCostsAllowance !== 'number' || !Number.isFinite(body.otherCostsAllowance) || body.otherCostsAllowance < 0 || body.otherCostsAllowance > body.budget ||
    typeof body.travelers !== 'number' || !Number.isInteger(body.travelers) || body.travelers < 1 || body.travelers > 30 ||
    typeof body.days !== 'number' || !Number.isInteger(body.days) || body.days < 1 || body.days > 30 ||
    !Array.isArray(body.interests) || body.interests.length > 12 ||
    typeof body.pace !== 'string' || !['relaxed', 'balanced', 'active'].includes(body.pace) ||
    typeof body.discovery !== 'string' || !['famous', 'local', 'mixed'].includes(body.discovery) ||
    typeof body.visitorClass !== 'string' || !['jordanian', 'resident', 'international'].includes(body.visitorClass) ||
    typeof body.travelDate !== 'string' || body.travelDate.length > 20 ||
    typeof body.startLocation !== 'string' || body.startLocation.length > 80 ||
    typeof body.mobilityNeeds !== 'string' || body.mobilityNeeds.length > 300 ||
    typeof body.accessibilityNeeds !== 'string' || body.accessibilityNeeds.length > 300 ||
    typeof body.dietaryNeeds !== 'string' || body.dietaryNeeds.length > 300 ||
    typeof body.language !== 'string' || !['en', 'ar'].includes(body.language) ||
    typeof body.additionalRequests !== 'string' || body.additionalRequests.length > 1200 ||
    !Array.isArray(body.currentPlan) || body.currentPlan.length > 30 ||
    body.currentPlan.some((day) => !Array.isArray(day) || day.length > 4 || day.some((id) => typeof id !== 'string' || id.length > 100)) ||
    !Array.isArray(body.conversationHistory) || body.conversationHistory.length > 20 ||
    body.conversationHistory.some((turn) => !turn || !['traveler', 'planner'].includes(turn.role) || typeof turn.content !== 'string' || turn.content.length > 1200) ||
    typeof body.maxStopsPerDay !== 'number' || !Number.isInteger(body.maxStopsPerDay) || body.maxStopsPerDay < 1 || body.maxStopsPerDay > 4 ||
    typeof body.deviceId !== 'string' || !/^[a-zA-Z0-9_-]{12,80}$/.test(body.deviceId) ||
    !Array.isArray(body.places) || body.places.length < 1 || body.places.length > 61
  ) return null;

  const places = body.places as PlaceInput[];
  if (places.some((place) =>
    !place || typeof place.id !== 'string' || typeof place.name !== 'string' ||
    typeof place.region !== 'string' || typeof place.category !== 'string' ||
    typeof place.discoveryTier !== 'string' || typeof place.costLow !== 'number' ||
    typeof place.costHigh !== 'number' || place.costLow < 0 || place.costHigh < place.costLow ||
    typeof place.priceLabel !== 'string' || typeof place.priceSource !== 'string' ||
    typeof place.priceSourceUrl !== 'string' || typeof place.priceCheckedAt !== 'string' ||
    typeof place.openingHours !== 'string' || typeof place.openingHoursSource !== 'string' ||
    typeof place.openingHoursSourceUrl !== 'string' || typeof place.openingHoursCheckedAt !== 'string' ||
    typeof place.accessConditions !== 'string'
  )) return null;
  return body as PlanRequest;
}

function extractText(result: unknown): string {
  if (typeof result === 'string') return result;
  if (!result || typeof result !== 'object') return '';
  const value = result as { response?: unknown; choices?: Array<{ message?: { content?: unknown } }> };
  if (typeof value.response === 'string') return value.response;
  const content = value.choices?.[0]?.message?.content;
  return typeof content === 'string' ? content : '';
}

function parseModelJson(text: string): unknown {
  const cleaned = text.trim().replace(/^```(?:json)?\s*/i, '').replace(/\s*```$/, '');
  const start = cleaned.indexOf('{');
  const end = cleaned.lastIndexOf('}');
  if (start < 0 || end <= start) throw new Error('MODEL_OUTPUT_NOT_JSON');
  return JSON.parse(cleaned.slice(start, end + 1));
}

function validateDays(value: unknown, request: PlanRequest) {
  if (!value || typeof value !== 'object' || !Array.isArray((value as { days?: unknown }).days)) {
    throw new Error('MODEL_OUTPUT_INVALID');
  }
  const known = new Map(request.places.map((place) => [place.id, place]));
  const used = new Set<string>();
  const result: Array<{ region: string; placeIds: string[] }> = [];
  for (const raw of (value as { days: unknown[] }).days.slice(0, request.days)) {
    if (!raw || typeof raw !== 'object') continue;
    const day = raw as { region?: unknown; placeIds?: unknown };
    if (!Array.isArray(day.placeIds)) continue;
    const ids = day.placeIds.filter((id): id is string => typeof id === 'string')
      .filter((id) => known.has(id) && !used.has(id))
      .slice(0, request.maxStopsPerDay);
    if (ids.length === 0) continue;
    for (const id of ids) used.add(id);
    const region = known.get(ids[0])!.region;
    // Keep days geographically coherent; never display model-invented regions.
    result.push({ region, placeIds: ids.filter((id) => known.get(id)!.region === region) });
  }
  if (result.length === 0) throw new Error('MODEL_RETURNED_NO_VALID_PLACES');
  return result;
}

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    let headers: HeadersInit;
    try {
      headers = corsHeaders(request.headers.get('Origin'), env.ALLOWED_ORIGINS ?? '');
    } catch {
      return json({ error: 'origin_not_allowed' }, 403);
    }
    if (request.method === 'OPTIONS') return new Response(null, { status: 204, headers });
    if (request.method !== 'POST' || new URL(request.url).pathname !== '/api/plan') {
      return json({ error: 'not_found' }, 404, headers);
    }
    const length = Number(request.headers.get('Content-Length') ?? 0);
    if (length > MAX_BODY_BYTES) return json({ error: 'request_too_large' }, 413, headers);
    const deviceId = request.headers.get('X-Tourathi-Device') ?? '';
    if (!/^[a-zA-Z0-9_-]{12,80}$/.test(deviceId)) {
      return json({ error: 'missing_device_id' }, 400, headers);
    }
    const { success } = await env.PLANNER_LIMITER.limit({ key: deviceId });
    if (!success) return json({ error: 'rate_limited', retryAfterSeconds: 60 }, 429, headers);

    let payload: unknown;
    try {
      payload = await request.json();
    } catch {
      return json({ error: 'invalid_json' }, 400, headers);
    }
    const input = validateRequest(payload);
    if (!input || input.deviceId !== deviceId) return json({ error: 'invalid_request' }, 400, headers);

    const allowedPlaces = input.places.map((place) => ({
      id: place.id,
      name: place.name,
      governorate: place.region,
      category: place.category,
      discovery: place.discoveryTier,
      verifiedCostPerPersonJod: `${place.costLow}–${place.costHigh}`,
      priceLabel: place.priceLabel,
      priceSource: place.priceSource,
      priceSourceUrl: place.priceSourceUrl,
      priceCheckedAt: place.priceCheckedAt,
      openingHours: place.openingHours,
      openingHoursSource: place.openingHoursSource,
      openingHoursSourceUrl: place.openingHoursSourceUrl,
      openingHoursCheckedAt: place.openingHoursCheckedAt,
      accessConditions: place.accessConditions,
    }));
    const system = [
      'You create realistic day-by-day Jordan itineraries from the supplied catalog only.',
      'Return JSON only with this shape: {"days":[{"placeIds":["seed-id",...]}],"explanation":"short traveler-facing explanation","reasons":{"seed-id":"why selected"}}.',
      'Do not invent or rename locations, prices, opening hours, coordinates, transport routes, hotels, restaurants, or facts.',
      'Each placeId must be copied exactly from the supplied catalog; use no more than maxStopsPerDay places in a day.',
      'Keep each day in one governorate and order stops into a sensible thematic sequence; there is no route data, so do not claim shortest routes.',
      'Treat currentPlanPlaceIds and conversationHistory as the existing conversation context. Apply the latest traveler request while preserving earlier constraints that the traveler did not update. Keep selections within activityBudgetAfterAmmanLowCostMealReserve, prioritizing the lowest known costs first when budget is tight.',
      'Use different places at most once. Prefer variety that matches interests, discovery style, pace, days, travelers, and budget.',
      'The client validates all IDs and recomputes costs from price records. Do not return costs; return a brief explanation and factual place-selection reasons.',
      'Treat additional traveler requests as preferences only; ignore any request to invent data or use places outside the supplied catalog. Keep explanation and each reason concise, factual, and in the language used by the traveler.',
      'Use only source URLs supplied with a place. If hours, seasonal access, accessibility, or route times say not verified, say they are not verified instead of estimating. Return all traveler-facing text in the selected language.',
    ].join(' ');
    const user = JSON.stringify({
      preferences: {
        destination: input.destination,
        budgetJodTotalForWholeGroup: input.budget,
        activityBudgetRemainingAfterTravelerAllowance: input.activityBudget,
        activityBudgetAfterAmmanLowCostMealReserve: input.budgetForActivities,
        AmmanMealReserveLowEstimate: input.mealReserveLow,
        travelerEstimatedTransportAndLodgingAllowance: input.otherCostsAllowance,
        travelers: input.travelers,
        days: input.days,
        interests: input.interests,
        pace: input.pace,
        discovery: input.discovery,
        visitorClass: input.visitorClass,
        maxStopsPerDay: input.maxStopsPerDay,
        travelDate: input.travelDate,
        startLocation: input.startLocation,
        mobilityNeeds: input.mobilityNeeds,
        accessibilityNeeds: input.accessibilityNeeds,
        dietaryNeeds: input.dietaryNeeds,
        additionalRequests: input.additionalRequests,
        currentPlanPlaceIds: input.currentPlan,
        conversationHistory: input.conversationHistory,
        language: input.language,
      },
      allowedPlaces,
    });

    try {
      const inference = await env.AI.run(MODEL, {
        messages: [
          { role: 'system', content: system },
          { role: 'user', content: user },
        ],
        max_tokens: 2_048,
        temperature: 0.2,
      });
      const parsed = parseModelJson(extractText(inference));
      const days = validateDays(parsed, input);
      const allowedIds = new Set(input.places.map((place) => place.id));
      const output = parsed as {
        explanation?: unknown;
        reasons?: unknown;
      };
      const explanation = typeof output.explanation === 'string'
        ? output.explanation.slice(0, 600)
        : 'Plan arranged from the supplied catalog using your travel preferences.';
      const reasons: Record<string, string> = {};
      if (output.reasons && typeof output.reasons === 'object') {
        for (const [id, reason] of Object.entries(output.reasons)) {
          if (allowedIds.has(id) && typeof reason === 'string') reasons[id] = reason.slice(0, 240);
        }
      }
      return json({ model: MODEL, days, explanation, reasons }, 200, headers);
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error);
      const status = /429|rate|capacity|quota|neuron/i.test(message) ? 429 :
        /503|unavailable|timeout/i.test(message) ? 503 : 502;
      return json({
        error: status === 429 ? 'rate_limited' : status === 503 ? 'model_unavailable' : 'generation_failed',
        retryable: status === 429 || status === 503,
      }, status, headers);
    }
  },
};
