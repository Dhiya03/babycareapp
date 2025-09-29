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

@Suppress("UnstableApiUsage")
var localProperties = java.util.Properties()
var localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localPropertiesFile.inputStream().use { localProperties.load(it) }
}

apply(from = File(localProperties.getProperty("flutter.groovy") ?: throw GradleException("Could not find flutter.groovy.")))
