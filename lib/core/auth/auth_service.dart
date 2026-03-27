// Auth service — GitHub OAuth flow + token storage.
// Implemented in Phase 1, Task 2.
//
// Will provide:
// - GitHub OAuth via device flow or PKCE
// - Token persistence via flutter_secure_storage
// - Session validation against /api/auth/get-session
// - Logout (clear tokens + redirect)
