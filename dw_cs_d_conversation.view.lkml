view: dw_cs_d_conversation {
  label: "Conversation"
  sql_table_name: dwh.dw.d_conversation;;

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: conversation_key {
    type: number
    sql: ${TABLE}.CONVERSATION_KEY ;;
    primary_key: yes
    hidden: yes
  }

  dimension: conversation_id {
    type: string
    sql: ${TABLE}.CONVERSATION_ID ;;
  }

  dimension: conversation_name {
    type: string
    sql: ${TABLE}.CONVERSATION_NAME ;;
  }

  dimension: conversation_type {
    type: string
    sql: ${TABLE}.CONVERSATION_TYPE ;;
  }

  dimension: conversation_priority {
    type: string
    sql: ${TABLE}.CONVERSATION_PRIORITY ;;
  }

  dimension_group: source_update_datetime {
    type: time
    sql: ${TABLE}.SOURCE_UPDATE_DATETIME ;;
  }


  set: detail {
    fields: [
      conversation_key,
      conversation_id,
      conversation_name,
      conversation_type,
      conversation_priority
    ]
  }
}
