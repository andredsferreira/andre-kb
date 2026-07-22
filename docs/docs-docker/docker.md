## Building & Dockerfiles

Buildx (client) ----> BuildKit (server)

When writing Dockerfiles place instructions that are not changed frequently
first. Docker uses a cache and reuses layers that did not change. If it hits an
instruction that represents a layer that was changed it invalidates the cache on
**subsequent** instructions, thus we place this instructions more at the bottom.

**Build context** The set of files that Buildx may access in the building stage. It
can be a local directory, a remote repository, or a tarball. When using "docker
build .", the dot at the end indicates that the build context is the current
local working directory. Thus, Dockerfile instructions, such as COPY, may
reference files in this directory.