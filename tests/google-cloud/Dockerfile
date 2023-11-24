ARG PYTHON_BUILDER_IMAGE
ARG PYTHON_DISTROLESS_IMAGE

FROM ${PYTHON_BUILDER_IMAGE} AS builder

COPY Pipfile Pipfile.lock ./
RUN PIPENV_VENV_IN_PROJECT=1 pipenv install --deploy

# ------------------------------------------------------------------

FROM ${PYTHON_DISTROLESS_IMAGE}

ARG PYTHON_VERSION

WORKDIR /app
COPY --chown=1000:1000 . .
COPY --chown=1000:1000 --from=builder /home/monty/.venv /home/monty/.venv

ENV PYTHONPATH=/home/monty/.venv/lib/python${PYTHON_VERSION}/site-packages
ENV WEB_CONCURRENCY=1

ENTRYPOINT [ "python", "main.py" ]
