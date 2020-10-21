view: addon_last_event {
  derived_table: {
    sql: WITH boxy_addon AS (

        select
            SO.CUSTOMER_EMAIL,
            dw_f_order.order_id,
            INCREMENT_ID,
            dw_f_order.ITEM_ID as ORDER_LINE_ITEM_ID,
            SO.BASE_SHIPPING_AMOUNT,
            dw_f_order.SKU as Item_Sku,
            dw_d_item.BRAND AS Item_Brand,
            dw_f_order.name AS Item_Name,
            dw_d_item.CATEGORY AS Item_Category,
            dw_d_item.SUB_CATEGORY AS Item_Sub_Category,
            dw_f_order.PRICE AS Total_Gross_Sales,
            (dw_f_order.QTY_ORDERED - dw_f_order.QTY_REFUNDED)AS Total_Quantity,
            dw_f_order.DISCOUNT_AMOUNT,
            EO.EVENT_START_DATE,
            SO.CREATED_AT AS Order_create_timestamp,
            DATEDIFF('DAY',EVENT_START_DATE,SO.CREATED_AT::DATE) AS COMPARISON_DAY_OF_EVENT,
            ecommerce_flag AS ECOM_FLAG,
            GS.month_of_feature AS ECOM_DATE,
            BC_ORDER_TYPE,
            ECOM_EVENT,
            ECOMMERCE_EVENTS_TYPE,
            GS.MSRP,
            UPPER(SO.COUPON_CODE) AS COUPON_CODE,
            CASE WHEN COUPON_CODE IS NOT NULL THEN 'YES' ELSE 'NO' END AS USED_COUPON,
            min(SO.CREATED_AT) OVER ()

            FROM fivetran.fivetran_magento.sales_order_item AS dw_f_order    --ORDER_ID
            LEFT JOIN dwh.dw.d_item AS dw_d_item ON dw_f_order.SKU = dw_d_item.ITEM_SKU
            LEFT JOIN fivetran.fivetran_magento.sales_order SO ON dw_f_order.ORDER_ID = SO.ENTITY_ID
            LEFT JOIN FIVETRAN.GSHEETS.ECOMMERCE_INVENTORY GS ON dw_f_order.SKU = GS.SKU
                            AND DATE_TRUNC('MONTH',GS.month_of_feature) = DATE_TRUNC('MONTH',SO.CREATED_AT)
            LEFT JOIN (SELECT ORDER_ID,
                              EE.EVENT_NAME,
                               DATE_TRUNC('MONTH', EVENT_START_DATE) AS EVENT_MONTH,
                               EVENT_START_DATE,
                               CASE WHEN EVENT_GROUP = 'add_on' THEN 'add_on'
                               WHEN EVENT_GROUP = 'boxypopup' THEN 'pop_up' END AS ECOM_EVENT,
                               CONCAT(UPPER(ECOM_EVENT),' : ',EVENT_MONTH) AS ECOMMERCE_EVENTS_TYPE
                        FROM BI_STAGING.BI_DATA.ECOM_EVENT_ORDERS AS EEO
                        LEFT JOIN BI_STAGING.BI_DATA.ECOMMERCE_EVENTS AS EE
                              ON EEO.EVENT_NAME = EE.EVENT_NAME
                        ) AS EO ON dw_f_order.ORDER_ID = EO.ORDER_ID
            WHERE dw_f_order.product_id NOT IN (646,645,644,643,836,1715)  AND Total_Quantity > 0
                AND dw_f_order.PRICE > 0
                AND dw_f_order.PARENT_ITEM_ID is null
  )
  ,
  item_type AS
  (
       SELECT *
          FROM
          (SELECT BRAND AS Item_Brand
          ,SKU_NUMBER AS Item_Sku
          , FAMILY AS Item_Category
          , SUB_FAMILY_SKU_
          , SUB_FAMILY_NEW_ AS Item_Sub_Category
          , DESCRIPTION
          ,ROW_NUMBER () OVER (PARTITION BY SKU_NUMBER ORDER BY SKU_NUMBER) AS rownum
      FROM FIVETRAN.GSHEETS.GS_PURCHASE_ORDERS po
      WHERE EXISTS (SELECT 1 FROM boxy_addon bp WHERE UPPER(po.SKU_NUMBER)=UPPER(bp.Item_Sku) )) a
      WHERE a.rownum =1
 )
 , prep_data AS (

            SELECT
            ORD1.CUSTOMER_EMAIL,
            ORD1.INCREMENT_ID,
            ORD1.Order_Id,
            BC_ORDER_TYPE,
            ORD1.ECOM_DATE,
            --ECOM_FLAG,
            --ECOM_EVENT,
            COALESCE(ECOM_FLAG, ECOM_EVENT) ECOMMERCE_FLAG,
            CONCAT(UPPER(ECOM_FLAG),' : ',ECOM_DATE) AS FLAG_MONTH,
            COALESCE(ECOMMERCE_EVENTS_TYPE,FLAG_MONTH) ECOMMERCE_FLAG_MONTH,
            COUPON_CODE,
            USED_COUPON,
            ORD1.ITEM_SKU,
            ORD1.MSRP,
            CASE WHEN ORD1.ITEM_SKU = 'SF-ACE-EY2SH02-E08' THEN 'Ace Beaute Huckleberry & French Vanilla Glimmer Eyeshadow Duo'
              ELSE ORD1.ITEM_NAME END AS ITEM_NAME,
            coalesce(i.Item_Brand,ord1.Item_Brand) as Item_Brand,
            coalesce(i.Item_Category,ord1.Item_Category) as Item_Category,
            coalesce(i.Item_Sub_Category,ord1.Item_Sub_Category) as Item_Sub_Category,
            ORD1.Order_create_timestamp,
            DATE_TRUNC('MONTH', ORDER_CREATE_TIMESTAMP)::DATE AS ORDER_MONTH,
            CASE WHEN ECOMMERCE_FLAG_MONTH = 'ADD_ON : 2020-07-01' THEN ORDER_CREATE_TIMESTAMP::DATE >= '2020-07-15' ELSE 'TRUE' END AS EDIT_START_DATE,
            DENSE_RANK() OVER (PARTITION BY ECOMMERCE_FLAG_MONTH ORDER BY ORDER_CREATE_TIMESTAMP::DATE) AS RANKING,
            DENSE_RANK() OVER (ORDER BY ORDER_MONTH DESC) AS CURRENT_V_PRIOR,
            MIN(ORDER_CREATE_TIMESTAMP) OVER (PARTITION BY ECOMMERCE_FLAG_MONTH) AS START_TIME,
            DATEDIFF('MINUTE', START_TIME, ORDER_CREATE_TIMESTAMP) AS TIME_DIFF,
           -- MIN(INV.COST) AS COST,
           -- MIN(INV.INVENTORY) AS INVENTORY,
           -- min(INV.CATEGORY_INVENTORY) AS CATEGORY_INVENTORY,
           -- min(INV.SUB_CATEGORY_INVENTORY) AS SUB_CATEGORY_INVENTORY,
            SUM(Total_Quantity) AS QTY,
            SUM(Total_Gross_Sales) AS GROSS_SALES,
            ifnull(SUM(ORD1.DISCOUNT_AMOUNT),0) AS DISCOUNT_AMOUNT
            FROM boxy_addon as ORD1
            LEFT JOIN item_type i
            ON ORD1.ITEM_SKU=i.ITEM_SKU
            WHERE ECOMMERCE_FLAG = 'add_on'
            GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19
   )--, TOTAL AS (
   SELECT * FROM (
   SELECT *, MAX(CASE WHEN DATE_TRUNC('MONTH',ORDER_CREATE_TIMESTAMP)::DATE = DATE_TRUNC('MONTH',CURRENT_DATE)
              THEN DATEDIFF('MINUTE', START_TIME, ORDER_CREATE_TIMESTAMP) END) OVER() AS MAX_CURRENT_MONTH
   FROM PREP_DATA
   WHERE CURRENT_V_PRIOR IN (1,2) AND ECOMMERCE_FLAG = 'add_on'
   GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26
   ORDER BY ORDER_CREATE_TIMESTAMP DESC
     )
     WHERE TIME_DIFF <= MAX_CURRENT_MONTH
 ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension_group: order_date {
    type: time
    sql: ${TABLE}."ORDER_DATE" ;;
  }

  dimension: ranking {
    type: number
    sql: ${TABLE}."RANKING" ;;
  }

  dimension: current_v_prior {
    type: number
    sql: ${TABLE}."ECOMMERCE_FLAG_MONTH" ;;
  }

  measure: event_month {
    type: date
    sql: ${TABLE}."EVENT_MONTH" ;;
  }

  dimension: edit_start_date {
    type: string
    sql: ${TABLE}."EDIT_START_DATE" ;;
  }

  dimension: order_day {
    type: date
    sql: ${TABLE}."ORDER_DAY" ;;
  }

  dimension: price {
    type: number
    sql: ${TABLE}."PRICE" ;;
  }

  measure: qty {
    type: sum
    sql: ${TABLE}."QTY" ;;
  }

  measure: revenue {
    label: "Gross Sales"
    type: sum
    sql: ${price}*${qty} ;;
    value_format_name: "usd_0"
  }


  set: detail {
    fields: [
      event_month,
      edit_start_date,
      order_day,
      ranking,
      current_v_prior
    ]
  }
}
