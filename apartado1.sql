CREATE OR REPLACE TABLE keepcoding.ivr_detail AS
SELECT 
calls.ivr_id AS calls_ivr_id 
,calls.phone_number AS calls_phone_number 
,calls.ivr_result AS calls_ivr_result 
,calls.vdn_label AS calls_vdn_label 
,calls.start_date AS calls_start_date 
,FORMAT_DATE('%Y%m%d', calls.start_date) AS calls_start_date_id 
,calls.end_date AS calls_end_date 
,FORMAT_DATE('%Y%m%d', calls.end_date) AS calls_end_date_id 
,calls.total_duration  AS calls_total_duration 
,calls.customer_segment AS calls_customer_segment 
,calls.ivr_language AS calls_ivr_language 
,calls.steps_module AS calls_steps_module 
,calls.module_aggregation AS calls_module_aggregation 
,modules.module_sequece  AS module_sequece 
,modules.module_name AS module_name 
,modules.module_duration AS module_duration 
,modules.module_result AS module_result 
,steps.step_sequence AS step_sequence 
,steps.step_name AS step_name 
,steps.step_result AS step_result 
,steps.step_description_error AS step_description_error 
,steps.document_type AS document_type 
,steps.document_identification AS document_identification
,steps.customer_phone  AS customer_phone 
,steps.billing_account_id AS billing_account_id
 
FROM keepcoding.steps steps
  LEFT JOIN keepcoding.modules modules
    ON steps.module_sequece = modules.module_sequece AND steps.ivr_id = modules.ivr_id
  LEFT JOIN keepcoding.calls calls
    ON modules.ivr_id = calls.ivr_id