# ComputerMonitorService
Computer Monitor Service

class HostInfo {

<#
.SYNOPSIS
Gets network configuration information for a computer.

.DESCRIPTION
The HostInfo class allows you to retrieve network configuration information for a computer. It includes the IP address, default gateway, DNS domain, and DNS server for each network adapter on the computer.

.PARAMETER ComputerNames
An array of computer names to retrieve the network configuration for.

.EXAMPLE
$hostInfo = [HostInfo]::new(@("localhost", "server01", "server02"))
$networkConfig = $hostInfo.Get-NetworkConfiguration()

Retrieves the network configuration for the local computer and the servers "server01" and "server02".

.NOTES
This class requires the WMI cmdlets to be available on the system.
#>

    [string[]]$ComputerNames

    [HostInfo]
    HostInfo([string[]]$ComputerNames) {
        $this.ComputerNames = $ComputerNames
    }

    function Get-NetworkConfiguration {
        # Use Get-WmiObject to retrieve the network configuration information for the computer
        $networkInfo = Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Property IPAddress, DefaultIPGateway, DNSDomain, DNSServerSearchOrder

        # Create a hashtable to store the results
        $result = @{}

        # Iterate over each network adapter and add the information to the results
        foreach ($adapter in $networkInfo) {
            $result.InterfaceAlias = $adapter.SettingID
            $result.IPAddress = $adapter.IPAddress[0]
            $result.DefaultGateway = $adapter.DefaultIPGateway[0]
            $result.DNSDomain = $adapter.DNSDomain
            $result.DNSServer = $adapter.DNSServerSearchOrder[0]
        }

        # Return the results
        return $result
    }
}
