ARG PYTHON_BUILDER_IMAGE
ARG PYTHON_DISTROLESS_IMAGE

FROM ${PYTHON_BUILDER_IMAGE} AS builder

WORKDIR /app
RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv sync --locked --no-install-project --no-dev
COPY . /app
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --locked --no-dev

# ------------------------------------------------------------------

FROM ${PYTHON_DISTROLESS_IMAGE}

ARG PYTHON_VERSION

COPY --from=builder --chown=1000:1000 /app /app
ENV PATH="/app/.venv/bin:$PATH"
ENV WEB_CONCURRENCY=1

ENTRYPOINT ["python", "run.py"]
