# Define Provider as Azure
provider "azurerm" {
    subscription_id = "${var.subscription_id}"
    client_id       = "${var.client_id}"
    client_secret   = "${var.client_secret}"
    tenant_id       = "${var.tenant_id}"
}

# Create Resource Group
resource "azurerm_resource_group" "getCfbData" {
    name        = "${var.prefix}-stats-test"
    location    = "${var.location}"

    tags {
        Owner           = "${lookup(var.azure_tags, "Owner")}"
        Exception       = "${lookup(var.azure_tags, "Exception")}"
        StopResources   = "${lookup(var.azure_tags, "StopResources")}"
        Description     = "${lookup(var.azure_tags, "Description")}"
    }
}

module "storage" {
    source = "./storage"
    rg_name = "${azurerm_resource_group.getCfbData.name}"
    rg_location = "${azurerm_resource_group.getCfbData.location}"
    prefix = "${var.prefix}"
}

# Create Logic App Base Workflow
resource "azurerm_logic_app_workflow" "getCfbData" {
    name                = "${var.prefix}WF"
    location            = "${azurerm_resource_group.getCfbData.location}"
    resource_group_name = "${azurerm_resource_group.getCfbData.name}"

    tags {
        Owner           = "${lookup(var.azure_tags, "Owner")}"
        Exception       = "${lookup(var.azure_tags, "Exception")}"
        StopResources   = "${lookup(var.azure_tags, "StopResources")}"
        Description     = "${lookup(var.azure_tags, "Description")}"
    }
}

# Create recurring schedule based trigger
resource "azurerm_logic_app_trigger_custom" "weeklySchedule" {
    name                = "weeklyRun"
    logic_app_id        = "${azurerm_logic_app_workflow.getCfbData.id}"
    body = <<BODY
    {
        "recurrence" : {
            "frequency" : "Week",
            "interval" : 1,
            "schedule" : {
                "hours" : ["6"],
                "minutes" : [30],
                "weekDays" : ["Monday"]
            },
            "timeZone" : "Central Standard Time"
        },
        "type" : "Recurrence"
    }
    BODY
}

# Create Action to get the full schedule of games
resource "azurerm_logic_app_action_http" "getScheduleOfGames" {
    name            = "getSchedule"
    logic_app_id    = "${azurerm_logic_app_workflow.getCfbData.id}"
    method          = "GET"
    uri             = "http://api.cfl.ca/v1/games/2018?key=${var.cflKey}"
}

# Create Action to parse the JSON
resource "azurerm_logic_app_action_custom" "parseScheduleData" {
    name = "parseSchedData"
    logic_app_id = "${azurerm_logic_app_workflow.getCfbData.id}"
    body = <<BODY
        {
            "inputs": {
            "content": "@body('getSchedule')",
            "schema": {
            "properties": {
                "data": {
                    "items": {
                        "properties": {
                            "attendance": {
                                "type": "integer"
                            },
                            "coin_toss": {
                                "properties": {
                                    "coin_toss_winner": {
                                        "type": "string"
                                    },
                                    "coin_toss_winner_election": {
                                        "type": "string"
                                    }
                                },
                                "type": "object"
                            },
                            "date_start": {
                                "type": "string"
                            },
                            "event_status": {
                                "properties": {
                                    "down": {
                                        "type": "integer"
                                    },
                                    "event_status_id": {
                                        "type": "integer"
                                    },
                                    "is_active": {
                                        "type": "boolean"
                                    },
                                    "minutes": {
                                        "type": "integer"
                                    },
                                    "name": {
                                        "type": "string"
                                    },
                                    "quarter": {
                                        "type": "integer"
                                    },
                                    "seconds": {
                                        "type": "integer"
                                    },
                                    "yards_to_go": {
                                        "type": "integer"
                                    }
                                },
                                "type": "object"
                            },
                            "event_type": {
                                "properties": {
                                    "event_type_id": {
                                        "type": "integer"
                                    },
                                    "name": {
                                        "type": "string"
                                    },
                                    "title": {
                                        "type": "string"
                                    }
                                },
                                "type": "object"
                            },
                            "game_duration": {
                                "type": "integer"
                            },
                            "game_id": {
                                "type": "integer"
                            },
                            "game_number": {
                                "type": "integer"
                            },
                            "season": {
                                "type": "integer"
                            },
                            "team_1": {
                                "properties": {
                                    "abbreviation": {
                                        "type": "string"
                                    },
                                    "is_at_home": {
                                        "type": "boolean"
                                    },
                                    "is_winner": {
                                        "type": "boolean"
                                    },
                                    "linescores": {
                                        "items": {
                                            "properties": {
                                                "quarter": {
                                                    "type": [
                                                        "integer",
                                                        "string"
                                                    ]
                                                },
                                                "score": {
                                                    "type": "integer"
                                                }
                                            },
                                            "required": [
                                                "quarter",
                                                "score"
                                            ],
                                            "type": "object"
                                        },
                                        "type": "array"
                                    },
                                    "location": {
                                        "type": "string"
                                    },
                                    "nickname": {
                                        "type": "string"
                                    },
                                    "score": {
                                        "type": "integer"
                                    },
                                    "team_id": {
                                        "type": "integer"
                                    },
                                    "venue_id": {
                                        "type": "integer"
                                    }
                                },
                                "type": "object"
                            },
                            "team_2": {
                                "properties": {
                                    "abbreviation": {
                                        "type": "string"
                                    },
                                    "is_at_home": {
                                        "type": "boolean"
                                    },
                                    "is_winner": {
                                        "type": "boolean"
                                    },
                                    "linescores": {
                                        "items": {
                                            "properties": {
                                                "quarter": {
                                                    "type": [
                                                        "integer",
                                                        "string"
                                                    ]
                                                },
                                                "score": {
                                                    "type": "integer"
                                                }
                                            },
                                            "required": [
                                                "quarter",
                                                "score"
                                            ],
                                            "type": "object"
                                        },
                                        "type": "array"
                                    },
                                    "location": {
                                        "type": "string"
                                    },
                                    "nickname": {
                                        "type": "string"
                                    },
                                    "score": {
                                        "type": "integer"
                                    },
                                    "team_id": {
                                        "type": "integer"
                                    },
                                    "venue_id": {
                                        "type": "integer"
                                    }
                                },
                                "type": "object"
                            },
                            "tickets_url": {
                                "type": "string"
                            },
                            "venue": {
                                "properties": {
                                    "name": {
                                        "type": "string"
                                    },
                                    "venue_id": {
                                        "type": "integer"
                                    }
                                },
                                "type": "object"
                            },
                            "weather": {
                                "properties": {
                                    "field_conditions": {
                                        "type": "string"
                                    },
                                    "sky": {
                                        "type": "string"
                                    },
                                    "temperature": {
                                        "type": "integer"
                                    },
                                    "wind_direction": {
                                        "type": "string"
                                    },
                                    "wind_speed": {
                                        "type": "string"
                                    }
                                },
                                "type": "object"
                            },
                            "week": {
                                "type": "integer"
                            }
                        },
                        "required": [
                            "game_id",
                            "date_start",
                            "game_number",
                            "week",
                            "season",
                            "attendance",
                            "game_duration",
                            "event_type",
                            "event_status",
                            "venue",
                            "weather",
                            "coin_toss",
                            "tickets_url",
                            "team_1",
                            "team_2"
                        ],
                        "type": "object"
                    },
                    "type": "array"
                },
                "errors": {
                    "type": "array"
                },
                "meta": {
                    "properties": {
                        "copyright": {
                            "type": "string"
                        }
                    },
                    "type": "object"
                }
            },
            "type": "object"
        }
    },
    "runAfter": {
        "getSchedule": [
            "Succeeded"
        ]
    },
    "type": "ParseJson"
    }
    BODY
}
