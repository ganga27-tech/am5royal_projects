# Razorpay SDK Keep Rules
-keep class com.razorpay.** { *; }
-dontwarn com.razorpay.**
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}
-keepattributes *Annotation*,InnerClasses
-dontwarn android.webkit.JavascriptInterface
