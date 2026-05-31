# Flutter ProGuard Rules
# 防止Flutter相关类被混淆导致白屏/崩溃

# Flutter 框架
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Flutter 本地代码
-keep class com.example.novel_ide.** { *; }

# 保留注解
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exceptions
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# 保留 native 方法
-keepclasseswithmembernames class * {
    native <methods>;
}

# 保留枚举
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# 保留 Parcelable
-keep class * implements android.os.Parcelable {
  public static final android.os.Parcelable$Creator *;
}

# 保留 Serializable
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Riverpod / Provider
-keep class * extends StateNotifier { *; }
-keep class * extends State { *; }

# Hive
-keep class * extends HiveObject { *; }
-keep class * { @com.hive.HiveField *; }

# 权限处理器
-keep class com.baseflow.permissionhandler.** { *; }

# 文件选择器
-keep class com.mr.flutter.plugin.filepicker.** { *; }

# Share Plus
-keep class dev.fluttercommunity.plus.share.** { *; }

# 路径提供者
-keep class io.flutter.plugins.pathprovider.** { *; }

# 网络连接
-keep class com.github.florent37.assets_audio_player.** { *; }

# Hive（补充）
-keep class io.flutter.plugins.hive.** { *; }
-keep class * extends HiveObject { *; }

# flutter_secure_storage
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# sqflite
-keep class com.tekartik.sqflite.** { *; }

# shared_preferences
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# url_launcher
-keep class io.flutter.plugins.urllauncher.** { *; }

# speech_to_text
-keep class com.csdcorp.speech_to_text.** { *; }

# local_notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# WebView
-keep class android.webkit.** { *; }
-keep class io.flutter.plugins.webviewflutter.** { *; }

# Dio 网络库
-keep class io.flutter.plugins.connectivity.** { *; }

# 避免警告
-dontwarn io.flutter.embedding.**
-dontwarn android.**
-dontwarn javax.annotation.**
-dontwarn sun.misc.Unsafe
-dontwarn org.codehaus.mojo.animal_snigner.**
