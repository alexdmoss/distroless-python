ARG PYTHON_VERSION
ARG DEBIAN_NAME
ARG PYTHON_DISTROLESS_IMAGE

FROM python:${PYTHON_VERSION}-slim-${DEBIAN_NAME} AS builder

RUN pip --quiet --no-cache-dir install pipenv
COPY Pipfile Pipfile.lock ./
RUN PIPENV_VENV_IN_PROJECT=1 pipenv install --deploy

# ------------------------------------------------------------------

FROM ${PYTHON_DISTROLESS_IMAGE}
ARG PYTHON_VERSION

WORKDIR /app
COPY --chown=1000:1000 *.py .
COPY --chown=1000:1000 --from=builder /.venv /.venv

ENTRYPOINT [ "/.venv/bin/python", "app.py", "--namespace", "default" ]
