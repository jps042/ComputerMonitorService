# ComputerMonitorService
Computer Monitor Service

class StorageMonitoring
{
    <#
        .DESCRIPTION
        The StorageMonitoring class retrieves storage information for a list of hosts. It has a single constructor that takes an array of host names as a parameter, and a single method: GetStorageInfo. The GetStorageInfo method retrieves the storage information for each host using the Win32_LogicalDisk WMI class, and returns the results as a hashtable.
        .SYNOPSIS
        Retrieves storage information for a list of hosts.
        .PARAMETER Hosts
        An array of host names to retrieve storage information for.
        .EXAMPLE
        $storageMonitor = [StorageMonitoring]::new('host1', 'host2')
        $storageInfo = $storageMonitor.GetStorageInfo()
    #>
    
    [string[]]$Hosts

    StorageMonitoring([string[]]$Hosts)
    {
        $this.Hosts = $Hosts
    }

    function GetStorageInfo()
    {
        $storageInfo = @{}
        foreach ($host in $this.Hosts)
        {
            $storageInfo[$host] = Get-WmiObject -Class Win32_LogicalDisk -ComputerName $host |
                Select-Object DeviceID, @{Name='Size';Expression={[math]::Round(($_.Size/1GB),2)}}, @{Name='FreeSpace';Expression={[math]::Round(($_.FreeSpace/1GB),2)}}, @{Name='FileSystem';Expression={$_.FileSystem}}, @{Name='VolumeName';Expression={$_.VolumeName}}, @{Name='VolumeSerialNumber';Expression={$_.VolumeSerialNumber}}
        }
        return $storageInfo
    }
}
