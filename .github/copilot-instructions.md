# Copilot Instructions - Emergency Tracker App

## 📱 Project Overview
This is a Flutter-based **Emergency Preparedness Tracker** application (`acil_durum_takip`) designed for emergency preparedness with dark theme UI, 20-language localization support, and strict adherence to memory-bank specifications.

**Key Characteristics:**
- 7 main screens implementing memory-bank/02_ui-structure.md specs
- Custom AppLocalizations delegate with JSON-based translations
- Shared navigation component with consistent Material Symbols icons
- Dark theme with specified color palette (ThemeColors)
- Emergency preparedness focus with product expiry tracking

---

## 🏗️ Architecture Patterns

### Core Structure
```
lib/
├── main.dart                    # App entry point with MaterialApp setup
├── l10n/
│   └── app_localizations.dart   # Custom localization delegate
├── screens/                     # 7 main screens + settings
├── widgets/
│   └── app_bottom_navigation.dart # Shared navigation component
├── models/                      # Product, Bag, Category SA models
├── services/                    # DataService, NotificationService
└── theme/
    └── theme_colors.dart        # Centralized color definitions
```

### Critical Components

#### 1. Localization System (`lib/l10n/app_localizations.dart`)
```dart
// ALWAYS use this pattern for translations
final loc = AppLocalizations.of(context);
Text(loc.translate('home.title'))

// With replacements
Text(loc.translate('bags.create.success', replacements: {'name': bagName}))
```

**Key Features:**
- Custom delegate implementation (NOT flutter_localizations generate)
- Turkish fallback system with 20 language support
- JSON-based translations in `assets/lang/{code}.json`
- Placeholder replacement support with `{key}` format

#### 2. Shared Navigation (`lib/widgets/app_bottom_navigation.dart`)
```dart
// ALWAYS use AppBottomNavigation in Scaffold bottomNavigationBar
AppBottomNavigation(current: AppNavItem.home)

// Navigation items: home, bags, depot, products, settings, info
enum AppNavItem { home, bags, depot, products, settings, info }
```

#### 3. Theme System (`lib/theme/theme_colors.dart`)
```dart
// ALWAYS use ThemeColors constants
backgroundColor: ThemeColors.bg1,        // Ana Sayfa: #121212
backgroundColor: ThemeColors.bg2,        // Yeni Ürün: #111714
backgroundColor: ThemeColors.bg3,        // Yeni Çanta: #1A181D
color: ThemeColors.pastelGreen,         // Success, selections: #A2E4B8
```

---

## 📋 Memory-Bank Compliance

### CRITICAL: Always Reference Memory-Bank Specs
Before making changes to UI/UX, data models, or navigation:

1. **UI Structure**: Check `memory-bank/02_ui-structure.md` for screen layouts
2. **Data Models**: Reference `memory-bank/03_data-models.md` for schemas
3. **Colors**: Use `memory-bank/06_system-patterns.md` color definitions
4. **Localization**: Follow `memory-bank/05_i18n-strategy.md` patterns

### Screen-Specific Rules

#### Ana Sayfa (Home Screen)
- Background: `ThemeColors.bg1` (#121212)
- Status cards with gradient backgrounds
- Icons: Material Symbols outlined style
- Critical alerts in red/yellow gradients

#### Yeni Ürün Ekle (Add Product)
- Background: `ThemeColors.bg2` (#111714)
- **34 fixed categories** from memory-bank/03_data-models.md
- Primary color: `ThemeColors.primaryGreen` (#38e07b)
- Form validation required for all fields

#### Navigation Structure
```
[Ana Sayfa] [Çantalar] [Depo] [Ürünler] [Ayarlar] [Bilgi]
```
**NEVER modify this order** - it matches memory-bank specifications.

---

## 🌐 Localization Guidelines

### JSON Structure Rules
```json
{
  "nav.home": "Ana Sayfa",
  "home.title": "Acil Durum Çantam", 
  "bags.create.success": "{name} çantası oluşturuldu!",
  "settings.notifications.title": "Bildirim Ayarları"
}
```

### Key Naming Convention
- **Hierarchical**: `screen.section.element`
- **Navigation**: `nav.{item}`
- **Actions**: `{action}.{context}` (e.g., `save.product`)
- **Placeholders**: Use `{key}` format for dynamic content

### Adding New Translations
1. Add key to `assets/lang/tr.json` (Turkish master)
2. Add same key to `assets/lang/en.json` (English fallback)
3. Optional: Add to other 18 language files
4. Use `AppLocalizations.of(context).translate('key')` in code

---

## 🎨 UI/UX Standards

### Color Usage Rules
```dart
// Status colors
ThemeColors.pastelGreen  // Success, search, selections
ThemeColors.pastelYellow // Warnings, expiring items
ThemeColors.pastelRed    // Errors, critical alerts
ThemeColors.pastelBlue   // PDF files, info
ThemeColors.pastelPurple // Media files, JPG

// Action colors
ThemeColors.primaryGreen  // Add Product button
ThemeColors.primaryPurple // Create Bag button
```

### Icon Standards
- **ALWAYS use Material Symbols outlined icons**
- Examples: `Icons.home_outlined`, `Icons.settings_outlined`
- Consistent sizing: usually 24.0 or as specified in designs

### Layout Patterns
```dart
// Standard card layout
Container(
  decoration: BoxDecoration(
    color: ThemeColors.bgCard,
    borderRadius: BorderRadius.circular(12),
  ),
  // content
)

// Status indicators with appropriate colors
Container(
  decoration: BoxDecoration(
    color: isExpired ? ThemeColors.pastelRed : ThemeColors.pastelGreen,
    borderRadius: BorderRadius.circular(8),
  ),
)
```

---

## 📱 Screen Implementation Guidelines

### New Screen Checklist
When creating/modifying screens:

1. **[ ]** Extends StatefulWidget if state management needed
2. **[ ]** Uses `AppBottomNavigation(current: AppNavItem.{screen})`
3. **[ ]** Implements proper localization with `AppLocalizations.of(context)`
4. **[ ]** Follows memory-bank color specifications
5. **[ ]** Uses Material Symbols outlined icons
6. **[ ]** Handles responsive overflow with `Expanded`/`Flexible`
7. **[ ]** Includes proper error handling for async operations

### Screen Template
```dart
class NewScreen extends StatefulWidget {
  const NewScreen({super.key});

  @override
  State<NewScreen> createState() => _NewScreenState();
}

class _NewScreenState extends State<NewScreen> {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: ThemeColors.bg1, // or appropriate background
      appBar: AppBar(
        title: Text(loc.translate('screen.title')),
        backgroundColor: Colors.transparent,
      ),
      body: // Screen content
      bottomNavigationBar: const AppBottomNavigation(
        current: AppNavItem.home, // Set appropriate nav item
      ),
    );
  }
}
```

---

## 🔧 Development Workflow

### Build Commands
```bash
# Debug build
flutter run

# Release APK build
flutter build apk --release

# Analyze code quality
flutter analyze

# Run tests
flutter test
```

### Device Testing
```bash
# Install debug APK
adb install -r build/app/outputs/flutter-apk/app-debug.apk

# Install release APK  
adb install -r build/app/outputs/flutter-apk/app-release.apk

# Launch app
adb shell am start -n com.example.acil_durum_takip/.MainActivity
```

### Localization Testing
1. Change device language to test different locales
2. Verify fallback to Turkish for missing keys
3. Test placeholder replacements work correctly
4. Ensure UI adjusts for text length variations

---

## 🚨 Critical Rules & Constraints

### NEVER Modify These Components Without Review
1. **AppLocalizations delegate** - Custom implementation, not generated
2. **AppBottomNavigation** - Shared across all screens
3. **ThemeColors** - Matches memory-bank specifications
4. **Navigation routes** in main.dart - Affects app structure
5. **Memory-bank compliance** - Core project requirement

### Code Quality Standards
- **0 Flutter analyzer errors** - Run `flutter analyze` before commits
- **Material 3 compliance** - Use `useMaterial3: true`
- **Dark theme only** - No light theme implementation
- **Consistent spacing** - Use standard Flutter spacing (8, 16, 24, 32)

### State Management
- Use `StatefulWidget` for local state
- `DataService` singleton for app-wide data
- Avoid complex state management libraries (Provider used minimally)

---

## 📦 Dependencies & Versions

### Core Dependencies
```yaml
flutter_localizations: sdk    # For basic localization support
provider: ^6.1.2             # Minimal state management
hive: ^2.2.3                 # Local data storage
image_picker: ^1.1.2         # Camera/gallery access
flutter_local_notifications: ^18.0.1  # Push notifications
```

### Asset Structure
```
assets/
└── lang/
    ├── tr.json  # Master language (Turkish)
    ├── en.json  # Primary fallback (English)
    └── [18 other language files]
```

---

## 🎯 AI Assistant Guidelines

When working on this project:

1. **Always check memory-bank files first** for specifications
2. **Use existing patterns** - don't reinvent localization or navigation
3. **Maintain color consistency** - reference ThemeColors for all colors
4. **Test on real devices** when possible, especially for UI overflow
5. **Preserve Turkish as primary language** - it's the target audience
6. **Follow emergency preparedness context** - this isn't a generic app

### Common Tasks Quick Reference

**Adding a new screen:**
1. Create in `lib/screens/`
2. Add route to `main.dart`
3. Add navigation item to `AppNavItem` enum if needed
4. Add localization keys to `tr.json` and `en.json`

**Adding new localizations:**
1. Add key to `assets/lang/tr.json`
2. Add same key to `assets/lang/en.json` 
3. Use `AppLocalizations.of(context).translate('key')` in UI

**Styling components:**
1. Check memory-bank specs for colors
2. Use `ThemeColors.{color}` constants
3. Apply Material Symbols outlined icons
4. Test responsive behavior with `Expanded`/`Flexible`

---

**Remember: This is an emergency preparedness app - prioritize reliability, accessibility, and adherence to proven patterns over experimental features.**