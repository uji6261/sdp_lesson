-- Silver層: ビジネスルールに基づくデータクレンジング
CREATE MATERIALIZED VIEW silver_orders_cleaned (
    -- 1995年以降の注文のみ対象
    CONSTRAINT recent_order EXPECT (o_orderdate >= '1995-01-01') ON VIOLATION DROP ROW,
    -- 一定額以上の注文のみ対象
    CONSTRAINT minimum_order_value EXPECT (o_totalprice >= 1000) ON VIOLATION DROP ROW,
    -- 優先度が設定されていること
    CONSTRAINT has_priority EXPECT (o_orderpriority IS NOT NULL) ON VIOLATION DROP ROW
) AS
SELECT 
    o_orderkey,
    o_custkey,
    o_totalprice,
    o_orderdate,
    o_orderpriority
FROM bronze_orders;


-- silverに複合的なデータ品質チェック
CREATE MATERIALIZED VIEW silver_orders_validated (
    -- 警告のみ: 監視用(1993年より前の古い注文を検出)
    CONSTRAINT warn_old_order EXPECT (o_orderdate >= '1993-01-01'),
    
    -- 違反行を除外: ビジネスルール
    CONSTRAINT drop_low_value EXPECT (o_totalprice >= 5000) ON VIOLATION DROP ROW,
    
    -- 失敗: 絶対に許容できない問題
    CONSTRAINT fail_invalid_status EXPECT (o_orderstatus IN ('F', 'O', 'P')) ON VIOLATION FAIL UPDATE
) AS
SELECT * FROM bronze_orders;


-- Gold層: 日別売上集計(品質チェック付き)
CREATE MATERIALIZED VIEW gold_daily_sales_validated (
    -- 売上がマイナスになっていないか確認
    CONSTRAINT valid_total EXPECT (total_sales >= 0),
    -- 注文数が0以上か確認
    CONSTRAINT valid_count EXPECT (order_count > 0) ON VIOLATION DROP ROW
) AS
SELECT 
    o_orderdate AS order_date,
    COUNT(*) AS order_count,
    SUM(o_totalprice) AS total_sales,
    AVG(o_totalprice) AS avg_order_value
FROM silver_orders_cleaned
GROUP BY o_orderdate
ORDER BY o_orderdate;


