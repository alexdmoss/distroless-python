ARG PYTHON_VERSION
ARG PYTHON_DISTROLESS_IMAGE

FROM python:${PYTHON_VERSION}-slim-bullseye AS build-env
RUN mkdir /app
COPY hello.py /app
WORKDIR /app

FROM ${PYTHON_DISTROLESS_IMAGE}

COPY --from=build-env /app /app
WORKDIR /app
CMD ["hello.py"]
