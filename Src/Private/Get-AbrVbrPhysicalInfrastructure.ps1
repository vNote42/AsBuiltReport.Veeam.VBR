
function Get-AbrVbrPhysicalInfrastructure {
    <#
    .SYNOPSIS
    Used by As Built Report to retrieve Veeam Physical Infrastructure inventory
    .DESCRIPTION
        Documents the configuration of Veeam VBR in Word/HTML/Text formats using PScribo.
    .NOTES
        Version:        0.3.1
        Author:         Jonathan Colon
        Twitter:        @jcolonfzenpr
        Github:         rebelinux
        Credits:        Iain Brighton (@iainbrighton) - PScribo module

    .LINK
        https://github.com/AsBuiltReport/AsBuiltReport.Veeam.VBR
    #>
    [CmdletBinding()]
    param (

    )

    begin {
        Write-PscriboMessage "Discovering Veeam VBR Physical Infrastructure inventory from $System."
    }

    process {
        try {
            if (Get-VBRInstalledLicense | Where-Object {$_.Status -ne "Expired"}) {
                if ((Get-VBRProtectionGroup).count -gt 0) {
                    Section -Style Heading3 'Physical Infrastructure' {
                        Paragraph "The following sections detail configuration information of the managed physical infrastructure backed-up by Veeam Server $(((Get-VBRServerSession).Server))."
                        BlankLine
                        if ((Get-VBRServerSession).Server) {
                            try {
                                Section -Style Heading4 'Protection Groups Summary' {
                                    Paragraph "The following table summarizes the physical backup protections managed by Veeam Server $(((Get-VBRServerSession).Server))."
                                    BlankLine
                                    $OutObj = @()
                                    $InventObjs = Get-VBRProtectionGroup
                                    foreach ($InventObj in $InventObjs) {
                                        try {
                                            Write-PscriboMessage "Discovered $($InventObj.Name) Protection Group."
                                            $inObj = [ordered] @{
                                                'Name' = $InventObj.Name
                                                'Type' = $InventObj.Type
                                                'Container' = $InventObj.Container
                                                'Schedule' = $InventObj.ScheduleOptions
                                                'Enabled' = ConvertTo-TextYN $InventObj.Enabled
                                            }

                                            $OutObj += [pscustomobject]$inobj
                                        }
                                        catch {
                                            Write-PscriboMessage -IsWarning $_.Exception.Message
                                        }
                                    }

                                    $TableParams = @{
                                        Name = "Protection Groups - $(((Get-VBRServerSession).Server).ToString().ToUpper().Split(".")[0])"
                                        List = $false
                                        ColumnWidths = 23, 23, 23, 16, 15
                                    }

                                    if ($Report.ShowTableCaptions) {
                                        $TableParams['Caption'] = "- $($TableParams.Name)"
                                    }
                                    $OutObj | Table @TableParams
                                    #---------------------------------------------------------------------------------------------#
                                    #                            Protection Groups Detailed Section                               #
                                    #---------------------------------------------------------------------------------------------#
                                    if ($InfoLevel.Inventory.PHY -ge 2) {
                                        try {
                                            $OutObj = @()
                                            $InventObjs = Get-VBRProtectionGroup
                                            if (($InventObjs).count -gt 0) {
                                                Section -Style Heading4 "Per Protection Group Configuration" {
                                                    foreach ($InventObj in $InventObjs) {
                                                        try {
                                                            if ($InventObj.Type -eq 'Custom' -and $InventObj.Container.Type -eq 'ActiveDirectory') {
                                                                try {
                                                                    Section -Style Heading5 "$($InventObj.Name)" {
                                                                        Write-PscriboMessage "Discovered $($InventObj.Name) Protection Group Setting."
                                                                        $inObj = [ordered] @{
                                                                            'Name' = $InventObj.Name
                                                                            'Domain' = ($InventObj).Container.Domain
                                                                            'Backup Objects' =  $InventObj.Container.Entity | ForEach-Object {"Name: $(($_).Name)`r`nType: $(($_).Type)`r`nDistinguished Name: $(($_).DistinguishedName)`r`n"}
                                                                            'Exclude VM' = ConvertTo-TextYN ($InventObj).Container.ExcludeVMs
                                                                            'Exclude Computers' = ConvertTo-TextYN ($InventObj).Container.ExcludeComputers
                                                                            'Exclude Offline Computers' = ConvertTo-TextYN ($InventObj).Container.ExcludeOfflineComputers
                                                                            'Excluded Entity' = ($InventObj).Container.ExcludedEntity -join ", "
                                                                            'Master Credentials' = ($InventObj).Container.MasterCredentials
                                                                            'Deployment Options' = "Install Agent: $(ConvertTo-TextYN $InventObj.DeploymentOptions.InstallAgent)`r`nUpgrade Automatically: $(ConvertTo-TextYN $InventObj.DeploymentOptions.UpgradeAutomatically)`r`nInstall Driver: $(ConvertTo-TextYN $InventObj.DeploymentOptions.InstallDriver)`r`nReboot If Required: $(ConvertTo-TextYN $InventObj.DeploymentOptions.RebootIfRequired)"
                                                                        }
                                                                        if (($InventObj.NotificationOptions.EnableAdditionalNotification) -like 'True') {
                                                                            $inObj.add('Notification Options', ("Send Time: $($InventObj.NotificationOptions.SendTime)`r`nAdditional Address: [$($InventObj.NotificationOptions.AdditionalAddress)]`r`nUse Notification Options: $(ConvertTo-TextYN $InventObj.NotificationOptions.UseNotificationOptions)`r`nSubject: $($InventObj.NotificationOptions.NotificationSubject)"))
                                                                        }

                                                                        $OutObj += [pscustomobject]$inobj

                                                                        $TableParams = @{
                                                                            Name = "Protection Group Configuration - $($InventObj.Name)"
                                                                            List = $true
                                                                            ColumnWidths = 40, 60
                                                                        }

                                                                        if ($Report.ShowTableCaptions) {
                                                                            $TableParams['Caption'] = "- $($TableParams.Name)"
                                                                        }
                                                                        $OutObj | Table @TableParams
                                                                    }
                                                                }
                                                                catch {
                                                                    Write-PscriboMessage -IsWarning $_.Exception.Message
                                                                }
                                                            }
                                                            elseif ($InventObj.Type -eq 'ManuallyAdded' -and $InventObj.Container.Type -eq 'IndividualComputers') {
                                                                try {
                                                                    Section -Style Heading5 "$($InventObj.Name)" {
                                                                        Write-PscriboMessage "Discovered $($InventObj.Name) Protection Group Setting."
                                                                        $inObj = [ordered] @{
                                                                            'Name' = $InventObj.Name
                                                                            'Deployment Options' = "Install Agent: $(ConvertTo-TextYN $InventObj.DeploymentOptions.InstallAgent)`r`nUpgrade Automatically: $(ConvertTo-TextYN $InventObj.DeploymentOptions.UpgradeAutomatically)`r`nInstall Driver: $(ConvertTo-TextYN $InventObj.DeploymentOptions.InstallDriver)`r`nReboot If Required: $(ConvertTo-TextYN $InventObj.DeploymentOptions.RebootIfRequired)"
                                                                        }
                                                                        if (($InventObj.NotificationOptions.EnableAdditionalNotification) -like 'True') {
                                                                            $inObj.add('Notification Options', ("Send Time: $($InventObj.NotificationOptions.SendTime)`r`nAdditional Address: [$($InventObj.NotificationOptions.AdditionalAddress)]`r`nUse Notification Options: $(ConvertTo-TextYN $InventObj.NotificationOptions.UseNotificationOptions)`r`nSubject: $($InventObj.NotificationOptions.NotificationSubject)"))
                                                                        }

                                                                        $OutObj += [pscustomobject]$inobj

                                                                        $TableParams = @{
                                                                            Name = "Protection Group Configuration - $($InventObj.Name)"
                                                                            List = $true
                                                                            ColumnWidths = 40, 60
                                                                        }

                                                                        if ($Report.ShowTableCaptions) {
                                                                            $TableParams['Caption'] = "- $($TableParams.Name)"
                                                                        }
                                                                        $OutObj | Table @TableParams
                                                                    }
                                                                }
                                                                catch {
                                                                    Write-PscriboMessage -IsWarning $_.Exception.Message
                                                                }
                                                            }
                                                        }
                                                        catch {
                                                            Write-PscriboMessage -IsWarning $_.Exception.Message
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        catch {
                                            Write-PscriboMessage -IsWarning $_.Exception.Message
                                        }
                                    }
                                }
                            }
                            catch {
                                Write-PscriboMessage -IsWarning $_.Exception.Message
                            }
                        }

                    }
                }
            }
        }
        catch {
            Write-PscriboMessage -IsWarning $_.Exception.Message
        }
    }
    end {}

}