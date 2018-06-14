# # This explore is intended to be JUST the Zendesk generated data (not Maestro data)
# # You'll probably want to replace this with the existing Zendesk block you have.
# # See the longer discussion in 'helpdesk_integration' documents

connection: "alooma-snowflake" # Replace with your connection name

include: "dw_cs_*.view.lkml" # include all views that end in .zendesk


explore: dw_cs_d_conversation {
  hidden: yes
  join: dw_cs_f_message {
    relationship: many_to_one
    sql_on: ${dw_cs_d_conversation.conversation_key} = ${dw_cs_f_message.conversation_key} ;;
  }
}

explore: dw_cs_f_message {
  hidden: yes
  join: dw_cs_d_agent {
    relationship: many_to_one
    sql_on: ${dw_cs_d_agent.agent_key} = ${dw_cs_f_message.agent_key} ;;
  }
}

# # Select the views that should be a part of this model,
# # and define the joins that connect them together.
#
# explore: order_items {
#   join: orders {
#     sql_on: ${orders.id} = ${order_items.order_id}
#   }
#
#   join: users {
#     sql_on: ${users.id} = ${orders.user_id}
#   }
# }
