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
3. In the CSV_Files stage, upload all files within the **/data/** folder. There are 11 of them.

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
