# Set file path, filename, date and time
# This is my standard path, you should adjust as needed
$filepath = "C:\PowerCLI\Output\"
$filename = "vm-info"
$initalTime = Get-Date
$date = Get-Date ($initalTime) -uformat %Y%m%d
$time = Get-Date ($initalTime) -uformat %H%M


Write-Host "Update the serverlist.txt before running this" -ForegroundColor Blue


Write-Host "---------------------------------------------------------" -ForegroundColor DarkYellow
Write-Host "Output will be saved to:"  								   -ForegroundColor Yellow
Write-Host $filepath$filename-$date$time".csv"  					   -ForegroundColor White
Write-Host "---------------------------------------------------------" -ForegroundColor DarkYellow

# Create empty results array to hold values
$resultsarray =@()

#$vmlist = Get-Content serverlist.txt
#$vms = Get-Vm "$vmlist"



$vms = Get-Content serverlist.txt | foreach { Get-VM $_ }



# Iterates each vm in the $vms variable
foreach ($vm in $vms){ 
	          
        write-output "Collecting info for: $($vm.Name)"
					
		# Create an array object to hold results, and add data as attributes using the add-member commandlet
		$resultObject = new-object PSObject
        $resultObject | add-member -membertype NoteProperty -name "Folder" -Value $vm.Folder.Name
		$resultObject | add-member -membertype NoteProperty -name "Host" -Value $vm.VMHost
		$resultObject | add-member -membertype NoteProperty -name "Name" -Value $vm.Name
		$resultObject | add-member -membertype NoteProperty -name "PowerState" -Value $vm.PowerState
		$resultObject | add-member -membertype NoteProperty -name "NumCpus" -Value $vm.NumCpu
		$resultObject | add-member -membertype NoteProperty -name "CPU Limit" -Value $vm.ExtensionData.Config.CpuAllocation.Limit
		$resultObject | add-member -membertype NoteProperty -name "CPU Shares" -Value $vm.ExtensionData.Config.CpuAllocation.Shares.shares
		$resultObject | add-member -membertype NoteProperty -name "MemGB" -Value $vm.MemoryGB
		$resultObject | add-member -membertype NoteProperty -name "Version" -Value $vm.ExtensionData.Config.version
		$resultObject | add-member -membertype NoteProperty -name "Tools" -Value $vm.ExtensionData.Config.Tools.ToolsVersion
		$resultObject | add-member -membertype NoteProperty -name "Guest OS" -Value $vm.ExtensionData.Config.GuestFullName
		$resultObject | add-member -membertype NoteProperty -name "Datastore" -Value $vm.ExtensionData.Config.DatastoreUrl.Name
		$UsedSpace  = $vm.UsedSpaceGB -as [int]
		$resultObject | add-member -membertype NoteProperty -name "Used Disk" -Value $UsedSpace
		$ProvisionedSpace  = $vm.ProvisionedSpaceGB -as [int]
		$resultObject | add-member -membertype NoteProperty -name "Provisioned Space" -Value $ProvisionedSpace
		#Removed following line that collect rdm mode because it slows the script down
		#$resultObject | add-member -membertype NoteProperty -name "RDM Disk Type" -Value (get-vm -Name $vm).ExtensionData.Config.Hardware.Device.Backing.CompatibilityMode
	
		# Write array output to results 
		$resultsarray += $resultObject						            
	   	
}
	


# output to gridview
$resultsarray | Out-GridView


# export to csv 
$resultsarray | Export-Csv $filepath$filename"-"$datacenter$cluster"-"$date$time".csv" -NoType
