# Cross-SSO_vMotion

> Edit (December 21st, 2020): I created this script a while ago for my specific need. However, a lot happened since 2016! In the meantime:

> * The [Cross vCenter Workload Migration Utility Fling](https://flings.vmware.com/cross-vcenter-workload-migration-utility) was released in 2018.
> * This Fling has been productized and is now part of the vSphere 7.0 Update 1c (Patch 02) release. For vSphere 6.x-to-6.x Migration, the Fling can still be used but for newer migrations, it is recommended that you use the official Advanced Cross vCenter vMotion feature included in vSphere 7.0 Update 1c.

> You will find more information on [William's blog post](https://www.virtuallyghetto.com/2020/12/history-of-cross-vcenter-workload-migration-utility-and-its-productization-in-vsphere-7-0-update-1c-p02.html).

## Description

PowerCLI script to vMotion a running VM between two vCenters, even if they are not in the same SSO domain.
The script will use the GetPortGroupObject() function to determine the portgroup type (standard or distributed) and return the correct object.

You can refer to the [related blog post](http://cloudmaniac.net/using-powercli-to-vmotion-vm-between-different-sso-domains-vcenters/) for more details.

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
* This script work only for VMs having a single NIC.
