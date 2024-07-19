#!/usr/bin/env pwsh

# Function to ping a host
function Ping-Host {
    param (
        [string]$TargetHost
    )
    Test-Connection -ComputerName $TargetHost -Count 4
}

# Function to display ARP table
function Display-Arp-Table {
    arp -a
}

# Function to check open ports on a host
function Check-Ports {
    param (
        [string]$TargetHost,
        [int[]]$Ports
    )
    $tcpClients = @()
    foreach ($Port in $Ports) {
        try {
            $tcpClient = New-Object System.Net.Sockets.TcpClient($TargetHost, $Port)
            Write-Output "Connection to $TargetHost on port $Port succeeded"
            $tcpClients += $tcpClient
        } catch {
            Write-Output "Connection to $TargetHost on port $Port failed"
        }
    }
    return $tcpClients
}

# Function to close ports
function Close-Ports {
    param (
        [System.Collections.ArrayList]$TcpClients
    )
    foreach ($tcpClient in $TcpClients) {
        if ($tcpClient -and $tcpClient.Connected) {
            $tcpClient.Close()
            Write-Output "Closed connection on port $($tcpClient.Client.RemoteEndPoint.Port)"
        }
    }
}

# Function to traceroute to a host
function Traceroute-Host {
    param (
        [string]$TargetHost
    )
    tracert $TargetHost
}

# Function to perform DNS lookup
function DNS-Lookup {
    param (
        [string]$Domain
    )
    $dnsResult = [System.Net.Dns]::GetHostAddresses($Domain)
    foreach ($address in $dnsResult) {
        Write-Output "$Domain resolved to IP address: $($address.IPAddressToString)"
    }
}

# Function to perform WHOIS lookup
function WHOIS-Lookup {
    param (
        [string]$Domain
    )
    $whoisResult = (Invoke-WebRequest -Uri "https://www.whois.com/whois/$Domain").Content
    Write-Output $whoisResult
}

# Function to display network interface information
function Display-Interfaces {
    Get-NetIPConfiguration
}

# Function to display routing table
function Display-RoutingTable {
    Get-NetRoute
}

# Function to display the menu
function Show-Menu {
    Write-Output "Choose an option:"
    Write-Output "1) Ping a host"
    Write-Output "2) Check open ports on a host"
    Write-Output "3) Display ARP table"
    Write-Output "4) Traceroute to a host"
    Write-Output "5) Perform DNS Lookup"
    Write-Output "6) Perform WHOIS Lookup"
    Write-Output "7) Display network interface information"
    Write-Output "8) Display routing table"
    Write-Output "9) Exit"
}

# Main loop
while ($true) {
    Show-Menu
    $choice = Read-Host "Enter your choice (1-9)"
    switch ($choice) {
        1 {
            Write-Output "Example: example.com or 192.168.1.1"
            $TargetHost = Read-Host "Enter the host to ping"
            Ping-Host -TargetHost $TargetHost
        }
        2 {
            Write-Output "Enter the host to check ports on (e.g., example.com or 192.168.1.1)"
            $TargetHost = Read-Host "Enter the host to check ports on"
            $ports = Read-Host "Enter the ports to check (space-separated, e.g., 22 80)"
            $portsArray = $ports -split " " | ForEach-Object { [int]$_ }
            $tcpClients = Check-Ports -TargetHost $TargetHost -Ports $portsArray
            $closePorts = Read-Host "Do you want to close the ports? (y/n)"
            if ($closePorts -eq 'y') {
                Close-Ports -TcpClients $tcpClients
            }
        }
        3 {
            Write-Output "Displaying ARP Table..."
            Display-Arp-Table
        }
        4 {
            Write-Output "Example: example.com or 192.168.1.1"
            $TargetHost = Read-Host "Enter the host to traceroute"
            Traceroute-Host -TargetHost $TargetHost
        }
        5 {
            $Domain = Read-Host "Enter the domain to perform DNS lookup"
            DNS-Lookup -Domain $Domain
        }
        6 {
            $Domain = Read-Host "Enter the domain to perform WHOIS lookup"
            WHOIS-Lookup -Domain $Domain
        }
        7 {
            Display-Interfaces
        }
        8 {
            Display-RoutingTable
        }
        9 {
            Write-Output "Exiting..."
            break
        }
        default {
            Write-Output "Invalid option, please try again."
        }
    }
    Write-Output ""
}
