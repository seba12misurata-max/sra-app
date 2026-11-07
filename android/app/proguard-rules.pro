# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Kotlin
-keep class kotlin.** { *; }

# HTTP
-keepattributes *Annotation*
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# File Picker
-keep class com.mr.flutter.plugin.filepicker.** { *; }
