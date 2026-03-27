# qdexcode-desktop

Flutter desktop app (macOS) for the qdexcode code intelligence platform. Standalone native app with filesystem access, git integration, terminal, and full UI.

## Architecture

- **Framework:** Flutter 3.x with Riverpod 3 (codegen) for state management
- **Backend:** qdexcode-cloud (Next.js on Cloudflare Workers) — all API calls go through `https://v2.chrisdrury.com`
- **Auth:** GitHub OAuth device flow (RFC 8628) — NOT cookie-based sessions
- **Database:** Postgres V2 (`qdexcode_v2`) on VPS, accessed via Cloudflare Hyperdrive + Access tunnel
- **Realtime:** WebSocket to pg-bridge via `wss://pg-bridge.chrisdrury.com/ws`
- **Models:** Freezed + json_serializable for immutable data classes

## Key Patterns

### API Response Format

The qdexcode-cloud API returns **camelCase** JSON keys (Drizzle ORM default). Flutter models must match — do NOT use `@JsonKey(name: 'snake_case')` annotations. The `Project` model, for example, uses `organizationId` not `organization_id`.

### Authentication

- Desktop app uses **Bearer token** auth, NOT cookies
- Token stored in macOS Keychain via `flutter_secure_storage` (requires Keychain Sharing entitlement in Xcode)
- `FlutterSecureStorage` must use `MacOsOptions(useDataProtectionKeyChain: true)`
- Session validation uses `GET /api/auth/me` (supports Bearer), NOT `/api/auth/session` (cookie-only)
- The qdexcode-cloud Next.js middleware passes Bearer token requests through without redirect

### Dio HTTP Client

- Responses from list endpoints may come as `String` (HTML redirect) if auth fails
- Always use `dio.get<dynamic>()` and check `raw is List` before casting — never use `dio.get<List<dynamic>>()` directly
- The `apiClientProvider` interceptor reads the Bearer token from secure storage on every request

### macOS Entitlements

Both `DebugProfile.entitlements` and `Release.entitlements` need:
- `com.apple.security.app-sandbox` — required for App Store
- `com.apple.security.network.client` — outgoing HTTP/WebSocket
- `com.apple.security.network.server` — incoming (for terminal PTY)
- `keychain-access-groups` — required for `flutter_secure_storage` (needs Xcode code signing)

### Code Generation

After modifying any `@freezed` or `@riverpod` annotated class:
```
dart run build_runner build --delete-conflicting-outputs
```

### MCP Servers Available

Two MCP servers are relevant when working on this project:

- **dart-mcp-server** — Connects to Dart/Flutter dev tools and running apps. Can analyze code, format, fix, manage packages, list devices, launch/stop apps, hot reload/restart, get app logs, runtime errors, widget tree, and run tests. Prefer this over raw shell commands for Dart/Flutter tooling.
- **qdexcode-devtools** — Embedded MCP server in the app itself (debug mode only, localhost:9731). Provides live app state inspection, screenshots, navigation control, and provider management. See the "Embedded Dev MCP Server" section below for full details.

## Project Structure

```
lib/
├── app.dart                    # Root app widget with splash screen
├── main.dart                   # Entry point with error handler init
├── core/
│   ├── api/api_client.dart     # Dio instance with Bearer token interceptor
│   ├── auth/                   # OAuth device flow, auth provider, login page
│   ├── error/                  # Crash logger, error handler, error widget
│   ├── models/                 # Freezed data models (Project, User, etc.)
│   ├── realtime/               # WebSocket connection, events, connection badge
│   ├── router/app_router.dart  # GoRouter with auth redirects + onboarding
│   ├── state/                  # Window state persistence
│   ├── theme/                  # App theme + theme toggle provider
│   └── widgets/                # Splash screen, context menu components
├── features/
│   ├── dashboard/              # Stats cards, charts (fl_chart), indexing progress
│   ├── file_tree/              # Lazy-loading file tree with FS watcher
│   ├── git/                    # Git status panel (git CLI via dart:io)
│   ├── onboarding/             # First-launch 3-step onboarding flow
│   ├── plans/                  # Plan explorer with phase tree + task detail
│   ├── projects/               # Project selector, add project dialog, GitHub repo picker
│   ├── settings/               # Settings page with 5 sub-tabs
│   ├── shell/                  # 3-panel resizable layout (multi_split_view)
│   └── terminal/               # dart_pty + dart_xterm terminal tabs
```

## Related Projects

- **qdexcode-cloud** (`/Users/chrisdrury/projects/qdexcode-cloud`) — Next.js backend on Cloudflare Workers
  - Project ID: `7a1e6975-827a-4344-8490-ec258cdaf3bc`
  - API endpoints the desktop app calls: `/api/auth/me`, `/api/auth/device/*`, `/api/projects`, `/api/plans`, `/api/stats`, `/api/github/repos`, `/api/ws/token`
  - Middleware at `src/middleware.ts` must allow Bearer token requests through

## Infrastructure

- **VPS:** `72.61.65.4` (SSH: `root@72.61.65.4`)
- **V2 Postgres:** `qdex-postgres-v2` container on port 5433 (user: `qdexcloud`, db: `qdexcode_v2`)
- **V1 Postgres:** `qdex-postgres` container on port 5432 (user: `qdexcode`, db: `qdexcode`) — separate, do not mix
- **Hyperdrive:** ID `1e9ce6f5f359419981d7a536036acb76`, connects via Cloudflare Access tunnel to `postgres-v2.chrisdrury.com`
- **Cloudflare Tunnel:** config at `/etc/cloudflared/config.yml` on VPS — `postgres-v2.chrisdrury.com → tcp://localhost:5433`
- **Deploy cloud:** `cd qdexcode-cloud && npm -w apps/web run deploy`

## Common Issues

| Symptom | Cause | Fix |
|---|---|---|
| `type 'String' is not a subtype of type 'List<dynamic>?'` | API returned HTML (auth redirect) instead of JSON | Check middleware allows Bearer tokens; use `dio.get<dynamic>()` |
| `PlatformException -34018 entitlement` | Missing Keychain Sharing entitlement | Open Xcode, enable Keychain Sharing capability with code signing |
| `Directionality widget ancestor` | Widget rendered outside MaterialApp | Wrap with `Directionality(textDirection: TextDirection.ltr)` |
| Server 500 on `/api/projects` | Missing columns in V2 Postgres | Apply pending migrations: `ALTER TABLE project ADD COLUMN ...` |
| WebSocket retry spam | ws/token failing due to auth or missing project | Fix auth first; WebSocket connects after project selection |

## Embedded Dev MCP Server (qdexcode-devtools)

The app includes an embedded MCP server for development that gives Claude Code direct access to live app state. It starts automatically in **debug mode only** on `localhost:9731` and is auto-discovered via `.mcp.json`.

### Architecture

- Built with `dart_mcp` SDK (`FastMCP` class) + HTTP+SSE transport (copied from magnet-terminal)
- 4 gateway tools, 14 commands — gateway pattern routes `{command, args}` internally
- Provider callbacks (`ProviderContainer`, `GoRouter`, `Dio`, `BuildContext`) called fresh on every tool invocation — never cached
- All handlers return `jsonEncode({...})`, never throw — errors returned as `{error: 'message'}` in JSON body
- Null values stripped from JSON-RPC responses (required for Claude Code compatibility)
- `Future.microtask()` used for UI thread dispatch (NOT `addPostFrameCallback` — deadlocks when app is idle)

### Key Files

| File | Purpose |
|---|---|
| `lib/services/devtools_server.dart` | Lifecycle manager — start/stop, port 9731, provider callbacks |
| `lib/services/mcp/http_transport.dart` | HTTP+SSE transport (copied from magnet-terminal — do NOT rewrite) |
| `lib/services/mcp/gateway_registry.dart` | Registers 4 gateway tools with FastMCP, `GatewayCallbacks` class |
| `lib/services/mcp/gateways/inspect_gateway.dart` | Read-only state queries (5 commands) |
| `lib/services/mcp/gateways/capture_gateway.dart` | Screenshots as base64 PNG (2 commands) |
| `lib/services/mcp/gateways/action_gateway.dart` | Mutate app state (4 commands) |
| `lib/services/mcp/gateways/server_gateway.dart` | Meta/health/discovery (3 commands) |
| `lib/services/mcp/provider_map.dart` | Shared provider name → ref registry |
| `lib/services/mcp/network_log_buffer.dart` | Ring buffer (50 entries) for Dio request/response logging |
| `lib/services/mcp/network_log_interceptor.dart` | Dio interceptor that feeds NetworkLogBuffer |

### Gateway Commands

**inspect** — Read-only state inspection

| Command | Args | Returns |
|---|---|---|
| `provider_state` | `{provider: "authProvider"}` or `{list: true}` | Provider value as JSON, or list of all provider names |
| `network_log` | `{limit: 10}`, `{filter: "error"}`, `{filter: "/api/projects"}` | Recent Dio requests with method, URL, status, duration (auth headers redacted) |
| `widget_tree` | `{depth: 3}`, `{search: "ProjectSelector"}` | Clean widget hierarchy (framework internals filtered out) |
| `route_state` | `{}` | Current route, auth state, selected project |
| `panel_layout` | `{}` | Panel widths, active tab, theme, window size |

**capture** — Visual output (base64 PNG)

| Command | Args | Returns |
|---|---|---|
| `screen` | `{}` or `{scale: 0.3}` | Full app screenshot (default 0.5x resolution for token efficiency) |
| `screen_widget` | `{widget: "DashboardPage"}` or `{widget: "DashboardPage", scale: 0.3}` | Specific widget capture |

**action** — Mutate app state

| Command | Args | Returns |
|---|---|---|
| `navigate` | `{route: "/"}` | Navigate via GoRouter |
| `switch_tab` | `{tab: "terminal"}` | Switch workspace tab (dashboard/terminal/editor/settings) |
| `invalidate` | `{provider: "projectListProvider"}` or `{provider: "all"}` | Force-refresh provider(s) |
| `logout` | `{}` | Clear auth and return to login |

**server** — Meta/discovery

| Command | Args | Returns |
|---|---|---|
| `health` | `{}` | Live auth state, selected project, server status |
| `list_commands` | `{}` or `{gateway: "inspect"}` | All gateways/commands with descriptions and arg schemas |
| `status` | `{}` | Uptime, connected clients, network log stats, provider counts |

### Common Debugging Workflows

**"Why is the API call failing?"**
```
inspect(command: "network_log", args: {filter: "error"})
```

**"What's the auth state?"**
```
inspect(command: "provider_state", args: {provider: "authProvider"})
```

**"What does the app look like right now?"**
```
capture(command: "screen", args: {scale: 0.3})
```

**"Force refresh project data"**
```
action(command: "invalidate", args: {provider: "projectListProvider"})
```

### Important Notes

- The `http_transport.dart` is copied from magnet-terminal and battle-tested — do NOT rewrite it
- Captures default to 0.5x resolution to save tokens. Use `scale: 0.3` for quick checks, `scale: 1.0` for full detail
- The `CenterPanel` watches `activeTabStateProvider` (not local state) so `switch_tab` works visually
- `.mcp.json` is in `.gitignore` (localhost-specific)

## qdexcode MCP Tools

This project is indexed by **qdexcode**. Use MCP tools for code navigation:

| I need to... | Command |
|---|---|
| Understand a function before editing | `code → extract` |
| Explore a directory | `code → module_context` |
| Find where something is called | `code → callers` |
| Check what breaks if I change something | `code → what_breaks_if` |
| Search for a pattern in code | `search → grep` |
| Find files by language or path | `search → files` |
| Ask a natural-language question about code | `search → context` |
| Get project overview | `project → overview` |
