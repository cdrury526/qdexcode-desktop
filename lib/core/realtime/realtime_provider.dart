// Realtime WebSocket provider — connects to pg-bridge.
// Implemented in Phase 2.
//
// Will provide:
// - JWT-authenticated WebSocket to wss://pg-bridge.chrisdrury.com/ws
// - Event stream for: index_progress, plan_update, task_update,
//   subtask_update, project_update
// - Auto-reconnect with exponential backoff
// - Connection status (connected / reconnecting / disconnected)
