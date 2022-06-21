ARG PYTHON_BUILDER_IMAGE
ARG GOOGLE_DISTROLESS_BASE_IMAGE

## -------------- layer to give access to newer python + its dependencies ------------- ##

FROM ${PYTHON_BUILDER_IMAGE} as python-base

## ------------------------------- distroless base image ------------------------------ ##

# build from distroless C or cc:debug, because lots of Python depends on C
FROM ${GOOGLE_DISTROLESS_BASE_IMAGE}

ARG CHIPSET_ARCH=x86_64-linux-gnu

## ------------------------- copy python itself from builder -------------------------- ##

# this carries more risk than installing it fully, but makes the image a lot smaller
COPY --from=python-base /usr/local/lib/ /usr/local/lib/
COPY --from=python-base /usr/local/bin/python /usr/local/bin/python
COPY --from=python-base /etc/ld.so.cache /etc/ld.so.cache

## -------------------------- add common compiled libraries --------------------------- ##

# If seeing ImportErrors, check if in the python-base already and copy as below

# required by lots of packages - e.g. six, numpy, wsgi
COPY --from=python-base /lib/${CHIPSET_ARCH}/libz.so.1 /lib/${CHIPSET_ARCH}/
# required by google-cloud/grpcio
COPY --from=python-base /usr/lib/${CHIPSET_ARCH}/libffi* /usr/lib/${CHIPSET_ARCH}/
COPY --from=python-base /lib/${CHIPSET_ARCH}/libexpat* /lib/${CHIPSET_ARCH}/

## -------------------------------- non-root user setup ------------------------------- ##

COPY --from=python-base /bin/echo /bin/echo
COPY --from=python-base /bin/rm /bin/rm
COPY --from=python-base /bin/sh /bin/sh

RUN echo "monty:x:1000:monty" >> /etc/group
RUN echo "monty:x:1001:" >> /etc/group
RUN echo "monty:x:1000:1001::/home/monty:" >> /etc/passwd

# quick validation that python still works whilst we have a shell
RUN python --version

RUN rm /bin/sh /bin/echo /bin/rm

## --------------------------- standardise execution env ----------------------------- ##

# default to running as non-root, uid=1000
USER monty

# standardise on locale, don't generate .pyc, enable tracebacks on seg faults
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONFAULTHANDLER 1

ENTRYPOINT ["/usr/local/bin/python"]
