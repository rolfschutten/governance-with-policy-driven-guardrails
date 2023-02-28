resource "azurerm_policy_definition" "encryption_at_host" {
  name         = "encryption-at-host"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "Virtual machines and virtual machine scale sets should have encryption at host enabled"

  metadata = <<METADATA
    {
    "category": "Compute",
    "version": "1.0.0"
    }
  METADATA


  policy_rule = <<POLICY_RULE
    {
        "if": {
          "anyOf": [
          {
              "allOf": [
              {
                  "field": "type",
                  "equals": "Microsoft.Compute/virtualMachines"
              },
              {
                  "field": "Microsoft.Compute/virtualMachines/securityProfile.encryptionAtHost",
                  "notEquals": "true"
              }
              ]
          },
          {
              "allOf": [
              {
                  "field": "type",
                  "equals": "Microsoft.Compute/virtualMachineScaleSets"
              },
              {
                  "field": "Microsoft.Compute/virtualMachineScaleSets/virtualMachineProfile.securityProfile.encryptionAtHost",
                  "notEquals": "true"
              }
              ]
          }
          ]
        },
        "then": {
            "effect": "Audit"
        }
  }
  POLICY_RULE
}

resource "azurerm_subscription_policy_assignment" "encryption_at_host" {
  name                 = "encryption-at-host"
  policy_definition_id = azurerm_policy_definition.encryption_at_host.id
  subscription_id      = data.azurerm_subscription.current.id
}