import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/services/supabase_service.dart';

final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService();
});

final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.read(supabaseServiceProvider).authStateChanges;
});

final currentUserProvider = Provider<User?>((ref) {
  // Reacts to auth state changes so widgets rebuild on sign-in / sign-out.
  ref.watch(authStateProvider);
  return Supabase.instance.client.auth.currentUser;
});
