# Releasing

Tag main, and push the tag.

```sh
git tag cli-v1.2.3
git push origin cli-v1.2.3
```

This'll trigger a [GitHub workflow](../../.github/workflows/cli-release.yml)
that creates a new draft GitHub release and attaches all the build artifacts to
it (zipped up binaries for various OS and architecture combinations).

## Local release builds

Run the release script to build the binaries for the various OS and architecture
cominations

```shell
./release.sh
```
