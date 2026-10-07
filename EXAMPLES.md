
# Examples

Naturally, not having a shell in distroless can mean changes are needed for docker images that worked on a debian or alpine base previously. Images that relied on an `entrypoint.sh` script in particular are going to suffer, as well as those that rely on calling an entry point that is `python some-args`.

This repo therefore has a few examples - which it also uses as [tests](./tests/) - to illustrate how this can be made to work. See notes below for more detail on specific tests.

---

## [Hello World](tests/hello-world/)

This is as simple as it gets - running the main line and printing back to console. It is used as a very basic test.

Note the use of `CMD` as a list, not a string - this is important. The entrypoint in the base image is defaulted to `python`.

Some standard practices are folded into the base image so it runs as non-root, has appropriate environment variables set - leading to a very simple Dockerfile in practice.

---

## [Flask / Gunicorn](tests/gunicorn/)

Simple gunicorn/flask app. Note the use of `run.py` to deal with entrypoint. We cannot run gunicorn directly - a small wrapper script is used so that we can execute it through the normal `python` entrypoint.

This was the first complex test. Running just the unicorn wsgi server without leaning into `pipenv` (no shell) or similar required some trickery, which is now incorporated into the base image - basically ensuring that the compiled C libraries are present.

This repo was converted from an initial pipenv-based one to use poetry, as poetry is capable of supporting both python 3.9 and 3.10, whereas the Pipfile does not support this. This caused a particular issue for this test, as Flask depends on `importlib-metadata`, which is built into 3.10 but not in 3.9. Pipfile.lock file issues ensued!

---

## [Fast API](tests/fastapi/)

Simple FastAPI app. As for the Flask/Gunicorn exampel above, note the use of `run.py` to deal with entrypoint. We cannot run `uvicorn` directly - a small wrapper script is used so that we can execute it through the normal `python` entrypoint. Its CLI syntax is a bit different to `gunicorn`.

This example uses `uv` instead of `poetry` to show how that can be handled in a relatively straight-forward way - `uv sync` builds a virtual environment in the builder stage, which is then copied across.

We are also using the `al3xos/python-builder` docker image as the base instead of `python:3.x-slim-<debian name>` - in practice this just saves us needing to bother installing `uv` really.

---

## [Pandas](tests/pandas/)

`pandas` dependency on `numpy` forces changes in the base image that the distroless one is built from - so a good test. A choice here was to make the required changes in distroless itself, or layer it in just for this image. I chose the latter in this case to demonstrate how this can be done (and also because I use `pandas` rarely myself, tbh).

This example sticks to the standard library tooling - a plain `python -m venv` and `pip` with a `requirements.txt` - rather than a package manager, just to prove that works fine. It can be a common practice to generate the requirements.txt file in CI for greater confidence in the build or easier portability.

It previously skipped the virtual environment and used `pip install --user`, copying `~/.local` across. That was fragile: pip skips installing anything the builder image already has, so those packages were only available because the distroless image used to carry the builder's `site-packages` too. Now that the distroless image ships no `site-packages`, a self-contained virtual environment is the reliable way to copy dependencies across.

---

## [Google Cloud](tests/google-cloud/)

Here we're testing one of the packages that is most awkward in `alpine` ... `grpcio`. We do this by having a bit of python that uses some Google Cloud client libraries that interact with PubSub - creating a topic then immediately deleting it.

To minimise the dependency on / need to access a GCP project, we make use of the PubSub emulator - this still gives the client libraries the workout we need. The `emulator.Dockerfile` builds this if needed locally.

---

## [Kubernetes](tests/kubernetes/)

This one works the python kubernetes client libraries. I've included it as I personally use Python with k8s a lot, so knowing the image works for this important to me - although the test doesn't actually do much different to some of the ones above.

This example uses `pipenv`, installed into a plain `python:3.x-slim-<debian name>` builder stage. `PIPENV_VENV_IN_PROJECT=1` makes pipenv create its virtual environment at a predictable path (`/.venv`) so it can be copied into the distroless image.

In a similar vein to the Google Cloud one, we make use of [`kind`](https://kind.sigs.k8s.io/) to spin up a small local k8s cluster to connect to as a test, rather than relying on access to one locally (which is quite painful).

The downside to this test existing in CI is that this process does take a while to execute!
