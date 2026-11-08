import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/auth_screen.dart';

/// Returns true if the user is signed in. Otherwise asks them to sign in,
/// opens the login page, and returns true only if they signed in there.
Future<bool> requireLogin(
  BuildContext context, {
  String message = 'Please sign in to continue.',
}) async {
  if (Supabase.instance.client.auth.currentUser != null) return true;

  final goToLogin = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Sign in required'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Not now'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Sign In'),
        ),
      ],
    ),
  );
  if (goToLogin != true || !context.mounted) return false;

  await Navigator.pushNamed(context, AuthScreen.routeName);
  return Supabase.instance.client.auth.currentUser != null;
}
