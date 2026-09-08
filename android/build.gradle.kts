import org.jetbrains.kotlin.gradle.dsl.KotlinVersion as KotlinLanguageVersion
import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Some third-party Flutter plugins still pin a Kotlin language version that the
// Kotlin compiler this project uses (org.jetbrains.kotlin.android 2.2.20, see
// settings.gradle.kts) no longer accepts. sentry_flutter 8.14.2 sets
// `kotlinOptions { languageVersion = "1.6" }` in its own android/build.gradle,
// and Kotlin 2.2 fails with:
//   e: Language version 1.6 is no longer supported; please, use version 1.8 or greater.
// Raise any sub-1.8 pin to the oldest version the compiler still supports. This
// only affects how those plugin modules are compiled; no app source changes.
subprojects {
    tasks.withType<KotlinCompile>().configureEach {
        compilerOptions {
            val pinnedLanguage = languageVersion.orNull
            if (pinnedLanguage != null && pinnedLanguage < KotlinLanguageVersion.KOTLIN_1_8) {
                languageVersion.set(KotlinLanguageVersion.KOTLIN_1_8)
            }
            val pinnedApi = apiVersion.orNull
            if (pinnedApi != null && pinnedApi < KotlinLanguageVersion.KOTLIN_1_8) {
                apiVersion.set(KotlinLanguageVersion.KOTLIN_1_8)
            }
        }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
