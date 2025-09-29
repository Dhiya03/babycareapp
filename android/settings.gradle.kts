pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
        // 👇 This is required for Flutter's Gradle plugin
        maven { url = uri("${System.getenv("FLUTTER_HOME") ?: "../../flutter"}/packages/flutter_tools/gradle") }
    }
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
