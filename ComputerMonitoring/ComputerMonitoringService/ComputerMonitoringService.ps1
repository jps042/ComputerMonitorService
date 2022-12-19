class ComputerMonitorService {

<#
    .DESCRIPTION
    The ComputerMonitorService class monitors a list of computers and retrieves network configuration, certificate, and storage information for them. It has a single constructor that gets the list of computers using the Get-ADComputer cmdlet, and two methods: MonitorComputers and Export-Results. The MonitorComputers method divides the list of computers into batches and creates an instance of the ComputerMonitor class for each batch. It then calls the Get-NetworkConfiguration, ReturnCertInfo, and Get-StorageInformation methods of the ComputerMonitor class to retrieve the network configuration, certificate, and storage information for the computers. The results are combined into a single object and returned to the caller. The Export-Results method calls the MonitorComputers method to get the results and then exports them to an Excel spreadsheet at the specified path.
    .PROPERTY Computers
    A property that stores the array of Active Directory computers for the class.
    .SYNOPSIS
    Monitors a list of computers and retrieves network configuration, certificate, and storage information for them.
    .PARAMETER ChunkSize
    The number of computers to include in each batch. The default value is 1000.
    .PARAMETER MaxJobs
    The maximum number of background jobs to run simultaneously. The default value is 5.
    .EXAMPLE
    $monitorService = [ComputerMonitorService]::new()
    $results = $monitorService.MonitorComputers()
    $monitorService.Export-Results('C:\results.csv')
#>



    # Import the ActiveDirectory and Microsoft.PowerShell.Utility modules
    Import-Module ActiveDirectory, Microsoft.PowerShell.Utility

    # Create a property to store the AD computers
    [PSObject[]]$Computers

    # Create a default constructor that gets the AD computers using Get-ADComputer
    [ComputerMonitorService]
    ComputerMonitorService() {
        $this.Computers = Get-ADComputer -Filter *
    }

    
    # Create a function to monitor the computers in batches
function MonitorComputers([int]$ChunkSize = 1000, [int]$MaxJobs = 5) {
    # Get the list of computers from Get-ADComputer
    $computers = Get-ADComputer -Filter * | Select-Object -Property Name

    # Divide the list of computers into batches
    $batches = $computers | Partition-Object -Property Name -ChunkSize $ChunkSize

    # Create an array to store the results
    $results = @()

    # Iterate over each batch and run the ComputerMonitor object as a background job
    $batches | ForEach-Object -ThrottleLimit $MaxJobs -Parallel {
        $batchResults = & {
            # Create a new instance of the ComputerMonitor class for each computer in the batch
            $monitor = [ComputerMonitor]::new($_)

            # Call the Get-NetworkConfiguration function to get the network configuration information for the computers
            $networkConfiguration = $monitor.Get-NetworkConfiguration()

            # Call the ReturnCertInfo function to get the certificate information for the computers
            $certificateInformation = $monitor.ReturnCertInfo()

            # Call the Export-ADComputers function to get the Active Directory computers for the batch
            $adComputers = $monitor.Export-ADComputers()

            # Combine the network configuration, certificate information, and Active Directory computers into a single object
    $combinedResults = New-Object -TypeName PSObject -Property @{
        NetworkConfiguration = $networkConfiguration
        CertificateInformation = $certificateInformation
        ADComputers = $adComputers
    }

    # Return the combined results
    return $combinedResults
    }

    # Wait for all background jobs to complete
    Wait-Job -State Running | Out-Null

    # Collect the results of all background jobs
    $results += Receive-Job

    # Clean up the background jobs
    Remove-Job -State Completed
    }

    # Return the combined results for all batches
    return $results
}


    # Create a function to export the results to an Excel spreadsheet
function Export-Results([string]$Path) {
    # Call the MonitorComputers function to get the results
    $results = $this.MonitorComputers()

    # Get the properties of the first result object
    $properties = $results[0].psobject.properties | Select-Object -Property Name

    # Create an array to store the headers
    $headers = @()

    # Iterate over the properties and add them to the headers array
    foreach ($property in $properties) {
        $headers += $property.Name
    }

    # Create an array to store the rows
    $rows = @()

    # Iterate over the results and create an array of values for each row
    foreach ($result in $results) {
        $row = @()
        foreach ($header in $headers) {
            $row += $result.$header
        }
        $rows += $row
    }

    # Export the results to the specified path
    $results | Export-Csv -Path $Path -NoTypeInformation -Header $headers -InputObject $rows
}

}
