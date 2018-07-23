view: dw_cs_d_agent {
  label: "Agent"
  sql_table_name: dwh.dw.d_agent;;

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: agent_key {
    type: number
    sql: ${TABLE}.AGENT_KEY ;;
    primary_key: yes
    hidden: yes
  }

  dimension: agent_id {
    type: string
    sql: ${TABLE}.AGENT_ID ;;
  }

  dimension: agent_email {
    type: string
    sql: ${TABLE}.AGENT_EMAIL ;;
  }

  dimension: agent_last_name {
    type: string
    sql: ${TABLE}.AGENT_LAST_NAME ;;
  }

  dimension: agent_middle_name {
    type: string
    sql: ${TABLE}.AGENT_MIDDLE_NAME ;;
  }

  dimension: agent_first_name {
    type: string
    sql: ${TABLE}.AGENT_FIRST_NAME ;;
  }

  dimension: agent_full_name {
    type: string
    sql: ${TABLE}.AGENT_FULL_NAME ;;
  }

  dimension: nick_name {
    type: string
    sql: ${TABLE}.NICK_NAME ;;
  }

  dimension: team_name {
    type: string
    sql: ${TABLE}.TEAM_NAME ;;
  }

  dimension: role_name {
    type: string
    sql: ${TABLE}.ROLE_NAME ;;
  }

  dimension: extended_role_name {
    type: string
    sql: ${TABLE}.EXTENDED_ROLE_NAME ;;
  }

  dimension: designation_name {
    type: string
    sql: ${TABLE}.DESIGNATION_NAME ;;
  }

  dimension: location_name {
    type: string
    sql: ${TABLE}.LOCATION_NAME ;;
  }

  dimension: agent_start_date {
    type: date
    sql: ${TABLE}.AGENT_START_DATE ;;
  }

  dimension: agent_end_date {
    type: date
    sql: ${TABLE}.AGENT_END_DATE ;;
  }

  dimension: agent_tier_name {
    type: string
    sql: ${TABLE}.AGENT_TIER_NAME ;;
  }

  dimension_group: source_update_datetime {
    type: time
    sql: ${TABLE}.SOURCE_UPDATE_DATETIME ;;
  }


  set: detail {
    fields: [
      agent_key,
      agent_id,
      agent_email,
      agent_last_name,
      agent_middle_name,
      agent_first_name,
      agent_full_name,
      nick_name,
      team_name,
      role_name,
      extended_role_name,
      designation_name,
      location_name,
      agent_start_date,
      agent_end_date,
      agent_tier_name,
      source_update_datetime_time
    ]
  }
}
