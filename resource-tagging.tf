resource "azurerm_policy_definition" "resource_tagging" {
  name         = "resource-tagging"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Resource Tagging"
  description = "This policy appends the 'CostCenter', 'Owner', and 'Department' tags with a timestamp as their value if they do not exist on resources."

  metadata = <<METADATA
    {
      "version": "1.0.1",
      "category": "Tags"
    }
  METADATA

  policy_rule = <<POLICY_RULE
  {
        "if": {
            "not": {
                "allOf": [
                    {
                        "field": "tags['CostCenter']",
                        "exists": "true"
                    },
                    {
                        "field": "tags['Owner']",
                        "exists": "true"
                    },
                    {
                        "field": "tags['Department']",
                        "exists": "true"
                    }
                ]
            }
        },
        "then": {
            "effect": "Modify",
            "details": {
                "roleDefinitionIds": [
                    "/providers/microsoft.authorization/roleDefinitions/9f1af436-2d4a-4c3c-bfd0-4aa7c3c4d54e"
                ],
                "operations": [
                    {
                        "operation": "add",
                        "field": "tags",
                        "value": {
                            "CostCenter": "[concat('CC-',utcNow())]",
                            "Owner": "[concat('Owner-',utcNow())]",
                            "Department": "[concat('Dept-',utcNow())]"
                        }
                    }
                ]
            }
        }
    }
  POLICY_RULE
}

resource "azurerm_subscription_policy_assignment" "resource_tagging" {
  name                 = "resource-tagging"
  policy_definition_id = azurerm_policy_definition.resource_tagging.id
  subscription_id      = data.azurerm_subscription.current.id
  location             = "westeurope"
  identity {
    type             = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "resource_tagging" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_subscription_policy_assignment.resource_tagging.identity[0].principal_id
}

resource "azurerm_subscription_policy_remediation" "resource_tagging" {
  name                 = "resource-tagging"
  subscription_id      = data.azurerm_subscription.current.id
  policy_assignment_id = azurerm_subscription_policy_assignment.resource_tagging.id
}