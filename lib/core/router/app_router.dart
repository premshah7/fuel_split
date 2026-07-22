import 'package:go_router/go_router.dart';
// Removed flutter/material.dart
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

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateChangesProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
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
        builder: (context, state) => const AddFuelLogScreen(),
      ),
    ],
  );
});
