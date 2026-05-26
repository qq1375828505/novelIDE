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

# 避免警告
-dontwarn io.flutter.embedding.**
-dontwarn android.**
