
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

This example uses `pipenv` instead of `poetry` to show how that can be handled in a relatively straight-forward way.

We are also using the `mosstech/python-builder` docker image as the base instead of `python:slim-bullseye` - in practice this just saves us needing to bother installing `pipenv` really.

---

## [Pandas](tests/pandas/)

`pandas` dependency on `numpy` forces changes in the base image that the distroless one is built from - so a good test. A choice here was to make the required changes in distroless itself, or layer it in just for this image. I chose the latter in this case to demonstrate how this can be done (and also because I use `pandas` rarely myself, tbh).

This example does not bother with a virtual environment, and also uses a `requirements.txt` instead - just to prove that works fine. It can be a common practice to generate the requirements.txt file in CI for greater confidence in the build or easier portability.

The value of a virtual environment inside a container is debatable - but many of the other examples listed here use it for a consistency with local development processes.
