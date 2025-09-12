USE ROLE SCNO_ROLE;
USE WAREHOUSE SCNO_WH;
USE DATABASE SUPPLY_CHAIN_NETWORK_OPTIMIZATION_DB;
USE SCHEMA ENTITIES;

copy into SUPPLIERS from '@CSV_FILES/suppliers.csv';
copy into BILL_OF_MATERIALS from '@CSV_FILES/bill_of_materials.csv';
copy into COMPONENT from '@CSV_FILES/component.csv';
copy into PRODUCT from '@CSV_FILES/product.csv';
copy into MFG_PLANT from '@CSV_FILES/mfg_plant.csv';
copy into MFG_INVENTORY from '@CSV_FILES/mfg_inventory.csv';
copy into CUSTOMER from '@CSV_FILES/customer.csv';
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

--update shipment dates to be recent and maintain logical order (ship_date < expected < actual)
update
    shipment
set
    ship_date = DATEADD(
        days,(
            select
                DATEDIFF(day, max(ship_date), CURRENT_DATE())
            from
                shipment
        ),
        ship_date
    ),
    expected_delivery_date = DATEADD(
        days,(
            select
                DATEDIFF(day, max(expected_delivery_date), CURRENT_DATE())
            from
                shipment
        ),
        expected_delivery_date
    ),
    actual_delivery_date = DATEADD(
        days,(
            select
                DATEDIFF(day, max(actual_delivery_date), CURRENT_DATE())
            from
                shipment
        ),
        actual_delivery_date
    );

--update inventory timestamps to be recent
update
    mfg_inventory
set
    last_updated_timestamp = DATEADD(
        days,(
            select
                DATEDIFF(day, max(last_updated_timestamp), CURRENT_TIMESTAMP())
            from
                mfg_inventory
        ),
        last_updated_timestamp
    );

--update bill of materials effective dates to be recent
update
    bill_of_materials
set
    effective_date = DATEADD(
        days,(
            select
                DATEDIFF(day, max(effective_date), CURRENT_DATE())
            from
                bill_of_materials
        ),
        effective_date
    );