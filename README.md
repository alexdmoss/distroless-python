# distroless-python

Creates a distroless container image with up-to-date python installed

---

## Usage

No `latest` tag is offered. The intent is to be intentional (!) in your choice of version and when to upgrade.

Usage examples can be found in the [`tests/`](tests/) directory. These are also described in [EXAMPLES.md](EXAMPLES.md).

### python/distroless

In general, you're going to want this:

```dockerfile
FROM al3xos/python-distroless:3.13-debian13
```

A debug image also exists:

```sh
docker run --rm -it --entrypoint=sh al3xos/python-distroless:3.13-debian13-debug
```

There are variants for Python versions 3.13 and Python 3.14, based on Debian 13. They are built from the `python:3.x-slim-bookworm` image base.

Both `linux/amd64` and `linux/arm64` variants are pushed. Your docker environment should pull down the one that matches your platform (they are built using `docker buildx`)

### python/builder

For convenience, the `builder` image used to create the above is also published. This is **not** in general going to be useful in running python apps, but can be a convenient way to get a top layer that is `python:3.13-slim-trixie` but with a non-root user and virtualenv/pipenv/poetry pre-installed - fewer stuff for you to sort in your Dockerfile! (Equivalent tags for 3.14 also exist).

To use it:

```dockerfile
FROM al3xos/python-builder:3.13-debian13
```

---

## Available Versions

This repo now only publishes Python 3.13 and 3.14 images based on Debian 13 (trixie). Tags existed for 3.9, 3.10 and 3.11 and 3.12 using debian12, but are no longer actively maintained due to missing important security fixes.

---

## Upgrading

Python and OS version are set in `.gitlab-ci.yml`. This repo originates at [https://gitlab.com/alexos-dev/distroless-python](https://gitlab.com/alexos-dev/distroless-python) but is mirrored to Github [https://github.com/alexdmoss/distroless-python](https://github.com/alexdmoss/distroless-python) for convenience in sharing. Perhaps I'll convert to use Github actions at some point 🤷‍♂️

---

## Rationale

1. Variants based on Debian (e.g. `python:*-slim-bullseye`) often have a number of vulnerabilities in them. Debian take their time responding and deal with many, and whilst this is quite often for very justifiable reasons, it is pretty toilsome work to reason about the risk and patch or suppress as needed.
2. Alpine would be my normal go-to here but that experience with Python is grim. I believe it all stems from its use of `musl` rather than `glibc` as its standard C library. Python wheels exist for the latter (so builds are much faster) and the two are not perfectly interoperable (i.e. there are potentially subtle bugs or performance differences). [This excellent blog post](https://pythonspeed.com/articles/alpine-docker-python/) elaborates on this.
3. The Google Distroless image for Python is marked as experimental and has been for a while, and tied to what Debian ships with - i.e. an old copy of python and dependent libraries. In other words it does not really solve for the problem statement in (1), and comes with several of its own.

---

## Implementation

Following issues copying the Bazel-based approach used by [Google's distroless repo itself](https://github.com/GoogleContainerTools/distroless), I switched approach to a technique I understood better - multi-layer docker images. I took the distroless C image as a base and then used an earlier docker layer to bring in my choice of Python + its dependencies in.

---

## License

These images are based on Google's distroless images, which are distributed under the Apache-2.0 license. This repo therefore uses the same.
