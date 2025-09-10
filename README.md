# For Beginners: The Demo Template

> [!IMPORTANT]  
> This is a customized version of the [Get Started With AI Agents](https://github.com/nitya/get-started-with-ai-agents) template recommended by Azure AI Foundry. The [original README](./README.azd.md) provides the documentation for the template itself. However _this_ repository contains a [WORKSHOP](./workshop/README.md) resource that will help guide you through setup and experimentation with the template, with a specific view on supporting the [Models For Beginners](https://aka.ms/models-for-beginners), [Model Mondays](https://aka.ms/model-mondays) and related 1P workshops focused on model selection, customization and optimization.

## What It Provides

This repository streamlines the _infrastructure setup_ for relevant open-source curricula 

This repository provides an actionable templat for delivering open-source curriculum or providing repo-hosted workshops in conjunction with Azure Samples projects, by taking advantage of the built-in GitHub Pages hosting in the source repository. 

1. The projects will use [Mkdocs Material](https://github.com/squidfunk/mkdocs-material) for the documentation setup
3. The projects will use [AI Quickstart Templates](https://ai.azure.com/templates) for infrastructure setup


## How To Use It

This template is ideally suited to "For Beginners" projects that have labs that require Azure AI Foundry usage. This template provides learners with the guidance for setting up, configuring, and customizing various aspects of the default Azure AI Foundry quickstart template for AI Agents.

This decouples infrastructure setup from curriculum usage, allowing projects like "Models For Beginners" to focus on lessons and labs that simply expect environment variables set to a pre-deployed infra. This has two benefits:

1. Learners can manually provision infra using Azure AI Foundry portal, CLI or SDK, working through this per lesson, or per curricula.
1. Learners can use this template to provision infra with azd (using our built-in guidance and extensions) for multiple lessons (or curricula) at one shot.

**The First Testbed for this will be the upcoming Models For Beginners curriculum with emphasis on using the new Foundry Architecture**.


## Personas

Each project will adhere to a consistent format for documentation to enhacne the learning experience for AI engineers and beginners alike. We expect three kinds of personas to use these projects, and want to make sure experience is optimized for all

1. **Beginner** - new to the topic - interested in concepts to code.
2. **Developer** - comfortable with code - interested in tools & techniques.
3. **AI Engineer** - building intelligent apps - interested in E2E solutions.

## Calls To Action

To complement the journey, we ask each template user to add these three calls to action to their README.md

1. [**Bookmark the Learn Collection** 📚](https://learn.microsoft.com/en-us/collections/7d2wswpx0d02qj) - and use it to discover other resources
1. [**Join the AI Discord**](https://discord.gg/zxKYvhSnVp) 💬 - connect with experts & builders online around AI!
1. [**Join the Global AI Community**](https://globalai.community/) - connect with experts & builders in your region!


## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft 