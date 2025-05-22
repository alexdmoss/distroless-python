from google.cloud import pubsub_v1
from google.api_core.exceptions import AlreadyExists


def main():

    print("Creating pubsub client ...")

    project_id = "made-up-project"
    topic_id = "alexos-distroless-python-test"

    publisher = pubsub_v1.PublisherClient()

    print("Client created - creating topic ...")

    topic_path = publisher.topic_path(project_id, topic_id)

    try:
        topic = publisher.create_topic(request={"name": topic_path})
        print(f"Created Topic [{topic.name}]")
    except AlreadyExists:
        print(f"Already Exists: Topic [{topic_path}]")

    publisher.delete_topic(request={"topic": topic_path})
    print(f"Deleted topic [{topic_path}]")


if __name__ == "__main__":
    main()
