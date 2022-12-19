class ComputerMonitor {
    <#
        .DESCRIPTION
        The ComputerMonitor class retrieves network configuration information and certificate information for a list of computers, as well as storage information for each computer. It has a single constructor that takes an array of Active Directory computers as an argument, and three methods: Get-NetworkConfiguration, ReturnCertInfo, and Get-StorageInformation. The Get-NetworkConfiguration method returns a hashtable containing the network configuration information for the computers using the Get-NetworkConfiguration method of the HostInfo class. The ReturnCertInfo method returns a hashtable containing the certificate information for the computers using the Get-CertificateInformation method of the ComputerCertificateInformation class. The Get-StorageInformation method retrieves the storage information for each computer using the GetStorageInfo method of the StorageMonitoring class.
        .PROPERTY HostInfo
        A property that stores the HostInfo object for the class.
        .PROPERTY ADComputers
        A property that stores the array of Active Directory computers for the class.
        .PROPERTY ComputerCertificateInformation
        A property that stores the ComputerCertificateInformation object for the class.
        .PROPERTY StorageMonitoring
        A property that stores the StorageMonitoring object for the class.
    #>


    # Import the ActiveDirectory module
    Import-Module ActiveDirectory

    # Create a property to store the HostInfo object
    [HostInfo]$HostInfo

    # Create a property to store the AD computers
    [PSObject[]]$ADComputers

    # Create a property to store the StorageMonitoring object
    [StorageMonitoring]$StorageMonitoring

    # Create a default constructor that creates new HostInfo and StorageMonitoring objects with the list of computers passed in the ADComputers parameter
    [ComputerMonitor]
    ComputerMonitor([PSObject[]]$ADComputers) {
        $this.ADComputers = $ADComputers
        $this.HostInfo = [HostInfo]::new($this.ADComputers.Name)
        $this.ComputerCertificateInformation = [ComputerCertificateInformation]::new($this.AdComputers.Name)
        $this.StorageMonitoring = [StorageMonitoring]::new($this.AdComputers.Name)
    }

    # Create a function to retrieve the network configuration information for the computers
    function Get-NetworkConfiguration() {
        return $this.HostInfo.Get-NetworkConfiguration()
    }

    function ReturnCertInfo {
        # Return the certificate information for the computers being monitored
        return $this.ComputerCertificateInformation.Get-CertificateInformation()
    }

    function Get-StorageInformation {
        # Return the storage information for the computers being monitored
        return $this.StorageMonitoring.GetStorageInfo()
    }

     function Export-ADComputers() {
        return $this.ADComputers
    }
}
