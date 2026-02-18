pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        // Use explicit Maven Central URL (repo1.maven.org is the official URL)
        maven { 
            url = uri("https://repo1.maven.org/maven2/")
            name = "Maven Central"
        }
        // Add Aliyun mirror as fallback (works when Maven Central is unreachable)
        maven { 
            url = uri("https://maven.aliyun.com/repository/public/")
            name = "Aliyun Maven"
        }
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.11.1" apply false
    id("org.jetbrains.kotlin.android") version "2.2.20" apply false
}

include(":app")
