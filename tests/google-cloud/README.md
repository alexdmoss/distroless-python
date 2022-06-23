# google-cloud test

Creates and immediately deletes a PubSub topic `distroless-python-test` in the specified project. To minimise external dependencies, this done using the [Google PubSub Emulator](https://cloud.google.com/pubsub/docs/emulator), which still requires all the requisite Python client libraries to be loaded.

To run locally outside of Docker:

```sh
gcloud beta emulators pubsub start --project=made-up-project --host-port=0.0.0.0:8085 --data-dir=/tmp
export PUBSUB_EMULATOR_HOST=[::1]:8085
pipenv run python main.py
```

To run locally in Docker (equivalent to what `tests.sh` does):

```sh
# you build this instead using emulator.Dockerfile if you prefer
docker run --rm --name=pubsub-emulator -d -p 8085:8085 mosstech/pubsub-emulator:latest

docker run --rm -e=PUBSUB_EMULATOR_HOST=pubsub-emulator:8085 "${image_tag}"
```
