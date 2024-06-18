import os
import chainlit as cl
from langchain_huggingface import HuggingFaceEndpoint
from langchain.prompts import PromptTemplate
from langchain.chains import LLMChain

# Set Hugging Face API token
os.environ['HUGGINGFACEHUB_API_TOKEN'] = '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'

# Model configuration
model_id = "bigscience/bloom"
conv_model = HuggingFaceEndpoint(
    huggingfacehub_api_token=os.environ['HUGGINGFACEHUB_API_TOKEN'],
    repo_id=model_id,
    max_new_tokens=150
)

# Chatbot prompt template
template = "My name is {query} and I am"


# How chatbot starts a conbersation
@cl.on_chat_start
def main():
    # Create a PromptTemplate with the provided template
    prompt = PromptTemplate(template=template, input_variables=["query"])

    # Create an LLMChain with the prompt and model
    conv_chain = LLMChain(llm=conv_model, prompt=prompt, verbose=True)

    # Store the chain in the user session
    cl.user_session.set("llm_chain", conv_chain)


# How chatbot handles messages
@cl.on_message
async def main(message):
    # Retrieve the LLMChain from the session
    llm_chain = cl.user_session.get("llm_chain")

    # Extract the message content
    user_input = message.content if hasattr(message, "content") else str(message)

    # Create the input for the model using the prompt template
    input_data = {"query": user_input}

    # Process the incoming message and get a response from the model
    res = await llm_chain.acall(input_data, callbacks=[cl.AsyncLangchainCallbackHandler()])

    # Extract the response text
    response_text = res.get("text", "Error processing your request")

    # Ensure the response starts with the template
    if not response_text.startswith(template.replace("{query}", user_input)):
        response_text = template.replace("{query}", user_input) + response_text

    # Send the response back to the user
    await cl.Message(content=response_text).send()
