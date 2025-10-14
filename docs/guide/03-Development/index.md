# 3. Development

Now you know how the AZD template is structured in your repository (_infrastructure as code_), let's deconstruct this specific template to understand what Azure AI Foundry features it provides us - that we can then customize and extend for our own application.

Specifically, the Get Started With AI Agents template has:

1. An Azure AI Foundry project & resource setup
1. A sample AI Agent using the Azure AI Agent Service
1. An AI chat model deployment (for use by the agent)
1. An AI Search resource with sample data and index
1. An AI embedding model deployment (for vector query)
1. Activated tracing & monitoring features (for observability)
1. An AI Red Teaming Agent sample (for adversarial testing)
1. An AI Evaluation SDK sample (for quality & safety testing)
1. An Azure Container Apps instance (for agent endpoint)
1. A basic React front-end (for web-based agent UI)

By the end of this section you should know how to  activate & test a specific feature - and where to find the code/configuration required to customize it. Some things you should be able to do:

1. Add your data - ground responses with your index
1. Add new models - replace or compare for better choice
1. Expand attack strategies for red teaming - for robust testing
1. Expand list of evaluators used - for quality, safety, agentic
1. Update the front-end application - custom UI/UX for app

---