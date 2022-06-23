from google.cloud import pubsub_v1
from google.api_core.exceptions import AlreadyExists

# if using creds builder:
from distutils.command.build import build
import json
from os import getenv
from google.oauth2 import service_account


def main():

    print("Creating pubsub client ...")

    project_id = "made-up-project"
    topic_id = "alexos-distroless-python-test"

    ### stubbed to use emulator instead. If reverting, then:
    # creds_json = getenv("GOOGLE_CREDENTIALS")
    # sa_info = json.loads(creds_json)
    # creds = service_account.Credentials.from_service_account_info(sa_info)
    # publisher = pubsub_v1.PublisherClient(credentials=creds)    
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
