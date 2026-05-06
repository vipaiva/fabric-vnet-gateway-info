# Fabric VNet Data Gateway Info

A PowerShell script to retrieve **Microsoft Fabric VNet Data Gateway** details and linked **Fabric Capacity** information via the Fabric REST API.

---

## 📌 Overview

This script automates the retrieval of:

- **VNet Data Gateway inventory**: name, ID, type, member count, sleep timeout
- **Virtual Network details**: VNet name, subnet, resource group, subscription
- **Linked Fabric Capacity**: display name, SKU, state, region
- **Estimated CU consumption**: calculated as `numberOfMemberGateways × 4 CUs`

---

## 🎯 Use Cases

- **Capacity planning**: understand which capacities back your VNet gateways
- **Cost visibility**: estimate CU consumption while gateways are active
- **Governance**: audit VNet gateway configuration across your tenant
- **Troubleshooting**: quickly surface gateway ↔ capacity relationships

---

## ⚙️ Prerequisites

### Required Tools
- [Azure CLI (`az`)](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) — for token acquisition
- PowerShell 5.1+ or PowerShell 7+ (`pwsh`)

### Required Permissions
- **Fabric Administrator** or **Capacity Administrator** — to list gateways and capacities
- Authenticated Azure CLI session (`az login`)

### Required APIs
| API | Endpoint |
|-----|----------|
| VNet Gateways | `https://api.fabric.microsoft.com/v1/gateways` |
| Fabric Capacities | `https://api.fabric.microsoft.com/v1/capacities` |

> **Note**: The Power BI REST API (`/v1.0/myorg/gateways`) does **not** return Fabric VNet Data Gateways. Use the Fabric REST API endpoints above.

---

## 🚀 Quick Start

### 1. Authenticate with Azure CLI
```powershell
az login
```

### 2. Clone this repository
```powershell
git clone https://github.com/vipaiva/fabric-vnet-gateway-info.git
cd fabric-vnet-gateway-info
```

### 3. Run the script
```powershell
.\fabric-vnet-gateway.ps1
```

### 4. (Optional) Export to CSV
Uncomment the last line in the script:
```powershell
$results | Export-Csv -Path "$env:USERPROFILE\fabric-vnet-gateways.csv" -NoTypeInformation
```

---

## 📝 Example Output

```
Gateway Name      : vnet-myorg-eastus2-VnetDataGateway
Gateway ID        : 10d56f42-8dd2-4325-bcb0-dee4eee6cdc2
Type              : VirtualNetwork
Member Gateways   : 1
Sleep After (min) : 30
VNet              : vnet-myorg-eastus2
Subnet            : VnetDataGateway
Resource Group    : myorg-rsgp-eastus
Subscription      : xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
Capacity Name     : myfabriccapacity
Capacity SKU      : F4
Capacity State    : Active
Capacity Region   : East US 2
CU Usage (active) : 4 CU(s)
```

---

## 💡 Understanding CU Consumption

Fabric VNet Data Gateways consume **Fabric Capacity Units (CUs)** when active:

| Scenario | CU Cost |
|----------|---------|
| 1 member gateway active | 4 CUs |
| 2 member gateways active | 8 CUs |
| Gateway sleeping (after inactivity) | 0 CUs |

- Billing starts on the **first query** routed through the gateway
- Gateway enters sleep mode after `inactivityMinutesBeforeSleep` (default: 30 min)
- Requires **F4 / P4 / A4 or higher** SKU

See: [Microsoft Fabric VNet Data Gateway billing](https://learn.microsoft.com/en-us/data-integration/vnet/overview)

---

## 🔐 Security Notes

- The script uses **Bearer token authentication** — token is obtained via Azure CLI and held in memory only
- No credentials or tokens are written to disk
- Token scope: `https://api.fabric.microsoft.com` (read-only REST calls)
- All API calls are **GET** — no data is modified

---

## 🐛 Troubleshooting

### Error: `Failed to get access token`
**Cause**: Azure CLI is not logged in  
**Solution**: Run `az login` and ensure you have access to the target tenant

### Output is empty / `No VNet Data Gateways found`
**Cause**: No VNet Data Gateways provisioned, or insufficient permissions  
**Solution**: Verify Fabric Admin role; confirm gateways exist in the Fabric portal under **Settings > Manage connections and gateways**

### `Invoke-RestMethod` returns 403
**Cause**: Token scope mismatch or insufficient Fabric role  
**Solution**: Ensure `--resource "https://api.fabric.microsoft.com"` is specified in the `az` command

### Capacity fields are empty (`$null`)
**Cause**: Gateway's `capacityId` does not match any returned capacity  
**Solution**: Verify the gateway is assigned to a capacity in the Fabric portal

---

## 🤝 Contributing

This is an **educational project**. Contributions are welcome!

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/my-improvement`)
3. Test in a non-production environment
4. Submit a pull request with a clear description

**Guidelines**:
- Do not include real tenant IDs, subscription IDs, or credentials in commits
- Keep the script dependency-free (Azure CLI + PowerShell only)

---

## ⚖️ License

**MIT License** — Copyright (c) 2026 Vivian Paiva

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.

---

## ⚠️ Disclaimer

This script is provided for **EDUCATIONAL PURPOSES ONLY**. It is NOT an official Microsoft product or endorsed solution.

**Important**:
- Review and test in a non-production environment before use
- The author assumes no responsibility for any unintended consequences
- This script performs **read-only** API operations — no data is modified or deleted
- Ensure you understand the permission implications before running in your tenant

**Use at your own risk.**

---

## 📞 Support

For questions, issues, or feature requests, open an issue on GitHub:  
https://github.com/vipaiva/fabric-vnet-gateway-info/issues

---

**Last Updated**: May 6, 2026  
**Version**: 1.0  
**Author**: Vivian Paiva
