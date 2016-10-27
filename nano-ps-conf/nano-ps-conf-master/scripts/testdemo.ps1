#requires -RunasAdministrator
Describe IsMyDemoGoingToWork {

    It 'C:\django should not exist' {
        Test-Path C:\django | Should be $true
    }
    It 'C:\psconf\nano should not exist' {
        Test-Path C:\psconf\nano | Should be $false
    }
    It 'Should have internet connection' {
        (tnc).PingSucceeded | should be $true
    }
    It '2016 Iso should be available' {
        ls C:\Users\*\downloads\*14393*.iso -OutVariable iso -ea 4
        $iso.name | Should be '14393.0.160715-1616.RS1_RELEASE_SERVER_EVAL_X64FRE_EN-US.ISO'
    }
    It 'Should have a vmswitch called Internal'{
        (Get-VMSwitch -Name Internal).SwitchType | Should be 'Internal'  #external if on PC
    }
    It 'Python is installed and in local app data'{
        Test-Path $env:LOCALAPPDATA\Programs\Python\ | Should be $true
    }
    It 'Wifi should be connected and functional'{
        (Get-NetAdapter -Name Wi-Fi).Status  | Should be 'Up'
    }
    It 'Wifi should be functional (Sent Bytes)'{
        (Get-NetAdapterStatistics -Name Wi-Fi).SentBytes  | Should not be 0
    }   
    It 'Wifi should be functional (Received Bytes)'{
        (Get-NetAdapterStatistics -Name Wi-Fi).ReceivedBytes | Should not be 0
    }
    It 'Should return a Null for Ipv4 Address for DNS Server '{
        ((gip -InterfaceAlias 'vEthernet (Internal)').DNSSERVER | Select -Last 1).ServerAddresses[0] | Should be $null
        } 
    It 'Should return a Ipv4 address - Valid '{
        (gip -InterfaceAlias 'vEthernet (Internal)').IPv4address.Ipaddress | Should be '192.168.137.1'              
    }
    It 'Should have IPv6 disabled on internal switch' {
        (Get-NetAdapterBinding -InterfaceAlias 'vEthernet (Internal)').Where{$Psitem.ComponentID -eq 'ms_tcpip6'}.Enabled | Should be $False
    }
}
