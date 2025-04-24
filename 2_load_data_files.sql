USE ROLE SCNO_ROLE;
USE WAREHOUSE SCNO_WH;
USE DATABASE SUPPLY_CHAIN_NETWORK_OPTIMIZATION_DB;
USE SCHEMA ENTITIES;

copy into COMPONENT from '@CSV_FILES/component.csv';
copy into PRODUCT from '@CSV_FILES/product.csv';
copy into MFG_PLANT from '@CSV_FILES/mfg_plant.csv';
copy into MFG_INVENTORY from '@CSV_FILES/mfg_inventory.csv';
copy into FAT_FACILITY from '@CSV_FILES/fat_facility.csv';
copy into FAT_INVENTORY from '@CSV_FILES/fat_inventory.csv';
copy into DISTRIBUTOR from '@CSV_FILES/distributor.csv';
copy into CUSTOMER from '@CSV_FILES/customer.csv';
copy into DISTRIBUTOR_INVENTORY from '@CSV_FILES/distributor_inventory.csv';
copy into SHIPMENT from '@CSV_FILES/shipment.csv';
copy into ORDERS from '@CSV_FILES/orders.csv';
copy into RAW_MATERIAL from '@CSV_FILES/raw_material.csv';
copy into TRANSPORT_COST_SURCHARGE from '@CSV_FILES/transport_cost_surcharge.csv';

--make sure orders are updated to recent order dates
update
    orders
set
    order_date = DATEADD(
        days,(
            select
                DATEDIFF(day, max(order_date), CURRENT_DATE())
            from
                orders
        ),
        order_date
    );