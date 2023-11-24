ARG PYTHON_VERSION
ARG DEBIAN_NAME
ARG PYTHON_DISTROLESS_IMAGE

FROM python:${PYTHON_VERSION}-slim-${DEBIAN_NAME} AS build-env
RUN mkdir /app
COPY hello.py /app
WORKDIR /app

FROM ${PYTHON_DISTROLESS_IMAGE}

WORKDIR /app
COPY --chown=1000:1000 --from=build-env /app /app

CMD ["hello.py"]
