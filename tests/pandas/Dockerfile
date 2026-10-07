ARG PYTHON_BUILDER_IMAGE
ARG PYTHON_DISTROLESS_IMAGE

FROM ${PYTHON_BUILDER_IMAGE} AS builder

ARG VIRTUAL_ENV=/home/monty/venv

WORKDIR /app
COPY requirements.txt .

RUN python -m venv ${VIRTUAL_ENV} && \
    ${VIRTUAL_ENV}/bin/pip install --no-cache-dir -r requirements.txt


FROM ${PYTHON_DISTROLESS_IMAGE}

ARG VIRTUAL_ENV=/home/monty/venv

WORKDIR /app
COPY --chown=1000:1000 *.py .
COPY --chown=1000:1000 --from=builder ${VIRTUAL_ENV} ${VIRTUAL_ENV}

ENTRYPOINT ["/home/monty/venv/bin/python"]
CMD ["bamboo.py"]
