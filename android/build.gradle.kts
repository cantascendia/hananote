import org.jetbrains.kotlin.gradle.dsl.KotlinVersion
import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

allprojects {
    repositories {
        google()
        mavenCentral()
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
    // Sentry 8.x requests Kotlin 1.6, removed by the pinned Kotlin 2.2 compiler.
    // Keep its published dependency locked and compile with the supported floor.
    if (name == "sentry_flutter") {
        afterEvaluate {
            tasks.withType<KotlinCompile>().configureEach {
                compilerOptions.languageVersion.set(KotlinVersion.KOTLIN_1_8)
                compilerOptions.apiVersion.set(KotlinVersion.KOTLIN_1_8)
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
