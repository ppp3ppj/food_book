# AGENTS.md - Development Guide for food_book

This file provides comprehensive guidance for AI agents and developers working on the food_book Flutter project. It outlines architecture patterns, coding standards, project structure, and best practices to ensure consistency and maintainability across the codebase.

## Project Overview

**App Name:** food_book  
**Company:** Unknown  
**Platform:** Flutter (Android)  
**Purpose:** Modern Food ordering and management system for retail businesses and restaurants to efficiently manage sales, inventory, customer data, and business operations with a beautiful Material 3 UI

**Architecture:** MVVM (Model-View-ViewModel) with Provider pattern for state management  
**Database:** Drift ORM with SQLite for local-first data persistence  
**Design System:** Material 3 with semantic color tokens and responsive design

## Architecture & Design Principles

### MVVM + Provider Architecture
- **Model:** Data models and business entities (`lib/data/tables/*.dart`)
- **View:** UI screens and widgets (`lib/views/`, `lib/widgets/`)
- **ViewModel:** Services and providers for business logic (`lib/services/`, `lib/viewmodels/`)
- **Provider Pattern:** State management with `ChangeNotifier` and `Consumer`
- **Dependency Injection:** Use `MultiProvider` for service registration
- **Reactive UI:** UI automatically updates when data changes via `Consumer<T>`

### Material 3 Design System
- **Always use Material 3** design tokens and components (`useMaterial3: true`)
- **Theme-driven colors:** Leverage `ColorScheme` from `lib/theme/app_theme.dart`
- **Semantic color roles:** `primary`, `secondary`, `surface`, `onSurface`, `error`, etc.
- **Component consistency:** Prefer Material 3 widgets over custom implementations
- **Elevation & surfaces:** Use Cards for elevated content, proper surface tints
- **Adaptive UI:** Support light/dark themes, high contrast, accessibility

### Typography & Visual Hierarchy
- **Material 3 typography:** Use scale tokens (`displayLarge`, `headlineMedium`, `bodyLarge`, `labelSmall`)
- **Google Fonts integration:** **Noto Sans Thai** as default font family for Thai/English support
- **Spacing system:** Use multiples of 8px (8, 16, 24, 32, 48) for consistency
- **Color contrast:** Ensure WCAG AA compliance with theme colors
- **Icon system:** Use Material Icons with semantic sizing (16, 24, 32, 48)
- **Thai Language Support:** Professional Thai text rendering with proper character spacing

### POS-Specific UX Patterns
- **Speed & efficiency:** Optimize for fast transactions and checkout flow
- **Touch-friendly:** Large tap targets (minimum 48px), gesture support
- **Visual feedback:** Immediate response to user actions, loading states
- **Error recovery:** Graceful error handling with clear recovery actions  
- **Offline-first:** Work without internet, sync when available
- **Multi-modal input:** Support barcode scanning, touch, keyboard shortcuts

### Component Design Standards
- **Consistent behavior:** Standardized interactions across all screens
- **Responsive layouts:** Handle various screen sizes (phone, tablet, desktop)
- **Accessibility:** Screen reader support, semantic labels, keyboard navigation
- **Performance:** Lazy loading, efficient list rendering, image optimization
- **Testing:** Widget testability with clear widget keys and test helpers

## Project Structure & Organization

### Current Project Directory Structure
```
food_book/
├─ lib/
│  ├─ main.dart                 # App entry point with MultiProvider setup
│  ├─ app.dart                  # App widget, routing, theme configuration
│  ├─ data/                     # Data layer with Drift ORM
│  │  ├─ app_database.dart      # Main database configuration
│  │  ├─ app_database.g.dart    # Generated database code
│  │  ├─ dao/                   # Data Access Objects
│  │  ├─ seed/                  # Database seeding utilities
│  │  └─ tables/                # Database table definitions
│  ├─ helpers/                  # Utility functions and constants
│  ├─ models/                   # Data transfer objects and models
│  ├─ providers/                # State management providers
│  ├─ services/                 # Business logic services
│  ├─ viewmodels/               # View model layer
│  ├─ views/                    # UI screens and pages
│  └─ widgets/                  # Reusable UI components
├─ android/                     # Android platform configuration
├─ build/                       # Build output directory
├─ analysis_options.yaml        # Dart analyzer configuration
├─ pubspec.yaml                 # Dependencies and project metadata
├─ pubspec.lock                 # Locked dependency versions
├─ AGENTS.md                    # This development guide
└─ README.md                    # Project documentation
```

### MVVM Implementation Guidelines

#### 1. Services (ViewModels)
```dart
/// Example from lib/services/item_service.dart
class ItemService extends ChangeNotifier {
  final AppDatabase _database;
  
  List<Item> _items = [];
  bool _isLoading = false;
  String? _error;
  
  ItemService(this._database) {
    loadItems();
  }
  
  // Getters for UI consumption
  List<Item> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasItems => _items.isNotEmpty;
  
  // Business operations
  Future<void> loadItems() async {
    _setLoading(true);
    _setError(null);
    
    try {
      _items = await _database.itemDao.getAllItems();
      debugPrint('📋 Loaded ${_items.length} items');
    } catch (e) {
      _setError('Failed to load items: ${e.toString()}');
      debugPrint('❌ Error loading items: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }
}
```

#### 2. Data Access Objects (DAOs)
```dart
/// Example from lib/data/dao/item_dao.dart
@DriftAccessor(tables: [Items, Categories, ItemTypes, Units, Taxes])
class ItemDao extends DatabaseAccessor<AppDatabase> with _$ItemDaoMixin {
  ItemDao(super.db);

  // Get all items with category information
  Future<List<Item>> getAllItems() {
    return select(items).get();
  }

  // Get items by category with join
  Future<List<Item>> getItemsByCategory(int categoryId) {
    return (select(items)..where((item) => item.categoryId.equals(categoryId))).get();
  }

  // Create new item
  Future<int> createItem(ItemsCompanion item) {
    return into(items).insert(item);
  }

  // Search items by name
  Future<List<Item>> searchItems(String query) {
    return (select(items)
      ..where((item) => 
        item.nameEN.contains(query) | 
        item.nameTH.contains(query) |
        item.itemCode.contains(query)
      )).get();
  }
}
```

#### 3. UI Integration with Consumer
```dart
/// Example from lib/views/order/order_screen.dart
class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  final List<CartItemModel> _cartItems = [];
  late AppDatabase _database;
  
  List<Category> _categories = [];
  List<Item> _items = [];
  List<Item> _filteredItems = [];
  int? _selectedCategoryId;
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ItemService>(
        builder: (context, itemService, child) {
          if (itemService.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          
          if (itemService.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text('Error: ${itemService.error}'),
                  ElevatedButton(
                    onPressed: () => itemService.loadItems(),
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }
          
          return _buildMenuGrid(itemService.items);
        },
      ),
    );
  }

  Widget _buildMenuGrid(List<Item> items) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildItemCard(item);
      },
    );
  }
}
```

### Code Quality Standards

#### Naming Conventions
- **Classes:** `PascalCase` (e.g., `ItemService`, `PosScreen`, `CartItemModel`)
- **Variables/Methods:** `camelCase` (e.g., `isLoading`, `loadItems()`, `addItemToCart()`)
- **Constants:** `SCREAMING_SNAKE_CASE` (e.g., `MAX_ITEMS_PER_PAGE`)
- **Files:** `snake_case` (e.g., `item_service.dart`, `order_screen.dart`, `cart_item_model.dart`)
- **Private members:** Prefix with `_` (e.g., `_items`, `_setLoading()`, `_database`)

#### Error Handling Strategy
- **Service Level:** Catch exceptions, set error state, notify listeners
- **UI Level:** Display user-friendly error messages with recovery actions
- **Repository Level:** Let exceptions bubble up with context
- **Validation:** Input validation at form level with immediate feedback

#### Performance Best Practices
- **Lazy Loading:** Load data on-demand, paginate large lists
- **Caching:** Cache frequently accessed data in services
- **Efficient Rebuilds:** Use `Consumer` with specific types, avoid unnecessary rebuilds
- **Memory Management:** Dispose controllers, streams, and listeners properly
- **Image Optimization:** Use appropriate image sizes, lazy loading for galleries

#### Testing Architecture
```dart
// Unit Tests - Services/Business Logic
class ItemServiceTest {
  test('should load items successfully', () async {
    // Given
    final mockDatabase = MockAppDatabase();
    final service = ItemService(mockDatabase);
    
    // When  
    await service.loadItems();
    
    // Then
    expect(service.items, isNotEmpty);
    expect(service.error, isNull);
    expect(service.hasItems, isTrue);
  });
  
  test('should handle error when loading items fails', () async {
    // Given
    final mockDatabase = MockAppDatabase();
    when(mockDatabase.itemDao.getAllItems()).thenThrow(Exception('Database error'));
    final service = ItemService(mockDatabase);
    
    // When
    await service.loadItems();
    
    // Then
    expect(service.items, isEmpty);
    expect(service.error, contains('Failed to load items'));
  });
}

// Widget Tests - UI Components  
class PosScreenTest {
  testWidgets('should display items when loaded', (tester) async {
    // Given
    final mockService = MockItemService();
    
    // When
    await tester.pumpWidget(
      ChangeNotifierProvider<ItemService>.value(
        value: mockService,
        child: PosScreen(),
      ),
    );
    
    // Then
    expect(find.byType(GridView), findsOneWidget);
    expect(find.byType(Card), findsWidgets);
  });
}
```

## Development Commands

### Build & Run
```bash
# Run on device/simulator
flutter run

# Run on specific device
flutter run -d "device-id"

# Release build
flutter build apk --release
```

### Code Quality
```bash
# Analyze code
flutter analyze

# Format code
dart format lib/ test/

# Get dependencies
flutter pub get

# Clean build
flutter clean
```

### Testing
```bash
# Run all tests
flutter test

# Run specific test
flutter test test/widget_test.dart

# Generate coverage
flutter test --coverage
```

### Asset Management
```bash
# Generate app icons
flutter pub run flutter_launcher_icons

# Generate splash screens  
flutter pub run flutter_native_splash:create
```

## Agent Task Documentation Requirements

### Task Completion Protocol
- **Mandatory Documentation:** Every completed task MUST be documented in the `agent_tasks/` directory
- **File Naming Convention:** Use descriptive names like `task_name_success.md` or `feature_implementation_YYYY-MM-DD.md`
- **Comprehensive Records:** Include implementation details, code changes, verification steps, and outcomes
- **Success Tracking:** Document what was accomplished, files modified, and business value delivered
- **Future Reference:** Provide maintenance guidance and lessons learned for future developers

### Documentation Template Structure
```markdown
# 🎯 Agent Task: [Task Name] - [STATUS] ✅/❌

**Date:** [Date]
**Task:** [Brief description]
**Status:** ✅ COMPLETED SUCCESSFULLY / ❌ FAILED
**Agent:** GitHub Copilot

## 📋 Task Summary
- **Objective:** [What was requested]
- **Requirements:** [Technical/business requirements]
- **Implementation:** [What was done]

## ✅ Verification & Results
- **Testing:** [How it was verified]
- **Performance Impact:** [Any performance considerations]
- **Success Metrics:** [Measurable outcomes]

## 📚 Documentation & Future Maintenance
- **Files Created/Updated:** [Documentation files]
- **Next Steps:** [Recommendations for future work]
- **Lessons Learned:** [Key insights and best practices]
```

### Task Categories for Organization
- **Performance Optimizations** - Database, UI, memory improvements
- **Feature Implementations** - New functionality additions
- **Bug Fixes** - Issue resolution and debugging
- **Architecture Changes** - MVVM, Provider pattern improvements  
- **UI/UX Enhancements** - Design system, typography, accessibility
- **Documentation Updates** - Guide improvements and maintenance

## Security & Privacy

### Data Handling
- **Local storage only** - no external data transmission
- **User consent** for calendar access
- **Privacy-first** approach - see `agent_assets/privacy-policy.md`

### Vulnerability Testing
- **Test vulnerabilities** are injected in separate files for security scanning
- **Never commit real secrets** or API keys
- **Use environment variables** for any external API integration

## Asset Guidelines

### Images & Icons

### Company Branding

## Common Pitfalls & Solutions

### Flutter Specific
- **Hot reload limitations:** Restart app after theme/provider changes
- **Asset loading:** Always provide errorBuilder for images
- **State management:** Avoid calling Provider in initState
- **Screen overflow:** Use Expanded, Flexible for responsive layouts

### Material 3 Migration
- **Color scheme:** Use colorScheme properties, not deprecated colors
- **Components:** Prefer Material 3 components over custom implementations
- **Theming:** Apply theme consistently across all screens

### Provider Pattern Issues
- **Build context access:** Never call `Provider.of` in `initState`, use `didChangeDependencies`
- **Memory leaks:** Always dispose controllers and streams in ViewModels
- **Unnecessary rebuilds:** Use `Consumer` with specific types, avoid broad selectors
- **Async operations:** Handle loading states properly, don't forget error handling

### Database Best Practices
- **Migration safety:** Always test database migrations with existing data
- **Performance:** Use indexes on frequently queried columns
- **Data integrity:** Implement foreign key constraints and validation
- **Backup strategy:** Implement data export/import for user data safety

### POS-Specific Issues
- **Currency handling:** Use `double` for prices, format with 2 decimal places
- **Transaction integrity:** Ensure atomicity for order operations
- **Offline resilience:** Cache critical data, queue operations when offline
- **Receipt printing:** Test on actual hardware, handle printer errors gracefully

## Best Practices Checklist

### Code Quality
- [ ] All public APIs have documentation comments
- [ ] Error handling implemented at service and UI levels
- [ ] Unit tests for business logic (services, repositories)
- [ ] Widget tests for critical UI components
- [ ] Integration tests for key user flows
- [ ] Code analysis passes without warnings
- [ ] Consistent naming conventions throughout codebase

### Agent Task Documentation
- [ ] **Task completion documented in `agent_tasks/` directory**
- [ ] **Implementation details and code changes recorded**
- [ ] **Verification steps and success metrics included**
- [ ] **Files modified and dependencies listed**
- [ ] **Business value and performance impact documented**
- [ ] **Future maintenance guidance provided**
- [ ] **Lessons learned and best practices captured**

### Performance
- [ ] Lazy loading for large data sets
- [ ] Efficient list rendering with `ListView.builder`
- [ ] Image optimization and caching
- [ ] Database queries optimized with proper indexes
- [ ] Memory usage monitored in development
- [ ] Build times kept reasonable with proper imports

### Accessibility
- [ ] Semantic labels for screen readers
- [ ] Proper color contrast ratios (WCAG AA)
- [ ] Keyboard navigation support
- [ ] Touch targets minimum 48px
- [ ] Text scaling support
- [ ] High contrast theme support

### Security
- [ ] Input validation on all user inputs
- [ ] SQL injection prevention with parameterized queries
- [ ] Sensitive data encrypted at rest
- [ ] No hardcoded secrets in source code
- [ ] Error messages don't leak sensitive information
- [ ] User permissions properly validated

## Future Roadmap

### Core Features Planned
- **Multi-location Support:** Manage inventory across multiple stores
- **Advanced Reporting:** Sales analytics, inventory insights, profit margins
- **Customer Management:** Loyalty programs, purchase history, customer profiles  
- **Supplier Integration:** Purchase orders, inventory replenishment, supplier management
- **Employee Management:** Role-based permissions, sales tracking, shift management
- **Payment Integration:** Multiple payment providers, split payments, tips handling

### Technical Enhancements
- **Cloud Sync:** Real-time data synchronization across devices
- **Backup & Restore:** Automated data backup with cloud storage
- **API Integration:** External inventory systems, accounting software integration
- **Mobile Receipt:** Digital receipts via email/SMS
- **Barcode Generation:** Generate barcodes for custom products
- **Hardware Integration:** Cash drawers, receipt printers, barcode scanners

### Platform Expansion
- **Tablet Optimization:** Enhanced UI for Android tablet-based POS terminals
- **Android TV Support:** Large screen POS interface for Android TV devices
- **Multi-language:** Complete localization for international markets
- **Android Hardware Integration:** Better support for Android-specific POS hardware

---

## Quick Reference Commands

### Development Workflow
```bash
# Setup new development environment
flutter pub get
dart run build_runner build --delete-conflicting-outputs

# Daily development
flutter run --hot
flutter analyze
dart format lib/ test/

# Testing
flutter test
flutter test --coverage
flutter test test/integration/

# Release preparation
flutter build apk --release
```

### Code Generation
```bash
# Drift database code generation
dart run build_runner build

# Clean and regenerate (when schema changes)
dart run build_runner build --delete-conflicting-outputs

# Watch mode for continuous generation
dart run build_runner watch
```

### Project Maintenance
```bash
# Update dependencies
flutter pub upgrade

# Clean project
flutter clean
flutter pub get

# Analyze dependencies
flutter pub deps
dart pub outdated
```

## Documentation Links

**Architecture Patterns:** 
- [Provider Pattern Guide](https://pub.dev/packages/provider)
- [MVVM in Flutter](https://docs.flutter.dev/development/data-and-backend/state-mgmt/simple)
- [Material 3 Design System](https://m3.material.io/)

**Database & Persistence:**
- [Drift ORM Documentation](https://drift.simonbinder.eu/)
- [SQLite Best Practices](https://www.sqlite.org/lang.html)

**Testing Resources:**
- [Flutter Testing Guide](https://docs.flutter.dev/testing)
- [Widget Testing](https://docs.flutter.dev/cookbook/testing/widget/introduction)
- [Integration Testing](https://docs.flutter.dev/testing/integration-tests)

---

## Emergency Troubleshooting

### Common Build Issues
```bash
# Fix dependency conflicts
flutter pub deps
flutter clean
flutter pub get

# Fix Dart analysis issues  
dart fix --apply
dart format lib/ test/

# Reset Drift code generation
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

### Performance Issues
```bash
# Check app size
flutter build apk --analyze-size

# Profile performance
flutter run --profile
flutter run --release

# Memory analysis
flutter run --observatory-port=9999
```

### Database Issues
```bash
# Reset local database (development only)
flutter clean
# Delete app data on device/simulator
# Reinstall app to recreate database schema
```

---

*This file should be updated as the project evolves. When adding major features or changing architecture patterns, update this guide accordingly. Last updated: September 2025*