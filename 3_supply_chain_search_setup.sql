USE SUPPLY_CHAIN_NETWORK_OPTIMIZATION_DB.ENTITIES;
USE WAREHOUSE scno_wh;
USE ROLE SCNO_ROLE;

create or replace table parse_pdfs as 
select relative_path, SNOWFLAKE.CORTEX.PARSE_DOCUMENT(@SUPPLY_CHAIN_NETWORK_OPTIMIZATION_DB.ENTITIES.SCN_PDF,relative_path,{'mode':'LAYOUT'}) as data
    from directory(@SUPPLY_CHAIN_NETWORK_OPTIMIZATION_DB.ENTITIES.SCN_PDF);

create or replace table parsed_pdfs as (
    with tmp_parsed as (select
        relative_path,
        SNOWFLAKE.CORTEX.SPLIT_TEXT_RECURSIVE_CHARACTER(TO_VARIANT(data):content, 'MARKDOWN', 1800, 300) AS chunks
    from parse_pdfs where TO_VARIANT(data):content is not null)
    select
        TO_VARCHAR(c.value) as PAGE_CONTENT,
        REGEXP_REPLACE(relative_path, '\\.pdf$', '') as TITLE,
        'SUPPLY_CHAIN_NETWORK_OPTIMIZATION_DB.ENTITIES.SCN_PDF' as INPUT_STAGE,
        RELATIVE_PATH as RELATIVE_PATH
    from tmp_parsed p, lateral FLATTEN(INPUT => p.chunks) c
);

create or replace CORTEX SEARCH SERVICE SUPPLY_CHAIN_NETWORK_OPTIMIZATION_DB.ENTITIES.SUPPLY_CHAIN_INFO
ON PAGE_CONTENT
WAREHOUSE = SCNO_WH
TARGET_LAG = '1 hour'
AS (
    SELECT '' AS PAGE_URL, PAGE_CONTENT, TITLE, RELATIVE_PATH
    FROM parsed_pdfs
);