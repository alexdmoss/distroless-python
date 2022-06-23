ARG PYTHON_BUILDER_IMAGE
ARG PYTHON_DISTROLESS_IMAGE

FROM ${PYTHON_BUILDER_IMAGE} AS builder

WORKDIR /app
COPY requirements.txt /app/

RUN pip install --no-cache-dir -r requirements.txt


FROM ${PYTHON_DISTROLESS_IMAGE}

ARG PYTHON_VERSION

COPY . /app
COPY --from=builder /home/monty/.local /home/monty/.local
# this is a dependency for numpy (which pandas depends on), which isn't in our distroless but is in the build-env
COPY --from=builder /lib/x86_64-linux-gnu/libbz2.so.1.0 /lib/x86_64-linux-gnu/

ENV PYTHONPATH=/home/monty/.local/lib/python${PYTHON_VERSION}/site-packages

WORKDIR /app

CMD ["bamboo.py"]
