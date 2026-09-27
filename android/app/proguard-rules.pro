# ≈ the same proguard-rules.pro you know from Android.
# Flutter's Gradle plugin already adds rules for the engine and plugins.
# Add keep rules here for any reflection-based native libraries you add.

# Strip android.util.Log calls from release builds (defence in depth).
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}
