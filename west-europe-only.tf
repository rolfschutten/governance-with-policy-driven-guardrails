resource "azurerm_policy_definition" "west_europe_only" {
  name         = "west-europe-only"
  display_name = "Ensure all resources are deployed in West Europe"
  description  = "This policy ensures that all resources are deployed in the West Europe region."
  policy_type  = "Custom"
  mode         = "Indexed"

  metadata = <<METADATA
    {
      "category": "Location"
    }
  METADATA

  policy_rule = <<POLICY_RULE
    {
      "if": {
        "not": {
          "field": "location",
          "in": [
            "westeurope"
          ]
        }
      },
      "then": {
        "effect": "deny"
      }
    }
  POLICY_RULE
}

resource "azurerm_subscription_policy_assignment" "west_europe_only" {
  name                 = "west-europe-only"
  policy_definition_id = azurerm_policy_definition.west_europe_only.id
  subscription_id      = data.azurerm_subscription.current.id
}