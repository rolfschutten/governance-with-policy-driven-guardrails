resource "azurerm_policy_definition" "linux_vm_guest_configuration" {
  name         = "linux-vm-guest-configuration"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "Linux VM Guest Configuration"
  description = "This policy deploys the Linux Guest Configuration extension to Linux virtual machines hosted in Azure that are supported by Guest Configuration."

  metadata = <<METADATA
    {
      "category": "Guest Configuration",
      "version": "3.0.0"
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
                "field": "Microsoft.Compute/imagePublisher",
                "in": [
                  "microsoft-aks",
                  "qubole-inc",
                  "datastax",
                  "couchbase",
                  "scalegrid",
                  "checkpoint",
                  "paloaltonetworks",
                  "debian",
                  "credativ"
                ]
              },
              {
                "allOf": [
                  {
                    "field": "Microsoft.Compute/imagePublisher",
                    "equals": "OpenLogic"
                  },
                  {
                    "field": "Microsoft.Compute/imageSKU",
                    "notLike": "6*"
                  }
                ]
              },
              {
                "allOf": [
                  {
                    "field": "Microsoft.Compute/imagePublisher",
                    "equals": "Oracle"
                  },
                  {
                    "field": "Microsoft.Compute/imageSKU",
                    "notLike": "6*"
                  }
                ]
              },
              {
                "allOf": [
                  {
                    "field": "Microsoft.Compute/imagePublisher",
                    "equals": "RedHat"
                  },
                  {
                    "field": "Microsoft.Compute/imageSKU",
                    "notLike": "6*"
                  }
                ]
              },
              {
                "allOf": [
                  {
                    "field": "Microsoft.Compute/imagePublisher",
                    "equals": "center-for-internet-security-inc"
                  },
                  {
                    "field": "Microsoft.Compute/imageOffer",
                    "notLike": "cis-windows*"
                  }
                ]
              },
              {
                "allOf": [
                  {
                    "field": "Microsoft.Compute/imagePublisher",
                    "equals": "Suse"
                  },
                  {
                    "field": "Microsoft.Compute/imageSKU",
                    "notLike": "11*"
                  }
                ]
              },
              {
                "allOf": [
                  {
                    "field": "Microsoft.Compute/imagePublisher",
                    "equals": "Canonical"
                  },
                  {
                    "field": "Microsoft.Compute/imageSKU",
                    "notLike": "12*"
                  }
                ]
              },
              {
                "allOf": [
                  {
                    "field": "Microsoft.Compute/imagePublisher",
                    "equals": "microsoft-dsvm"
                  },
                  {
                    "field": "Microsoft.Compute/imageOffer",
                    "notLike": "dsvm-win*"
                  }
                ]
              },
              {
                "allOf": [
                  {
                    "field": "Microsoft.Compute/imagePublisher",
                    "equals": "cloudera"
                  },
                  {
                    "field": "Microsoft.Compute/imageSKU",
                    "notLike": "6*"
                  }
                ]
              },
              {
                "allOf": [
                  {
                    "field": "Microsoft.Compute/imagePublisher",
                    "equals": "microsoft-ads"
                  },
                  {
                    "field": "Microsoft.Compute/imageOffer",
                    "like": "linux*"
                  }
                ]
              },
              {
                "allOf": [
                  {
                    "anyOf": [
                      {
                        "field": "Microsoft.Compute/virtualMachines/osProfile.linuxConfiguration",
                        "exists": "true"
                      },
                      {
                        "field": "Microsoft.Compute/virtualMachines/storageProfile.osDisk.osType",
                        "like": "Linux*"
                      }
                    ]
                  },
                  {
                    "anyOf": [
                      {
                        "field": "Microsoft.Compute/imagePublisher",
                        "exists": "false"
                      },
                      {
                        "field": "Microsoft.Compute/imagePublisher",
                        "notIn": [
                          "OpenLogic",
                          "RedHat",
                          "credativ",
                          "Suse",
                          "Canonical",
                          "microsoft-dsvm",
                          "cloudera",
                          "microsoft-ads",
                          "center-for-internet-security-inc",
                          "Oracle",
                          "AzureDatabricks",
                          "azureopenshift"
                        ]
                      }
                    ]
                  }
                ]
              }
            ]
          }
        ]
      },
      "then": {
        "effect": "deployIfNotExists",
        "details": {
          "roleDefinitionIds": [
            "/providers/microsoft.authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c"
          ],
          "type": "Microsoft.Compute/virtualMachines/extensions",
          "name": "AzurePolicyforLinux",
          "existenceCondition": {
            "allOf": [
              {
                "field": "Microsoft.Compute/virtualMachines/extensions/publisher",
                "equals": "Microsoft.GuestConfiguration"
              },
              {
                "field": "Microsoft.Compute/virtualMachines/extensions/type",
                "equals": "ConfigurationforLinux"
              },
              {
                "field": "Microsoft.Compute/virtualMachines/extensions/provisioningState",
                "equals": "Succeeded"
              }
            ]
          },
          "deployment": {
            "properties": {
              "mode": "incremental",
              "parameters": {
                "vmName": {
                  "value": "[field('name')]"
                },
                "location": {
                  "value": "[field('location')]"
                }
              },
              "template": {
                "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
                "contentVersion": "1.0.0.0",
                "parameters": {
                  "vmName": {
                    "type": "string"
                  },
                  "location": {
                    "type": "string"
                  }
                },
                "resources": [
                  {
                    "apiVersion": "2019-07-01",
                    "name": "[concat(parameters('vmName'), '/AzurePolicyforLinux')]",
                    "type": "Microsoft.Compute/virtualMachines/extensions",
                    "location": "[parameters('location')]",
                    "properties": {
                      "publisher": "Microsoft.GuestConfiguration",
                      "type": "ConfigurationforLinux",
                      "typeHandlerVersion": "1.0",
                      "autoUpgradeMinorVersion": true,
                      "enableAutomaticUpgrade": true,
                      "settings": {},
                      "protectedSettings": {}
                    }
                  }
                ]
              }
            }
          }
        }
      }
  }
  POLICY_RULE
}

resource "azurerm_subscription_policy_assignment" "linux_vm_guest_configuration" {
  name                 = "linux-vm-guest-configuration"
  policy_definition_id = azurerm_policy_definition.linux_vm_guest_configuration.id
  subscription_id      = data.azurerm_subscription.current.id
  location             = "westeurope"
  identity {
      type             = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "linux_vm_guest_configuration" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_subscription_policy_assignment.linux_vm_guest_configuration.identity[0].principal_id
}