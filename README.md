# ComputerMonitorService
Computer Monitor Service

class HostServiceMonitor
{
    <#
        .DESCRIPTION
        The HostServiceMonitor class retrieves information about running services on a host. It has a single constructor that takes a host name as a parameter, and a single method: GetRunningServices. The GetRunningServices method retrieves the list of running services on the host using the Win32_Service WMI class, and returns the results as an array of objects.
        .SYNOPSIS
        Retrieves information about running services on a host.
        .PARAMETER Host
        The host name to retrieve information about running services for.
        .EXAMPLE
        $serviceMonitor = [HostServiceMonitor]::new('host1')
        $runningServices = $serviceMonitor.GetRunningServices()
    #>
    [string]$Host

    HostServiceMonitor([string]$Host)
    {
        $this.Host = $Host
    }

    function GetRunningServices()
    {
        return Get-WmiObject -Class Win32_Service -ComputerName $this.Host |
            Where-Object { $_.State -eq 'Running' } |
            Select-Object DisplayName, Name, StartMode, Status
    }
}
