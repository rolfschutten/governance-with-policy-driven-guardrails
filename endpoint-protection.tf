resource "azurerm_policy_definition" "endpoint_protection" {
  name         = "endpoint-protection"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Endpoint protection should be installed on your machines"

  metadata = <<METADATA
    {
    "category": "Security Center"
    }
  METADATA


  policy_rule = <<POLICY_RULE
    {
        "if": {
            "allOf": [
            {
                "field": "type",
                "in": [
                    "Microsoft.Compute/virtualMachines",
                    "Microsoft.ClassicCompute/virtualMachines",
                    "Microsoft.HybridCompute/machines"
                ]
            }
            ]
        },
        "then": {
            "effect": "AuditIfNotExists",
            "details": {
                "type": "Microsoft.Security/assessments",
                "name": "4fb67663-9ab9-475d-b026-8c544cced439",
                "existenceCondition": {
                    "field": "Microsoft.Security/assessments/status.code",
                    "in": [
                        "NotApplicable",
                        "Healthy"
                    ]
                }
            }
        }
    }
  POLICY_RULE
}

resource "azurerm_subscription_policy_assignment" "endpoint_protection" {
  name                 = "endpoint-protection"
  policy_definition_id = azurerm_policy_definition.endpoint_protection.id
  subscription_id      = data.azurerm_subscription.current.id
}