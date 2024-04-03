// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.
/*
  SUMMARY: This file deploys following:
    - the ALZ default policies if the parDeployAlzDefaultPolicies parameter is set to true
    - the customer specified policies to the management group. The customer specified policies are specified in the parCustomerPolicies parameter.
    - the policy exemptions to the management group. The policy exemptions are specified in the parPolicyExemptions parameter.
    - the policy assignments to the management group. The policy assignments are specified in the parPolicyAssignments parameter.
  AUTHOR/S: Cloud for Sovereignty
*/
targetScope = 'managementGroup'

@description('The prefix that will be added to all resources created by this deployment.')
@minLength(2)
@maxLength(5)
param parDeploymentPrefix string

@description('The suffix that will be added to management group suffix name the same way to be added to management group prefix names.')
@maxLength(5)
param parDeploymentSuffix string = ''

@description('Enforcement mode for all policy assignments.')
param parPolicyAssignmentEnforcementMode string

@description('The resource ID for the DDoS plan.')
param parDdosPlanResourceId string = ''

@description('The allowed Azure regions where resources are allowed to be deployed. Allowed values : asia, asiapacific, australia, australiacentral, australiacentral2, australiaeast, australiasoutheast, brazil, brazilsouth, brazilsoutheast, canada, canadacentral, canadaeast, centralindia, centralus, centraluseuap, centralusstage, eastasia, eastasiastage, eastus, eastus2, eastus2euap, eastus2stage, eastusstage, eastusstg, europe, france, francecentral, francesouth, germany, germanynorth, germanywestcentral, global, india, japan, japaneast, japanwest, jioindiacentral, jioindiawest, korea, koreacentral, koreasouth, northcentralus, northcentralusstage, northeurope, norway, norwayeast, norwaywest, qatarcentral, singapore, southafrica, southafricanorth, southafricawest, southcentralus, southcentralusstage, southcentralusstg, southeastasia, southeastasiastage, southindia, swedencentral, switzerland, switzerlandnorth, switzerlandwest, uae, uaecentral, uaenorth, uk, uksouth, ukwest, unitedstates, unitedstateseuap, westcentralus, westeurope, westindia, westus, westus2, westus2stage, westus3, westusstage')
param parAllowedLocations array

@description('The allowed Azure regions where confidential computing resources are allowed to be deployed. Allowed values : asia, asiapacific, australia, australiacentral, australiacentral2, australiaeast, australiasoutheast, brazil, brazilsouth, brazilsoutheast, canada, canadacentral, canadaeast, centralindia, centralus, centraluseuap, centralusstage, eastasia, eastasiastage, eastus, eastus2, eastus2euap, eastus2stage, eastusstage, eastusstg, europe, france, francecentral, francesouth, germany, germanynorth, germanywestcentral, global, india, japan, japaneast, japanwest, jioindiacentral, jioindiawest, korea, koreacentral, koreasouth, northcentralus, northcentralusstage, northeurope, norway, norwayeast, norwaywest, qatarcentral, singapore, southafrica, southafricanorth, southafricawest, southcentralus, southcentralusstage, southcentralusstg, southeastasia, southeastasiastage, southindia, swedencentral, switzerland, switzerlandnorth, switzerlandwest, uae, uaecentral, uaenorth, uk, uksouth, ukwest, unitedstates, unitedstateseuap, westcentralus, westeurope, westindia, westus, westus2, westus2stage, westus3, westusstage')
param parAllowedLocationsForConfidentialComputing array

@description('The ID for the Log Analytics workspace that was created to centralize log ingest.')
param parLogAnalyticsWorkspaceId string = ''

@description('Set to true to deploy ALZ default policies, otherwise false. DEFAULT: false')
param parDeployAlzDefaultPolicies bool = false

@description('The region where the Log Analytics Workspace & Automation Account are deployed.')
param parLogAnalyticsWorkSpaceAndAutomationAccountLocation string = ''

@description('Number of days of log retention for Log Analytics Workspace.')
param parLogAnalyticsWorkspaceLogRetentionInDays string

@description('Automation account name.')
param parAutomationAccountName string = ''

@description('An e-mail address that you want Microsoft Defender for Cloud alerts to be sent to.')
param parMsDefenderForCloudEmailSecurityContact string = ''

@description('Resource ID of the Resource Group that conatin the Private DNS Zones. If left empty, the policy Deploy-Private-DNS-Zones will not be assigned to the corp Management Group.')
param parPrivateDnsResourceGroupId string = ''

@description('Set to true to deploy SLZ builtin policies, otherwise false. DEFAULT: false')
var varDeploySlzBuiltInPolicies = true

@description('Effect type for all policy definitions')
param parPolicyEffect string

var varDeployPolicies = parPolicyAssignmentEnforcementMode == 'Default' ? true : false

var varExcludedALZPolicyAssignments = [
  'Audit-AppGW-WAF'
  'Audit-PeDnsZones'
  'Audit-Location-Match'
  'Audit-UnusedResources'
  'Audit-ZoneResiliency'
  'Deny-AppGW-Without-WAF'
  'Deny-Classic-Resources'
  'Deny-DataB-Pip'
  'Deny-DataB-Sku'
  'Deny-DataB-Vnet'
  'Enforce-AKS-HTTPS'
  'Deny-HybridNetworking'
  'Deny-IP-Forwarding'
  'Deny-MgmtPorts-Internet'
  'Deny-Priv-Containers-AKS'
  'Deny-Priv-Escalation-AKS'
  'Deny-Public-Endpoints'
  'Deny-Public-IP-On-NIC'
  'Deny-Public-IP'
  'Deny-RDP-From-Internet'
  'Deny-Resource-Locations'
  'Deny-Resource-Types'
  'Deny-RSG-Locations'
  'Deny-Storage-http'
  'Deny-Subnet-Without-Nsg'
  'Deny-Subnet-Without-Udr'
  'Deny-UnmanagedDisk'
  'Deploy-AKS-Policy'
  'Deploy-ASC-Monitoring'
  'Deploy-AzActivity-Log'
  'Deploy-AzSqlDb-Auditing'
  'Deploy-Log-Analytics'
  'Deploy-LX-Arc-Monitoring'
  'Deploy-MDEndpoints'
  'Deploy-MDFC-Config'
  'Deploy-MDFC-OssDb'
  'Deploy-MDFC-SqlAtp'
  'Deploy-Private-DNS-Zones'
  'Deploy-Resource-Diag'
  'Deploy-SQL-DB-Auditing'
  'Deploy-SQL-Security'
  'Deploy-SQL-TDE'
  'Deploy-SQL-Threat'
  'Deploy-VM-Backup'
  'Deploy-VM-Monitoring'
  'Deploy-VMSS-Monitoring'
  'Deploy-WS-Arc-Monitoring'
  'Enable-DDoS-VNET'
  'Enforce-ACSB'
  'Enforce-ALZ-Decomm'
  'Enforce-ALZ-Sandbox'
  'Enforce-GR-KeyVault'
  'Enforce-TLS-SSL'
]
var varExcludedPolicyAssignments = parDeployAlzDefaultPolicies ? [] : varExcludedALZPolicyAssignments

var varPolicyAssignmentScopeName = '${parDeploymentPrefix}${parDeploymentSuffix}'
var varPolicyExemptionConfidentialOnlineManagementGroup = '${parDeploymentPrefix}-landingzones-confidential-online${parDeploymentSuffix}'
var varPolicyExemptionConfidentialCorpManagementGroup = '${parDeploymentPrefix}-landingzones-confidential-corp${parDeploymentSuffix}'

var varSlzGlobalLibDef = loadJsonContent('../../dependencies/infra-as-code/bicep/modules/policy/assignments/lib/policy_assignments/policy_assignment_es_enforce_sovereignty_baseline_global.tmpl.json')
var varSlzGlobalAssignmentName = toLower(varSlzGlobalLibDef.name)

// The following module is used to deploy the ALZ default policies
module modAlzPolicyAssignments '../../dependencies/infra-as-code/bicep/modules/policy/assignments/alzDefaults/alzDefaultPolicyAssignments.bicep' = {
  name: take('${parDeploymentPrefix}-deploy-alz-default-policies${parDeploymentSuffix}', 64)
  params: {
    parTopLevelManagementGroupPrefix: parDeploymentPrefix
    parTopLevelManagementGroupSuffix: parDeploymentSuffix
    parLogAnalyticsWorkSpaceAndAutomationAccountLocation: parLogAnalyticsWorkSpaceAndAutomationAccountLocation
    parLogAnalyticsWorkspaceResourceId: parLogAnalyticsWorkspaceId
    parLogAnalyticsWorkspaceLogRetentionInDays: parLogAnalyticsWorkspaceLogRetentionInDays
    parAutomationAccountName: parAutomationAccountName
    parMsDefenderForCloudEmailSecurityContact: parMsDefenderForCloudEmailSecurityContact
    parDdosProtectionPlanId: parDdosPlanResourceId
    parPrivateDnsResourceGroupId: parPrivateDnsResourceGroupId
    parDisableAlzDefaultPolicies: !varDeployPolicies
    parDisableSlzDefaultPolicies: !varDeployPolicies
    parExcludedPolicyAssignments: varExcludedPolicyAssignments
    parTopLevelPolicyAssignmentSovereigntyGlobal: {
      parTopLevelSovereigntyGlobalPoliciesEnable: varDeploySlzBuiltInPolicies
      parListOfAllowedLocations: parAllowedLocations
      parPolicyEffect: parPolicyEffect
    }
    parPolicyAssignmentSovereigntyConfidential: {
      parAllowedResourceTypes: []
      parListOfAllowedLocations: parAllowedLocationsForConfidentialComputing
      parAllowedVirtualMachineSKUs: []
      parPolicyEffect: parPolicyEffect
    }
    parLandingZoneMgConfidentialEnable: varDeploySlzBuiltInPolicies
  }
}

// The following module is used to deploy the policy exemptions
module modPolicyExemptionsConfidentialOnline '../../modules/compliance/policyExemptions.bicep' = {
  scope: managementGroup(varPolicyExemptionConfidentialOnlineManagementGroup)
  name: take('${parDeploymentPrefix}-deploy-policy-exemptions${parDeploymentSuffix}', 64)
  params: {
    parPolicyAssignmentScopeName: varPolicyAssignmentScopeName
    parPolicyDefinitionReferenceIds: ['AllowedLocationsForResourceGroups', 'AllowedLocations']
    parPolicyAssignmentName: varSlzGlobalAssignmentName
    parExemptionName: 'Confidential-Online-Location-Exemption'
    parExemptionDisplayName: 'Confidential Online Location Exemption'
    parDescription: 'Exempt the confidential online management group from the SLZ Global Policies location policies. The confidential management groups have their own location restrictions and this may result in a conflict if both sets are included.'
  }
  dependsOn: [modAlzPolicyAssignments]
}

// The following module is used to deploy the policy exemptions
module modPolicyExemptionsConfidentialCorp '../../modules/compliance/policyExemptions.bicep' = {
  scope: managementGroup(varPolicyExemptionConfidentialCorpManagementGroup)
  name: take('${parDeploymentPrefix}-deploy-policy-exemptions${parDeploymentSuffix}', 64)
  params: {
    parPolicyAssignmentScopeName: varPolicyAssignmentScopeName
    parPolicyDefinitionReferenceIds: ['AllowedLocationsForResourceGroups', 'AllowedLocations']
    parPolicyAssignmentName: varSlzGlobalAssignmentName
    parExemptionName: 'Confidential-Corp-Location-Exemption'
    parExemptionDisplayName: 'Confidential Corp Location Exemption'
    parDescription: 'Exempt the confidential corp management group from the SLZ Global Policies location policies. The confidential management groups have their own location restrictions and this may result in a conflict if both sets are included.'
  }
  dependsOn: [modAlzPolicyAssignments]
}
