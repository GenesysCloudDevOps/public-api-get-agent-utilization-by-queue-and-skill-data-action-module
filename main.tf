resource "genesyscloud_integration_action" "action" {
    name           = var.action_name
    category       = var.action_category
    integration_id = var.integration_id
    secure         = var.secure_data_action
    
    contract_input  = jsonencode({
        "$schema" = "http://json-schema.org/draft-04/schema#",
        "additionalProperties" = true,
        "properties" = {
            "PageNumber" = {
                "default" = "1",
                "type" = "string"
            },
            "QueueId" = {
                "description" = "Queue ID",
                "type" = "string"
            },
            "RoutingStatus" = {
                "description" = "Routing status",
                "type" = "string"
            },
            "Skills" = {
                "description" = "Skill names",
                "type" = "string"
            }
        },
        "required" = [
            "QueueId",
            "RoutingStatus",
            "Skills",
            "PageNumber"
        ],
        "type" = "object"
    })
    contract_output = jsonencode({
        "$schema" = "http://json-schema.org/draft-04/schema#",
        "additionalProperties" = true,
        "description" = "Response",
        "properties" = {
            "NumActive" = {
                "items" = {
                    "type" = "integer"
                },
                "type" = "array"
            },
            "NumAcw" = {
                "items" = {
                    "type" = "integer"
                },
                "type" = "array"
            },
            "NumAgents" = {
                "description" = "Count of agents up to 100",
                "type" = "integer"
            },
            "NumCommunicate" = {
                "items" = {
                    "type" = "integer"
                },
                "type" = "array"
            },
            "UserIds" = {
                "items" = {
                    "type" = "string"
                },
                "type" = "array"
            }
        },
        "title" = "Response",
        "type" = "object"
    })
    
    config_request {
        request_template     = "$${input.rawRequest}"
        request_type         = "GET"
        request_url_template = "/api/v2/routing/queues/$${input.QueueId}/members?skills=$esc.url($${input.Skills})&routingStatus=$${input.RoutingStatus}&joined=true&expand=conversationSummary&pageSize=100&pageNumber=$${input.PageNumber}"
        
    }

    config_response {
        success_template = "{ \"NumAgents\": $${numAgents}, \"UserIds\": $${userIds}, \"NumActive\": $${active}, \"NumAcw\": $${acw}, \"NumCommunicate\": $${communicate} }"
        translation_map = { 
			numAgents = "$.entities.size()"
			userIds = "$.entities[*].id"
			active = "$.entities[*].user.conversationSummary.message.contactCenter.active"
			acw = "$.entities[*].user.conversationSummary.message.contactCenter.acw"
			communicate = "$.entities[*].user.conversationSummary.message.enterprise.active"
		}
        translation_map_defaults = {       
			numAgents = "0"
			userIds = "[]"
			active = "[]"
			acw = "[]"
			communicate = "[]"
		}
    }
}