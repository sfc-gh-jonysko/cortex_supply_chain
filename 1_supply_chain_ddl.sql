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

-- Component
create or replace TABLE COMPONENT (
	COMPONENT_ID VARCHAR(36) NOT NULL COMMENT 'Unique identifier for the component (UUID)',
	COMPONENT_NAME VARCHAR(255) NOT NULL COMMENT 'Name of the component',
	COMPONENT_DESCRIPTION VARCHAR(1024) COMMENT 'Description of the component',
	BILL_OF_MATERIALS_ID VARCHAR(36) COMMENT 'Foreign key referencing a bill_of_materials table (if applicable)',
	BUSINESS_LINE VARCHAR(10) COMMENT 'business line (AERO, IA, BA, ESS)',
	primary key (COMPONENT_ID)
)COMMENT='Information about individual components'
;

-- Product
create or replace TABLE PRODUCT (
	PRODUCT_ID VARCHAR(36) NOT NULL COMMENT 'Unique identifier for the product (UUID)',
	PRODUCT_NAME VARCHAR(255) NOT NULL COMMENT 'Name of the product',
	PRODUCT_DESCRIPTION VARCHAR(1024) COMMENT 'Description of the product',
	PRODUCT_CATEGORY VARCHAR(100) COMMENT 'Category of the product',
	UNIT_PRICE NUMBER(10,2) COMMENT 'Price per unit of the product',
	BUSINESS_LINE VARCHAR(10) COMMENT 'business line (AERO, IA, BA, ESS)',
	primary key (PRODUCT_ID)
)COMMENT='Information about finished goods products'
;

-- CMF Facility
create or replace TABLE MFG_PLANT (
	MFG_PLANT_ID VARCHAR(36) COMMENT 'Unique identifier for each manufacturing plant.',
	MFG_PLANT_NAME VARCHAR(255) COMMENT 'The name of the manufacturing plant.',
	ADDRESS VARCHAR(255) COMMENT 'Manufacturing plant addresses.',
	CITY VARCHAR(100) COMMENT 'Names of cities where manufacturing plants are located.',
	STATE VARCHAR(50) COMMENT 'The abbreviated name of the U.S. state where the manufacturing plant is located.',
	COUNTRY VARCHAR(50) COMMENT 'The country where the manufacturing plant is located.',
	ZIP_CODE VARCHAR(20) COMMENT 'Five-digit codes representing specific geographic locations in the United States.',
	LATITUDE NUMBER(10,6) COMMENT 'The geographical latitude coordinate.',
	LONGITUDE NUMBER(11,6) COMMENT 'Longitudes of manufacturing plant locations.',
	PLANT_MANAGER_CONTACT_ID VARCHAR(36) COMMENT 'Unique identifier for the contact person managing each manufacturing plant.',
	SQUARE_FOOTAGE NUMBER(10,2) COMMENT 'The size of the manufacturing plant measured in square footage.',
	NUMBER_OF_EMPLOYEES NUMBER(38,0) COMMENT 'The number of employees at the manufacturing plant.',
	IS_ACTIVE BOOLEAN COMMENT 'Indicates whether the manufacturing plant is currently in operation.',
	BUSINESS_LINE VARCHAR(10) COMMENT 'The business line to which the manufacturing plant belongs.'
)COMMENT='The table contains records of manufacturing plants, each record including the plant''s name, location details, plant manager contact information, square footage, number of employees, and business line.'
;


-- CMF Inventory
create or replace TABLE MFG_INVENTORY (
	MFG_PLANT_ID VARCHAR(36) NOT NULL COMMENT 'Foreign key referencing MFG_PLANT',
	MATERIAL_ID VARCHAR(36) COMMENT 'Foreign key referencing a raw_material table (if applicable)',
	COMPONENT_ID VARCHAR(36) COMMENT 'Foreign key referencing component (if applicable, otherwise NULL if material_id is populated)',
	QUANTITY_ON_HAND NUMBER(38,0) COMMENT 'Current quantity of the material/component on hand',
	QUANTITY_ON_ORDER NUMBER(38,0) COMMENT 'Quantity of the material/component currently on order',
	SAFETY_STOCK_LEVEL NUMBER(38,0) COMMENT 'Minimum inventory level to maintain',
	LAST_UPDATED_TIMESTAMP TIMESTAMP_NTZ(9) COMMENT 'Timestamp of the last inventory update',
	MATERIAL_LEAD_TIME NUMBER(38,0) COMMENT 'How many days lead time to acquire this raw material',
	DAYS_FORWARD_COVERAGE NUMBER(38,0) COMMENT 'The number of days the current on-hand inventory of a raw material at a CMF facility can sustain production, assuming no further replenishment, based on expected demand of that material.',
	LEAD_TIME_VARIABILITY NUMBER(38,0) COMMENT 'The variability in material lead time, measured in days'
)COMMENT='Inventory levels of raw materials and components at CMFs'
;



-- FAT Facility
create or replace TABLE FAT_FACILITY (
	FAT_FACILITY_ID VARCHAR(36) NOT NULL COMMENT 'Unique identifier for the FAT facility (UUID)',
	FACILITY_NAME VARCHAR(255) NOT NULL COMMENT 'Name of the FAT facility',
	ADDRESS VARCHAR(255) COMMENT 'Street address of the facility',
	CITY VARCHAR(100) COMMENT 'City of the facility',
	STATE VARCHAR(50) COMMENT 'State/Province of the facility',
	COUNTRY VARCHAR(50) COMMENT 'Country of the facility',
	ZIP_CODE VARCHAR(20) COMMENT 'Postal code of the facility',
	LATITUDE NUMBER(10,6) COMMENT 'Latitude coordinate of the facility',
	LONGITUDE NUMBER(11,6) COMMENT 'Longitude coordinate of the facility',
	PLANT_MANAGER_CONTACT_ID VARCHAR(36) COMMENT 'Foreign key referencing a contacts table (if applicable)',
	SQUARE_FOOTAGE NUMBER(10,2) COMMENT 'Total square footage of the facility',
	NUMBER_OF_EMPLOYEES NUMBER(38,0) COMMENT 'Number of employees at the facility',
	IS_ACTIVE BOOLEAN COMMENT 'Indicates if the facility is currently active',
	BUSINESS_LINE VARCHAR(10) COMMENT 'business line (AERO, IA, BA, ESS)',
	primary key (FAT_FACILITY_ID)
)COMMENT='Information about Final Assembly and Test (FAT) Facilities'
;


-- FAT Inventory
create or replace TABLE FAT_INVENTORY (
	FAT_FACILITY_ID VARCHAR(36) NOT NULL COMMENT 'Foreign key referencing fat_facility',
	COMPONENT_ID VARCHAR(36) COMMENT 'Foreign key referencing component (if applicable, otherwise NULL if product_id is populated)',
	PRODUCT_ID VARCHAR(36) COMMENT 'Foreign key referencing product (if applicable, otherwise NULL if component_id is populated)',
	QUANTITY_ON_HAND NUMBER(38,0) COMMENT 'Current quantity of the component/product on hand',
	QUANTITY_ON_ORDER NUMBER(38,0) COMMENT 'Quantity of the component/product currently on order',
	REORDER_POINT NUMBER(38,0) COMMENT 'Inventory level at which a reorder should be placed',
	SAFETY_STOCK_LEVEL NUMBER(38,0) COMMENT 'Minimum inventory level to maintain',
	LAST_UPDATED_TIMESTAMP TIMESTAMP_NTZ(9) COMMENT 'Timestamp of the last inventory update'
)COMMENT='Inventory levels of components and finished goods at FAT facilities'
;



-- Distributor
create or replace TABLE DISTRIBUTOR (
	DISTRIBUTOR_ID VARCHAR(36) NOT NULL COMMENT 'Unique identifier for the distributor (UUID)',
	DISTRIBUTOR_NAME VARCHAR(255) NOT NULL COMMENT 'Name of the distributor',
	ADDRESS VARCHAR(255) COMMENT 'Street address of the distributor',
	CITY VARCHAR(100) COMMENT 'City of the distributor',
	STATE VARCHAR(50) COMMENT 'State/Province of the distributor',
	COUNTRY VARCHAR(50) COMMENT 'Country of the distributor',
	ZIP_CODE VARCHAR(20) COMMENT 'Postal code of the distributor',
	CONTACT_PERSON_ID VARCHAR(36) COMMENT 'Foreign key referencing a contacts table (if applicable)',
	REGION_SERVED VARCHAR(100) COMMENT 'Geographic region served by the distributor',
	BUSINESS_LINE VARCHAR(10) COMMENT 'business line (AERO, IA, BA, ESS)',
	primary key (DISTRIBUTOR_ID)
)COMMENT='Information about distributors'
;

-- Customer
create or replace TABLE CUSTOMER (
	CUSTOMER_ID VARCHAR(36) NOT NULL COMMENT 'Unique identifier for the customer (UUID)',
	CUSTOMER_NAME VARCHAR(255) NOT NULL COMMENT 'Name of the customer',
	ADDRESS VARCHAR(255) COMMENT 'Street address of the customer',
	CITY VARCHAR(100) COMMENT 'City of the customer',
	STATE VARCHAR(50) COMMENT 'State/Province of the customer',
	COUNTRY VARCHAR(50) COMMENT 'Country of the customer',
	ZIP_CODE VARCHAR(20) COMMENT 'Postal code of the customer',
	CONTACT_PERSON_ID VARCHAR(36) COMMENT 'Foreign key referencing a contacts table (if applicable)',
	INDUSTRY VARCHAR(100) COMMENT 'Industry of the customer',
	BUSINESS_LINE VARCHAR(10) COMMENT 'business line (AERO, IA, BA, ESS)',
	primary key (CUSTOMER_ID)
)COMMENT='Information about direct customers'
;

-- Distributor Inventory
create or replace TABLE DISTRIBUTOR_INVENTORY (
	DISTRIBUTOR_ID VARCHAR(36) NOT NULL COMMENT 'Foreign key referencing distributor',
	PRODUCT_ID VARCHAR(36) NOT NULL COMMENT 'Foreign key referencing product',
	QUANTITY_ON_HAND NUMBER(38,0) COMMENT 'Current quantity of the product on hand at the distributor',
	REORDER_POINT NUMBER(38,0) COMMENT 'Inventory level at which the distributor should reorder',
	SAFETY_STOCK_LEVEL NUMBER(38,0) COMMENT 'Minimum inventory level to maintain at the distributor',
	LAST_UPDATED_TIMESTAMP TIMESTAMP_NTZ(9) COMMENT 'Timestamp of the last inventory update'
)COMMENT='Inventory levels of finished goods at distributor locations'
;

-- Shipment (Added, as per previous recommendations)
create or replace TABLE SHIPMENT (
	SHIPMENT_ID VARCHAR(36) NOT NULL COMMENT 'Unique identifier for the shipment (UUID)',
	ORIGIN_FACILITY_ID VARCHAR(36) COMMENT 'Foreign key referencing the originating facility (CMF or FAT)',
	DESTINATION_FACILITY_ID VARCHAR(36) COMMENT 'Foreign key referencing the destination facility (FAT, Distributor, or Customer)',
	SHIP_DATE DATE COMMENT 'Date the shipment was shipped',
	EXPECTED_DELIVERY_DATE DATE COMMENT 'Expected delivery date of the shipment',
	ACTUAL_DELIVERY_DATE DATE COMMENT 'Actual delivery date of the shipment',
	SHIPPING_COST NUMBER(10,2) COMMENT 'Cost of shipping',
	TRACKING_NUMBER VARCHAR(50) COMMENT 'Tracking number for the shipment',
	primary key (SHIPMENT_ID)
)COMMENT='Information about shipments between facilities, distributors, and customers'
;

-- Orders (Added, as per previous recommendations)
create or replace TABLE ORDERS (
	ORDER_ID VARCHAR(36) NOT NULL COMMENT 'Unique identifier for the order (UUID)',
	CUSTOMER_ID VARCHAR(36) COMMENT 'Foreign key referencing the customer (if applicable)',
	DISTRIBUTOR_ID VARCHAR(36) COMMENT 'Foreign key referencing the distributor (if applicable)',
	ORDER_DATE TIMESTAMP_NTZ(9) COMMENT 'Date and time the order was placed',
	PRODUCT_ID VARCHAR(36) NOT NULL COMMENT 'Foreign key referencing the product',
	QUANTITY NUMBER(38,0) NOT NULL COMMENT 'Quantity of the product ordered',
	UNIT_PRICE NUMBER(10,2) NOT NULL COMMENT 'Price per unit at the time of order',
	TOTAL_PRICE NUMBER(10,2) NOT NULL COMMENT 'Total price of the order line',
	ORDER_STATUS VARCHAR(50) COMMENT 'Status of the order (e.g., Placed, Shipped, Delivered, Cancelled)',
	primary key (ORDER_ID)
)COMMENT='Information about customer and distributor orders'
;

create or replace TABLE RAW_MATERIAL (
	MATERIAL_ID VARCHAR(36) COMMENT 'Unique identifier for each raw material.',
	MATERIAL_NAME VARCHAR(16777216) COMMENT 'Names of raw materials used in the supply chain network.',
	MATERIAL_DESCRIPTION VARCHAR(16777216) COMMENT 'Detailed descriptions of raw materials.',
	MATERIAL_COST NUMBER(10,2) COMMENT 'The cost of the raw material from the supplier'
)COMMENT='The table contains records of various raw materials. Each record includes a unique identifier and a descriptive name and description for the material.'
;

create or replace TABLE TRANSPORT_COST_SURCHARGE (
	SOURCE_FACILITY_ID VARCHAR(36) NOT NULL COMMENT 'Unique identifier for the source CMF facility with excess inventory that will transfer raw materials',
	DESTINATION_FACILITY_ID VARCHAR(36) NOT NULL COMMENT 'Unique identifier for the destination CMF facility with low inventory that will receive raw materials',
	TRANSPORT_COST_SURCHARGE NUMBER(3,2) NOT NULL COMMENT 'Transport costs multiplier between these facilities depending on distance and difficulty of transport'
)COMMENT='The transport cost surcharge involved in moving raw materials from one Component Manufacturing Facility (CMF) to another.'
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