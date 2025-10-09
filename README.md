# Supply Chain Intelligent Assistant Demo

## Step 1 - DDL Setup

1. Open a new worksheet in Snowsight
2. Import the **1_supply_chain_ddl.sql** file.
3. Run All.

## Step 2 - Upload docs and files

Within the first step, all objects have been created in SUPPLY_CHAIN_NETWORK_OPTIMIZATION_DB.ENTITIES database/schema.
We created three internal stages, and will upload files to them now.

1. In the SCN_PDF stage, upload the **/search/Supply Chain Network Overview.pdf** file
2. In the SEMANTIC_STAGE stage, upload the **/semantic/supply_chain_network.yaml** file
3. In the CSV_Files stage, upload all files within the **/data/** folder. There are 13 of them.

## Step 3 - Table Loading

1. Open a new worksheet in Snowsight
2. Import the **2_load_data_files.sql** file.
3. Run All.

## Step 4 - Cortex Search Service Creation

1. Open a new worksheet in Snowsight
2. Import the **3_supply_chain_search_setup.sql** file.
3. Run All.

## Step 5 - Create the Streamlit application

1. Create a new Streamlit application within SUPPLY_CHAIN_NETWORK_OPTIMIZATION_DB.ENTITIES, using the SCNO_WH warehouse.
2. Replace the template code with the code within the **4_Supply_Chain_Assistant_streamlit.py** file.
3. Click on Packages, and add the **scipy** package
4. **Note:** This app references claude-3.5-sonnet in the Cortex Agents API on line 225 which may not be available in your region. Feel free to change this to a model available in your region.
4. We need to add a couple images to this application. Open the App Explorer on the left pane (you may need to use the pane view buttons on the bottom left of Snowsight)
5. Click the **+** sign above the _environment.yml_ and _streamlit_app.py_ files, and upload the two images within the **/images/** folder.

## Step 6 - Demo the App!

1. Click Run on your new application (**Note: this app doesn't look great in dark mode, use light unless you change the markdown settings**)
2. Click on the **Supply Chain Assistant** button on the sidebar
3. Start asking questions! I like to start simple with _"How many orders did we receive in the last month?"_
4. Try a question that should be routed to Cortex Search. I like _"Explain how shipment tracking works in our business"_
5. I like to get more complex with an Analyst question like _"Which manufacturing plants have low inventory for which raw materials?"_
6. My most complex question is _"For Manufacturing plants with low inventory of a raw material, compare the cost of replenishing from a supplier vs transferring from another plant with excess inventory"_
7. Jumping off this point, I explain that this is a regular problem I'd like to solve, and I'd like to go from possible recommendations to optimized transfer actions. Click on the **Optimization Execution** button on the sidebar.
8. On the Optimization Execution page, a diagram of the problem we're trying to solve as well as a description of linear optimization can be found. There is also a preloaded dataframe containing the last question we asked - Low and Excess Inventory plants of certain materials. Click on the **Optimize for Cost** button, and the Solver will run, outputting the 10 actions we will take today, as well as some metrics.
9. **Please note:** This application was created with a preview version of the Cortex Agents API, and some behavior may have changed. For a consistent experience, consider leveraging Snowflake Intelligence as detailed in the Step below.

## Step 7 - Snowflake Intelligence Updates!

1. Once you have your Semantic Model and your Search Service created, we can now use these same assets when creating an agent for Snowflake Intelligence.
2. Click on **Agents** within the AI & ML section on the left-hand navigation bar. Click **Create Agent**. Name the agent **Supply_Chain_Agent**.
3. Once the agent is created, click **Edit**, and then navigate to **Tools** on the left.
4. Add a Cortex Analyst tool. Name it **Supply Chain Data**, click **Semantic Model File**, and navigate to SUPPLY_CHAIN_NETWORK_OPTIMIZATION_DB.ENTITIES database/schema and SEMANTIC_STAGE stage. Select **supply_chain_network.yaml**, and select a warehouse to submit queries against it. You'll need to add a description. I used "This Cortex Analyst tool contains the semantic model for our supply chain network data, and should be used to answer data-driven questions about our supply chain."
5. Add a Cortex Search Service tool. Name it **Supply Chain Documents**. Create a description. I used "This search service is indexed on our documentation about our business and our supply chain, and should be used to answer questions about those topics that are not data-driven." Select the SUPPLY_CHAIN_NETWORK_OPTIMIZATION_DB.ENTITIES.SUPPLY_CHAIN_INFO service. Use **PAGE_URL** as the ID column and **TITLE** as the Title column.
6. Save your Agent, and go use it in Snowflake Intelligence

## Step 8 - Extra Credit!

1. We have added some weather data that reflects the locations in our Supply Chain in the **/weather/** folder. It also includes an extra .yaml file that can used for another semantic model. When creating Agents in Snowflake Intelligence, this semantic model can be added as an additional tool, and the agent can answer questions across both semantic models.
2. Speaking of tools, we have added some custom tool definitions in **/tools/tool_DDL.sql**. This includes Tool Descriptions (to be used in the Agent Definition) and the DDL for the UDFs/Stored Procedures that you will use as Custom Tools. These 4 tools include: 
    1. a Web Search that will use the DuckDuckGo HTML endpoint to search for web results on a given topic
    2. a Web Scrape that will extract text content from webpages (such as those returned by the Web Search)
    3. an HTML generator intended to format emails or newsletters in consistent HTML formatting
    4. an Email Send tool that uses Snowflake's SYSTEM$SEND_EMAIL function to deliver an email, newsletter, executive summary, etc. **Note:** this will require an email integration.
