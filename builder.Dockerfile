ARG PYTHON_VERSION="3.13.7"
ARG DEBIAN_NAME="trixie"

# several optimisations in python-slim images already, benefit from these
FROM python:${PYTHON_VERSION}-slim-${DEBIAN_NAME}

# ------------ setup standard non-root user for use downstream --------------  #

ARG NONROOT_USER="monty"
ARG NONROOT_GROUP="monty"

RUN groupadd ${NONROOT_GROUP} \
    && useradd -m ${NONROOT_USER} -g ${NONROOT_GROUP}

USER ${NONROOT_USER}

ENV PATH="/home/${NONROOT_USER}/.local/bin:${PATH}"

# ------------ setup user environment with good python practices ------------  #

USER ${NONROOT_USER}
WORKDIR /home/${NONROOT_USER}

ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONFAULTHANDLER=1

# ------------- pipenv/poetry for use elsewhere as builder image ------------  #

RUN pip install --upgrade pip && \
    pip install --no-warn-script-location virtualenv poetry pipenv

# ----------- install latest uv for use elsewhere as builder image ----------  #

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/
ENV UV_COMPILE_BYTECODE=1 UV_LINK_MODE=copy
ENV UV_PYTHON_DOWNLOADS=0
