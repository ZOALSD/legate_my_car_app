# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# Uncomment this to preserve the line number information for
# debugging stack traces.
#-keepattributes SourceFile,LineNumberTable

# If you keep the line number information, uncomment this to
# hide the original source file name.
#-renamesourcefileattribute SourceFile

# Keep network-related classes
-keep class okhttp3.** { *; }
-keep class retrofit2.** { *; }
-keep class com.google.android.gms.** { *; }
-keep class com.google.android.gms.maps.** { *; }

# Keep Dio and network classes
-keep class dio.** { *; }
-keep class flutter_map.** { *; }

# Keep connectivity classes
-keep class dev.fluttercommunity.plus.connectivity.** { *; }

# Keep geolocator classes
-keep class com.baseflow.geolocator.** { *; }

# Keep all native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep all classes that might be used by reflection
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# Keep all public classes and methods
-keep public class * {
    public <methods>;
}

# Keep all classes in the app package
-keep class com.laqeetarabeety.managers.** { *; }
