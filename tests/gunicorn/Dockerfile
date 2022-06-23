ARG PYTHON_VERSION
ARG PYTHON_DISTROLESS_IMAGE

FROM python:${PYTHON_VERSION}-slim-bullseye AS builder

RUN pip install poetry
COPY poetry.lock .
COPY pyproject.toml .

ARG VIRTUAL_ENV=/home/venv

RUN pip install --upgrade pip && \
    pip --quiet --no-cache-dir install virtualenv && \
    pip --quiet --no-cache-dir install poetry && \
    poetry config virtualenvs.create false && \
    virtualenv ${VIRTUAL_ENV} && \
    poetry install --no-dev

# ------------------------------------------------------------------

FROM ${PYTHON_DISTROLESS_IMAGE}

ARG PYTHON_VERSION

COPY . /app/
COPY --from=builder /home/venv /home/venv

ENV PYTHONPATH=/home/venv/lib/python${PYTHON_VERSION}/site-packages

WORKDIR /app

ENTRYPOINT ["python", "run.py", "-b", "0.0.0.0:5000", "app:app"]
