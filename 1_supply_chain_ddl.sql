/* set up roles */
use role accountadmin;

create warehouse if not exists scno_wh WAREHOUSE_SIZE=SMALL comment='{"origin":"sf_sit","name":"scno","version":{"major":1, "minor":0},"attributes":{"component":"scno"}}';

/* create role and add permissions required by role for installation of framework */
create role if not exists scno_role;

/* perform grants */

grant create database on account to role scno_role with grant option;
grant execute task on account to role scno_role;

/* add cortex_user database role to use Cortex */
grant database role snowflake.cortex_user to role scno_role;
grant role scno_role to role sysadmin;
grant usage, operate on warehouse scno_wh to role scno_role;

/* set up provider side objects */
use role scno_role;

use warehouse scno_wh;

/* create database */
create or replace database supply_chain_network_optimization_db comment='{"origin":"sf_sit","name":"scno","version":{"major":1, "minor":0},"attributes":{"component":"scno"}}';
create or replace schema supply_chain_network_optimization_db.entities comment='{"origin":"sf_sit","name":"scno","version":{"major":1, "minor":0},"attributes":{"component":"scno"}}';

drop schema if exists supply_chain_network_optimization_db.public;

use database supply_chain_network_optimization_db;
use schema entities;

-- Suppliers
create or replace TABLE SUPPLIERS (
	SUPPLIER_ID INTEGER NOT NULL COMMENT 'Unique identifier for the supplier',
	SUPPLIER_NAME VARCHAR(255) NOT NULL COMMENT 'Name of the supplier company',
	ADDRESS VARCHAR(255) COMMENT 'Street address of the supplier',
	CITY VARCHAR(100) COMMENT 'City of the supplier',
	STATE VARCHAR(50) COMMENT 'State/Province of the supplier',
	COUNTRY VARCHAR(50) COMMENT 'Country of the supplier',
	ZIP_CODE VARCHAR(20) COMMENT 'Postal code of the supplier',
	CONTACT_PERSON_NAME VARCHAR(255) COMMENT 'Primary contact person at the supplier',
	CONTACT_EMAIL VARCHAR(255) COMMENT 'Contact email address',
	CONTACT_PHONE VARCHAR(50) COMMENT 'Contact phone number',
	SUPPLIER_TYPE VARCHAR(100) COMMENT 'Type of supplier (Raw Materials, Components, Services, etc.)',
	BUSINESS_LINE VARCHAR(15) COMMENT 'business line (AEROSPACE, INDUSTRIAL, BUILDINGS, ENERGY)',
	IS_PREFERRED BOOLEAN DEFAULT FALSE COMMENT 'Indicates if this is a preferred supplier',
	PAYMENT_TERMS VARCHAR(50) COMMENT 'Standard payment terms (Net 30, Net 60, etc.)',
	primary key (SUPPLIER_ID)
)COMMENT='Information about suppliers who provide raw materials and components'
;

-- Bill of Materials
create or replace TABLE BILL_OF_MATERIALS (
	BOM_ID INTEGER NOT NULL COMMENT 'Unique identifier for the bill of materials entry',
	PARENT_PRODUCT_ID INTEGER COMMENT 'Product that uses these materials/components',
	PARENT_COMPONENT_ID INTEGER COMMENT 'Component that uses these materials (for sub-assemblies)',
	CHILD_MATERIAL_ID INTEGER COMMENT 'Raw material used in this BOM',
	CHILD_COMPONENT_ID INTEGER COMMENT 'Component used in this BOM',
	QUANTITY_REQUIRED NUMBER(10,4) NOT NULL COMMENT 'Quantity of the child item required per parent item',
	UNIT_OF_MEASURE VARCHAR(50) COMMENT 'Unit of measure (pieces, kg, meters, etc.)',
	SCRAP_FACTOR NUMBER(5,4) DEFAULT 0.0 COMMENT 'Expected scrap/waste factor (0.05 = 5% scrap)',
	EFFECTIVE_DATE DATE COMMENT 'Date when this BOM version becomes effective',
	EXPIRATION_DATE DATE COMMENT 'Date when this BOM version expires',
	primary key (BOM_ID)
)COMMENT='Bill of materials defining what raw materials and components are needed to produce products and components'
;

-- Component
create or replace TABLE COMPONENT (
	COMPONENT_ID INTEGER NOT NULL COMMENT 'Unique identifier for the component',
	COMPONENT_NAME VARCHAR(255) NOT NULL COMMENT 'Name of the component',
	COMPONENT_DESCRIPTION VARCHAR(1024) COMMENT 'Description of the component',
	BILL_OF_MATERIALS_ID INTEGER COMMENT 'Foreign key referencing a bill_of_materials table (if applicable)',
	BUSINESS_LINE VARCHAR(15) COMMENT 'business line (AEROSPACE, INDUSTRIAL, BUILDINGS, ENERGY)',
	primary key (COMPONENT_ID)
)COMMENT='Information about individual components'
;

-- Product
create or replace TABLE PRODUCT (
	PRODUCT_ID INTEGER NOT NULL COMMENT 'Unique identifier for the product',
	PRODUCT_NAME VARCHAR(255) NOT NULL COMMENT 'Name of the product',
	PRODUCT_DESCRIPTION VARCHAR(1024) COMMENT 'Description of the product',
	PRODUCT_CATEGORY VARCHAR(100) COMMENT 'Category of the product',
	UNIT_PRICE NUMBER(10,2) COMMENT 'Price per unit of the product',
	BUSINESS_LINE VARCHAR(15) COMMENT 'business line (AEROSPACE, INDUSTRIAL, BUILDINGS, ENERGY)',
	primary key (PRODUCT_ID)
)COMMENT='Information about finished goods products'
;

-- Manufacturing Plant
create or replace TABLE MFG_PLANT (
	MFG_PLANT_ID INTEGER COMMENT 'Unique identifier for each manufacturing plant.',
	MFG_PLANT_NAME VARCHAR(255) COMMENT 'The name of the manufacturing plant.',
	ADDRESS VARCHAR(255) COMMENT 'Manufacturing plant addresses.',
	CITY VARCHAR(100) COMMENT 'Names of cities where manufacturing plants are located.',
	STATE VARCHAR(50) COMMENT 'The abbreviated name of the U.S. state where the manufacturing plant is located.',
	COUNTRY VARCHAR(50) COMMENT 'The country where the manufacturing plant is located.',
	ZIP_CODE VARCHAR(20) COMMENT 'Five-digit codes representing specific geographic locations in the United States.',
	LATITUDE NUMBER(10,6) COMMENT 'The geographical latitude coordinate.',
	LONGITUDE NUMBER(11,6) COMMENT 'Longitudes of manufacturing plant locations.',
	PLANT_MANAGER_CONTACT_ID INTEGER COMMENT 'Unique identifier for the contact person managing each manufacturing plant.',
	SQUARE_FOOTAGE NUMBER(10,2) COMMENT 'The size of the manufacturing plant measured in square footage.',
	NUMBER_OF_EMPLOYEES NUMBER(38,0) COMMENT 'The number of employees at the manufacturing plant.',
	IS_ACTIVE BOOLEAN COMMENT 'Indicates whether the manufacturing plant is currently in operation.',
	BUSINESS_LINE VARCHAR(15) COMMENT 'The business line to which the manufacturing plant belongs (AEROSPACE, INDUSTRIAL, BUILDINGS, ENERGY).'
)COMMENT='Manufacturing plants that produce components and assemble finished products for direct sale to customers'
;

-- Manufacturing Plant Inventory (handles both raw materials, components, and finished products)
create or replace TABLE MFG_INVENTORY (
	MFG_PLANT_ID INTEGER NOT NULL COMMENT 'Foreign key referencing MFG_PLANT',
	MATERIAL_ID INTEGER COMMENT 'Foreign key referencing raw_material table (if applicable)',
	COMPONENT_ID INTEGER COMMENT 'Foreign key referencing component table (if applicable)',
	PRODUCT_ID INTEGER COMMENT 'Foreign key referencing product table (if applicable)',
	QUANTITY_ON_HAND NUMBER(38,0) COMMENT 'Current quantity on hand',
	QUANTITY_ON_ORDER NUMBER(38,0) COMMENT 'Quantity currently on order',
	SAFETY_STOCK_LEVEL NUMBER(38,0) COMMENT 'Minimum inventory level to maintain',
	REPLENISHMENT_POINT NUMBER(38,0) COMMENT 'Target inventory level for replenishment calculations',
	LAST_UPDATED_TIMESTAMP TIMESTAMP_NTZ(9) COMMENT 'Timestamp of the last inventory update',
	MATERIAL_LEAD_TIME NUMBER(38,0) COMMENT 'Lead time in days to acquire/produce this item',
	DAYS_FORWARD_COVERAGE NUMBER(38,0) COMMENT 'Number of days current inventory can sustain demand',
	LEAD_TIME_VARIABILITY NUMBER(38,0) COMMENT 'Variability in lead time, measured in days'
)COMMENT='Inventory levels of raw materials, components, and finished products at manufacturing plants'
;

-- Customer
create or replace TABLE CUSTOMER (
	CUSTOMER_ID INTEGER NOT NULL COMMENT 'Unique identifier for the customer',
	CUSTOMER_NAME VARCHAR(255) NOT NULL COMMENT 'Name of the customer',
	ADDRESS VARCHAR(255) COMMENT 'Street address of the customer',
	CITY VARCHAR(100) COMMENT 'City of the customer',
	STATE VARCHAR(50) COMMENT 'State/Province of the customer',
	COUNTRY VARCHAR(50) COMMENT 'Country of the customer',
	ZIP_CODE VARCHAR(20) COMMENT 'Postal code of the customer',
	CONTACT_PERSON_ID INTEGER COMMENT 'Foreign key referencing a contacts table (if applicable)',
	INDUSTRY VARCHAR(100) COMMENT 'Industry of the customer',
	BUSINESS_LINE VARCHAR(15) COMMENT 'business line (AEROSPACE, INDUSTRIAL, BUILDINGS, ENERGY)',
	primary key (CUSTOMER_ID)
)COMMENT='Information about direct customers who purchase products from manufacturing plants'
;

-- Shipment (simplified for direct MFG plant to customer shipments)
create or replace TABLE SHIPMENT (
	SHIPMENT_ID INTEGER NOT NULL COMMENT 'Unique identifier for the shipment',
	ORIGIN_MFG_PLANT_ID INTEGER COMMENT 'Foreign key referencing the originating manufacturing plant',
	DESTINATION_CUSTOMER_ID INTEGER COMMENT 'Foreign key referencing the destination customer',
	SHIP_DATE DATE COMMENT 'Date the shipment was shipped',
	EXPECTED_DELIVERY_DATE DATE COMMENT 'Expected delivery date of the shipment',
	ACTUAL_DELIVERY_DATE DATE COMMENT 'Actual delivery date of the shipment',
	SHIPPING_COST NUMBER(10,2) COMMENT 'Cost of shipping',
	TRACKING_NUMBER VARCHAR(50) COMMENT 'Tracking number for the shipment',
	primary key (SHIPMENT_ID)
)COMMENT='Information about shipments from manufacturing plants directly to customers'
;

-- Orders (simplified for direct customer to MFG plant orders)
create or replace TABLE ORDERS (
	ORDER_ID INTEGER NOT NULL COMMENT 'Unique identifier for the order',
	CUSTOMER_ID INTEGER NOT NULL COMMENT 'Foreign key referencing the customer',
	MFG_PLANT_ID INTEGER COMMENT 'Foreign key referencing the manufacturing plant fulfilling the order',
	ORDER_DATE TIMESTAMP_NTZ(9) COMMENT 'Date and time the order was placed',
	PRODUCT_ID INTEGER NOT NULL COMMENT 'Foreign key referencing the product',
	QUANTITY NUMBER(38,0) NOT NULL COMMENT 'Quantity of the product ordered',
	UNIT_PRICE NUMBER(10,2) NOT NULL COMMENT 'Price per unit at the time of order',
	TOTAL_PRICE NUMBER(10,2) NOT NULL COMMENT 'Total price of the order line',
	ORDER_STATUS VARCHAR(50) COMMENT 'Status of the order (e.g., Placed, In Production, Shipped, Delivered, Cancelled)',
	primary key (ORDER_ID)
)COMMENT='Information about customer orders placed directly with manufacturing plants'
;

create or replace TABLE RAW_MATERIAL (
	MATERIAL_ID INTEGER NOT NULL COMMENT 'Unique identifier for each raw material.',
	MATERIAL_NAME VARCHAR(16777216) COMMENT 'Names of raw materials used in the supply chain network.',
	MATERIAL_DESCRIPTION VARCHAR(16777216) COMMENT 'Detailed descriptions of raw materials.',
	SUPPLIER_ID INTEGER COMMENT 'Foreign key referencing the primary supplier for this material',
	MATERIAL_COST NUMBER(10,2) COMMENT 'The cost of the raw material from the supplier',
	PLANT_TRANSPORT_COST NUMBER(10,2) COMMENT 'Base cost for transporting this material between plants (before surcharge multiplier)',
	BUSINESS_LINE VARCHAR(15) COMMENT 'business line (AEROSPACE, INDUSTRIAL, BUILDINGS, ENERGY)',
	primary key (MATERIAL_ID)
)COMMENT='Raw materials sourced from suppliers and used in manufacturing plants to produce components and products'
;

create or replace TABLE TRANSPORT_COST_SURCHARGE (
	SOURCE_FACILITY_ID INTEGER NOT NULL COMMENT 'Unique identifier for the source facility with excess inventory',
	DESTINATION_FACILITY_ID INTEGER NOT NULL COMMENT 'Unique identifier for the destination facility that will receive materials',
	TRANSPORT_COST_SURCHARGE NUMBER(3,2) NOT NULL COMMENT 'Transport costs multiplier between facilities depending on distance and transport difficulty'
)COMMENT='Transport cost surcharge for moving materials between manufacturing plants'
;

-- Run the following statement to create a Snowflake managed internal stage to store the semantic model specification file.
create or replace stage SEMANTIC_STAGE encryption = (TYPE = 'SNOWFLAKE_SSE') directory = ( ENABLE = true );

-- Run the following statement to create a Snowflake managed internal stage to store the PDF documents.
 create or replace stage SCN_PDF encryption = (TYPE = 'SNOWFLAKE_SSE') directory = ( ENABLE = true );

 create or replace file format csvformat  
  skip_header = 1  
  field_optionally_enclosed_by = '"'  
  type = 'CSV';  
 
 -- Run the following statement to create a Snowflake managed internal stage to store the csv data files.
 create or replace stage CSV_FILES file_format = csvformat encryption = (TYPE = 'SNOWFLAKE_SSE') directory = ( ENABLE = true );

-- Conversation History table for storing chat threads and messages
create or replace TABLE CONVERSATION_HISTORY (
	CONVERSATION_ID STRING NOT NULL COMMENT 'Unique identifier for each conversation thread',
	THREAD_NAME STRING NOT NULL COMMENT 'User-friendly name for the conversation thread',
	CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Timestamp when the conversation was created',
	UPDATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Timestamp when the conversation was last updated',
	MESSAGES VARIANT COMMENT 'JSON array of messages in the conversation thread',
	primary key (CONVERSATION_ID)
)COMMENT='Storage for conversation history and chat threads for the Supply Chain Assistant';