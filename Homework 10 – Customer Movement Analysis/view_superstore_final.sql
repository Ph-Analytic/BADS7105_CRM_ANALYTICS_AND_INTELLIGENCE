WITH Tables_superstore AS (
    SELECT Distinct 
    CUST_CODE as Customer_code,
    PARSE_DATE('%Y%m%d',Cast(SHOP_DATE AS STRING )) as Transection_date
    FROM `psyched-cab-273503.spp_dataset.spp_table`
    where CUST_CODE is not null
    
)   

    SELECT 
        Year_Month,
        COUNT(DISTINCT CASE WHEN Customers_segment = 'New_customers' THEN Customer_code ELSE NULL END) AS NEW_CUSTOMERS,
        COUNT(DISTINCT CASE WHEN Customers_segment = 'Repeat' THEN Customer_code ELSE NULL END) AS REPEAT,
        COUNT(DISTINCT CASE WHEN Customers_segment = 'Reactivated' THEN Customer_code ELSE NULL END) AS REACTIVATED,
        -COUNT(DISTINCT CASE WHEN Customers_segment = 'Churn' THEN Customer_code ELSE NULL END) AS CHURN
    
    FROM (
        SELECT 
            Customer_code, 
            Transection_date as Year_Month,
            Date_Month
            ,CASE 
                WHEN DATE_DIFF(Transection_date, Date_Month, MONTH) IS NULL THEN 'New_customers'
                WHEN DATE_DIFF(Transection_date, Date_Month, MONTH) = 1 THEN 'Repeat'
                WHEN DATE_DIFF(Transection_date, Date_Month, MONTH) > 1 THEN 'Reactivated'
            ELSE NULL END AS Customers_segment
        
    FROM (
          SELECT 
            Customer_code,
            Transection_date, 
            LAG(Transection_date, 1) OVER (PARTITION BY Customer_code ORDER BY Transection_date) AS Date_Month

    FROM Tables_superstore
        )
   
        UNION ALL
            SELECT 
                Customer_code, 
                DATE_ADD(Transection_date , INTERVAL 1 MONTH) as Year_Month, 
                Transection_date  as Date_Month,
                'Churn' AS Customers_segment
    FROM (
            SELECT 
                 Customer_code,
                 Transection_date,
                 LEAD(Transection_date, 1) OVER (PARTITION BY Customer_code ORDER BY Transection_date) AS next_trans_date,
                DATE_DIFF(LEAD(Transection_date, 1) OVER (PARTITION BY Customer_code ORDER BY Transection_date), Transection_date, MONTH) AS n_months
    FROM Tables_superstore
            ) 
    WHERE 
        (n_months > 1 or n_months is null) AND Transection_date < (SELECT MAX(Transection_date) FROM Tables_superstore)
        ) GROUP BY Year_Month
        order by Year_Month



