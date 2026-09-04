pluginManagement {
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        val localProperties = file("local.properties")
        if (localProperties.exists()) {
            localProperties.inputStream().use { properties.load(it) }
        }
        properties.getProperty("flutter.sdk") ?: System.getenv("FLUTTER_ROOT") ?: ""
    }

    if (flutterSdkPath.isNotEmpty()) {
        includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")
    }

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.11.1" apply false
    id("org.jetbrains.kotlin.android") version "2.2.20" apply false
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.PREFER_SETTINGS)
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://jitpack.io") }
        maven { url = uri("https://maven.ffmpegkit.org") }
    }
}

include(":app")
