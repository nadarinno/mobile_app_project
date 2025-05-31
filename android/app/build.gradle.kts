plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

dependencies {
    // Import the Firebase BoM
    implementation(platform("com.google.firebase:firebase-bom:33.13.0"))
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-messaging")
    implementation("com.google.firebase:firebase-firestore")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")



    android {
        namespace = "com.example.mobile_app_project"
        compileSdk = flutter.compileSdkVersion
        ndkVersion = "27.0.12077973"

        compileOptions {
            sourceCompatibility = JavaVersion.VERSION_11
            targetCompatibility = JavaVersion.VERSION_11
            isCoreLibraryDesugaringEnabled = true
        }

        kotlinOptions {
            jvmTarget = JavaVersion.VERSION_11.toString()
        }

        defaultConfig {
            applicationId = "com.example.mobile_app_project"
            minSdk = 23 // Compatible with flutter_stripe
            targetSdk = flutter.targetSdkVersion
            versionCode = flutter.versionCode
            versionName = flutter.versionName
        }

        buildTypes {
            release {
                signingConfig = signingConfigs.getByName("debug")
            }
        }
    }


}

flutter {
    source = "../.."
}