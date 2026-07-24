# Keep ML Kit and Google Play Services classes to prevent NullPointerException in release builds
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.mlkit.**
-dontwarn com.google.android.gms.**

# Keep mobile_scanner classes
-keep class dev.steenbakker.mobile_scanner.** { *; }
-dontwarn dev.steenbakker.mobile_scanner.**
