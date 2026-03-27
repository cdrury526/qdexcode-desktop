# qdexcode-desktop Agent Guide

This repository contains the Flutter desktop client for qdexcode. The parent planning project may live elsewhere, but this folder is the implementation workspace for the desktop app.

Canonical qdexcode project ID for this repo:

- `f53b41c3-3193-4eaa-b910-2bb3064f11ee`

Prefer using this project ID in qdexcode MCP calls once the repo has been synced/re-embedded, especially after commits, pushes, or workspace path changes.

Cloudflare MCP is also available in this environment and is useful for inspecting Cloudflare Workers that belong to the parent qdexcode project, even when this desktop repo is only one part of the overall system.

## Product Context

qdexcode is a native code intelligence platform. This desktop app is expected to provide:

- authenticated access to the qdexcode backend
- project and plan management UI
- realtime indexing visibility
- a desktop-oriented workspace for code intelligence workflows
- eventually, feature areas such as dashboard, projects, plans, terminal, git, editor, and file tree

The current codebase is an early scaffold with core plumbing in place and many feature folders still empty.

## Current Stack

- Flutter desktop app
- Riverpod with code generation for state and long-lived providers
- GoRouter for routing and auth-aware redirects
- Dio for HTTP APIs
- WebSocket support via `web_socket_channel`
- `flutter_secure_storage` for token persistence
- `shared_preferences` for local non-secret settings
- `freezed` + `json_serializable` for models

## Start Every Session

Use qdexcode MCP tools first.

1. `mcp__qdexcode__project(command: "overview", project: "f53b41c3-3193-4eaa-b910-2bb3064f11ee")`
2. `mcp__qdexcode__project(command: "tasks", project: "f53b41c3-3193-4eaa-b910-2bb3064f11ee")`
3. `mcp__qdexcode__code(command: "module_context", args: {module_path: "lib"}, project: "f53b41c3-3193-4eaa-b910-2bb3064f11ee")`

Before changing an existing symbol, use `extract` first. Prefer `read_file` over raw file reads for indexed source files.

If the task touches backend infrastructure that lives in Cloudflare Workers, use the Cloudflare MCP alongside qdexcode MCP rather than guessing from the desktop client alone.

Known relevant Workers currently visible through Cloudflare MCP:

- `qdexcode-cloud-mcp`
- `qdexcode-cloud-web`
- `qdexcode-indexer-orchestrator`
- `qdexcode-realtime`
- `qdexcode-webhook`

Use Cloudflare MCP for:

- listing deployed Workers and their metadata
- inspecting Worker bindings, routes, and account-side configuration
- understanding how parent-project backend services relate to this desktop client

Do not assume the desktop repo contains the full backend implementation. When a feature depends on parent-project Cloudflare infrastructure, verify it through the Cloudflare MCP.

## Repository Shape

Top-level Flutter app entry:

- `lib/main.dart` initializes Flutter bindings, global error handling, and Riverpod
- `lib/app.dart` owns app bootstrap, splash flow, and `MaterialApp.router`

Core shared infrastructure:

- `lib/core/api` contains the shared Dio client and API plumbing
- `lib/core/auth` contains auth state, device-flow auth service, and login UI
- `lib/core/error` contains crash/error handling
- `lib/core/models` contains backend-aligned models using `freezed`
- `lib/core/realtime` is reserved for websocket/realtime state
- `lib/core/router` contains GoRouter setup and auth redirects
- `lib/core/theme` contains the app theme system
- `lib/core/widgets` contains reusable cross-feature widgets

Feature areas:

- `lib/features/dashboard`
- `lib/features/projects`
- `lib/features/plans`
- `lib/features/terminal`
- `lib/features/git`
- `lib/features/editor`
- `lib/features/file_tree`

Treat `lib/core` as shared infrastructure and `lib/features/*` as product slices. New user-facing functionality should usually land in a feature folder, not in `core`, unless it is truly cross-cutting.

## Architecture Rules

Follow these rules when extending the app:

1. Keep routing, state, services, and UI separated.
2. Put backend transport logic in services/providers, not widgets.
3. Keep widgets declarative. Side effects belong in notifiers, providers, or dedicated controllers.
4. Add reusable UI primitives to `lib/core/widgets` only after a pattern repeats.
5. Keep feature-specific widgets, providers, and services inside the owning feature folder.
6. Do not let feature code reach directly into another feature's private implementation. Share through `core` or explicit public feature APIs.

Recommended feature structure once a slice grows:

```text
lib/features/<feature>/
  data/
  application/
  presentation/
  widgets/
```

Use this structure when the folder has enough complexity to justify it. Do not create empty subfolders speculatively.

## State Management Conventions

Use Riverpod as the source of truth.

- Prefer generated providers with `@riverpod` or `@Riverpod`
- Use `keepAlive: true` only for app-lifetime state such as auth, router, or shared clients
- Keep async flows in providers/notifiers, not inside widget lifecycle methods unless bootstrap requires it
- When a provider models UI state transitions, prefer explicit sealed states like `AuthLoading`, `AuthAuthenticated`, and `AuthUnauthenticated`
- Avoid storing duplicate derived state when it can be computed from other providers

## Routing Conventions

`lib/core/router/app_router.dart` is the routing authority.

- Centralize route registration there until route volume justifies splitting
- Keep redirect logic auth-aware and deterministic
- Prefer typed route construction patterns when routes become more complex
- Protect feature entry points with router redirects or guard providers, not ad hoc widget checks

The current app already uses auth-aware redirects:

- unauthenticated users are sent to `/login`
- authenticated users are redirected away from `/login`
- `/` is currently a placeholder home and should evolve into the main workspace shell

## Auth and API Rules

Authentication is already built around OAuth device flow.

- Do not duplicate token storage logic outside auth and API layers
- Use `flutter_secure_storage` only for secrets such as auth tokens
- Use `shared_preferences` only for non-secret local preferences
- Keep backend base URL and auth endpoint assumptions centralized
- If backend auth behavior changes, update both `auth_service.dart` and the API client assumptions together

Important existing behavior:

- `AuthService` performs device flow login and token persistence
- `authProvider` restores prior sessions on startup and drives router redirects
- `apiClient` injects bearer tokens automatically into requests

## Models and Serialization

Models in `lib/core/models` mirror backend schemas and event payloads.

- Prefer extending existing model files before inventing parallel DTOs
- Keep JSON key mappings explicit with `@JsonKey`
- Maintain naming parity with backend fields where practical
- Use `freezed` models for immutable app state and API payloads

Current domain model coverage includes:

- plans, phases, tasks, subtasks, acceptance criteria, and file scopes
- projects and indexing status
- realtime indexing progress payloads
- users and auth session data

## Generated Files

This repo uses generated Dart files. Do not hand-edit generated output.

Never manually edit:

- `*.g.dart`
- `*.freezed.dart`

When changing annotated models or generated providers, run:

```bash
dart run build_runner build --delete-conflicting-outputs
```

For active development, this is often better:

```bash
dart run build_runner watch --delete-conflicting-outputs
```

## UI and Theming

The current theme direction is already established in `lib/core/theme/app_theme.dart`.

- preserve the neutral, restrained visual system unless a product decision changes it
- use theme tokens instead of hard-coded colors where possible
- keep desktop ergonomics in mind: spacing, panel density, hover states, keyboard navigation
- design for large-window layouts first, then ensure smaller desktop widths still behave sensibly
- avoid mobile-first patterns that waste horizontal space in a desktop workspace

The eventual main shell should likely be a multi-panel workspace rather than a stack of mobile-style full-screen pages.

## Error Handling and Resilience

- route uncaught app-level failures through the existing error handling setup
- prefer explicit loading, empty, and error states for async feature screens
- fail closed on auth expiration and let the router return the user to login
- avoid silent catch-and-ignore behavior unless the failure is truly non-actionable

## Desktop-Specific Expectations

This app is a desktop client, not a generic mobile app.

- optimize for keyboard and pointer interaction
- prefer layouts that take advantage of width and multiple panes
- be careful with platform-specific behaviors such as opening URLs or local process integration
- keep macOS, Linux, and Windows compatibility in mind when adding platform-dependent code

If a behavior is macOS-only today, document it in code comments and avoid accidentally implying cross-platform support.

## Testing and Verification

Do not add tests unless the user asks for them or the active plan explicitly includes them.

When verifying changes, prefer the lightest relevant commands:

```bash
flutter analyze
dart run build_runner build --delete-conflicting-outputs
flutter test
```

Use `flutter test` only when tests exist or when you add them intentionally.

## File Size and Modularity

Keep files under 600 lines.

- split growing widgets into smaller presentation pieces
- split complex providers/services before they become mixed responsibility files
- avoid building giant workspace screens in a single file

If a feature screen grows, break it into:

- route/screen entry widget
- feature widgets
- state/provider layer
- service/repository layer

## Preferred Workflow for Changes

When implementing a feature:

1. inspect the relevant module with qdexcode MCP
2. identify whether the work belongs in `core` or a `features/*` slice
3. update models/providers/services first if the change affects data flow
4. add or update UI after state and routing shape are clear
5. regenerate code if annotations changed
6. run targeted verification

When implementing a new backend-backed screen, prefer this order:

1. model alignment
2. API/service layer
3. Riverpod provider or notifier
4. route wiring
5. screen and child widgets

## Project-Specific Guidance for Upcoming Work

Based on the current scaffold, likely next implementation areas are:

- replace the placeholder `/` home with the real desktop workspace shell
- populate the empty feature folders with concrete slices
- connect projects, plans, and indexing models to actual API-backed views
- wire realtime indexing updates into UI state
- add desktop workspace features such as file tree, editor, terminal, and git surfaces

When doing that work, keep the app aligned with the qdexcode domain models already present instead of inventing alternate local schemas.

## Documentation Intent

This `AGENTS.md` is the repo-specific working contract for agents in this folder. Keep it focused on how to build and modify this desktop app. If the implementation direction changes materially, update this file so future work stays aligned.
