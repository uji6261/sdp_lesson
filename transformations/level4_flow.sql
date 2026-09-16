-- 統合テーブル(箱)を定義
CREATE STREAMING TABLE all_orders (
    CONSTRAINT valid_amount EXPECT (amount > 0) ON VIOLATION DROP ROW
);


-- オンライン注文用フロー
CREATE FLOW online_orders AS
INSERT INTO all_orders BY NAME
SELECT *
FROM STREAM read_files(
    '/Volumes/workspace/sdp_schema/orders_volume/current/',
    format => 'csv',
    header => 'true',
    schema => 'order_id INT, customer_id STRING, amount INT, order_date DATE, channel STRING'
)
WHERE channel = 'online';


-- 実店舗注文用フロー
CREATE FLOW store_orders AS
INSERT INTO all_orders BY NAME
SELECT *
FROM STREAM read_files(
    '/Volumes/workspace/sdp_schema/orders_volume/current/',
    format => 'csv',
    header => 'true',
    schema => 'order_id INT, customer_id STRING, amount INT, order_date DATE, channel STRING'
)
WHERE channel = 'store';


-- 2023年データのバックフィル(1回だけ実行)
CREATE FLOW backfill_2023 AS
INSERT INTO ONCE all_orders BY NAME
SELECT *
FROM read_files(
    '/Volumes/workspace/sdp_schema/orders_volume/archive/historical_2023.csv',
    format => 'csv',
    header => 'true',
    schema => 'order_id INT, customer_id STRING, amount INT, order_date DATE, channel STRING'
);

