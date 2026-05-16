# rail_one

A new Flutter project.

## Environments & Flavors

This project uses Flutter flavors to manage different environments: Development, Staging, and Production.

#First get all dependencies
```bash
flutter pub get
```

# BUILD RUNNER
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```



### Running the App

To run the app in a specific environment, use the `--flavor` flag.

**Development:**
```bash
flutter run --flavor dev 
```

**Staging:**
```bash
flutter run --flavor staging -t lib/main_staging.dart
```

**Production:**
```bash
flutter run --flavor prod -t lib/main_prod.dart
```

### Building the App (APK)

**Development:**
```bash
flutter build apk --flavor dev -t lib/main_dev.dart
```

**Staging:**
```bash
flutter build apk --flavor staging  
```

**Production:**
```bash
flutter build apk --flavor production
```

### Building the App (iOS)

**Development:**
```bash
flutter build ipa --flavor dev 
```

**Staging:**
```bash
flutter build ipa --flavor staging 
```

**Production:**
```bash
flutter build ipa --flavor production
```
