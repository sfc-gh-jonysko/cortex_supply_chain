USE ROLE SCNO_ROLE;
USE WAREHOUSE SCNO_WH;
USE DATABASE SUPPLY_CHAIN_NETWORK_OPTIMIZATION_DB;

-- Create weather schema if it doesn't exist
CREATE SCHEMA IF NOT EXISTS WEATHER COMMENT='Weather data for supply chain locations';
USE SCHEMA WEATHER;

-- Create the weather forecast table based on the semantic model structure
CREATE OR REPLACE TABLE CITY_DAILY_IMPERIAL (
    COUNTRY_CODE VARCHAR(2) COMMENT 'The country code',
    ADMIN_CODE VARCHAR(10) COMMENT 'Administrative code',
    CITY_NAME VARCHAR(100) COMMENT 'The name of the city or city district',
    LATITUDE NUMBER(7,5) COMMENT 'The latitude of a city or location',
    LONGITUDE NUMBER(8,5) COMMENT 'The longitude of a city',
    DATE DATE COMMENT 'The date of the weather forecast',
    DAY_FLAG VARCHAR(1) COMMENT 'Flag indicating the forecast is for Day or Night',
    PHRASE_SHORT VARCHAR(30) COMMENT 'Weather forecast summary in a brief phrase',
    PHRASE_LONG VARCHAR(250) COMMENT 'Weather forecast description',
    WEATHER_ICON NUMBER(38,0) COMMENT 'The type of weather icon used to represent the forecast',
    ALLERGY_GRASS_24HR_MAX NUMBER(38,0) COMMENT 'The maximum 24-hour allergy level for grass in the area',
    ALLERGY_MOLD_24HR_MAX NUMBER(38,0) COMMENT 'The maximum amount of mold or fungi spores in the air over a 24-hour period',
    ALLERGY_RAGWEED_24HR_MAX NUMBER(38,0) COMMENT 'The maximum 24-hour allergy level for ragweed in the area',
    ALLERGY_TREE_24HR_MAX NUMBER(38,0) COMMENT 'The maximum 24-hour allergy tree pollen count',
    CLOUD_COVER_AVG NUMBER(38,0) COMMENT 'The average percentage of cloud cover in the sky',
    EVAPOTRANSPIRATION_LWE_TOTAL NUMBER(5,2) COMMENT 'Evapotranspiration loss due to total water evaporation',
    MINUTES_OF_ICE_TOTAL NUMBER(6,0) COMMENT 'Minutes of ice total',
    MINUTES_OF_PRECIPITATION_TOTAL NUMBER(6,0) COMMENT 'The total minutes of precipitation total',
    MINUTES_OF_RAIN_TOTAL NUMBER(6,0) COMMENT 'The total minutes of rain in a given day',
    MINUTES_OF_SNOW_TOTAL NUMBER(6,0) COMMENT 'The total minutes of snowfall',
    MINUTES_OF_SUN_24HR_TOTAL NUMBER(7,0) COMMENT 'The total number of minutes of sunshine in a 24-hour period',
    ICE_PROBABILITY NUMBER(38,0) COMMENT 'The probability of ice formation',
    ICE_LWE_TOTAL NUMBER(8,5) COMMENT 'The total amount of ice accumulation in inches',
    INDEX_AIR_QUALITY_24HR_MAX NUMBER(38,0) COMMENT 'The 24-hour maximum air quality index',
    INDEX_UV_24HR_MAX NUMBER(38,0) COMMENT 'The maximum amount of ultraviolet radiation in a 24-hour period',
    HAS_PRECIPITATION BOOLEAN COMMENT 'Whether precipitation is expected',
    PRECIPITATION_INTENSITY_MAX VARCHAR(50) COMMENT 'The maximum intensity of precipitation',
    PRECIPITATION_LWE_TOTAL NUMBER(8,5) COMMENT 'Precipitation in liquid units, measured in inches',
    PRECIPITATION_PROBABILITY NUMBER(38,0) COMMENT 'The probability of precipitation',
    PRECIPITATION_TYPE_DESC_PREDOMINANT VARCHAR(50) COMMENT 'The predominant type of precipitation',
    RAIN_PROBABILITY NUMBER(38,0) COMMENT 'The probability of rain',
    RAIN_LWE_TOTAL NUMBER(8,5) COMMENT 'The total amount of rainfall in inches',
    SNOW_PROBABILITY NUMBER(38,0) COMMENT 'The probability of snowfall in percentage',
    SNOW_TOTAL NUMBER(8,5) COMMENT 'The total amount of snowfall in inches',
    SOLAR_IRRADIANCE_TOTAL NUMBER(7,2) COMMENT 'The total amount of solar radiation received by the location',
    TEMPERATURE_AVG NUMBER(5,2) COMMENT 'The average temperature in degrees Fahrenheit',
    TEMPERATURE_MAX NUMBER(5,2) COMMENT 'The maximum temperature in degrees Fahrenheit',
    TEMPERATURE_MIN NUMBER(5,2) COMMENT 'The minimum temperature in degrees Fahrenheit',
    TEMPERATURE_REALFEEL_AVG NUMBER(5,2) COMMENT 'The average real-feel temperature in degrees Fahrenheit',
    TEMPERATURE_REALFEEL_MAX NUMBER(5,2) COMMENT 'The maximum real-feel temperature in degrees Fahrenheit',
    TEMPERATURE_REALFEEL_MIN NUMBER(5,2) COMMENT 'The minimum real-feel temperature in degrees Fahrenheit',
    TEMPERATURE_REALFEEL_SHADE_AVG NUMBER(5,2) COMMENT 'The average real-feel temperature in degrees in degrees Fahrenheit',
    TEMPERATURE_REALFEEL_SHADE_MAX NUMBER(5,2) COMMENT 'The maximum real-feel temperature in degrees Fahrenheit',
    TEMPERATURE_REALFEEL_SHADE_MIN NUMBER(5,2) COMMENT 'The minimum real-feel temperature in the shade in degrees Fahrenheit',
    THUNDERSTORM_PROBABILITY NUMBER(38,0) COMMENT 'The probability of thunderstorms',
    WIND_DIRECTION_AVG NUMBER(38,0) COMMENT 'The average direction of the wind',
    WIND_GUST_MAX NUMBER(38,0) COMMENT 'The maximum wind gust speed in MPH',
    WIND_GUST_DIRECTION_AVG NUMBER(38,0) COMMENT 'Wind gust direction averages',
    WIND_SPEED_AVG NUMBER(38,0) COMMENT 'The average wind speed in MPH'
) COMMENT='Weather forecast data for supply chain cities in imperial units - 2 weeks of daily/nightly forecasts';

-- Create file format for weather CSV if it doesn't exist
CREATE OR REPLACE FILE FORMAT WEATHER_CSV_FORMAT
    TYPE = 'CSV'
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    NULL_IF = ('', 'NULL', 'null')
    EMPTY_FIELD_AS_NULL = TRUE
    COMMENT = 'File format for weather CSV files';

-- Create stage for weather files if it doesn't exist
CREATE OR REPLACE STAGE WEATHER_FILES 
    FILE_FORMAT = WEATHER_CSV_FORMAT
    ENCRYPTION = (TYPE = 'SNOWFLAKE_SSE') 
    DIRECTORY = (ENABLE = TRUE)
    COMMENT = 'Stage for weather data files';

-- Load the extended weather data (2 weeks of forecasts)
COPY INTO CITY_DAILY_IMPERIAL 
FROM '@WEATHER_FILES/supply_chain_weather_extended.csv'
FILE_FORMAT = WEATHER_CSV_FORMAT
ON_ERROR = 'ABORT_STATEMENT';

-- Verify the data was loaded
SELECT 
    COUNT(*) as total_records,
    COUNT(DISTINCT CITY_NAME) as unique_cities,
    COUNT(DISTINCT DATE) as unique_dates,
    MIN(DATE) as earliest_date,
    MAX(DATE) as latest_date,
    COUNT(CASE WHEN DAY_FLAG = 'D' THEN 1 END) as day_records,
    COUNT(CASE WHEN DAY_FLAG = 'N' THEN 1 END) as night_records
FROM CITY_DAILY_IMPERIAL;

-- Show hurricane conditions summary
SELECT 
    'Hurricane Impact Summary' as report_type,
    COUNT(DISTINCT CITY_NAME) as affected_cities,
    COUNT(*) as hurricane_records,
    MIN(DATE) as first_hurricane_date,
    MAX(DATE) as last_hurricane_date
FROM CITY_DAILY_IMPERIAL 
WHERE PHRASE_SHORT LIKE '%hurricane%' OR PHRASE_SHORT LIKE '%Hurricane%';

-- Show sample of hurricane conditions
SELECT 
    CITY_NAME,
    DATE,
    DAY_FLAG,
    PHRASE_SHORT,
    PHRASE_LONG,
    TEMPERATURE_AVG,
    PRECIPITATION_LWE_TOTAL,
    WIND_SPEED_AVG,
    WIND_GUST_MAX,
    THUNDERSTORM_PROBABILITY
FROM CITY_DAILY_IMPERIAL 
WHERE PHRASE_SHORT LIKE '%hurricane%' OR PHRASE_SHORT LIKE '%Hurricane%'
ORDER BY DATE, CITY_NAME, DAY_FLAG
LIMIT 20;

-- Show weather forecast for all supply chain cities
SELECT 
    CITY_NAME,
    DATE,
    DAY_FLAG,
    PHRASE_SHORT,
    TEMPERATURE_AVG,
    TEMPERATURE_MAX,
    TEMPERATURE_MIN,
    HAS_PRECIPITATION,
    PRECIPITATION_PROBABILITY,
    WIND_SPEED_AVG,
    CASE 
        WHEN PHRASE_SHORT LIKE '%hurricane%' OR PHRASE_SHORT LIKE '%Hurricane%' THEN '🌀 HURRICANE'
        WHEN WIND_SPEED_AVG > 25 THEN '💨 HIGH WINDS'
        WHEN PRECIPITATION_PROBABILITY > 70 THEN '🌧️ HEAVY RAIN'
        WHEN TEMPERATURE_AVG > 90 THEN '🌡️ EXTREME HEAT'
        ELSE '✅ NORMAL'
    END as weather_alert
FROM CITY_DAILY_IMPERIAL 
WHERE DATE >= CURRENT_DATE() AND DATE <= CURRENT_DATE() + 7  -- Next 7 days
ORDER BY 
    CASE 
        WHEN PHRASE_SHORT LIKE '%hurricane%' OR PHRASE_SHORT LIKE '%Hurricane%' THEN 1
        WHEN WIND_SPEED_AVG > 25 THEN 2
        WHEN PRECIPITATION_PROBABILITY > 70 THEN 3
        ELSE 4
    END,
    DATE, CITY_NAME, DAY_FLAG
LIMIT 50;
