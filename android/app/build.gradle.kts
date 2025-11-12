import java.util.Properties

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties().apply {
    val keystorePropertiesFile = rootProject.file("key.properties")
    if (keystorePropertiesFile.exists()) {
        keystorePropertiesFile.inputStream().use { load(it) }
    }
}

android {
    namespace = "com.appistry.vezu"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.appistry.vezu"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        getByName("debug") {
            keyAlias = (keystoreProperties["keyAlias"] as String?) ?: "flutter_key"
            keyPassword = (keystoreProperties["keyPassword"] as String?) ?: "Ercin!1283."
            storeFile = (keystoreProperties["storeFile"] as String?)?.let { file(it) }
                ?: file("/Users/ercinakkaya/Desktop/code/school/flutter_keystore.jks")
            storePassword = (keystoreProperties["storePassword"] as String?) ?: "Ercin!1283."
        }
        create("release") {
            keyAlias = (keystoreProperties["keyAlias"] as String?) ?: "flutter_key"
            keyPassword = (keystoreProperties["keyPassword"] as String?) ?: "Ercin!1283."
            storeFile = (keystoreProperties["storeFile"] as String?)?.let { file(it) }
                ?: file("/Users/ercinakkaya/Desktop/code/school/flutter_keystore.jks")
            storePassword = (keystoreProperties["storePassword"] as String?) ?: "Ercin!1283."
        }
    }

    buildTypes {
        debug {
            signingConfig = signingConfigs.getByName("debug")
        }
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}
