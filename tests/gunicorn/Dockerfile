ARG PYTHON_VERSION
ARG DEBIAN_NAME
ARG PYTHON_DISTROLESS_IMAGE

FROM python:${PYTHON_VERSION}-slim-${DEBIAN_NAME} AS builder

WORKDIR /tmp
COPY poetry.lock pyproject.toml ./

ARG VIRTUAL_ENV=/home/venv

RUN pip --quiet --no-cache-dir install --upgrade pip && \
    pip --quiet --no-cache-dir install poetry && \
    poetry config virtualenvs.create false && \
    python -m venv ${VIRTUAL_ENV} && \
    . ${VIRTUAL_ENV}/bin/activate && \
    poetry install --no-dev

# ------------------------------------------------------------------

FROM ${PYTHON_DISTROLESS_IMAGE}

ARG VIRTUAL_ENV=/home/venv

WORKDIR /app
COPY --chown=1000:1000 *.py .
COPY --chown=1000:1000 --from=builder ${VIRTUAL_ENV} ${VIRTUAL_ENV}

ENTRYPOINT ["/home/venv/bin/python", "run.py", "-b", "0.0.0.0:5000", "app:app"]
