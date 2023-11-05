ARG PYTHON_BUILDER_IMAGE
ARG PYTHON_DISTROLESS_IMAGE

FROM ${PYTHON_BUILDER_IMAGE} AS builder

WORKDIR /app
COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt


FROM ${PYTHON_DISTROLESS_IMAGE}

WORKDIR /app
COPY --chown=1000:1000 *.py .
COPY --chown=1000:1000 --from=builder /home/monty/.local /home/monty/.local

CMD ["bamboo.py"]
