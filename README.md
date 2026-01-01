# FoodBook

A senior-friendly food tracking application built with Flutter.

## Overview

FoodBook is a simplified food ordering and tracking system designed specifically for users aged 50 and above. The app features large text, calming colors, and intuitive navigation to make food tracking accessible and stress-free for seniors.

## Key Features

**Item Management**
- Add, edit, and delete food items with ease
- Track item name, price, date, and optional notes
- Smart suggestions based on recent items
- One-tap fill for frequently ordered items

**Date Navigation**
- Browse items by date with intuitive next/previous controls
- Quick return to today's date
- Calendar picker for selecting specific dates

**Menu Analysis**
- View food items across date ranges
- Summary statistics for each date
- Export menu details with customizable header and footer

**Senior-Friendly Design**
- Large text sizes (18-22px) for better readability
- High contrast color scheme (soft teal, sage green, warm terracotta)
- Generous spacing and large touch targets (56-60px)
- Thai language support throughout

## Technical Stack

**Framework & Language**
- Flutter 3.10.4+
- Dart SDK
- Material Design 3

**State Management**
- Riverpod 3.1.0 with Notifier pattern
- Flutter Hooks for local state

**Database**
- SQLite3 for local data persistence
- Indexed queries for performance
- Expression index on LOWER(name) for Thai language support

**Navigation**
- go_router 17.0.1 for declarative routing
- MaterialPageRoute for detail screens

**Dependencies**
- package_info_plus: App version display
- shared_preferences: Settings persistence
- path_provider: Database path management

## Architecture

**Pattern**: MVVM (Model-View-ViewModel)

**Project Structure**
```
lib/
├── data/                   # Database layer
│   ├── app_database.dart   # SQLite configuration
│   └── tables/             # Table definitions
├── models/                 # Data models
│   └── item_model.dart     # Item entity
├── providers/              # State management
│   ├── item_provider.dart  # Item operations
│   └── settings_provider.dart
├── views/                  # UI screens
│   ├── item_list_screen.dart
│   ├── add_item_screen.dart
│   ├── edit_item_screen.dart
│   ├── menu_analysis_screen.dart
│   └── settings_screen.dart
├── router/                 # Navigation
│   └── app_router.dart
└── main.dart              # App entry point
```

## Performance Optimizations

**Caching Strategy**
- Date-based caching with 7-day LRU cache
- Suggestions cache with 5-minute TTL
- Automatic cache invalidation on data changes

**Database Indexing**
- idx_items_date: Fast date filtering
- idx_items_name_lower: Thai language grouping optimization

**UI Performance**
- RepaintBoundary for complex widgets
- ListView.builder for efficient list rendering
- Skeleton loaders for loading states

## Development Setup

**Prerequisites**
- Flutter SDK 3.10.4 or higher
- Dart SDK
- Android Studio or VS Code with Flutter extensions

**Installation**
1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Run `flutter run` to start the app

**Build Release APK**
```bash
flutter build apk --release
```

## Database Schema

**items table**
- id: INTEGER PRIMARY KEY AUTOINCREMENT
- name: TEXT NOT NULL
- price: REAL NOT NULL
- date: TEXT NOT NULL (YYYY-MM-DD format)
- reason: TEXT (optional notes)
- created_at: TEXT (timestamp)
- updated_at: TEXT (timestamp)

**Indexes**
- idx_items_date ON items(date)
- idx_items_name_lower ON items(LOWER(name))

## Color Palette

**Primary Colors**
- Primary: #2E7D8C (Soft Teal)
- Secondary: #6B9B7D (Sage Green)
- Tertiary: #D97D54 (Warm Terracotta)

**Surfaces**
- Surface: #F8F9FA (Soft Off-white)
- Background: #FAFBFC (Warm Background)
- Text: #2C3E50 (High Contrast Blue-grey)

**Accessibility**
- WCAG AAA compliant contrast ratios
- High visibility error states
- Clear visual hierarchy

## Version History

**v1.1.0**
- Added smart item suggestions with usage count
- Implemented 5-minute caching for suggestions
- Added expression index for Thai language support
- New senior-friendly color theme (teal, sage, terracotta)
- Added "Today" button for quick date navigation
- Improved touch targets and text sizes
- Added app version display in settings

**v1.0.0**
- Initial release
- Basic item CRUD operations
- Date-based item filtering
- Menu sharing functionality
- Settings for header and footer customization

## License

This project is private and not intended for public distribution.

## Support

For issues or questions, please contact the development team.
