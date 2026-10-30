# python:<version>-slim-<debian name>@sha256:..., set in .gitlab-ci.yml
ARG PYTHON_BASE_IMAGE

# ghcr gives Renovate no release timestamps, so uv is tracked via its GitHub releases
# renovate: datasource=github-releases depName=astral-sh/uv
ARG UV_VERSION=0.13.6

FROM ghcr.io/astral-sh/uv:${UV_VERSION} AS uv

# several optimisations in python-slim images already, benefit from these
FROM ${PYTHON_BASE_IMAGE}

# ------------ setup standard non-root user for use downstream --------------  #

ARG NONROOT_USER="monty"
ARG NONROOT_GROUP="monty"

RUN groupadd ${NONROOT_GROUP} \
    && useradd -m ${NONROOT_USER} -g ${NONROOT_GROUP}

ENV PATH="/home/${NONROOT_USER}/.local/bin:${PATH}"

# ------------ setup user environment with good python practices ------------  #

WORKDIR /home/${NONROOT_USER}

ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONFAULTHANDLER=1

# ------------- pipenv/poetry for use elsewhere as builder image ------------  #

RUN pip install --upgrade pip && \
    rm -rf /home/${NONROOT_USER}/.cache/pip && \
    rm -rf /usr/local/lib/python3.*/site-packages/pip-*/ && \
    pip install --no-warn-script-location virtualenv poetry pipenv

# ----------- install latest uv for use elsewhere as builder image ----------  #
USER ${NONROOT_USER}
COPY --from=uv /uv /uvx /bin/
ENV UV_COMPILE_BYTECODE=1 UV_LINK_MODE=copy
ENV UV_PYTHON_DOWNLOADS=0
