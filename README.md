# Flutter for Android Devs

A learn-by-example Flutter app for Android developers. Every screen maps a
Flutter idea to the Android concept you already know, with animated explainers
and hands-on component demos.

## What's inside

| Tab | What it teaches |
|-----|-----------------|
| **Learn** | 16 concepts (widgets, state, lifecycle, layouts, lists, navigation, state management, async, isolates, platform channels, animations, theming, hot reload, the three trees, build modes). Each concept has three tabs: **Learn** (explanation + Brain Power + Bullet Points), **Animate** (interactive animated demo) and **Compare** (Android vs Flutter table + code). |
| **Components** | 13 working demos: Layouts, Lists & Grids, Navigation (with results), Forms, Dialogs, Networking (http + FutureBuilder), Local Storage, State (Provider cart), Streams, Lifecycle logger, Background work (Isolates), Animations (incl. Hero), Platform Channel (real Kotlin code). |
| **Settings** | Light/dark/system theme persisted with SharedPreferences, device & build info. |

## Docs (`docs/`)

| PDF | Contents |
|-----|----------|
| `01_Flutter_Project_Structure_for_Android_Devs.pdf` | Every folder and file explained with its Android equivalent, the architecture of this app, the Android → Flutter Rosetta Stone, Dart for Kotlin developers, daily workflow |
| `02_Flutter_Core_Concepts_for_Android_Devs.pdf` | Widgets, layouts, lists, navigation, state management, async/isolates, platform channels, animations, theming, internals |
| `03_Flutter_Lifecycle_Signing_Publishing.pdf` | Widget and app lifecycles, process death, versioning, flavors, keystores and Play App Signing, publishing to Google Play, CI/CD, App Store overview |
| `04_Flutter_App_Security_Guide.pdf` | Threat model, HTTPS and SSL pinning in Dart, obfuscation, secrets, secure storage, root/tamper detection, FLAG_SECURE, auth, deep links, WebViews, supply chain, release security checklist |

## Run it

```bash
flutter doctor        # fix anything marked with a cross
flutter pub get
flutter run           # r = hot reload, R = hot restart, q = quit
flutter test          # widget tests
flutter analyze       # lints
```

## Project layout

```
lib/
├── main.dart                 entry point (≈ Application + launcher Activity)
├── app.dart                  MaterialApp: theme + routes (≈ <application>)
├── core/routes/              screen registry (≈ <activity> list + Intents)
├── core/theme/               ThemeData (≈ themes.xml / colors.xml)
├── data/                     models, ApiService (≈ Retrofit), StorageService, repository
├── state/                    ChangeNotifiers (≈ ViewModels)
├── widgets/                  reusable widgets (≈ custom views)
└── features/                 home, learn (+ demos/), components, settings
android/app/src/main/kotlin/.../MainActivity.kt   MethodChannel for battery/device info
```

## Release signing

Create `android/key.properties` (git-ignored) pointing to your upload keystore.
See chapter 5 of `docs/03_Flutter_Lifecycle_Signing_Publishing.pdf`. Without it,
release builds fall back to the debug key so you can still run `flutter run --release`.
