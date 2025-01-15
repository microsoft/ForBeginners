# Introduction

This repository provides a template for building workshops or open-source curriculum in a way that complies with Microsoft open-source and compliance standards. The project has three objectives:

1. Instrument repos with a _dev container_ to make setup fast and consistent
1. Create an _mkdocs website_ that can be hosted on GitHub pages
1. Review for _website compliance_ to get a Microsoft-approved baseline

Once completed, this repository will be converted into a template with two base projects, one for each "type" of content delivery. Simply instantiate the template and refactor the identified folders to reflect _your_ instructions and code samples.

## WORKSHOP: RAG on Azure AI

This section contains the step-by-step instructions format that is suitable for delivering a workshop in events like the Microsoft AI Tour. 

It provides guidance on setup and usage with Skillable, to allow learners to view a hosted version of workshop instructions (from your instance's GH pages) or launch their own preview within GitHuB Codespaces.

It provides code steps in the form of _src.sample/_ folders where instructions simply ask learners to copy things over (too build from scratch) or reference inline (to understand code structures).

<br/>

## CURRICULUM: Agents For Beginners

This section contains the lesson-by-lesson coverage of a topic intended for self-guided learning in a curriculum format. 

It provides exercises in the form of _sample notebooks_ that learners can execute in GitHub Codespaces (where the content creator can ensure requirements are met with dev container configuration updates)

---

## Getting Started

This repository is instrumented with a `devcontainer.json` to give you a development environment with all required dependencies pre-installed. To get started:

1. [Fork the repository](https://github.com/nitya/azure-ai-rag-workshop) to your personal profile. _Visit your fork in the browser_.

1. Launch Codespaces on that fork. _Setup will take a few minutes_.
1. Type this command into the VS Code terminal when ready. _A dialog will pop up_.

    ```bash title=""
    mkdocs serve
    ```

1. Select the "View in browser" option in the pop-up dialog. _You should see this guide_.

1. Open a second VS Code terminal pane. _Use that for all further instructions_.
