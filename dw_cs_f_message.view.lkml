view: dw_cs_f_message {
  label: "Messages"
  sql_table_name: dwh.dw.f_message;;

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: total_unique_cases {
    type: count_distinct
    sql:  ${conversation_key} ;;
  }

  dimension: message_date_key {
    type: number
    sql: ${TABLE}.MESSAGE_DATE_KEY ;;
    hidden:  yes
  }


  dimension_group: message {
    type: time
    timeframes: [date, time, week, month, time_of_day, hour_of_day, hour, raw]
    sql: ${TABLE}.MESSAGE_TIMESTAMP ;;
    convert_tz: yes
  }

  dimension: conversation_create_date_key {
    type: number
    sql: ${TABLE}.CONVERSATION_CREATE_DATE_KEY ;;
    hidden: yes
  }


  dimension_group: conversation_create {
    type: time
    timeframes: [date, time, week, month, time_of_day, hour_of_day, hour, day_of_week, raw]
    sql: ${TABLE}.conversion_create_timestamp ;;
    convert_tz: yes
  }

  dimension: agent_key {
    type: number
    sql: ${TABLE}.AGENT_KEY ;;
    hidden:  yes
  }

  dimension: customer_key {
    type: number
    sql: ${TABLE}.CUSTOMER_KEY ;;
    hidden:  yes
  }

  dimension: channel_key {
    type: number
    sql: ${TABLE}.CHANNEL_KEY ;;
    hidden:  yes
  }

  dimension: misc_attribs_key {
    type: number
    sql: ${TABLE}.MISC_ATTRIBS_KEY ;;
    hidden:  yes
  }

  dimension: conversation_key {
    type: number
    sql: ${TABLE}.CONVERSATION_KEY ;;
    hidden:  yes
  }

  dimension: macro_key {
    type: number
    sql: ${TABLE}.MACRO_KEY ;;
    hidden:  yes
  }

  dimension: conversation_id {
    type: string
    sql: ${TABLE}.CONVERSATION_ID ;;
  }

  dimension: message_id {
    type: string
    sql: ${TABLE}.MESSAGE_ID ;;
  }

  dimension: customer_id {
    type: string
    sql: ${TABLE}.CUSTOMER_ID ;;
  }

  dimension: message_sequence_nbr {
    type: number
    sql: ${TABLE}.MESSAGE_SEQUENCE_NBR ;;
  }

  dimension: outbound_msg_count {
    type: string
    sql: ${TABLE}.OUTBOUND_MSG_COUNT ;;
  }

  dimension: inbound_msg_count {
    type: number
    sql: ${TABLE}.INBOUND_MSG_COUNT ;;
  }

  dimension: duration_since_last_msg {
    type: number
    sql: ${TABLE}.DURATION_SINCE_LAST_MSG ;;
  }

  dimension: duration_since_create_msg {
    type: number
    sql: ${TABLE}.DURATION_SINCE_CREATE_MSG ;;
  }

  dimension_group: source_update_datetime {
    type: time
    sql: ${TABLE}.SOURCE_UPDATE_DATETIME ;;
  }



  set: detail {
    fields: [
      message_time,
      conversation_create_time,
      conversation_id,
      message_id,
      customer_id,
      message_sequence_nbr,
      outbound_msg_count,
      inbound_msg_count,
      duration_since_last_msg,
      duration_since_create_msg
    ]
  }
}
