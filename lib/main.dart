import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'src/app.dart';
import 'src/recovery_flag.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Capture the URL NOW before Supabase.initialize() cleans it via
  // window.history.replaceState. Works for both ?code= (PKCE) and
  // #access_token=...&type=recovery (implicit) formats.
  final uri = Uri.base;
  kHasRecoveryToken = uri.queryParameters.containsKey('code') ||
      Uri.splitQueryString(uri.fragment).containsKey('access_token');

  await Supabase.initialize(
  url: 'https://lapxlngpjrrmqscbvqjx.supabase.co',
  anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxhcHhsbmdwanJybXFzY2J2cWp4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg3OTE2MDUsImV4cCI6MjA5NDM2NzYwNX0.Qx8FOwb2jlG0KGXwI58zSM8Oo3fP5ggsHnlHXTzpFyk',
);

  runApp(const ProviderScope(child: SpoonyApp()));
}