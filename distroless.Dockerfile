ARG PYTHON_BUILDER_IMAGE
ARG GOOGLE_DISTROLESS_BASE_IMAGE

## -------------- layer to give access to newer python + its dependencies ------------- ##

FROM ${PYTHON_BUILDER_IMAGE} AS python-base

# this script is dealing with the fact that with buildx we can't tell the path to these libs (it's not just TARGETARCH)
COPY lib_linker.sh /
RUN /lib_linker.sh

## ------------------------------- distroless base image ------------------------------ ##

# build from distroless C or cc:debug, because lots of Python depends on C
FROM ${GOOGLE_DISTROLESS_BASE_IMAGE}

ARG PYTHON_MINOR
ARG PYTHON_VERSION

## ------------------------- copy python itself from builder -------------------------- ##

# this carries more risk than installing it fully, but makes the image a lot smaller
COPY --from=python-base /usr/local/lib/ /usr/local/lib/
COPY --from=python-base /usr/local/bin/python /usr/local/bin/
COPY --from=python-base /etc/ld.so.cache /etc/

## -------------------------- add common compiled libraries --------------------------- ##

# see lib_linker.sh for how these tmp paths get generated
COPY --from=python-base /tmp/python-libs/libz.so.1 /lib/x86_64-linux-gnu/
COPY --from=python-base /tmp/python-libs/libffi* /usr/lib/x86_64-linux-gnu/
COPY --from=python-base /tmp/python-libs/libexpat* /lib/x86_64-linux-gnu/

## -------------------------------- non-root user setup ------------------------------- ##

COPY --from=python-base /bin/echo /bin/ln /bin/rm /bin/sh /bin/

# quick validation that python still works whilst we have a shell
# pipenv links python to python3 in venv
RUN echo "monty:x:1000:monty" >> /etc/group \
    && echo "monty:x:1001:" >> /etc/group \
    && echo "monty:x:1000:1001::/home/monty:" >> /etc/passwd \
    && python --version \
    && ln -s /usr/local/bin/python /usr/local/bin/python3 \
    && ln -s /usr/local/bin/python /usr/local/bin/python${PYTHON_MINOR} \
    && ln -s /usr/local/bin/python /usr/local/bin/python${PYTHON_VERSION}

# clear out our temporary shell now done with it
RUN rm /bin/echo /bin/ln /bin/rm /bin/sh

## --------------------------- standardise execution env ----------------------------- ##

# default to running as non-root, uid=1000
USER monty

# standardise on locale, don't generate .pyc, enable tracebacks on seg faults
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONFAULTHANDLER=1

ENTRYPOINT ["/usr/local/bin/python"]
