
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
