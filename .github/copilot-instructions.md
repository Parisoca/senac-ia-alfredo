# AI Coding Agent Instructions

These project-specific guidelines help AI agents contribute productively to this Flutter (Android + Web) demo app "Grocery Guard".
Keep responses concise, change only what is needed, and prefer clarity over abstraction.

## 1. Big Picture
Local-first demo (no backend). Flow:
Home -> Capture (camera / gallery) -> Azure OpenAI (vision + chat) -> Review -> Persist locally (Hive) -> List / Select -> Recipe suggestion -> Mark items used (hidden).
No auth. All state is local Hive box `grocery_items`. LLM calls can be bypassed via demo mode.

## 2. Core Modules
- `lib/config.dart`: Central constants + demo flags + fixed demo data. NEVER scatter Azure constants elsewhere.
- `lib/models/grocery_item.dart`: Plain Hive model + manual adapter (typeId=1). Add fields by appending new @HiveField numbers (never reorder existing IDs).
- `lib/services/local_storage.dart`: Thin CRUD over Hive. Use `LocalStorageService.listenable()` for reactive UI instead of manual setState loops.
- `lib/services/azure_openai_service.dart`: All Azure chat/vision + normalization + plural/singular handling. If adding endpoints, follow `_postChat` pattern and structured error handling (`AzureApiException`). Sanitize fenced code blocks before JSON decode.
- `lib/services/logger.dart`: Central logging (`logInfo/logWarn/logError`). Use contextual `context:` tags (e.g. screen or service segment) for new logs.
- `lib/screens/*.dart`: Stateless/Stateful UI; navigation via `MaterialPageRoute`. Keep business logic minimal—delegate to services.
- `lib/demo_seed.dart`: Provides initial demo items; only used when `kDemoSafeMode` is true and storage empty.

## 3. Demo Mode Semantics
- Flag: `kDemoSafeMode` + `kDemoSafeModeNotifier` banner wrapper in `main.dart`.
- When ON: Azure calls return fixed data (`kDemoDetectedItems`, `kDemoExpiryItems`, `kDemoRecipeText`). Do not perform network requests.
- All new LLM-dependent features must also short‑circuit under demo mode with deterministic sample output.

## 4. Azure Integration Rules
- Construct URLs exactly: `https://<resource>.openai.azure.com/openai/deployments/<deployment>/chat/completions?api-version=<version>`.
- Headers: `Content-Type: application/json`, `api-key: <key>`.
- Retry logic: Already handles unsupported `max_tokens`. Follow existing pattern for new params.
- Always sanitize LLM output: strip ``` fences then parse JSON. Validate schema shape before trusting fields.

## 5. Data & Expiry Logic
- Expiry fallback: If missing, UI assumes `capturedAt + 3 days`. Keep this consistent for new views.
- Dedup/normalization relies on `_normalizeName` and singularization helpers; reuse them instead of duplicating text transforms.

## 6. UI/State Patterns
- Reactive lists: wrap relevant sections in `ValueListenableBuilder` with `LocalStorageService.listenable()`; do NOT manually hold stale copies.
- Marking items used: call `LocalStorageService.markUsed(ids)` then rely on reactive rebuild; avoid filtering in multiple places.
- Keep Portuguese user-facing strings (existing style). If adding English text, provide Brazilian Portuguese equivalent.

## 7. Adding Fields to GroceryItem
1. Append new `@HiveField(<nextIndex>)` and property.
2. Update constructor + `copyWith` + adapter `read/write` (increment the `writeByte` count).
3. Bump nothing else—do NOT change existing indices.

## 8. Logging Conventions
- Use concise messages: action + result ("Detect items parsed (n=5)").
- Error cases: convert HTTP failures to `AzureApiException` with status + code when possible.
- Avoid print() directly—always use logger helpers.

## 9. Build & Run Workflows
Typical local:
```
flutter pub get
flutter run -d chrome   # Web
flutter run -d android  # Emulator/device
```
Packaging slim APK (see README):
```
flutter build apk --release --split-per-abi --split-debug-info=build/symbols --obfuscate
```
Prefer existing VS Code tasks for builds when available.

## 10. Safe Changes Checklist (Before PR / Commit)
- Analyzer clean: `dart analyze` (expect zero warnings for new code; follow interpolation + style patterns already enforced).
- No hardcoded secrets outside `config.dart` (flag if present).
- Demo mode respected (no network when ON).
- Hive schema unchanged except additive fields.

## 11. What NOT to Introduce
- No global singletons besides existing logger/config patterns.
- No state management libraries (Provider, Riverpod, etc.)—keep it simple.
- No asynchronous side-effects inside widget `build` methods.

## 12. Extension Ideas (If Asked)
Offer behind a flag: settings screen for API key input, recipe history view, filtering used vs unused toggle (already partly present via includeUsed flag).
Do not implement unless explicitly requested.

---
If unsure about a modification, summarize the intended diff (files + rationale) before applying. Keep responses focused on THIS project’s patterns.
