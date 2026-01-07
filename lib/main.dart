import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/app_database.dart';
import 'providers/database_provider.dart';
import 'router/app_router.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database
  final database = AppDatabase();
  await database.initialize();

  // Test database connection
  debugPrint('🔌 Testing database connection...');
  final isConnected = await database.testConnection();

  if (isConnected) {
    debugPrint('✅ Database initialized successfully');
    debugPrint('📌 SQLite version: ${database.getVersion()}');
  } else {
    print('⚠️ Database initialization warning - check logs'); // Keep in release
  }

  // Run app with ProviderScope for Riverpod
  runApp(
    ProviderScope(
      overrides: [
        // Override database provider with actual instance
        databaseProvider.overrideWithValue(database),
      ],
      child: const MyApp(),
    ),
  );
}

/// Main app widget - Now stateless and uses Riverpod + go_router
/// Performance optimized with declarative routing
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'Food Book POS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Senior-friendly warm & calming color scheme
        colorScheme: ColorScheme.light(
          primary: const Color(0xFF2E7D8C), // Soft Teal - calming, professional
          primaryContainer: const Color(0xFFB8E3E8), // Light Teal
          secondary: const Color(0xFF6B9B7D), // Sage Green - natural, easy on eyes
          secondaryContainer: const Color(0xFFD4E8DC), // Light Sage
          tertiary: const Color(0xFFD97D54), // Warm Terracotta - friendly accent
          tertiaryContainer: const Color(0xFFFADFD0), // Light Terracotta
          surface: const Color(0xFFFAFBFC), // Warm Off-White
          surfaceContainerHighest: const Color(0xFFF0F4F5), // Light Gray-Blue
          error: const Color(0xFFD84848), // Soft Red - clear but not harsh
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: const Color(0xFF2C3E50), // Dark Blue-Gray for text
          onSurfaceVariant: const Color(0xFF5A6A7A), // Medium Gray for secondary text
          outline: const Color(0xFFD0D8E0), // Soft borders
        ),
        useMaterial3: true,
        // Use Sarabun font for better Thai readability
        fontFamily: 'Sarabun',
        // Card theme for food items
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.white,
        ),
        // Elevated button theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        // Floating action button theme
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        // App bar theme
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: false,
          iconTheme: IconThemeData(size: 28, color: Colors.white),
          actionsIconTheme: IconThemeData(size: 28, color: Colors.white),
        ),
      ),
      routerConfig: goRouter,
    );
  }
}
