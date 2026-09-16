-- Bronze層: サンプルデータをそのまま取り込む
CREATE MATERIALIZED VIEW bronze_orders AS
SELECT * FROM samples.tpch.orders;


-- Silver層: 完了した注文のみをフィルタリング
CREATE MATERIALIZED VIEW silver_completed_orders AS
SELECT 
    o_orderkey,
    o_custkey,
    o_totalprice,
    o_orderdate,
    o_orderpriority
FROM bronze_orders
WHERE o_orderstatus = 'F';  -- 'F' = Fulfilled(完了)


-- Gold層: 日別の売上集計
CREATE MATERIALIZED VIEW gold_daily_sales AS
SELECT 
    o_orderdate AS order_date,
    COUNT(*) AS order_count,
    SUM(o_totalprice) AS total_sales,
    AVG(o_totalprice) AS avg_order_value
FROM silver_completed_orders
GROUP BY o_orderdate;

-- Gold層: 優先度別の注文集計
CREATE MATERIALIZED VIEW gold_priority_summary AS
SELECT 
    o_orderpriority AS priority,
    COUNT(*) AS order_count,
    SUM(o_totalprice) AS total_sales
FROM silver_completed_orders
GROUP BY o_orderpriority;


