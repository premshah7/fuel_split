import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/repositories/auth_repository.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/profile_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/trips/screens/add_trip_screen.dart';
import '../../features/trips/screens/trip_detail_screen.dart';
import '../../features/trips/screens/edit_trip_screen.dart';
import '../../features/trips/screens/fuel_log_list_screen.dart';
import '../../features/trips/screens/add_fuel_log_screen.dart';
import '../../features/trips/models/trip.dart';
import '../../features/trips/models/fuel_log.dart';

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen(
      authStateChangesProvider,
      (_, _) => notifyListeners(),
    );
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    refreshListenable: notifier,
    initialLocation: '/',
    redirect: (context, state) {
      final authState = ref.read(authStateChangesProvider);
      if (authState.isLoading || authState.hasError) return null;

      final isAuthenticated = authState.value != null;
      final isLoggingInOrRegistering = state.matchedLocation == '/login' || state.matchedLocation == '/register';

      if (!isAuthenticated && !isLoggingInOrRegistering) return '/login';
      if (isAuthenticated && isLoggingInOrRegistering) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/add-trip',
        builder: (context, state) => const AddTripScreen(),
      ),
      GoRoute(
        path: '/trip/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final trip = state.extra as Trip?;
          return TripDetailScreen(tripId: id, initialTrip: trip);
        },
      ),
      GoRoute(
        path: '/edit-trip/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final trip = state.extra as Trip?;
          return EditTripScreen(tripId: id, initialTrip: trip);
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/fuel-logs',
        builder: (context, state) => const FuelLogListScreen(),
      ),
      GoRoute(
        path: '/add-refuel',
        builder: (context, state) {
          final log = state.extra as FuelLog?;
          return AddFuelLogScreen(initialLog: log);
        },
      ),
      GoRoute(
        path: '/edit-refuel/:id',
        builder: (context, state) {
          final log = state.extra as FuelLog?;
          return AddFuelLogScreen(initialLog: log);
        },
      ),
    ],
  );
});
