ARG PYTHON_BUILDER_IMAGE
ARG PYTHON_DISTROLESS_IMAGE

FROM ${PYTHON_BUILDER_IMAGE} AS builder

COPY Pipfile .
COPY Pipfile.lock .
RUN PIPENV_VENV_IN_PROJECT=1 pipenv install --deploy

# ------------------------------------------------------------------

FROM ${PYTHON_DISTROLESS_IMAGE}

ARG PYTHON_VERSION

COPY . /app
COPY --from=builder /home/monty/.venv /home/monty/.venv

ENV PYTHONPATH=/home/monty/.venv/lib/python${PYTHON_VERSION}/site-packages

WORKDIR /app

ENV WEB_CONCURRENCY=1

CMD ["run.py"]
