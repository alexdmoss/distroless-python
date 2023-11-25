ARG PYTHON_BUILDER_IMAGE
ARG PYTHON_DISTROLESS_IMAGE

FROM ${PYTHON_BUILDER_IMAGE} AS builder

WORKDIR /home/monty
COPY Pipfile Pipfile.lock ./
RUN PIPENV_VENV_IN_PROJECT=1 pipenv install --deploy

# ------------------------------------------------------------------

FROM ${PYTHON_DISTROLESS_IMAGE}

ARG PYTHON_VERSION

WORKDIR /app
COPY --chown=1000:1000 *.py /app/
COPY --chown=1000:1000 --from=builder /home/monty/.venv /home/monty/.venv
ENV WEB_CONCURRENCY=1

ENV PYTHONPATH=/home/monty/.venv/lib/python${PYTHON_VERSION}/site-packages
CMD ["run.py"]
