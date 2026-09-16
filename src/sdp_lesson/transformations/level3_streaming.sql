-- Bronze層: ボリュームからCSVを増分取り込み
CREATE STREAMING TABLE bronze_orders_st;

CREATE FLOW ingest_orders AS
INSERT INTO bronze_orders_st BY NAME
SELECT 
    order_id::INT,
    customer_id::INT,
    amount::DOUBLE,
    order_date::DATE
FROM STREAM read_files(
    '/Volumes/workspace/sdp_schema/demo_volume/',
    format => 'csv',
    header => 'true'
);


-- Silver層: 高額注文のみをフィルタリング
CREATE STREAMING TABLE silver_high_value_orders_st;

CREATE FLOW filter_high_value AS
INSERT INTO silver_high_value_orders_st BY NAME
SELECT *
FROM STREAM bronze_orders_st  -- STREAMキーワードで増分読み取り
WHERE amount >= 10000;


-- Silver層: エクスペクテーション付きストリーミングテーブル
CREATE STREAMING TABLE silver_orders_validated_st (
    CONSTRAINT positive_amount EXPECT (amount > 0) ON VIOLATION DROP ROW,
    CONSTRAINT valid_date EXPECT (order_date >= '2024-01-01') ON VIOLATION DROP ROW
);

CREATE FLOW validate_orders AS
INSERT INTO silver_orders_validated_st BY NAME
SELECT *
FROM STREAM bronze_orders_st;


-- Gold層: 集計はマテリアライズドビュー
CREATE MATERIALIZED VIEW gold_daily_sales_mv AS
SELECT 
    order_date,
    COUNT(*) AS order_count,
    SUM(amount) AS total_sales
FROM silver_orders_validated_st  -- STREAMなし(バッチ読み取り)
GROUP BY order_date
ORDER BY order_date;
