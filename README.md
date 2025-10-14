# Supply Chain Assistant with Snowflake Intelligence

## Solution Overview

Modern supply chain operations face a critical challenge: efficiently managing raw material inventory across multiple manufacturing facilities. Operations managers must constantly balance inventory levels, deciding whether to transfer materials between plants with excess and shortage, or purchase new materials from suppliers. Making these decisions manually is time-consuming, error-prone, and often results in suboptimal cost outcomes.

This quickstart demonstrates how to build an intelligent supply chain assistant using Snowflake Intelligence and Cortex AI capabilities. By combining natural language querying with semantic search over both structured and unstructured data, you'll create a complete solution that helps operations managers make data-driven decisions about inventory management.

Here is a summary of what you will be able to learn by following this quickstart:

* **Setup Environment**: Create a comprehensive supply chain database with tables for manufacturing plants, inventory, suppliers, customers, orders, and shipments
* **Cortex Analyst**: Build a semantic model that understands your supply chain data and enables natural language text-to-SQL queries
* **Cortex Search**: Index unstructured supply chain documentation for intelligent retrieval using RAG (Retrieval Augmented Generation)
* **Snowflake Intelligence**: Create a no-code AI agent that intelligently routes user questions between Cortex Analyst and Cortex Search tools
* **Advanced Analytics**: Perform complex multi-table analysis to identify inventory rebalancing opportunities across your supply chain network

## The Problem

![Alt text](/images/problem.png "The Problem")

Supply chain operations managers face daily challenges managing raw material inventory across manufacturing facilities:

* **Inventory Imbalances**: Some plants have excess raw materials while others face shortages, creating inefficiency
* **Complex Decision Making**: Determining whether to transfer materials between plants or purchase from suppliers requires analyzing multiple factors including material costs, transport costs, lead times, and safety stock levels
* **Manual Analysis**: Traditional approaches require running multiple reports, spreadsheet analysis, and manual cost comparisons
* **Time Sensitivity**: Inventory decisions need to be made quickly to avoid production delays or excess carrying costs



## The Solution

![Alt text](/images/solution.png "The Solution")

This solution leverages Snowflake Intelligence and Cortex AI capabilities to create an intelligent assistant that:

1. **Answers Ad-Hoc Questions**: Operations managers can ask natural language questions about inventory levels, orders, shipments, and supplier information - the agent automatically converts questions to SQL and executes them
2. **Provides Contextual Information**: The assistant can search and retrieve relevant information from supply chain documentation using semantic search
3. **Intelligent Routing**: Automatically determines whether to query structured data (via Cortex Analyst) or search documents (via Cortex Search) based on the nature of the question
4. **Complex Analysis**: Handles sophisticated multi-table queries like identifying plants with low inventory alongside plants with excess inventory of the same materials, and comparing costs between suppliers and inter-plant transfers
5. **No-Code Agent Creation**: Build and deploy the entire solution using Snowflake Intelligence's visual interface without writing application code

## What is Snowflake Cortex?

Snowflake Cortex provides fully managed Generative AI capabilities that run securely within your Snowflake environment and governance boundary. Key features include:

**Cortex Analyst** - Enables business users to ask questions about structured data in natural language. It uses a semantic model to understand your data and generates accurate SQL queries automatically.

**Cortex Search** - Provides easy-to-use semantic search over unstructured data. It handles document chunking, embedding generation, and retrieval, making it simple to implement RAG (Retrieval Augmented Generation) patterns.

**Cortex Agents** - Orchestrates multiple AI capabilities (like Analyst and Search) to intelligently route user queries to the appropriate service and synthesize responses.

Learn more about [Snowflake Cortex](https://www.snowflake.com/en/product/features/cortex/).

## What is Snowflake Intelligence?

Snowflake Intelligence is a unified experience for building and deploying AI agents within Snowflake. It provides:

* **No-Code Agent Builder**: Create agents that combine multiple tools (Cortex Analyst, Cortex Search, Custom Tools) without writing code
* **Integrated Tools**: Easily connect your semantic models and search services as agent capabilities
* **Conversational Interface**: Interact with your agent through a chat interface within Snowsight
* **Enterprise Ready**: Built on Snowflake's security and governance foundation

Learn more about [Snowflake Intelligence](https://docs.snowflake.com/en/user-guide/snowflake-cortex/snowflake-intelligence).

## What You Will Learn

* How to model a multi-tier supply chain in Snowflake with proper relationships
* How to create a semantic model for Cortex Analyst with dimensions, measures, filters, and verified queries
* How to set up Cortex Search services on unstructured documents  
* How to build AI agents using Snowflake Intelligence's no-code interface
* How to combine multiple AI tools (Cortex Analyst and Cortex Search) in a single agent
* How to write effective tool descriptions and semantic models for accurate AI responses
* How to handle complex supply chain analytics questions using natural language

## What You Will Build

* A comprehensive supply chain database with 11 tables and realistic sample data
* A semantic model that understands supply chain terminology and relationships
* A Cortex Search service indexed on supply chain documentation
* A Snowflake Intelligence agent that intelligently routes questions to the appropriate AI tool
* Complex verified queries for inventory analysis, cost comparison, and rebalancing opportunities
* A production-ready AI assistant accessible directly within Snowsight

## Prerequisites

* A Snowflake account with Cortex features enabled. If you do not have a Snowflake account, you can [register for a free trial](https://signup.snowflake.com/).
* A Snowflake account login with ACCOUNTADMIN role OR a role that has the ability to create databases, schemas, tables, stages, and Cortex Search services.
* Cortex Analyst, Cortex Search, and Snowflake Intelligence must be available in your Snowflake region.
* Snowflake Intelligence privilege setup detailed [here](https://docs.snowflake.com/en/user-guide/snowflake-cortex/snowflake-intelligence#set-up-sf-intelligence) has been completed.

---



## Step 1 - DDL Setup

1. Open a new worksheet in Snowsight
2. Import the **1_supply_chain_ddl.sql** file.
3. Run All.

## Step 2 - Upload docs and files

Within the first step, all objects have been created in SUPPLY_CHAIN_NETWORK_OPTIMIZATION_DB.ENTITIES database/schema.
We created three internal stages, and will upload files to them now.

1. Navigate to the **Database Explorer** from the left side menu under **Horizon Catalog**.
2. Navigate to the SUPPLY_CHAIN_NETWORK_OPTIMIZATION_DB.ENTITIES database/schema, and then to **Stages**. We will click on each one in the steps below.
3. In the SCN_PDF stage, upload the **/search/Supply Chain Network Overview.pdf** file using the **+ Files** button on the top right
4. In the SEMANTIC_STAGE stage, upload the **/semantic/supply_chain_network.yaml** file using the **+ Files** button on the top right
5. In the CSV_Files stage, upload all files within the **/data/** folder using the **+ Files** button on the top right. There are 11 of them.

## Step 3 - Table Loading

1. Open a new worksheet in Snowsight
2. Import the **2_load_data_files.sql** file.
3. Run All.

## Step 4 - Cortex Search Service Creation

1. Open a new worksheet in Snowsight
2. Import the **3_supply_chain_search_setup.sql** file.
3. Run All.

## Step 5 - Create Your Snowflake Intelligence Agent

Now that you have your Semantic Model and Search Service created, you can combine them into an intelligent agent using Snowflake Intelligence.

1. Click on **Agents** within the AI & ML section on the left-hand navigation bar in Snowsight
2. Click **Create Agent** and name it **Supply_Chain_Agent**
3. Once created, click **Edit**, then navigate to **Tools** on the left

### Add Cortex Analyst Tool

4. Click **Add Tool** and select **Cortex Analyst**
5. Name it **Supply_Chain_Data**
6. Click **Semantic Model File** and navigate to:
   - Database: `SUPPLY_CHAIN_NETWORK_OPTIMIZATION_DB`
   - Schema: `ENTITIES`
   - Stage: `SEMANTIC_STAGE`
   - File: `supply_chain_network.yaml`
7. Select a warehouse to run queries (e.g., `SCNO_WH`)
8. Add a tool description: *"This Cortex Analyst tool contains the semantic model for our supply chain network data, and should be used to answer data-driven questions about our supply chain including inventory levels, orders, shipments, plants, customers, and suppliers."*

### Add Cortex Search Tool

9. Click **Add Tool** and select **Cortex Search**
10. Name it **Supply_Chain_Documents**
11. Add a tool description: *"This search service is indexed on our documentation about our business and our supply chain, and should be used to answer questions about business processes, policies, and conceptual information that are not data-driven."*
12. Select the search service: `SUPPLY_CHAIN_NETWORK_OPTIMIZATION_DB.ENTITIES.SUPPLY_CHAIN_INFO`
13. Set **PAGE_URL** as the ID column and **TITLE** as the Title column

### Save and Test Your Agent

14. Click **Save** to save your agent configuration
15. Start testing the agent directly on the right hand pane **or** Navigate to **Snowflake Intelligence** in the left navigation AI & ML menu
16. Select your **Supply_Chain_Agent** from the dropdown
17. Start asking questions!

## Step 6 - Try These Example Questions

Start with simple questions and build up to more complex analysis:

**Data Questions (routed to Cortex Analyst):**
- "How many orders did we receive in the last month?"
- "Which manufacturing plants have low inventory for which raw materials?"
- "Who are our top 5 customers by order value?"
- "What's the total quantity of finished goods in our manufacturing plants?"

**Documentation Questions (routed to Cortex Search):**
- "Explain how shipment tracking works in our business"
- "What are our business lines?"
- "How does our supply chain network operate?"

**Complex Analysis Questions:**
- "Which manufacturing plants have low inventory of raw materials AND which plants have excess inventory of those same materials?"
- "For plants with low inventory of a raw material, compare the cost of replenishing from a supplier vs transferring from another plant with excess inventory"

Notice how the agent automatically determines which tool to use based on your question!

![Alt text](/images/Agent.gif "Snowflake Intelligence")

## Step 7 - Extra Credit!

1. We have added some weather data that reflects the locations in our Supply Chain in the **/weather/** folder. It also includes an extra .yaml file that can used for another semantic model. When creating Agents in Snowflake Intelligence, this semantic model can be added as an additional tool, and the agent can answer questions across both semantic models.
2. Speaking of tools, we have added some custom tool definitions in **/tools/tool_DDL.sql**. This includes Tool Descriptions (to be used in the Agent Definition) and the DDL for the UDFs/Stored Procedures that you will use as Custom Tools. These 4 tools include: 
    1. a Web Search that will use the DuckDuckGo HTML endpoint to search for web results on a given topic
    2. a Web Scrape that will extract text content from webpages (such as those returned by the Web Search)
    3. an HTML generator intended to format emails or newsletters in consistent HTML formatting
    4. an Email Send tool that uses Snowflake's SYSTEM$SEND_EMAIL function to deliver an email, newsletter, executive summary, etc. **Note:** this will require an [email notification integration](https://docs.snowflake.com/en/user-guide/notifications/email-notifications).
