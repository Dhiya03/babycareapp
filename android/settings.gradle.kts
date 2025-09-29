pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
        // 👇 This is required for Flutter's Gradle plugin
        maven { url = uri("${System.getenv("FLUTTER_HOME") ?: "../../flutter"}/packages/flutter_tools/gradle") }
    }
}

plugins {
    id("dev.flutter.flutter-gradle-plugin") version "1.0.0" apply false
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.name = "babycareapp"
include(":app")
