CREATE OR REPLACE TABLE keepcoding.ivr_summary AS

WITH apartado2a   
  AS (SELECT ivr_detail.calls_ivr_id AS ivr_id
      ,ivr_detail.calls_phone_number AS phone_number
      ,ivr_detail.calls_ivr_result AS ivr_result
      ,CASE WHEN STARTS_WITH(ivr_detail.calls_vdn_label,'ATC') THEN 'FRONT'
            WHEN STARTS_WITH(ivr_detail.calls_vdn_label,'TECH') THEN 'TECH'
            WHEN STARTS_WITH(ivr_detail.calls_vdn_label,'ABSORPTION') THEN 'ABSORPTION'
            ELSE 'RESTO'
        END AS vdn_aggregation
      ,ivr_detail.calls_start_date AS start_date
      ,ivr_detail.calls_end_date AS end_date
      ,ivr_detail.calls_total_duration AS total_duration
      ,ivr_detail.calls_customer_segment AS customer_segment
      ,ivr_detail.calls_ivr_language AS ivr_language
      ,ivr_detail.calls_steps_module AS steps_module
      ,ivr_detail.calls_module_aggregation AS module_aggregation
      ,IFNULL(STRING_AGG(NULLIF(ivr_detail.document_type, 'NULL')
                  , '; ' LIMIT 1),'NULL') AS document_type
      ,IFNULL(STRING_AGG(NULLIF(ivr_detail.document_identification,'NULL')
                  , '; ' LIMIT 1),'NULL') AS document_identification
      ,IFNULL(STRING_AGG(NULLIF(ivr_detail.customer_phone,'NULL')
                  , '; ' LIMIT 1),'NULL') AS customer_phone
      ,IFNULL(STRING_AGG(NULLIF(ivr_detail.billing_account_id,'NULL')
                  , '; ' LIMIT 1),'NULL') AS billing_account_id
      ,MAX(IF(ivr_detail.module_name = 'AVERIA_MASIVA',1,0)) AS masiva_lg
      ,MAX(IF(ivr_detail.step_name = 'CUSTOMERINFOBYPHONE.TX' and ivr_detail.step_description_error = 'NULL',1,0)) AS info_by_phone_lg
      ,MAX(IF(ivr_detail.step_name = 'CUSTOMERINFOBYDNI.TX' and ivr_detail.step_description_error = 'NULL',1,0)) AS info_by_dni_lg

      FROM keepcoding.ivr_detail ivr_detail 
      group by ivr_id, phone_number,ivr_result,vdn_aggregation,start_date,end_date,total_duration,customer_segment,ivr_language,steps_module,module_aggregation)
  ,fechas_comienzo
  AS (SELECT apartado2a.phone_number AS phone_number
      ,apartado2a.start_date AS start_date
      FROM apartado2a)
  ,rellamadas
  AS (SELECT apartado2a.ivr_id as ivr_id
        ,MAX(IF(DATETIME_DIFF(apartado2a.start_date, fechas_comienzo.start_date, SECOND)> 0 and DATETIME_DIFF(apartado2a.start_date, fechas_comienzo.start_date, SECOND)<=86400,1,0)) as repeated_phone_24H
        ,MAX(IF(DATETIME_DIFF(apartado2a.start_date, fechas_comienzo.start_date, SECOND)< 0 and DATETIME_DIFF(apartado2a.start_date, fechas_comienzo.start_date, SECOND)>=-86400,1,0)) as cause_recall_phone_24H
      from apartado2a
      JOIN fechas_comienzo
      ON apartado2a.phone_number = fechas_comienzo.phone_number
      group by ivr_id)

SELECT apartado2a.*,rellamadas.repeated_phone_24H,rellamadas.cause_recall_phone_24H
FROM apartado2a
LEFT JOIN rellamadas
ON apartado2a.ivr_id = rellamadas.ivr_id