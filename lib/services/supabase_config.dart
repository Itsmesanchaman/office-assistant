class SupabaseConfig {
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://xjzxscqrubzctxkeuzgt.supabase.co', // Udayapurgadhi (production) — default fallback
  );

  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_mvyubtV_WzBCaXzP1d2ESg_EmfMXlmu', // Udayapurgadhi (production) — default fallback
  );
}