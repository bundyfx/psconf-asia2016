break


## Nano Server
mkdir C:\psconf\nano -ea 4
git clone https://github.com/bundyfx/nano-ps-conf.git C:\psconf\nano -q


#mount iso
$start = (gdr).root
ls C:\Users\*\downloads\*14393*.iso -OutVariable iso -ea 4
Mount-DiskImage $iso.FullName

#get path -  packages
((compare (gdr).root $start).InputObject) + 'NanoServer' | tee -var media |  cp -dest C:\psconf\nano -Recurse -PassThru -OutVariable source -Force

#import module
ipmo $source.Where{$Psitem.Name -clike '*.psm1'}.Fullname -Verbose


#time to bake our image
$params = @{
    DeploymentType        = 'Guest'
    Edition               = 'Standard'
    MediaPath             = ($media|sls '^[A-Z]:\\').Matches.Value
    BasePath              = ($source.FullName[0]|sls '^[A-Z]:\\.*\\').Matches.Value
    TargetPath            = (Join-path ($source.FullName[0]|sls '^[A-Z]:\\.*\\').Matches.Value -ChildPath '\nanoServer.vhd')
    Computername          = (Get-Random) 
    InterfaceNameOrIndex  = 'Ethernet'
    AdministratorPassword = 'P@ssword!1' | ConvertTo-SecureString -AsPlainText -Force
    Package               = $source.Where{$Psitem.Name -clike '*DSC*.cab'}[0].Basename
    Verbose               = $true
    IPv4DNS               = '192.168.137.1'
    CopyPath              = 'C:\django\myapp',"$env:LOCALAPPDATA\Programs\Python",'C:\psconf\nano\scripts\djangobootstrap.ps1'
    SetupCompleteCommand  = 'powershell.exe -file C:\djangobootstrap.ps1'
}


$time = Measure-Command { New-NanoServerImage  @params}
'Completed creating Nano Server image in {0} Minutes and {1} Seconds' -f $time.Minutes, $time.Seconds


New-VM -Name (Get-Random | tee -var vmname) `
       -Generation 1 `
       -SwitchName (Get-VMSwitch).Where{$Psitem.Name -eq 'Internal'}.Name `
       -VHDPath (Join-path ($source.FullName[0]|sls '^[A-Z]:\\.*\\').Matches.Value -ChildPath '\nanoServer.vhd') `
       -MemoryStartupBytes (2GB)

Set-VM $vmname -StaticMemory -Passthru  | Start-VM

$creds = [pscredential]::new('~\administrator',(ConvertTo-SecureString -String 'P@ssword!1' -AsPlainText -Force))

Enter-PSSession -VMName $vmname -Credential $creds
    
    gip 
    #Show application
    Get-CimInstance -class Win32_operatingsystem | select Name

    #packages? We're like Linux now!
    Find-PackageProvider nuget | Install-packageprovider -ForceBootstrap -Force
    Find-Package awspowershell.NetCore | Install-Package -verbose -ForceBootstrap -Force

    exit


#Configuration management
$params.Remove('CopyFile')
$params.Remove('SetupCompleteCommand')
$params.Remove('TargetPath')
$params.Remove('Computername')
[Array]$params.Package += $source.Where{$Psitem.Name -clike '*IIS*.cab'}[0].Basename

#computernames
[Array]$cn += 0..1 |%{Get-Random}

$time = Measure-command { 0..1 | % {New-NanoServerImage @params -ComputerName $cn[$Psitem] -TargetPath C:\psconf\nano\nanoServer$Psitem.vhd} }
'Completed creating 2 Nano Server images in {0} Minutes and {1} Seconds' -f $time.Minutes, $time.Seconds

## https://portal.azure.com

Configuration NanoDev {

Import-DSCResource -ModuleName 'PSDesiredStateConfiguration'

    node localhost
    {
        File logsDirectory
        {
            DestinationPath = 'C:\Logs'
            Type            = 'Directory'
            Ensure          = 'Present' 
        }
        Service bitsStop
        {
            DependsOn = '[File]logsDirectory'
            Name      = 'bits'
            State     = 'Stopped'
            Ensure    = 'Present'        
        }    
    }
}
NanoDev -outputpath C:\psconf\nano\

Dismount-DiskImage $iso.FullName

0..1 | % {New-VM -Name $cn[$Psitem] `
       -Generation 1 `
       -SwitchName (Get-VMSwitch).Where{$Psitem.Name -eq 'Internal'}.Name `
       -VHDPath (Join-path ($source.FullName[0]|sls '^[A-Z]:\\.*\\').Matches.Value -ChildPath "\nanoServer$Psitem.vhd") `
       -MemoryStartupBytes (1GB) } | Start-VM

Enable-VMIntegrationService -Name 'Guest Service Interface' -VMName ((Get-VM).Where{$Psitem.State -eq 'Running'} | 
                                                            sort UpTime -Descending | 
                                                            select -Last 2 | 
                                                            tee -Variable newnano).Name

#Powershell Direct
Copy-VMFile -VMName $newnano.Name -SourcePath C:\psconf\nano\localhost.mof -DestinationPath C:\localhost.mof -FileSource Host -Verbose -Force

$newnano.name | % { Invoke-command -VMName $PSItem {Start-DscConfiguration -Path C:\ -Verbose -Wait} -Credential $creds }


#IIS Restart demo

$ips = $newnano.name | % { Invoke-command -VMName $PSItem {(gip).Ipv4Address.IPAddress} -Credential $creds } 
$ips| % { start microsoft-edge:http://$Psitem }

curl 'https://msdnshared.blob.core.windows.net/media/MSDNBlogsFS/prod.evol.blogs.msdn.com/CommunityServer.Components.PostAttachments/00/02/28/75/22/PowerShellLicensePlate.jpg' -UseBasicParsing -OutFile C:\psconf\nano\snover.jpg
Copy-VMFile -VMName $newnano.Name -SourcePath C:\psconf\nano\snover.jpg -DestinationPath C:\inetpub\wwwroot\iisstart.png -FileSource Host -Verbose -Force

#restart
(Get-VM).Where{$Psitem.State -eq 'Running'} | sort UpTime -Descending | select -Last 2 | Restart-VM -Force 



#App-X CMdlets
Invoke-command -VMName $newnano.name[0] {(Get-Command).Where{$PSitem.Source -eq 'Appx'}} -Credential $creds

#emergency console

#Back to slides
