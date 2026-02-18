// Gradle init script to redirect Maven Central URLs
// This runs before any project evaluation

settingsEvaluated {
    pluginManagement {
        repositories {
            all { repo ->
                if (repo is MavenArtifactRepository) {
                    val url = repo.url.toString()
                    if (url.contains("repo.maven.apache.org")) {
                        repo.url = java.net.URI(url.replace("repo.maven.apache.org", "repo1.maven.org"))
                    }
                }
            }
        }
    }
}

projectsLoaded {
    allprojects {
        repositories {
            all { repo ->
                if (repo is MavenArtifactRepository) {
                    val url = repo.url.toString()
                    if (url.contains("repo.maven.apache.org")) {
                        repo.url = java.net.URI(url.replace("repo.maven.apache.org", "repo1.maven.org"))
                    }
                }
            }
        }
    }
}
