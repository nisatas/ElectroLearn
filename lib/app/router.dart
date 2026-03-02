import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_notifier.dart';
import 'supabase_config.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/signup_screen.dart';
import '../features/home/home_screen.dart';
import '../features/lesson/lesson_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/quiz/quiz_screen.dart';
import '../features/result/result_screen.dart';

GoRouter createGoRouter(AuthNotifier authNotifier) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: authNotifier,
    redirect: (context, state) {
      if (supabaseUrl.startsWith('YOUR_') || supabaseAnonKey.startsWith('YOUR_')) {
        return null;
      }
      final isLoggedIn = Supabase.instance.client.auth.currentUser != null;
      final isAuthRoute = state.matchedLocation == '/login' || state.matchedLocation == '/signup';
      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && isAuthRoute) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const HomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (_, __) => const SignupScreen(),
      ),
      GoRoute(
        path: '/lesson/:id',
        builder: (_, state) {
          final id = state.pathParameters['id']!;
          return LessonScreen(skillId: id);
        },
      ),
      GoRoute(
        path: '/quiz/:id',
        builder: (_, state) {
          final id = state.pathParameters['id']!;
          return QuizScreen(skillId: id);
        },
      ),
      GoRoute(
        path: '/result',
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final correct = (extra?['correct'] as int?) ?? 0;
          final total = (extra?['total'] as int?) ?? 0;
          final xp = (extra?['xp'] as int?) ?? 0;
          final skillId = extra?['skillId'] as String?;
          return ResultScreen(
            correct: correct,
            total: total,
            xpEarned: xp,
            skillId: skillId,
          );
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (_, __) => const ProfileScreen(),
      ),
    ],
  );
}
