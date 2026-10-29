# distroless-python

Creates a distroless container image with up-to-date python installed

---

## Usage

No `latest` tag is offered. The intent is to be intentional (!) in your choice of version and when to upgrade.

### Tags

Each image (and its `-debug` variant, and the `python-builder` equivalents) is published under three tags:

| Tag | Example | Meaning |
|---|---|---|
| `<minor>-<debian>` | `3.14-debian13` | Latest build of that Python minor. Moves on every rebuild, including Python patch releases and Debian security fixes |
| `<version>-<debian>` | `3.14.8-debian13` | Latest build of that exact Python version. Moves when the base is rebuilt (Debian fixes) |
| `<version>-<debian>-<pipeline>-<YYYY.MM.DD.hhmm>` | `3.14.8-debian13-3005468189-2026.10.29.1830` | One specific build (GitLab pipeline ID + its start time in UTC). **Never moves** |

Debug variants put `-debug` straight after `<debian>`, e.g. `3.14.8-debian13-debug-3005468189-2026.10.29.1830`. Use the moving tags to keep receiving security fixes (ideally pinned by digest with something like Renovate bumping it), or a stamped tag if you need a build that will never change.

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

There are variants for Python versions 3.13 and Python 3.14, based on Debian 13. They are built from the `python:3.x-slim-<debian name>` image base (pinned by tag and digest as `PYTHON_BASE_IMAGE` in [`.gitlab-ci.yml`](.gitlab-ci.yml); Renovate bumps the digest whenever upstream rebuilds it).

Both `linux/amd64` and `linux/arm64` variants are pushed. Your docker environment should pull down the one that matches your platform (they are built using `docker buildx`)

> [!WARNING]
> **Change from Python `3.13.16` / `3.14.8` onwards:** the distroless image no longer ships the builder's tooling (`pip`, `poetry`, `pipenv`, `virtualenv` and their dependencies) in `site-packages` - it contains Python and its standard library only. This removes vulnerabilities in packages your app never uses (e.g. `urllib3` vendored inside `pip`) and cuts the image size by roughly two thirds.
>
> If you install dependencies into a virtualenv in a build stage and copy it across (as all the [`tests/`](tests/) examples do), nothing changes for you. If you instead relied on packages already present in the image - e.g. `pip install --user` in the builder and copying `~/.local` across, where pip skips anything the builder already had - you may now see `ImportError`s. Switch to a virtualenv (see [`tests/pandas/Dockerfile`](tests/pandas/Dockerfile) for a plain `python -m venv` + `pip` example), or pin to the previous patch tag (`3.13.15-debian13` / `3.14.7-debian13`) while you migrate - noting that pinned tags do not receive further security fixes.

### python/builder

For convenience, the `builder` image used to create the above is also published. This is **not** in general going to be useful in running python apps, but can be a convenient way to get a top layer that is `python:3.x-slim-<debian name>` but with a non-root user and virtualenv/pipenv/poetry pre-installed - fewer stuff for you to sort in your Dockerfile! (Equivalent tags for 3.14 also exist).

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
