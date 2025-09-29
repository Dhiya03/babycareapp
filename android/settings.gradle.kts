pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()

        // 👇 Point Gradle to Flutter SDK's embedded plugin
        val localProperties = java.util.Properties()
        val localPropertiesFile = file("local.properties")
        if (localPropertiesFile.exists()) {
            localProperties.load(localPropertiesFile.inputStream())
            val flutterSdkPath = localProperties.getProperty("flutter.sdk")
                ?: throw GradleException("flutter.sdk not set in local.properties")
            maven { url = uri("$flutterSdkPath/packages/flutter_tools/gradle") }
        } else {
            throw GradleException("local.properties not found. Flutter SDK path required.")
        }
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
