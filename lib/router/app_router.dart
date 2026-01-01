import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../views/item_list_screen.dart';
import '../views/add_item_screen.dart';
import '../views/edit_item_screen.dart';
import '../views/settings_screen.dart';
import '../views/menu_analysis_screen.dart';
import '../models/item_model.dart';

/// Route paths as constants for type safety and easy refactoring
class AppRoutes {
  static const String home = '/';
  static const String addItem = '/add-item';
  static const String editItem = '/edit-item';
  static const String settings = '/settings';
  static const String menuAnalysis = '/menu-analysis';
}

/// GoRouter configuration provider
/// Declarative routing with type-safe navigation
/// Better performance than imperative Navigator.push
final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: true,
    routes: [
      // Home route - Item List Screen
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        pageBuilder: (context, state) =>
            const MaterialPage(child: ItemListScreen()),
      ),

      // Add Item route
      GoRoute(
        path: AppRoutes.addItem,
        name: 'add-item',
        pageBuilder: (context, state) {
          final date = state.extra as String?;
          return MaterialPage(child: AddItemScreen(date: date));
        },
      ),

      // Edit Item route with item parameter
      GoRoute(
        path: AppRoutes.editItem,
        name: 'edit-item',
        pageBuilder: (context, state) {
          final params = state.extra as Map<String, dynamic>;
          final item = params['item'] as ItemModel;
          final date = params['date'] as String?;
          return MaterialPage(
            child: EditItemScreen(item: item, date: date),
          );
        },
      ),

      // Settings route
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        pageBuilder: (context, state) =>
            const MaterialPage(child: SettingsScreen()),
      ),

      // Menu Analysis route
      GoRoute(
        path: AppRoutes.menuAnalysis,
        name: 'menu-analysis',
        pageBuilder: (context, state) =>
            const MaterialPage(child: MenuAnalysisScreen()),
      ),
    ],

    // Error handling
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Page not found: ${state.uri}', textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    ),
  );
});
