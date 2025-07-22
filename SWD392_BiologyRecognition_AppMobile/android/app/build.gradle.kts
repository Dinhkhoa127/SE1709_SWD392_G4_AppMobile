plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")  // 🔧 THÊM DÒNG NÀY
}

android {
    namespace = "com.example.se1709_swd392_biologyrecognitionsystem_appmobile"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"  // 🔧 Thêm NDK version mới nhất

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"  // Thay đổi từ "11"
    }

    defaultConfig {
        applicationId = "com.example.se1709_swd392_biologyrecognitionsystem_appmobile"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true  // 🔧 Thêm multiDex support
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
    // Thêm phần này để suppress warnings
    lint {
        disable += setOf("InvalidPackage")
        checkReleaseBuilds = false
        abortOnError = false
    }
}

flutter {
    source = "../.."
}

// 🔧 THÊM TOÀN BỘ PHẦN DEPENDENCIES NÀY
dependencies {
    implementation("androidx.multidex:multidex:2.0.1")
    implementation("com.google.android.gms:play-services-auth:20.7.0")
    implementation("com.google.firebase:firebase-auth-ktx:22.3.0")
    implementation("com.google.firebase:firebase-core:21.1.1")
    implementation(platform("com.google.firebase:firebase-bom:32.7.0"))
}
