# ============================================================
# Flutter Local Notifications
# ============================================================
-keep class com.dexterous.** { *; }
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# ============================================================
# Gson — dipakai flutter_local_notifications untuk serialisasi
# ============================================================
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer
-keepclassmembers,allowobfuscation class * {
  @com.google.gson.annotations.SerializedName <fields>;
}

# ============================================================
# Timezone library
# ============================================================
-keep class org.threeten.** { *; }
-keep class com.jakewharton.threetenabp.** { *; }

# ============================================================
# Flutter & Dart
# ============================================================
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# ============================================================
# Supabase / OkHttp / Kotlin Coroutines
# ============================================================
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }
-keep class kotlin.coroutines.** { *; }
-keepclassmembers class kotlin.Metadata { *; }