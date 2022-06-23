import click
import logging
from kubernetes import config, client, watch

logging.basicConfig(level=logging.INFO, format='[%(levelname)s] %(message)s')

@click.command()
@click.option('--namespace', '-n', required=True, type=str)
def list_pods(namespace: str):

    logging.info(f"Listing deployments for [{namespace}]")

    client = k8s_client()

    w = watch.Watch()
    for event in w.stream(client.list_namespaced_deployment, namespace=namespace, _request_timeout=3600):
        logging.info(f"Event: {event['type']} {event['object'].metadata.name}")

    logging.info("Ended")


def k8s_client():
    try:
        config.load_kube_config()
    except config.ConfigException:
        config.load_incluster_config()

    return client.AppsV1Api()


if __name__ == "__main__":
    list_pods()
