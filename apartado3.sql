CREATE OR REPLACE FUNCTION keepcoding.clean_integer (entero INT64) RETURNS INT64 
AS (IFNULL(entero,-999999));