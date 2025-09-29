pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }

    // The settings for plugins are applied after the projects are evaluated.
    // The following closure is executed after the projects are evaluated.
    plugins {
        id("dev.flutter.flutter-plugin-loader") version "1.0.0"
        id("com.android.application") version "8.3.2" apply false
        id("org.jetbrains.kotlin.android") version "1.9.24" apply false
    }
}

include(":app")

apply(from = File(settings.pluginManagement.resolutionStrategy.eachPlugin.find { it.pluginId == "dev.flutter.flutter-plugin-loader" }!!.origin.toString()))
