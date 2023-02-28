resource "azurerm_policy_definition" "virtual_machine_sku_restriction" {
  name         = "virtual-machine-sku-restriction"
  display_name = "Virtual Machine SKU Restriction"
  description  = "Restricts the allowed SKU's for virtual machine resources to only the specified sizes."
  policy_type  = "Custom"
  mode         = "Indexed"

  policy_rule = <<POLICY_RULE
{
  "if": {
    "not": {
        "field": "Microsoft.Compute/virtualMachines/sku.name",
        "in": ["Standard_D2s_v5", "Standard_D4s_v5", "Standard_D8s_v5"]
      }
  },
  "then": {
    "effect": "deny"
  }
}
POLICY_RULE
}

resource "azurerm_subscription_policy_assignment" "virtual_machine_sku_restriction" {
  name                 = "virtual-machine-sku-restriction"
  policy_definition_id = azurerm_policy_definition.virtual_machine_sku_restriction.id
  subscription_id      = data.azurerm_subscription.current.id
}