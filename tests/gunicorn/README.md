# gitlab-distroless-python-test

Simple gunicorn/flask app. Note the use of `run.py` to deal with entrypoint lack of shell shenanigans.

This repo was converted from an initial pipenv-based one to use poetry, as poetry is capable of supporting both python 3.9 and 3.10, whereas the Pipfile does not support this. This caused a particular issue for this test, as Flask depends on `importlib-metadata`, which is built into 3.10 but not in 3.9. Pipfile.lock file issues ensued!

---

## Usage

Flask:

```sh
pip install poetry
poetry install
poetry run python app.py
```

Gunicorn:

```sh
docker build --build-arg=PYTHON_VERSION=3.9 --build-arg=PYTHON_DISTROLESS_IMAGE=al3xos/python-distroless:3.9-debian11 -t gunicorn-test .
docker run --rm -p 5000:5000 gunicorn-test
```
