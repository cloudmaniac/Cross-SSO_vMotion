# Name: Cross-SSO_vMotion-between-vCenters.ps1
# Description: PowerCLI script to vMotion a running VM between two vCenters which are
#              not in the same SSO domain.
#              The script will use the GetPortGroupObject() function to determine the 
#              port group type (standard or distributed) and return the correct object.          
# Reference: http://cloudmaniac.net/using-powercli-to-vmotion-vm-between-different-sso-domains/
# Version: 1.0
# Author: Romain Decker <romain@cloudmaniac.net>
# January 2017

####################################################################################
# Variables
####################################################################################
# vCenter Source Details (SSO Domain A)
$SrcvCenter = 'vc01-dc-a.sddc.lab'
$SrcvCenterUserName = 'administrator@ssodomain-a.local'
$SrcvCenterPassword = 'VMware1!'

# vCenter Destination Details (SSO Domain B)
$DstvCenter = 'vc01-dc-b.sddc.lab'
$DstvCenterUserName = 'administrator@ssodomain-b.local'
$DstvCenterPassword = 'VMware1!'

# vMotion Details
$vmToMigrate = 'web01' # The VM Name to migrate
$DstDatastore = 'nfs01-dc-b' # The destination datastore
$DstCluster = 'Compute Cluster B' # The destination cluster
$DstPortGroup = 'DPortGroupB' # The port group or distributed port group.

####################################################################################
# Function GetPortGroupObject
function GetPortGroupObject {
    Param(
        [Parameter(Mandatory=$True)]
        [string]$PortGroup
    )

    if (Get-VDPortGroup -Name $DstPortGroup -ErrorAction SilentlyContinue) {
        return Get-VDPortGroup -Name $DstPortGroup
    }
    else {
        if (Get-VirtualPortGroup -Name $DstPortGroup -ErrorAction SilentlyContinue) {
            return Get-VirtualPortGroup -Name $DstPortGroup
        }
        else {
            Write-Host "The PorGroup '$DstPortGroup' doesn't exist in the destination vCenter"
            exit
        }
    }
}

function Drawline {
    for($i=0; $i -lt (get-host).ui.rawui.buffersize.width; $i++) {write-host -nonewline -foregroundcolor cyan "-"}
}

####################################################################################
# Connect to vCenter Servers
Connect-ViServer -Server $SrcvCenter -User $SrcvCenterUserName -Password $SrcvCenterPassword -WarningAction Ignore | out-null
write-Host -foregroundcolor Yellow "`nConnected to Source vCenter..."
Connect-ViServer -Server $DstvCenter -User $DstvCenterUserName -Password $DstvCenterPassword -WarningAction Ignore | out-null
write-Host -foregroundcolor Yellow "Connected to Destination vCenter..."

####################################################################################
# vMotion :)
$vm = Get-VM $vmToMigrate
$destination = Get-VMHost -Location $DstCluster | Select-Object -First 1
$networkAdapter = Get-NetworkAdapter -VM $vmToMigrate
$destinationPortGroup = GetPortGroupObject -PortGroup $DstPortGroup
$destinationDatastore = Get-Datastore $DstDatastore

$vm | Move-VM -Destination $destination -NetworkAdapter $networkAdapter -PortGroup $destinationPortGroup -Datastore $destinationDatastore | out-null

####################################################################################
# Display VM information after vMotion
write-host -foregroundcolor Cyan "`nVM is now running on:"
Drawline
Get-VM $vmToMigrate | Get-NetworkAdapter | Select-Object @{N="VM Name";E={$_.Parent.Name}},@{N="Cluster";E={Get-Cluster -VM $_.Parent}},@{N="ESXi Host";E={Get-VMHost -VM $_.Parent}},@{N="Datastore";E={Get-Datastore -VM $_.Parent}},@{N="Network";E={$_.NetworkName}} | Format-List

####################################################################################
# Disconnect
Disconnect-VIServer -Server * -Force -Confirm:$false