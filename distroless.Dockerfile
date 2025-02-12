ARG PYTHON_BUILDER_IMAGE
ARG GOOGLE_DISTROLESS_BASE_IMAGE

## -------------- layer to give access to newer python + its dependencies ------------- ##

FROM ${PYTHON_BUILDER_IMAGE} as python-base

## ------------------------------- distroless base image ------------------------------ ##

# build from distroless C or cc:debug, because lots of Python depends on C
FROM ${GOOGLE_DISTROLESS_BASE_IMAGE}

## -------------------------------- non-root user setup ------------------------------- ##

COPY --from=python-base /bin/echo /bin/ln /bin/rm /bin/sh /bin/

# quick validation that python still works whilst we have a shell
# pipenv links python to python3 in venv
RUN echo "monty:x:1000:monty" >> /etc/group \
    && echo "monty:x:1001:" >> /etc/group \
    && echo "monty:x:1000:1001::/home/monty:" >> /etc/passwd \
    && python --version \
    && ln -s /usr/local/bin/python /usr/local/bin/python3

## ------------------------- copy python itself from builder -------------------------- ##

# this carries more risk than installing it fully, but makes the image a lot smaller
COPY --from=python-base /usr/local/lib/ /usr/local/lib/
COPY --from=python-base /usr/local/bin/python /usr/local/bin/
COPY --from=python-base /etc/ld.so.cache /etc/

## -------------------------- add common compiled libraries --------------------------- ##

# This is ugly but haven't come up with a better way yet.
# We attempt to copy for both architectures because we are now using buildx and TARGETARCH
# won't let us work out these paths.
# The hello file is there so that the COPY doesn't fail
RUN touch /tmp/hello

# If seeing ImportErrors, check if in the python-base already and copy as below
# - libffi + libexpat are required by google-cloud/grpcio
# - libz.so is required by lots of packages - e.g. six, numpy, wsgi

# for amd64 arch
COPY --from=python-base /tmp/hello /lib/x86_64-linux-gnu/libz.so.1 /lib/x86_64-linux-gnu/
COPY --from=python-base /tmp/hello /usr/lib/x86_64-linux-gnu/libffi* /usr/lib/x86_64-linux-gnu/
COPY --from=python-base /tmp/hello /lib/x86_64-linux-gnu/libexpat* /lib/x86_64-linux-gnu/

# for arm64 arch
COPY --from=python-base /tmp/hello /lib/aarch64-linux-gnu/libz.so.1 /lib/aarch64-linux-gnu/
COPY --from=python-base /tmp/hello /usr/lib/aarch64-linux-gnu/libffi* /usr/lib/aarch64-linux-gnu/
COPY --from=python-base /tmp/hello /lib/aarch64-linux-gnu/libexpat* /lib/aarch64-linux-gnu/

# clear out our temporary shell now done with it
RUN rm /bin/echo /bin/ln /bin/rm /bin/sh

## --------------------------- standardise execution env ----------------------------- ##

# default to running as non-root, uid=1000
USER monty

# standardise on locale, don't generate .pyc, enable tracebacks on seg faults
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONFAULTHANDLER 1

ENTRYPOINT ["/usr/local/bin/python"]
