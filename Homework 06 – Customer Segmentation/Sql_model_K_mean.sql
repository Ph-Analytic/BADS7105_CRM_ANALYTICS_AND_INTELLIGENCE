SELECT * FROM `psyched-cab-273503.sp_dataset.sp_table` LIMIT 1000

CREATE OR REPLACE MODEL`sp_dataset.customer` 

OPTIONS(model_type='kmeans',num_clusters=5, kmeans_init_method='kmeans++',max_iterations=50)

AS(

    SELECT 

    COUNT(DISTINCT BASKET_ID)/COUNT(DISTINCT SHOP_WEEK) AS AVG_WEEKLY_VISIT,

    SUM(SPEND)/COUNT(DISTINCT BASKET_ID) AS TICKET_SIZE,

    FROM `psyched-cab-273503.sp_dataset.sp_table`

    WHERE CUST_CODE IS NOT NULL 

    GROUP BY CUST_CODE
