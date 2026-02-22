# Nedo Core Architecture

This package provides the core architectural components for Flutter applications, designed around **Clean Architecture** principles. It streamlines error handling, networking, local storage, and localization, allowing you to focus on feature implementation.

## 🌟 Features

- **Robust Error Handling**: Standardized flow from Exception to UI-friendly messages.
- **Functional Programming**: Built-in support for `fpdart` (`Either<Failure, T>`) for safe error handling.
- **Network Module**: Pre-configured `DioClient` with interceptors, logging, and global error parsing.
- **Database Module**: Pre-configured `DatabaseService` with `sqflite` for managing local database.
- **Secure Storage**: Helper wrapper around `flutter_secure_storage` for managing tokens.
- **Localization**: Ready-to-use localization (ID/EN) for standard error messages.

## 🏗️ Architecture & Error Handling Flow

This brick enforces a strict unidirectional data flow for error handling:

1.  **Data Source (Core)**: The `DioClient` catches raw `DioException` and parses them into domain-specific exceptions (e.g., `ServerException`, `NetworkException`).
2.  **Repository**: Catches these Exceptions and maps them into **`Failure`** objects (returning `Left(Failure)` via `fpdart`).
3.  **Bloc/Cubit**: Calls the UseCase, folds the result, and emits an error state containing the `Failure` object.
4.  **UI**: Consumes the `Failure` object. Using the extension method `.getLocalizedMessage(context)`, the UI automatically displays the correct, localized error message to the user without needing manual `if-else` checks in the view.

## 📦 Dependencies

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  equatable: ^2.0.5
  fpdart: ^1.1.0
  intl: ^0.19.0 
  dio: ^5.0.0
  flutter_secure_storage: ^8.0.0
  sqflite: ^2.4.2
  google_fonts: ^8.0.0
  image_picker: ^1.0.7
  permission_handler: ^11.3.0
  connectivity_plus: ^5.0.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1

flutter:
  uses-material-design: true

# Required for code generation
flutter:
  generate: true
```

## Setup & Usage

1. Installation
Run the brick to generate the core files in your project:
```bash
mason make nedo_core
```

2. Post-Install Setup
After generation, run these commands to install dependencies and generate localization files:
```bash
flutter pub get
flutter gen-l10n
```

3. Usage Example (UI)
When your Bloc state returns a Failure, you can display it easily:
```dart
// In your UI (e.g., SnackBar or Dialog)
if (state is ErrorState) {
  // Automatically gets the localized message (e.g., "Koneksi internet bermasalah" or "Connection timeout")
  // based on the specific failure type.
  final message = state.failure.getLocalizedMessage(context);
  
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
```

4. Api Configuration
Modify lib/core/network/api_config.dart to set your base URL:
```dart
factory ApiConfig.defaultConfig() {
  return const ApiConfig(
    baseUrl: '[https://api.your-backend.com](https://api.your-backend.com)',
    connectTimeout: Duration(seconds: 30),
  )
}
```

## 📂 Folder Structure
```
lib/
├── core/
│   ├── error/              # Failure (Domain) and Exception (Data) classes.
│   ├── l10n/               # Localization files (.arb).
│   ├── network/            # DioClient, Interceptors, and API configurations.
│   ├── services/           # External services (e.g., SecureStorage, Database).
│   ├── usecase/            # Base UseCase class (forces Either<Failure, T>).
│   └── extension/          # Helper extensions (e.g., ScreenSize, Localization, Theme).
l10n.yaml                   # Localization configuration file.
```