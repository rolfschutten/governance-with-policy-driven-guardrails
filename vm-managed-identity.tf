resource "azurerm_policy_definition" "vm_managed_identity" {
  name         = "vm-managed-identity"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "VM Managed identity"
  description = "This policy adds a system-assigned managed identity to virtual machines hosted in Azure that are supported by Guest Configuration but do not have any managed identities."

  metadata = <<METADATA
    {
      "category": "Guest Configuration",
      "version": "4.0.0"
    }
  METADATA


  policy_rule = <<POLICY_RULE
    {
        "if": {
        "allOf": [
          {
            "field": "type",
            "equals": "Microsoft.Compute/virtualMachines"
          },
          {
            "anyOf": [
              {
                "field": "identity.type",
                "exists": "false"
              },
              {
                "field": "identity.type",
                "equals": "None"
              }
            ]
          }
        ]
      },
      "then": {
        "effect": "modify",
        "details": {
          "roleDefinitionIds": [
            "/providers/microsoft.authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c"
          ],
          "operations": [
            {
              "operation": "addOrReplace",
              "field": "identity.type",
              "value": "SystemAssigned"
            }
          ]
        }
      }
    }
  POLICY_RULE
}

resource "azurerm_subscription_policy_assignment" "vm_managed_identity" {
  name                 = "vm-managed-identity"
  policy_definition_id = azurerm_policy_definition.vm_managed_identity.id
  subscription_id      = data.azurerm_subscription.current.id
  location             = "westeurope"
  identity {
      type             = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "vm_managed_identity" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_subscription_policy_assignment.vm_managed_identity.identity[0].principal_id
}

resource "azurerm_subscription_policy_remediation" "vm_managed_identity" {
  name                 = "vm-managed-identity"
  subscription_id      = data.azurerm_subscription.current.id
  policy_assignment_id = azurerm_subscription_policy_assignment.vm_managed_identity.id
}