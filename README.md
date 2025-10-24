# Legate My Car (لقيت عربيتي)

🇸🇩 A Sudanese platform to help citizens find their lost or abandoned cars

## App Concept

"Legate My Car" (لقيت عربيتي) is a youth initiative by a group of volunteers in Khartoum, aimed at helping people find their lost or stolen cars during the war period. The team roams the streets, photographs abandoned cars, and documents their data in the app, allowing owners to search for them easily.

## App Contents

### 1. 🏠 Home Page

- Contains a list of the latest cars added by the team
- Each car is displayed as a card containing:
  - Car image
  - Plate number (if available)
  - Car type and model
  - Color
  - Date added

### 2. 🔍 Search Bar at the Top

- Contains a search icon in the header
- Users can search by:
  - Plate number
  - Brand or model
  - Color
  - Area
- Search displays results instantly in an organized and fast manner

### 3. ➕ Add Car Section (Report)

- Any volunteer or user can upload data of a car they found on the street
- Required fields:
  - Car images (from sides)
  - Plate number (if available)
  - Car type and model
  - Color
  - Condition description (e.g., abandoned, burned, damaged...)
  - Location

### 4. 🚙 Missing Cars Section

- Displays cars that owners have reported as missing
- Any volunteer can review them and try to find them
- Each report contains:
  - Complete car data
  - Last known location
  - Contact owner option (via in-app notifications)

## Visual Identity

- **Colors**: From Sudan flag 🇸🇩
  - 🔴 **Red** → Determination and rescue
  - ⚫ **Black** → Resilience
  - ⚪ **White** → Purity and transparency
  - 🟢 **Green** → Hope and life
- **Icons**: Car, Sudan map, location pin (📍)
- **Font**: Clear and easy-to-read Arabic font, in a formal (Corporate) style

## App Features

- 📱 View all lost cars with detailed information
- 🔍 Advanced search functionality for cars by various criteria
- 🎨 Modern UI with Sudan flag-inspired theme
- 🏗️ MVVM architecture with GetX state management
- 📊 Real-time data from API
- 🌍 Multi-language support (English & Arabic)
- 🔄 RTL (Right-to-Left) support for Arabic
- 🎛️ Easy language switching
- 📸 Photo upload for found cars
- 📍 Location-based search
- 🔔 Push notifications for matches
- 👥 Volunteer reporting system
- 📋 Missing car reports

## App Theme

- **Red**: #DC143C (Determination and rescue)
- **Black**: #000000 (Resilience)
- **White**: #FFFFFF (Purity and transparency)
- **Green**: #228B22 (Hope and life)

## Car Model Structure

```json
{
  "id": 1,
  "plate_number": "QHH-1734",
  "chassis_number": "6408A776914E4C8D9",
  "brand": "BMW",
  "model": "5 Series",
  "color": "Orange",
  "description": "Missing car last seen at Shopping Mall. Please contact owner.",
  "image_path": null,
  "user_id": 2,
  "status": "lost",
  "lost_date": "2025-09-13T00:00:00.000000Z",
  "location": "Shopping Mall",
  "contact_info": "@owner585",
  "created_at": "2025-10-24T08:26:18.000000Z"
}
```

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio / VS Code
- iOS Simulator / Android Emulator

### Installation

1. Clone the repository
2. Navigate to the project directory
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Configure environment variables in `.env` file
5. Run the app:
   ```bash
   flutter run
   ```

## Architecture

- **MVVM Pattern**: Model-View-ViewModel architecture
- **State Management**: GetX for reactive state management
- **API Integration**: HTTP client for data fetching
- **Environment Configuration**: Environment variables for API URLs
- **Internationalization**: GetX translation system with RTL support

## Vision

To make "Legate My Car" (لقيت عربيتي) the first platform in Sudan for documenting lost and abandoned cars, and to be a bridge between the community, volunteers, and relevant authorities to restore property safely.

## Project Structure

```
lib/
├── main.dart
├── models/
│   ├── car_model.dart
│   └── missing_car_model.dart
├── views/
│   ├── car_list_view.dart
│   ├── missing_cars_view.dart
│   └── add_car_view.dart
├── viewmodels/
│   ├── car_viewmodel.dart
│   └── missing_car_viewmodel.dart
├── controllers/
│   └── language_controller.dart
├── services/
│   ├── api_service.dart
│   ├── car_api_service.dart
│   └── demo_data_service.dart
├── translations/
│   ├── app_translations.dart
│   ├── en_translations.dart
│   └── ar_translations.dart
├── config/
│   └── env_config.dart
├── utils/
│   ├── constants.dart
│   └── translation_helper.dart
└── theme/
    └── app_theme.dart
```

## Environment Setup

Create a `.env` file in the root directory with:

```
API_BASE_URL=your_api_url_here
```

## Translation System

The app supports multiple languages with GetX translation system using organized file structure:

### Supported Languages

- **English** (en_US) - Default language
- **Arabic** (ar_SA) - With RTL support

### Translation Structure

```
lib/translations/
├── app_translations.dart    # Main translation class
├── en_translations.dart     # English translations
├── ar_translations.dart     # Arabic translations
└── utils/
    └── translation_helper.dart  # Translation utilities
```

### Key Features

- **Uppercase Keys**: All translation keys use UPPERCASE format for consistency
- **Separate Files**: Each language has its own dedicated file
- **Easy Maintenance**: Clean separation makes it easy to manage translations
- **RTL Support**: Automatic text direction for Arabic
- **Helper Utilities**: Translation helper for advanced usage

### How to Use

1. Tap the language icon in the app bar
2. Select your preferred language
3. The app will automatically switch languages and adjust text direction

### Adding New Languages

1. Create new translation file (e.g., `fr_translations.dart`)
2. Add translations with uppercase keys
3. Import and add to `AppTranslations` class
4. Add locale to `LanguageController.supportedLocales`
5. Update the language switcher dialog

### Translation Key Format

All keys use UPPERCASE format:

```dart
'APP_TITLE'.tr           // App Title
'SEARCH_HINT'.tr         // Search hint text
'STATUS_LOST'.tr         // Lost status
'CONTACT_OWNER'.tr       // Contact owner button
```

## Dependencies

- `get`: State management, routing, and translations
- `http`: API calls
- `intl`: Date formatting
- `cached_network_image`: Image handling
