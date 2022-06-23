ARG PYTHON_VERSION
ARG PYTHON_DISTROLESS_IMAGE

FROM python:${PYTHON_VERSION}-slim-bullseye AS builder

RUN pip install pipenv
COPY Pipfile .
COPY Pipfile.lock .
RUN PIPENV_VENV_IN_PROJECT=1 pipenv install --deploy

# ------------------------------------------------------------------

FROM ${PYTHON_DISTROLESS_IMAGE}

ARG PYTHON_VERSION

COPY . /app
COPY --from=builder /.venv /.venv

ENV PYTHONPATH=/.venv/lib/python${PYTHON_VERSION}/site-packages

WORKDIR /app

CMD [ "app.py", "--namespace", "default" ]
