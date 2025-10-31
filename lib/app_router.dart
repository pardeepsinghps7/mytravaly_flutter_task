import 'package:go_router/go_router.dart';
import 'presentation/screens/auth/google_signin_screen.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/search/search_results_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => GoogleSignInScreen()),
      GoRoute(path: '/home', builder: (context, state) => HomeScreen()),
      GoRoute(
        path: '/search',
        builder: (context, state) {
          final q = state.uri.queryParameters['q'] ?? '';
          final type = state.uri.queryParameters['type'] ?? 'citySearch';
          final display = state.uri.queryParameters['display'];
          return SearchResultsScreen(
            query: q,
            type: type,
            display: display,
          );
        },
      ),
    ],
  );
}
