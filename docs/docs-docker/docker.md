## Docker

When writing Dockerfiles place instructions that are not changed frequently
first. Docker uses a cache and reuses layers that did not change. If it hits an
instruction that represents a layer that was changed it invalidates the cache on
**subsequent** instructions, thus we place this instructions more at the bottom.

