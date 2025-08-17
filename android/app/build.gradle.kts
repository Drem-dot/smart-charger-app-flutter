import java.util.Properties
import java.io.File
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Cú pháp Kotlin để đọc file .env
// 1. Khai báo biến bằng val và gọi constructor đầy đủ
val dotEnv = Properties()
// 2. Sử dụng project.rootDir để có đường dẫn chính xác và an toàn hơn
val dotEnvFile = File(project.rootDir, "../.env")
// 3. Cú pháp if và load vẫn tương tự
if (dotEnvFile.exists()) {
    dotEnv.load(FileInputStream(dotEnvFile))
}

android {
    namespace = "com.example.smart_charger_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "29.0.13846066"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // 4. Cú pháp Kotlin cho resValue và cách lấy thuộc tính từ Properties
        resValue(
            "string",
            "google_maps_key",
            dotEnv.getProperty("GOOGLE_MAPS_API_KEY", "NO_KEY")
        )
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}