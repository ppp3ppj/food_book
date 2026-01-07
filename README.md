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

**Menu Sharing** NEW in v1.2.x
- Triple-mode sharing: Native share dialog, direct LINE sharing, or text preview
- Share to any app (LINE, WhatsApp, messaging, email, etc.)
- One-tap direct sharing to LINE app
- Preview formatted text before sharing
- Preserves Thai text formatting and menu structure
- Smart error handling for missing apps

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
- share_plus: Native share dialog functionality
- url_launcher: Deep linking and external app launching

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

## Using the Sharing Feature

**How to Share Your Menu:**

1. **Open the main screen** (Item List)
2. **Tap the share icon** in the top-right corner
3. **Choose your sharing method:**
   - **แชร์ไปยังแอปอื่น** (Share to other apps): Opens native share dialog where you can choose any installed app
   - **แชร์ไปยัง LINE** (Share to LINE): Directly opens LINE app with pre-filled menu text
   - **ดูตัวอย่างข้อความ** (View Text Preview): Preview the formatted text before deciding how to share

**Shared Format:**
```
[Your custom header]
วันที่ 7 ม.ค. 2569

1. ข้าวผัด - ฿45.00
   หมายเหตุ: ไม่ใส่ผัก

2. กะเพราหมู - ฿50.00

[Your custom footer]
```

**Requirements:**
- For LINE sharing: LINE app must be installed on your device
- Internet connection not required (shares locally stored data)

## Development Setup

**Prerequisites**
- Flutter SDK 3.10.4 or higher
- Dart SDK
- Android Studio or VS Code with Flutter extensions
- For LINE sharing feature: Android 11+ requires AndroidManifest.xml configuration

**Installation**
1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Run `flutter run` to start the app

**Build Release APK**
```bash
flutter build apk --release
```

**Android Configuration for Sharing:**
The app includes LINE app query configuration in `AndroidManifest.xml`:
```xml
<queries>
    <intent>
        <action android:name="android.intent.action.VIEW"/>
        <data android:scheme="line"/>
    </intent>
</queries>
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

**v1.2.1** Latest
- **NEW: Text preview option in sharing menu**
  - Added "ดูตัวอย่างข้อความ" (View Text Preview) as third sharing option
  - Preview formatted menu text before sharing
  - Selectable text in preview dialog for partial copying
  - Orange visibility icon for easy identification
- **Enhanced User Experience**
  - Users can verify menu content before deciding how to share
  - Senior-friendly dialog with large, readable text
  - Consistent Thai language and visual design

**v1.2.0**
- **NEW: Dual-mode menu sharing functionality**
  - Native share dialog: Share to any app (LINE, WhatsApp, messaging, etc.)
  - Direct LINE sharing: One-tap sharing directly to LINE app
  - Bottom sheet UI with large touch targets for senior-friendly access
- **Package Updates**
  - Updated share_plus to 12.0.1 (migrated to new SharePlus API)
  - Updated url_launcher to 6.3.2 for LINE deep linking
- **Android Configuration**
  - Added LINE app query intent for Android 11+ compatibility
- **Enhanced User Experience**
  - Thai language support throughout sharing flow
  - Smart error handling when LINE app is not installed
  - Preserves menu text formatting in all sharing methods

**v1.1.1**
- Fixed delete item UI refresh bug for non-current dates
- Delete now correctly reloads the viewed date instead of today
- Updated package_info_plus to version 9.0.0

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
