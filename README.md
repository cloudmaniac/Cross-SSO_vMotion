# Cross-SSO_vMotion

## Description
PowerCLI script to vMotion a running VM between two vCenters, even if they are not in the same SSO domain.
The script will use the GetPortGroupObject() function to determine the portgroup type (standard or distributed) and return the correct object.

For more information, you can refer to the [related blog post] (http://cloudmaniac.net/using-powercli-to-vmotion-vm-between-different-sso-domains-vcenters/) for more details.

## Requirements
* Windows system
* [PowerCLI 6.5 R1](https://my.vmware.com/group/vmware/details?downloadGroup=PCLI650R1&productId=568)
* vCenter Server 6.0 or 6.5
* ESXi 6.0

## Configuration

This section describes the credentials to your vCenter Servers (source and destination).

```console
# vCenter Source Details (SSO Domain A)
$SrcvCenter = 'vc01-dc-a.sddc.lab'
$SrcvCenterUserName = 'administrator@ssodomain-a.local'
$SrcvCenterPassword = 'VMware1!'

# vCenter Destination Details (SSO Domain B)
$DstvCenter = 'vc01-dc-b.sddc.lab'
$DstvCenterUserName = 'administrator@ssodomain-b.local'
$DstvCenterPassword = 'VMware1!'
```

This section describes the VM to migrate as well as the destination (datastore, cluster and port group). The destination port group can be a standard or a distributed port group.
The script will automatically check the type using the GetPortGroupObject() function and return the correct object.

```console
# vMotion Details
$vmToMigrate = 'web01'
$DstDatastore = 'nfs01-dc-b'
$DstCluster = 'Compute Cluster B'
$DstPortGroup = 'DPortGroupB'
```

Once you have configured the parameters to match your infrastructure, you can run the script to vMotion the Virtual Machine.

## Considerations
* This script will work only for VMs having a single NIC.