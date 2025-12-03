# ProGuard / R8 rules for Flutter + common libraries
# Keep Flutter/Dart entry points and avoid stripping required classes.

# Flutter engine bindings
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**

# Keep AppCompat and Kotlin metadata
-keep class androidx.** { *; }
-dontwarn androidx.**
-keep class kotlin.** { *; }
-dontwarn kotlin.**

# Keep annotations (used by reflection)
-keepattributes *Annotation*

# Keep Application, Activities, and Content Providers
-keep class **.MainActivity { *; }
-keep class **.MainApplication { *; }
-keep class **.Application { *; }
-keep class **.provider.** { *; }

# Keep classes referenced via reflection (adjust as needed)
# -keep class com.yourpkg.** { *; }

# Retain resource class names
-keep class **.R$* { *; }

# Optional: Improve stacktrace mapping with obfuscation
-renamesourcefileattribute SourceFile
-keepattributes SourceFile,LineNumberTable
