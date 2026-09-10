import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Load signing config from key.properties
val keyPropertiesFile = rootProject.file("key.properties")
val keyProperties = Properties()
if (keyPropertiesFile.exists()) {
    keyProperties.load(FileInputStream(keyPropertiesFile))
}

android {
    namespace = "in.finora.app"
    compileSdk = flutter.compileSdkVersion

    // Use pre-installed NDK if available to avoid downloading and unzipping NDK on CI
    val ndkHome = System.getenv("ANDROID_NDK_HOME")
    val ndkDir = File(System.getenv("ANDROID_SDK_ROOT") ?: System.getenv("ANDROID_HOME") ?: "", "ndk")
    val installedNdk = when {
        !ndkHome.isNullOrBlank() -> File(ndkHome).name
        ndkDir.exists() -> ndkDir.listFiles()?.filter { it.isDirectory }?.map { it.name }?.sortedDescending()?.firstOrNull()
        else -> null
    }
    ndkVersion = installedNdk ?: flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    signingConfigs {
        create("release") {
            keyAlias = keyProperties["keyAlias"] as String? ?: System.getenv("KEY_ALIAS") ?: ""
            keyPassword = keyProperties["keyPassword"] as String? ?: System.getenv("KEY_PASSWORD") ?: ""
            storeFile = keyProperties["storeFile"]?.let { file(it as String) }
                ?: System.getenv("KEYSTORE_PATH")?.let { file(it) }
            storePassword = keyProperties["storePassword"] as String? ?: System.getenv("STORE_PASSWORD") ?: ""
        }
    }

    defaultConfig {
        applicationId = "in.finora.app"
        minSdk = flutter.minSdkVersion  // Required for Firebase Auth Google Sign-In
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            signingConfig = signingConfigs.getByName("release")
        }
        debug {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
