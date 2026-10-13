## Flutter wrapper
#-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
#-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-dontwarn io.flutter.embedding.**
-dontwarn android.**

-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

-keepattributes JavascriptInterface
-keepattributes *Annotation*
-keepattributes LineNumberTable,SourceFile

-dontwarn com.razorpay.**
-keep class com.razorpay.** {*;}

-optimizations !method/inlining/*

-keepclasseswithmembers class * {
  public void onPayment*(...);
}



# AGP 9 (2026-10-13): the old proguard-android.txt (which turned optimisation off) is no longer allowed, so the
# build uses proguard-android-optimize.txt; this keeps release builds as they were (no R8 optimisation) until
# a release build has been tested with optimisation on.
-dontoptimize
