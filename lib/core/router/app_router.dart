import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/detail/detail_screen.dart';
import '../../features/home/main_scaffold.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final user = Supabase.instance.client.auth.currentUser;
      final path = state.uri.path;
      final isAuthRoute = path == '/login' || path == '/register';

      if (user == null && !isAuthRoute) return '/login';
      if (user != null && isAuthRoute) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        redirect: (context, state) {
          final user = Supabase.instance.client.auth.currentUser;
          return user != null ? '/home' : '/login';
        },
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const MainScaffold(),
      ),
      GoRoute(
        path: '/movie/:id',
        name: 'movie-detail',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return DetailScreen(movieId: id);
        },
      ),
    ],
  );
});
