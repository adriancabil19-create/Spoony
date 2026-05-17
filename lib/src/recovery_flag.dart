/// Set to true in main() when the app URL contains a password-recovery token.
/// Captured before Supabase.initialize() cleans the URL via replaceState.
bool kHasRecoveryToken = false;
