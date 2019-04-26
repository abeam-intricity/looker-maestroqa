view: boxyluxe_waitlist_new {
  derived_table: {
    sql: SELECT BS.*,UA.DATE AS BEGINNING_DATE, UA.NEXT_DATE, UA.NUMBER_BOXYLUXE_ORDERS
    , UA.BOXYLUXE_ORDER_CREATION, UA.BOXYLUXE_REBILL_CREATION, UA.BOXYLUXE_PAYMENT_FAILURE, UA.BOXYLUXE_WAITING_CANCELLED, UA.BOXYLUXE_WAITING_CANCELLED_TO_WAITING
    , UA.BASE_ORDER_CREATION, UA.BASE_REBILL_CREATION, UA.BASE_PAYMENT_FAILURE, UA.BASE_WAITING_CANCELLED, UA.BASE_WAITING_CANCELLED_TO_WAITING
    , CASE WHEN CALENDAR_DATE < SUBSCRIPTION_START_DATE THEN 'Prior to Subscription'
           WHEN CALENDAR_DATE >= CANCEL_DATE AND (CANCEL_DATE_REGULAR IS NULL OR CANCEL_DATE_REGULAR = CURRENT_DATE + INTERVAL'1 DAY') THEN 'Cancelled BoxyLuxe Only Subscription'
           WHEN CALENDAR_DATE >= CANCEL_DATE AND CALENDAR_DATE >= CANCEL_DATE_REGULAR AND CANCEL_DATE_REGULAR > CANCEL_DATE THEN 'Cancelled BoxyLuxe then Cancelled Regular'
           WHEN CALENDAR_DATE >= CANCEL_DATE AND CANCEL_DATE >= CANCEL_DATE_REGULAR AND CANCEL_DATE_REGULAR = CANCEL_DATE THEN 'Cancelled All Subscriptions'
           WHEN BOXYLUXE_PAYMENT_FAILURE = 1 OR BASE_PAYMENT_FAILURE = 1 THEN 'Involuntarily Cancelled due to Payment Failure'
           WHEN BOXYLUXE_WAITING_CANCELLED = 1 THEN 'Downgraded BoxyLuxe - Left Waitlist'
           WHEN BOXYLUXE_WAITING_CANCELLED_TO_WAITING = 1 THEN 'Upgraded to BoxyLuxe from Waiting Cancelled'
           WHEN CALENDAR_DATE >= SUBSCRIPTION_START_DATE AND (NUMBER_BOXYLUXE_ORDERS = 0 OR NUMBER_BOXYLUXE_ORDERS IS NULL) THEN 'Waiting Status - BoxyLuxe'
           WHEN (BOXYLUXE_ORDER_CREATION = 1 OR BOXYLUXE_REBILL_CREATION = 1 OR BASE_REBILL_CREATION = 1 OR BASE_ORDER_CREATION = 1) AND NUMBER_BOXYLUXE_ORDERS = 1 THEN 'Waitlist Processed - Active'
           WHEN (BOXYLUXE_ORDER_CREATION = 1 OR BOXYLUXE_REBILL_CREATION = 1 OR BASE_REBILL_CREATION = 1 OR BASE_ORDER_CREATION = 1) AND NUMBER_BOXYLUXE_ORDERS > 1 THEN 'Renewed Previously - Active'
           WHEN NUMBER_BOXYLUXE_ORDERS IS NULL THEN 'Prior to Subscription'
           ELSE 'Other' END AS FLAG_DESCRIPTION
FROM BI_STAGING.BI_DATA.BOXYLUXE_SHELL AS BS
LEFT JOIN BI_STAGING.BI_DATA.BOXYLUXE_UNION_ACTION AS UA
    ON (BS.CUSTOMER_KEY = UA.CUSTOMER_KEY
    AND BS.SUBSCRIPTION_ID = UA.SUBSCRIPTION_ID
    AND BS.CALENDAR_DATE >= UA.DATE
    AND (BS.CALENDAR_DATE < UA.NEXT_DATE OR BS.CALENDAR_DATE = CASE WHEN UA.NEXT_DATE = CURRENT_DATE THEN CURRENT_DATE ELSE '3000-01-01' END)
       ;;
  }

  dimension: calendar_date {
    type: date
    sql: ${TABLE}."CALENDAR_DATE" ;;
  }

  dimension: beginning_date {
    type: date
    sql: ${TABLE}."BEGINNING_DATE" ;;
  }

  dimension: next_date {
    type: date
    sql: ${TABLE}."NEXT_DATE" ;;
  }

  dimension: customer_key {
    type: number
    sql: ${TABLE}."CUSTOMER_KEY" ;;
  }

  dimension: customer_id {
    type: number
    sql: ${TABLE}."CUSTOMER_ID" ;;
  }

  dimension: email_address {
    type: string
    sql: ${TABLE}."EMAIL_ADDRESS" ;;
  }

  dimension: subscription_id {
    type: number
    sql: ${TABLE}."SUBSCRIPTION_ID" ;;
  }

  dimension: normal_subscription_id {
    type: number
    sql: ${TABLE}."NORMAL_SUBSCRIPTION_ID" ;;
  }

  dimension: billing_period_label {
    type: string
    sql: ${TABLE}."BILLING_PERIOD_LABEL" ;;
  }

  dimension: subscription_start_date {
    type: date
    sql: ${TABLE}."SUBSCRIPTION_START_DATE" ;;
  }

  dimension: cancel_date {
    type: date
    sql: ${TABLE}."CANCEL_DATE" ;;
  }

  dimension: cancel_date_regular {
    type: date
    sql: ${TABLE}."CANCEL_DATE_REGULAR" ;;
  }

  dimension: number_boxyluxe_orders {
    type: number
    sql: ${TABLE}."NUMBER_BOXYLUXE_ORDERS" ;;
  }

  dimension: boxyluxe_order_creation {
    type: number
    sql: ${TABLE}."BOXYLUXE_ORDER_CREATION" ;;
  }

  dimension: boxyluxe_rebill_creation {
    type: number
    sql: ${TABLE}."BOXYLUXE_REBILL_CREATION" ;;
  }

  dimension: boxyluxe_payment_failure {
    type: number
    sql: ${TABLE}."BOXYLUXE_PAYMENT_FAILURE" ;;
  }

  dimension: boxyluxe_waiting_cancelled {
    type: number
    sql: ${TABLE}."BOXYLUXE_WAITING_CANCELLED" ;;
  }

  dimension: boxyluxe_waiting_cancelled_to_waiting {
    type: number
    sql: ${TABLE}."BOXYLUXE_WAITING_CANCELLED_TO_WAITING" ;;
  }

  dimension: base_order_creation {
    type: number
    sql: ${TABLE}."BASE_ORDER_CREATION" ;;
  }

  dimension: base_rebill_creation {
    type: number
    sql: ${TABLE}."BASE_REBILL_CREATION" ;;
  }

  dimension: base_payment_failure {
    type: number
    sql: ${TABLE}."BASE_PAYMENT_FAILURE" ;;
  }

  dimension: base_waiting_cancelled {
    type: number
    sql: ${TABLE}."BASE_WAITING_CANCELLED" ;;
  }

  dimension: base_waiting_cancelled_to_waiting {
    type: number
    sql: ${TABLE}."BASE_WAITING_CANCELLED_TO_WAITING" ;;
  }

  dimension: flag_description {
    type: string
    sql: ${TABLE}."FLAG_DESCRIPTION" ;;
  }

##################### Measures #######################

  measure: count_subscriptions {
    type: count_distinct
    sql: ${TABLE}."NORMAL_SUBSCRIPTION_ID" ;;
  }

  measure: new_signups {
    type: count_distinct
    sql: CASE WHEN ${TABLE}."CALENDAR_DATE" = ${TABLE}."SUBSCRIPTION_START_DATE" THEN ${TABLE}."NORMAL_SUBSCRIPTION_ID" END ;;
  }

  measure: voluntary_cancel {
    type: count_distinct
    sql: CASE WHEN ${TABLE}."CALENDAR_DATE" = ${TABLE}."CANCEL_DATE" THEN ${TABLE}."NORMAL_SUBSCRIPTION_ID" END ;;
  }

  measure: involuntary_cancel {
    type: count_distinct
    sql: CASE WHEN ${TABLE}."CALENDAR_DATE" = ${TABLE}."BEGINNING_DATE" AND ${TABLE}."FLAG_DESCRIPTION" = 'Involuntarily Cancelled due to Payment Failure' THEN ${TABLE}."NORMAL_SUBSCRIPTION_ID" END ;;
  }

}
