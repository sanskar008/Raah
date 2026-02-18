allprojects {
    repositories {
        google()
        // Use explicit Maven Central URL (repo1.maven.org is the official URL)
        maven { 
            url = uri("https://repo1.maven.org/maven2/")
            name = "Maven Central"
        }
        // Add Aliyun mirror as fallback (faster in some regions)
        maven { 
            url = uri("https://maven.aliyun.com/repository/public/")
            name = "Aliyun Maven"
        }
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

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
