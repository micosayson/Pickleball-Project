class SupabaseConfig {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://aznkmrzmaxtpboczpdbk.supabase.co',
  );

  static const String supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImF6bmttcnptYXh0cGJvY3pwZGJrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODExNzQwNTQsImV4cCI6MjA5Njc1MDA1NH0.3XaWLgtkbbPZNpa4mZd4CbxVI8FKeUjuQXRXbvZhe5Y',
  );
}
