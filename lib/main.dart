import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'src/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL', defaultValue: 'https://lapxlngpjrrmqscbvqjx.supabase.co'),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxhcHhsbmdwanJybXFzY2J2cWp4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg3OTE2MDUsImV4cCI6MjA5NDM2NzYwNX0.Qx8FOwb2jlG0KGXwI58zSM8Oo3fP5ggsHnlHXTzpFyk'),
  );

  runApp(const ProviderScope(child: SpoonyApp()));
}
 