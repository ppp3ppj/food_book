import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/app_database.dart';

/// Provider for the SQLite database instance
/// This is a global singleton that provides access to the database
/// throughout the app via Riverpod dependency injection
final databaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError(
    'databaseProvider must be overridden in ProviderScope with actual database instance',
  );
});
