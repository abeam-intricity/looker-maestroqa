view: skin_concerns_beauty_quiz {
  derived_table: {
    sql: SELECT CUSTOMER_ID, ANSWER AS SKINCARE_CONCERNS FROM BI_ALLOCATIONS.BI_DATA.CUSTOMER_BEAUTY_QUIZ_DETAILS
      where question = 'skin_concerns'
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: customer_id {
    type: string
    sql: ${TABLE}."CUSTOMER_ID" ;;
  }


  measure: count_customer_id {
    type: count
    sql: ${TABLE}."CUSTOMER_ID" ;;
  }


  dimension: skincare_concerns {
    type: string
    sql: ${TABLE}."SKINCARE_CONCERNS" ;;
  }

  set: detail {
    fields: [customer_id, skincare_concerns]
  }
}
