-- Databricks notebook source
-- ボリュームを作成(カタログ・スキーマは適宜変更)
use catalog workspace;
use schema sdp_schema;

CREATE VOLUME IF NOT EXISTS demo_volume;

-- COMMAND ----------

-- MAGIC %python
-- MAGIC data_batch1 = """order_id,customer_id,amount,order_date
-- MAGIC 1,101,15000,2024-01-15
-- MAGIC 2,102,8500,2024-01-16
-- MAGIC 3,103,22000,2024-01-17
-- MAGIC """
-- MAGIC
-- MAGIC # ボリュームのパスは適宜変更してください
-- MAGIC dbutils.fs.put("/Volumes/workspace/sdp_schema/demo_volume/orders_batch1.csv", data_batch1, overwrite=True)
-- MAGIC
-- MAGIC print("batch1を作成しました(3件)")
-- MAGIC

-- COMMAND ----------

-- MAGIC %python
-- MAGIC data_batch2 = """order_id,customer_id,amount,order_date
-- MAGIC 4,104,5000,2024-01-18
-- MAGIC 5,105,18000,2024-01-19
-- MAGIC """
-- MAGIC
-- MAGIC dbutils.fs.put("/Volumes/workspace/sdp_schema/demo_volume/orders_batch2.csv", data_batch2, overwrite=True)
-- MAGIC
-- MAGIC print("batch2を作成しました(2件)")
-- MAGIC

-- COMMAND ----------

select * from workspace.sdp_schema.bronze_orders_st;