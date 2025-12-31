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
  print('🔌 Testing database connection...');
  final isConnected = await database.testConnection();
  
  if (isConnected) {
    print('✅ Database initialized successfully');
    print('📌 SQLite version: ${database.getVersion()}');
  } else {
    print('⚠️ Database initialization warning - check logs');
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: goRouter,
    );
  }
}
