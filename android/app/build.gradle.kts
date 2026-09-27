import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// ── Release signing ───────────────────────────────────────────────
// Create android/key.properties (NEVER commit it) with:
//   storePassword=...
//   keyPassword=...
//   keyAlias=upload
//   storeFile=/absolute/path/to/upload-keystore.jks
// See docs/03_Flutter_Lifecycle_Signing_Publishing.pdf
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.example.learnflutter.flutter_learning_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // Change this to your own unique id before publishing (it can never change later).
        applicationId = "com.example.learnflutter.flutter_learning_app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Both come from `version: 1.0.0+1` in pubspec.yaml
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (keystorePropertiesFile.exists()) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            // Use the upload key when key.properties exists, otherwise fall back
            // to debug keys so `flutter run --release` still works while learning.
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            // R8: shrink + obfuscate the Java/Kotlin side.
            // (Dart code is obfuscated separately with --obfuscate.)
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
