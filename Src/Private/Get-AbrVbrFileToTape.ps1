
function Get-AbrVbrFileToTape {
    <#
    .SYNOPSIS
        Used by As Built Report to returns tape backup jobs configuration created in Veeam Backup & Replication.
    .DESCRIPTION
        Documents the configuration of Veeam VBR in Word/HTML/Text formats using PScribo.
    .NOTES
        Version:        0.4.0
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
        Write-PscriboMessage "Discovering Veeam VBR File to Tape Backup jobs configuration information from $System."
    }

    process {
        try {
            if ((Get-VBRTapeJob).count -gt 0) {
                Section -Style Heading3 'File To Tape Job Configuration' {
                    Paragraph "The following section details file to tape jobs configuration."
                    BlankLine
                    $OutObj = @()
                    $TBkjobs = Get-VBRTapeJob | Where-Object {$_.Type -eq 'FileToTape'}
                    if ($TBkjobs) {
                        foreach ($TBkjob in $TBkjobs) {
                            Section -Style Heading4 "$($TBkjob.Name) Configuration" {
                                Section -Style Heading5 'Backups Information' {
                                    $OutObj = @()
                                    try {
                                        Write-PscriboMessage "Discovered $($TBkjob.Name) common information."
                                        $inObj = [ordered] @{
                                            'Name' = $TBkjob.Name
                                            'Type' = $TBkjob.Type
                                            'Next Run' = Switch ($TBkjob.Enabled) {
                                                'False' {'Disabled'}
                                                default {$TBkjob.NextRun}
                                            }
                                            'Description' = $TBkjob.Description
                                        }
                                        $OutObj = [pscustomobject]$inobj

                                        $TableParams = @{
                                            Name = "Common Information - $($TBkjob.Name)"
                                            List = $true
                                            ColumnWidths = 40, 60
                                        }
                                        if ($Report.ShowTableCaptions) {
                                            $TableParams['Caption'] = "- $($TableParams.Name)"
                                        }
                                        $OutObj | Table @TableParams
                                    }
                                    catch {
                                        Write-PscriboMessage -IsWarning $_.Exception.Message
                                    }
                                }
                                if ($TBkjob.Object) {
                                    try {
                                        Section -Style Heading5 'Files and Folders' {
                                            $OutObj = @()
                                            foreach ($File in $TBkjob.Object) {
                                                try {
                                                    Write-PscriboMessage "Discovered $($File.Name) files and folders to process."
                                                    $inObj = [ordered] @{
                                                        'Name' = $File.Server.Name
                                                        'Type' = $File.Server.Type
                                                        'Selection Type' = $File.SelectionType
                                                        'Path' = $File.Path
                                                        'Include Filter' = ConvertTo-EmptyToFiller $File.IncludeMask
                                                        'Exclude Filter' = ConvertTo-EmptyToFiller $File.ExcludeMask
                                                    }
                                                    $OutObj += [pscustomobject]$inobj
                                                }
                                                catch {
                                                    Write-PscriboMessage -IsWarning $_.Exception.Message
                                                }
                                            }
                                            if ($TBkjob.NdmpObject) {
                                                foreach ($NDMP in $TBkjob.NdmpObject) {
                                                    try {
                                                        Write-PscriboMessage "Discovered $($NDMP.Name) NDMP to process."
                                                        $inObj2 = [ordered] @{
                                                            'Name' = Switch ((Get-VBRNDMPServer -Id $NDMP.ServerId).Name) {
                                                                $Null {'NDMP Object'}
                                                                default {(Get-VBRNDMPServer -Id $NDMP.ServerId).Name}
                                                            }
                                                            'Type' = 'NDMP'
                                                            'Selection Type' = 'Directory'
                                                            'Path' = $NDMP.Name
                                                            'Include Filter' = '-'
                                                            'Exclude Filter' = '-'
                                                        }
                                                        $OutObj += [pscustomobject]$inobj2
                                                    }
                                                    catch {
                                                        Write-PscriboMessage -IsWarning $_.Exception.Message
                                                    }
                                                }
                                            }

                                            $TableParams = @{
                                                Name = "Files and Folders - $($TBkjob.Name)"
                                                List = $false
                                                ColumnWidths = 25, 15, 15, 25, 10, 10
                                            }
                                            if ($Report.ShowTableCaptions) {
                                                $TableParams['Caption'] = "- $($TableParams.Name)"
                                            }
                                            $OutObj | Sort-Object -Property 'Name' | Table @TableParams
                                        }
                                    }
                                    catch {
                                        Write-PscriboMessage -IsWarning $_.Exception.Message
                                    }
                                }
                                if ($TBkjob.FullBackupMediaPool) {
                                    try {
                                        Section -Style Heading5 'Full Backup' {
                                            $OutObj = @()
                                            foreach ($BackupMediaPool in $TBkjob.FullBackupMediaPool) {
                                                try {
                                                    Write-PscriboMessage "Discovered $($TBkjob.Name) media pool."
                                                    $inObj = [ordered] @{
                                                        'Name' = $BackupMediaPool.Name
                                                        'Pool Type' = $BackupMediaPool.Type
                                                        'Tape Count' = (Get-VBRTapeMedium -MediaPool $BackupMediaPool.Name).count
                                                        'Capacity' = ConvertTo-FileSizeString $BackupMediaPool.Capacity
                                                        'Remaining' = ConvertTo-FileSizeString $BackupMediaPool.FreeSpace
                                                        'Is WORM' = ConvertTo-TextYN $BackupMediaPool.Worm
                                                        'Schedule Enabled' = ConvertTo-TextYN $TBkjob.FullBackupPolicy.Enabled
                                                    }
                                                    if ($BackupMediaPool.Type -eq "Custom" -and $TBkjob.FullBackupPolicy.Enabled) {
                                                        if ($TBkjob.FullBackupPolicy.Type -eq 'Daily') {
                                                            $inObj.add('Daily at this Time', ("$($TBkjob.FullBackupPolicy.DailyOptions.Period) - $($TBkjob.FullBackupPolicy.DailyOptions.DayOfWeek -join ", ")"))
                                                        }
                                                        elseif ($TBkjob.FullBackupPolicy.Type  -eq 'Monthly') {
                                                            $Months = Switch (($TBkjob.FullBackupPolicy.MonthlyOptions.Months).count) {
                                                                12 {'Every Month'}
                                                                default {$TBkjob.FullBackupPolicy.MonthlyOptions.Months -join ", "}
                                                            }
                                                            if ($TBkjob.FullBackupPolicy.MonthlyOptions.DayNumberInMonth -eq 'OnDay') {
                                                                $inObj.add('Monthly at this Time', ("At $($TBkjob.FullBackupPolicy.DailyOptions.Period), Monthly on the: $($TBkjob.FullBackupPolicy.MonthlyOptions.DayOfMonth) day of $Months"))
                                                            } else {
                                                                $inObj.add('Monthly at this Time', ("At $($TBkjob.FullBackupPolicy.DailyOptions.Period), Monthly on the: $($TBkjob.FullBackupPolicy.MonthlyOptions.DayNumberInMonth) $($TBkjob.FullBackupPolicy.MonthlyOptions.DayOfWeek) of $Months"))
                                                            }
                                                        }
                                                    }
                                                    $OutObj += [pscustomobject]$inobj
                                                }
                                                catch {
                                                    Write-PscriboMessage -IsWarning $_.Exception.Message
                                                }
                                            }

                                            $TableParams = @{
                                                Name = "Full Backup - $($TBkjob.Name)"
                                                List = $True
                                                ColumnWidths = 40, 60
                                            }
                                            if ($Report.ShowTableCaptions) {
                                                $TableParams['Caption'] = "- $($TableParams.Name)"
                                            }
                                            $OutObj | Sort-Object -Property 'Name' | Table @TableParams
                                        }
                                    }
                                    catch {
                                        Write-PscriboMessage -IsWarning $_.Exception.Message
                                    }
                                }
                                if ($TBkjob.IncrementalBackupPolicy) {
                                    try {
                                        Section -Style Heading5 'Incremental Backup' {
                                            $OutObj = @()
                                            foreach ($BackupMediaPool in $TBkjob.IncrementalBackupMediaPool) {
                                                try {
                                                    Write-PscriboMessage "Discovered $($TBkjob.Name) incremental backup."
                                                    $inObj = [ordered] @{
                                                        'Name' = $BackupMediaPool.Name
                                                        'Pool Type' = $BackupMediaPool.Type
                                                        'Tape Count' = (Get-VBRTapeMedium -MediaPool $BackupMediaPool.Name).count
                                                        'Capacity' = ConvertTo-FileSizeString $BackupMediaPool.Capacity
                                                        'Remaining' = ConvertTo-FileSizeString $BackupMediaPool.FreeSpace
                                                        'Is WORM' = ConvertTo-TextYN $BackupMediaPool.Worm
                                                        'Schedule Enabled' = ConvertTo-TextYN $TBkjob.IncrementalBackupPolicy.Enabled
                                                    }
                                                    if ($BackupMediaPool.Type -eq "Custom" -and $TBkjob.IncrementalBackupPolicy.Enabled) {
                                                        if ($TBkjob.IncrementalBackupPolicy.Type -eq 'Daily') {
                                                            $inObj.add('Daily at this Time', ("$($TBkjob.IncrementalBackupPolicy.DailyOptions.Period) - $($TBkjob.IncrementalBackupPolicy.DailyOptions.DayOfWeek -join ", ")"))
                                                        }
                                                        elseif ($TBkjob.IncrementalBackupPolicy.Type  -eq 'Monthly') {
                                                            $Months = Switch (($TBkjob.IncrementalBackupPolicy.MonthlyOptions.Months).count) {
                                                                12 {'Every Month'}
                                                                default {$TBkjob.IncrementalBackupPolicy.MonthlyOptions.Months -join ", "}
                                                            }
                                                            if ($TBkjob.IncrementalBackupPolicy.MonthlyOptions.DayNumberInMonth -eq 'OnDay') {
                                                                $inObj.add('Monthly at this Time', ("At $($TBkjob.IncrementalBackupPolicy.DailyOptions.Period), Monthly on the: $($TBkjob.IncrementalBackupPolicy.MonthlyOptions.DayOfMonth) day of $Months"))
                                                            } else {
                                                                $inObj.add('Monthly at this Time', ("At $($TBkjob.IncrementalBackupPolicy.DailyOptions.Period), Monthly on the: $($TBkjob.IncrementalBackupPolicy.MonthlyOptions.DayNumberInMonth) $($TBkjob.IncrementalBackupPolicy.MonthlyOptions.DayOfWeek) of $Months"))
                                                            }
                                                        }
                                                    }
                                                    $OutObj += [pscustomobject]$inobj
                                                }
                                                catch {
                                                    Write-PscriboMessage -IsWarning $_.Exception.Message
                                                }
                                            }

                                            $TableParams = @{
                                                Name = "Incremental Backup - $($TBkjob.Name)"
                                                List = $True
                                                ColumnWidths = 40, 60
                                            }
                                            if ($Report.ShowTableCaptions) {
                                                $TableParams['Caption'] = "- $($TableParams.Name)"
                                            }
                                            $OutObj | Sort-Object -Property 'Name' | Table @TableParams
                                        }
                                    }
                                    catch {
                                        Write-PscriboMessage -IsWarning $_.Exception.Message
                                    }
                                }
                                try {
                                    Section -Style Heading5 'Options' {
                                        $OutObj = @()
                                        try {
                                            Write-PscriboMessage "Discovered $($TBkjob.Name) options."
                                            $inObj = [ordered] @{
                                                'Use Microsoft volume shadow copy (VSS)' = ConvertTo-TextYN $TBkjob.UseVss
                                                'Eject Tape Media Upon Job Completion' = ConvertTo-TextYN $TBkjob.EjectCurrentMedium
                                                'Export the following MediaSet Upon Job Completion' = ConvertTo-TextYN $TBkjob.ExportCurrentMediaSet
                                            }
                                            $OutObj += [pscustomobject]$inobj
                                        }
                                        catch {
                                            Write-PscriboMessage -IsWarning $_.Exception.Message
                                        }

                                        $TableParams = @{
                                            Name = "Options - $($TBkjob.Name)"
                                            List = $True
                                            ColumnWidths = 40, 60
                                        }
                                        if ($Report.ShowTableCaptions) {
                                            $TableParams['Caption'] = "- $($TableParams.Name)"
                                        }
                                        $OutObj | Sort-Object -Property 'Name' | Table @TableParams
                                        if ($InfoLevel.Jobs.Tape -ge 2 -and $TBkjob.NotificationOptions.EnableAdditionalNotification) {
                                            try {
                                                Section -Style Heading5 'Advanced Settings (Notifications)' {
                                                    $OutObj = @()
                                                    try {
                                                        Write-PscriboMessage "Discovered $($TBkjob.Name) notification options."
                                                        $inObj = [ordered] @{
                                                            'Send Email Notification' = ConvertTo-TextYN $TBkjob.NotificationOptions.EnableAdditionalNotification
                                                            'Email Notification Additional Recipients' = $TBkjob.NotificationOptions.AdditionalAddress -join ","
                                                        }
                                                        if (!$TBkjob.NotificationOptions.UseNotificationOptions) {
                                                            $inObj.add('Use Global Notification Settings', (ConvertTo-TextYN $TBkjob.NotificationOptions.UseNotificationOptions))
                                                        }
                                                        elseif ($TBkjob.NotificationOptions.UseNotificationOptions) {
                                                            $inObj.add('Use Custom Notification Settings', ('Yes'))
                                                            $inObj.add('Subject', ($TBkjob.NotificationOptions.NotificationSubject))
                                                            $inObj.add('Notify On Success', (ConvertTo-TextYN $TBkjob.NotificationOptions.NotifyOnSuccess))
                                                            $inObj.add('Notify On Warning', (ConvertTo-TextYN $TBkjob.NotificationOptions.NotifyOnWarning))
                                                            $inObj.add('Notify On Error', (ConvertTo-TextYN $TBkjob.NotificationOptions.NotifyOnError))
                                                            $inObj.add('Notify On Last Retry Only', (ConvertTo-TextYN $TBkjob.NotificationOptions.NotifyOnLastRetryOnly))
                                                            $inObj.add('Notify When Waiting For Tape', (ConvertTo-TextYN $TBkjob.NotificationOptions.NotifyWhenWaitingForTape))
                                                        }
                                                        $OutObj += [pscustomobject]$inobj
                                                    }
                                                    catch {
                                                        Write-PscriboMessage -IsWarning $_.Exception.Message
                                                    }

                                                    $TableParams = @{
                                                        Name = "Advanced Settings (Notifications) - $($TBkjob.Name)"
                                                        List = $True
                                                        ColumnWidths = 40, 60
                                                    }
                                                    if ($Report.ShowTableCaptions) {
                                                        $TableParams['Caption'] = "- $($TableParams.Name)"
                                                    }
                                                    $OutObj | Sort-Object -Property 'Name' | Table @TableParams
                                                }
                                            }
                                            catch {
                                                Write-PscriboMessage -IsWarning $_.Exception.Message
                                            }
                                        }
                                        if ($InfoLevel.Jobs.Tape -ge 2 -and $TBkjob.NotificationOptions.EnableAdditionalNotification) {
                                            try {
                                                Section -Style Heading5 'Advanced Settings (Advanced)' {
                                                    $OutObj = @()
                                                    try {
                                                        Write-PscriboMessage "Discovered $($TBkjob.Name) advanced options."
                                                        $inObj = [ordered] @{
                                                            'Use Hardware Compression when available' = ConvertTo-TextYN $TBkjob.UseHardwareCompression
                                                        }
                                                        if (!$TBkjob.JobScriptOptions.PreScriptEnabled) {
                                                            $inObj.add('Pre Job Script Enabled', (ConvertTo-TextYN $TBkjob.JobScriptOptions.PreScriptEnabled))
                                                        }
                                                        elseif ($TBkjob.JobScriptOptions.PreScriptEnabled) {
                                                            $inObj.add('Run the following script before job', ($TBkjob.JobScriptOptions.PreCommand))
                                                        }
                                                        if (!$TBkjob.JobScriptOptions.PostScriptEnabled) {
                                                            $inObj.add('Post Job Script Enabled', (ConvertTo-TextYN $TBkjob.JobScriptOptions.PostScriptEnabled))
                                                        }
                                                        elseif ($TBkjob.JobScriptOptions.PostScriptEnabled) {
                                                            $inObj.add('Run the following script after job', ($TBkjob.JobScriptOptions.PostCommand))
                                                        }
                                                        if ($TBkjob.JobScriptOptions.PreScriptEnabled -or $TBkjob.JobScriptOptions.PostScriptEnabled) {
                                                            if ($TBkjob.JobScriptOptions.Periodicity -eq 'Days') {
                                                                $FrequencyValue = $TBkjob.JobScriptOptions.Day -join ", "
                                                                $FrequencyText = 'Run Script on the Selected Days'
                                                            }
                                                            elseif ($TBkjob.JobScriptOptions.Periodicity -eq 'Cycles') {
                                                                $FrequencyValue = "Every $($TBkjob.JobScriptOptions.Frequency) backup session"
                                                                $FrequencyText = 'Run Script Every Backup Session'
                                                            }
                                                            $inObj.add($FrequencyText, ($FrequencyValue))
                                                        }
                                                        $OutObj += [pscustomobject]$inobj
                                                    }
                                                    catch {
                                                        Write-PscriboMessage -IsWarning $_.Exception.Message
                                                    }

                                                    $TableParams = @{
                                                        Name = "Advanced Settings (Advanced) - $($TBkjob.Name)"
                                                        List = $True
                                                        ColumnWidths = 40, 60
                                                    }
                                                    if ($Report.ShowTableCaptions) {
                                                        $TableParams['Caption'] = "- $($TableParams.Name)"
                                                    }
                                                    $OutObj | Sort-Object -Property 'Name' | Table @TableParams
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
        }
        catch {
            Write-PscriboMessage -IsWarning $_.Exception.Message
        }
    }
    end {}

}
