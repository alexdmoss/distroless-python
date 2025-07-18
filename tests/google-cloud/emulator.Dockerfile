FROM google/cloud-sdk:529.0.0-alpine

RUN apk --no-cache update && \
    apk --no-cache add openjdk21-jre && \
    rm -rf /var/cache/apk/*

RUN gcloud components install --quiet beta pubsub-emulator && \
    gcloud components update

EXPOSE 8085

VOLUME /data

ENTRYPOINT ["gcloud", "beta", "emulators", "pubsub"]
CMD ["start", "--host-port=0.0.0.0:8085", "--data-dir=/data"]
