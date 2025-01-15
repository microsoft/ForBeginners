# ----------------------------------------------
# 1. Create Project Inference Chat Client
# ----------------------------------------------
import os
from pathlib import Path
from opentelemetry import trace
from azure.ai.projects import AIProjectClient
from azure.identity import DefaultAzureCredential
from config import ASSET_PATH, get_logger, enable_telemetry
from get_product_documents import get_product_documents


# initialize logging and tracing objects
logger = get_logger(__name__)
tracer = trace.get_tracer(__name__)

# create a project client using environment variables loaded from the .env file
project = AIProjectClient.from_connection_string(
    conn_str=os.environ["AIPROJECT_CONNECTION_STRING"], credential=DefaultAzureCredential()
)

# create a chat client we can use for testing
chat = project.inference.get_chat_completions_client()


# ----------------------------------------------
# 2. Define Function To Chat With Products
# ----------------------------------------------
from azure.ai.inference.prompts import PromptTemplate


@tracer.start_as_current_span(name="chat_with_products")
def chat_with_products(messages: list, context: dict = None) -> dict:
    if context is None:
        context = {}

    documents = get_product_documents(messages, context)

    # do a grounded chat call using the search results
    grounded_chat_prompt = PromptTemplate.from_prompty(Path(ASSET_PATH) / "grounded_chat.prompty")

    system_message = grounded_chat_prompt.create_messages(documents=documents, context=context)
    response = chat.complete(
        model=os.environ["CHAT_MODEL"],
        messages=system_message + messages,
        **grounded_chat_prompt.parameters,
    )
    logger.info(f"💬 Response: {response.choices[0].message}")

    # Return a chat protocol compliant response
    return {"message": response.choices[0].message, "context": context}


# ----------------------------------------------
# 3. Test Chat Function with sample query
# ----------------------------------------------
if __name__ == "__main__":
    import argparse

    # load command line arguments
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--query",
        type=str,
        help="Query to use to search product",
        default="I need a new tent for 4 people, what would you recommend?",
    )
    parser.add_argument(
        "--enable-telemetry",
        action="store_true",
        help="Enable sending telemetry back to the project",
    )
    args = parser.parse_args()
    if args.enable_telemetry:
        enable_telemetry(True)

    # run chat with products
    response = chat_with_products(messages=[{"role": "user", "content": args.query}])


# ----------------------------------------------------------
# To test:
#  - make sure `assets/grounded_chat.prompty` exists
#  - run as: 
#     python chat_with_products.py 
#       --query "I need a new tent for 4 people, what would you recommend?"
# ----------------------------------------------------------
# Response Looks Something Like:
'''
💬 Response: {
    'content': "I recommend the TrailMaster X4 Tent. 
    It is specifically designed for four occupants and features a 
    durable polyester construction. The tent is water-resistant and 
    comes with a rainfly for additional weather protection. It has 
    multiple doors for easy access, mesh panels for ventilation, 
    and reflective guy lines for visibility at night. Plus, it offers 
    inner pockets for keeping small items organized. It's a great choice 
    for your camping needs!", 'role': 'assistant'
   }
'''
# ----------------------------------------------------------