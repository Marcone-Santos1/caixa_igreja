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
}

subprojects {
    project.plugins.withId("com.android.library") {
        val extension = project.extensions.findByName("android")
        if (extension != null) {
            try {
                val getNamespace = extension.javaClass.methods.firstOrNull { it.name == "getNamespace" && it.parameterCount == 0 }
                val setNamespace = extension.javaClass.methods.firstOrNull { it.name == "setNamespace" && it.parameterCount == 1 }
                val currentNamespace = getNamespace?.invoke(extension)
                if (currentNamespace == null) {
                    val defaultNamespace = if (project.name == "blue_thermal_printer") {
                        "id.kakzaki.blue_thermal_printer"
                    } else {
                        "com.example.${project.name.replace('-', '_')}"
                    }
                    setNamespace?.invoke(extension, defaultNamespace)
                }
            } catch (_: Exception) {}
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
