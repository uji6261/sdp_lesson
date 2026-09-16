-- CDCソースを取り込むストリーミングテーブル
CREATE STREAMING TABLE customers_cdc_raw;

CREATE FLOW ingest_cdc AS
INSERT INTO customers_cdc_raw BY NAME
SELECT *
FROM STREAM read_files(
    '/Volumes/workspace/sdp_schema/cdc_volume/customers/',
    format => 'csv',
    header => 'true',
    schema => 'id INT, name STRING, email STRING, address STRING, operation STRING, event_time TIMESTAMP'
);


-- AUTO CDCでマスターテーブルに同期(SCD Type 1)
CREATE STREAMING TABLE customers;

CREATE FLOW sync_customers AS
AUTO CDC INTO customers
FROM STREAM customers_cdc_raw
KEYS (id)
APPLY AS DELETE WHEN operation = 'DELETE'
SEQUENCE BY event_time
COLUMNS * EXCEPT (operation, event_time);


-- AUTO CDCで履歴テーブルに同期(SCD Type 2)
CREATE STREAMING TABLE customers_history;

CREATE FLOW sync_customers_history AS
AUTO CDC INTO customers_history
FROM STREAM customers_cdc_raw
KEYS (id)
APPLY AS DELETE WHEN operation = 'DELETE'
SEQUENCE BY event_time
COLUMNS * EXCEPT (operation, event_time)
STORED AS SCD TYPE 2;
