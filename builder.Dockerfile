ARG PYTHON_VERSION

# several optimisations in python-slim images already, benefit from these
FROM python:${PYTHON_VERSION}-slim-bullseye

# ------------ setup standard non-root user for use downstream --------------  #

ARG NONROOT_USER="monty"
ARG NONROOT_GROUP="monty"

RUN groupadd ${NONROOT_GROUP}
RUN useradd -m ${NONROOT_USER} -g ${NONROOT_GROUP}

USER ${NONROOT_USER}

ENV PATH="/home/${NONROOT_USER}/.local/bin:${PATH}"

# ------------ setup user environment with good python practices ------------  #

USER ${NONROOT_USER}
WORKDIR /home/${NONROOT_USER}

ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONFAULTHANDLER 1

# ------------- pipenv/poetry for use elsewhere as builder image ------------  #

RUN pip install --upgrade pip && \
    pip install --no-warn-script-location virtualenv poetry pipenv
