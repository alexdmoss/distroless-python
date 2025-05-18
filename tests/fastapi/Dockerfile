ARG PYTHON_BUILDER_IMAGE
ARG PYTHON_DISTROLESS_IMAGE

FROM ${PYTHON_BUILDER_IMAGE} AS builder

WORKDIR /app
COPY pyproject.toml uv.lock /app/
RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv sync --locked --no-install-project --no-dev

# ------------------------------------------------------------------

FROM ${PYTHON_DISTROLESS_IMAGE}

ARG PYTHON_VERSION

COPY --chown=1000:1000 . /app
COPY --chown=1000:1000 --from=builder /app/.venv /app/.venv
ENV PATH="/app/.venv/bin:$PATH"
ENV WEB_CONCURRENCY=1

WORKDIR /app
ENTRYPOINT ["python", "run.py"]
