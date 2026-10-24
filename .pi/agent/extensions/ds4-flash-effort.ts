/**
 * ds4-flash-effort - per-request reasoning effort for one physical model.
 *
 * Registers `router/ds4-flash-effort`, a virtual model that always dispatches to
 * openrouter/@preset/ds4-flash and varies ONLY the thinking level per request:
 *
 * - user request            -> high   (new ask, new decisions)
 * - retry                   -> high   (something broke; do not lower effort)
 * - continuation, tool error -> high   (the plan's premise just broke)
 * - continuation, edit/write -> high   (micro-decisions at insert points)
 * - continuation, read/grep/ -> low    (plumbing)
 * - direct (compaction)     -> low    (extraction, not reasoning)
 *
 * The selection stays `router/ds4-flash-effort` for the whole session, so nothing
 * touches /model. Each assistant message records the physical model and the level
 * that actually answered, and the footer shows both:
 *
 *     ds4-flash-effort • high -> ds4-flash • low
 *
 * The preset is baked in: change PHYSICAL (and the id/name below) to retarget.
 * Levels are clamped to what the physical model actually supports, so a preset
 * without `max` degrades instead of silently jumping up a level.
 *
 * Load: placed in ~/.pi/agent/extensions/, or try it with
 *   pi -e ~/.pi/agent/extensions/ds4-flash-effort.ts --model router/ds4-flash-effort
 */

import { clampThinkingLevel } from "@earendil-works/pi-ai";
import type { ModelThinkingLevel } from "@earendil-works/pi-ai";
import type {
	ExtensionAPI,
	ExtensionContext,
	ModelRouteRequest,
} from "@earendil-works/pi-coding-agent";

/** The physical model every request is dispatched to. Keep the virtual id in sync. */
const PHYSICAL = { provider: "openrouter", id: "@preset/ds4-flash" } as const;

/** Limits of the physical model, shown before the first response answers them. */
const CONTEXT_WINDOW = 1_048_576;
const MAX_TOKENS = 943_718;

/** Tools whose successful result means the model is making a choice, not fetching one. */
const DECISION_TOOLS = new Set(["edit", "write"]);

function lastToolResult(messages: ModelRouteRequest["messages"]) {
	for (let i = messages.length - 1; i >= 0; i--) {
		const message = messages[i];
		if (message?.role === "toolResult") return message;
	}
	return undefined;
}

/** The level we want, before clamping to what the physical model supports. */
function desiredLevel(request: ModelRouteRequest): ModelThinkingLevel {
	// Compaction and other out-of-band calls: extraction work, not reasoning.
	if (request.reason === "direct") return "low";

	// A retry is not the moment to think less.
	if (request.reason === "retry") return "high";

	// The user asked something: this is where effort pays for itself.
	if (request.reason === "user") return "high";

	// Continuation: the previous tool round is what tells us whether to think.
	const last = lastToolResult(request.messages);
	if (!last) return "high";
	if (last.isError) return "high";
	if (DECISION_TOOLS.has(last.toolName)) return "high";
	return "low";
}

export default function (pi: ExtensionAPI) {
	pi.registerVirtualModel({
		provider: "router",
		id: "ds4-flash-effort",
		name: "DS4 Flash (adaptive effort)",
		// Only what @preset/ds4-flash supports: its thinkingLevelMap maps
		// minimal/medium/xhigh to null. Update this if PHYSICAL changes.
		thinkingLevels: ["off", "low", "high", "max"],
		contextWindow: CONTEXT_WINDOW,
		maxTokens: MAX_TOKENS,
		route(request: ModelRouteRequest, ctx: ExtensionContext) {
			const model = ctx.modelRegistry.find(PHYSICAL.provider, PHYSICAL.id);
			if (!model) {
				throw new Error(
					`${PHYSICAL.provider}/${PHYSICAL.id} is not in the catalog. ` +
						"Fix PHYSICAL in ds4-flash-effort.ts or check that the provider is logged in.",
				);
			}
			return { model, thinkingLevel: clampThinkingLevel(model, desiredLevel(request)) };
		},
	});
}
