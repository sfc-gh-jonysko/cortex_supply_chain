USE ROLE SCNO_ROLE;
USE WAREHOUSE SCNO_WH;
USE DATABASE SUPPLY_CHAIN_NETWORK_OPTIMIZATION_DB;
USE SCHEMA WEATHER;

-- Update weather forecast dates to be recent and current
-- This script adjusts the weather data dates to reflect the current time period
-- similar to how the supply chain data dates are updated

UPDATE CITY_DAILY_IMPERIAL
SET DATE = DATEADD(
    days, (
        SELECT 
            DATEDIFF(day, MAX(DATE), CURRENT_DATE())
        FROM 
            CITY_DAILY_IMPERIAL
    ),
    DATE
);

-- Verify the update worked correctly
SELECT 
    'Weather Data Summary' as data_type,
    MIN(DATE) as earliest_date,
    MAX(DATE) as latest_date,
    COUNT(*) as total_records,
    COUNT(DISTINCT CITY_NAME) as unique_cities,
    COUNT(DISTINCT DATE) as unique_dates,
    COUNT(CASE WHEN DAY_FLAG = 'D' THEN 1 END) as day_forecasts,
    COUNT(CASE WHEN DAY_FLAG = 'N' THEN 1 END) as night_forecasts
FROM CITY_DAILY_IMPERIAL

UNION ALL

-- Compare with supply chain data dates for context
SELECT 
    'Supply Chain Orders' as data_type,
    MIN(ORDER_DATE::DATE) as earliest_date,
    MAX(ORDER_DATE::DATE) as latest_date,
    COUNT(*) as total_records,
    COUNT(DISTINCT CUSTOMER_ID) as unique_customers,
    COUNT(DISTINCT ORDER_DATE::DATE) as unique_dates,
    NULL as day_forecasts,
    NULL as night_forecasts
FROM SUPPLY_CHAIN_NETWORK_OPTIMIZATION_DB.ENTITIES.ORDERS

UNION ALL

SELECT 
    'Supply Chain Shipments' as data_type,
    MIN(SHIP_DATE) as earliest_date,
    MAX(SHIP_DATE) as latest_date,
    COUNT(*) as total_records,
    COUNT(DISTINCT ORIGIN_MFG_PLANT_ID) as unique_plants,
    COUNT(DISTINCT SHIP_DATE) as unique_dates,
    NULL as day_forecasts,
    NULL as night_forecasts
FROM SUPPLY_CHAIN_NETWORK_OPTIMIZATION_DB.ENTITIES.SHIPMENT

ORDER BY data_type;

-- Show hurricane impact timeline with updated dates
SELECT 
    '🌀 HURRICANE TIMELINE' as alert_type,
    DATE,
    COUNT(DISTINCT CITY_NAME) as affected_cities,
    AVG(WIND_SPEED_AVG) as avg_wind_speed,
    MAX(WIND_GUST_MAX) as max_wind_gust,
    AVG(PRECIPITATION_LWE_TOTAL) as avg_rainfall,
    MAX(PRECIPITATION_LWE_TOTAL) as max_rainfall
FROM CITY_DAILY_IMPERIAL 
WHERE PHRASE_SHORT LIKE '%hurricane%' OR PHRASE_SHORT LIKE '%Hurricane%'
AND DATE >= CURRENT_DATE() - 1  -- Show recent hurricane activity
GROUP BY DATE
ORDER BY DATE;

-- Show current weather alerts for supply chain operations
SELECT 
    CITY_NAME,
    DATE,
    DAY_FLAG,
    PHRASE_SHORT,
    TEMPERATURE_AVG,
    PRECIPITATION_LWE_TOTAL,
    WIND_SPEED_AVG,
    WIND_GUST_MAX,
    CASE 
        WHEN PHRASE_SHORT LIKE '%hurricane%' OR PHRASE_SHORT LIKE '%Hurricane%' THEN '🌀 HURRICANE - CRITICAL SUPPLY CHAIN RISK'
        WHEN WIND_SPEED_AVG > 35 THEN '💨 DANGEROUS WINDS - SHIPMENT DELAYS LIKELY'
        WHEN PRECIPITATION_LWE_TOTAL > 0.5 THEN '🌧️ HEAVY RAIN - TRANSPORT DISRUPTION'
        WHEN WIND_SPEED_AVG > 25 THEN '💨 HIGH WINDS - MONITOR SHIPMENTS'
        WHEN PRECIPITATION_PROBABILITY > 70 THEN '🌧️ RAIN LIKELY - PLAN ACCORDINGLY'
        WHEN TEMPERATURE_AVG > 95 THEN '🌡️ EXTREME HEAT - MATERIAL RISK'
        ELSE '✅ NORMAL CONDITIONS'
    END as supply_chain_impact
FROM CITY_DAILY_IMPERIAL 
WHERE DATE >= CURRENT_DATE() AND DATE <= CURRENT_DATE() + 5  -- Next 5 days critical period
ORDER BY 
    CASE 
        WHEN PHRASE_SHORT LIKE '%hurricane%' OR PHRASE_SHORT LIKE '%Hurricane%' THEN 1
        WHEN WIND_SPEED_AVG > 35 THEN 2
        WHEN PRECIPITATION_LWE_TOTAL > 0.5 THEN 3
        WHEN WIND_SPEED_AVG > 25 THEN 4
        ELSE 5
    END,
    DATE, CITY_NAME, DAY_FLAG
LIMIT 50;

-- Supply chain locations at risk analysis
WITH at_risk_locations AS (
    SELECT 
        w.CITY_NAME,
        w.DATE,
        w.PHRASE_SHORT,
        w.WIND_SPEED_AVG,
        w.PRECIPITATION_LWE_TOTAL,
        CASE 
            WHEN w.PHRASE_SHORT LIKE '%hurricane%' OR w.PHRASE_SHORT LIKE '%Hurricane%' THEN 'HURRICANE'
            WHEN w.WIND_SPEED_AVG > 35 THEN 'DANGEROUS_WINDS'
            WHEN w.PRECIPITATION_LWE_TOTAL > 0.5 THEN 'HEAVY_RAIN'
            ELSE 'NORMAL'
        END as risk_level
    FROM CITY_DAILY_IMPERIAL w
    WHERE w.DATE BETWEEN CURRENT_DATE() AND CURRENT_DATE() + 7
    AND (w.PHRASE_SHORT LIKE '%hurricane%' OR w.PHRASE_SHORT LIKE '%Hurricane%' 
         OR w.WIND_SPEED_AVG > 25 OR w.PRECIPITATION_LWE_TOTAL > 0.3)
)
SELECT 
    '📊 SUPPLY CHAIN RISK SUMMARY' as report_title,
    risk_level,
    COUNT(DISTINCT CITY_NAME) as affected_cities,
    COUNT(*) as total_forecasts,
    MIN(DATE) as risk_start_date,
    MAX(DATE) as risk_end_date,
    LISTAGG(DISTINCT CITY_NAME, ', ') WITHIN GROUP (ORDER BY CITY_NAME) as cities_at_risk
FROM at_risk_locations
GROUP BY risk_level
ORDER BY 
    CASE risk_level 
        WHEN 'HURRICANE' THEN 1 
        WHEN 'DANGEROUS_WINDS' THEN 2 
        WHEN 'HEAVY_RAIN' THEN 3 
        ELSE 4 
    END;
