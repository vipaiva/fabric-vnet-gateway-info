# ============================================================
# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Vivian Paiva
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use,
# copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following
# conditions: The above copyright notice and this permission
# notice shall be included in all copies or substantial portions
# of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.
#
# DISCLAIMER: This script is intended for educational purposes
# only. It is provided as a learning reference for interacting
# with the Microsoft Fabric REST API. Use in production
# environments at your own risk.
# ============================================================
# Fabric VNet Data Gateway — Info & Capacity
# Requires: Azure CLI (az) logged in
# ============================================================

# 1. Acquire access token for Fabric API
$token = az account get-access-token --resource "https://api.fabric.microsoft.com" --query accessToken -o tsv
if (-not $token) { throw "Failed to get access token. Run: az login" }

$headers = @{ Authorization = "Bearer $token"; "Content-Type" = "application/json" }

# 2. Get all VNet Data Gateways
$gateways = (Invoke-RestMethod -Uri "https://api.fabric.microsoft.com/v1/gateways" -Headers $headers -Method GET).value

# 3. Get all Fabric Capacities (keyed by ID for fast lookup)
$capacities = @{}
(Invoke-RestMethod -Uri "https://api.fabric.microsoft.com/v1/capacities" -Headers $headers -Method GET).value |
    ForEach-Object { $capacities[$_.id] = $_ }

# 4. Combine and display
if ($gateways.Count -eq 0) {
    Write-Warning "No VNet Data Gateways found in this tenant."
} else {
    $results = $gateways | ForEach-Object {
        $cap  = $capacities[$_.capacityId]
        $vnet = $_.virtualNetworkAzureResource
        [PSCustomObject]@{
            "Gateway Name"       = $_.displayName
            "Gateway ID"         = $_.id
            "Type"               = $_.type
            "Member Gateways"    = $_.numberOfMemberGateways
            "Sleep After (min)"  = $_.inactivityMinutesBeforeSleep
            "VNet"               = $vnet.virtualNetworkName
            "Subnet"             = $vnet.subnetName
            "Resource Group"     = $vnet.resourceGroupName
            "Subscription"       = $vnet.subscriptionId
            "Capacity Name"      = $cap.displayName
            "Capacity SKU"       = $cap.sku
            "Capacity State"     = $cap.state
            "Capacity Region"    = $cap.region
            "CU Usage (active)"  = "$($_.numberOfMemberGateways * 4) CU(s)"
        }
    }

    $results | Format-List

    # Optional: export to CSV
    # $results | Export-Csv -Path "$env:USERPROFILE\fabric-vnet-gateways.csv" -NoTypeInformation
}
