
function Get-AbrVbrTapeInfraSummary {
    <#
    .SYNOPSIS
    Used by As Built Report to retrieve Veeam VBR Tape Infrastructure Summary.
    .DESCRIPTION
        Documents the configuration of Veeam VBR in Word/HTML/Text formats using PScribo.
    .NOTES
        Version:        0.4.1
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
        Write-PscriboMessage "Discovering Veeam VBR Tape Infrastructure Summary from $System."
    }

    process {
        try {
            $OutObj = @()
            if ((Get-VBRServerSession).Server) {
                try {
                    $TapeServer = Get-VBRTapeServer
                    $TapeLibrary = Get-VBRTapeLibrary
                    $TapeMediaPool = Get-VBRTapeMediaPool
                    $TapeVault = Get-VBRTapeVault
                    $TapeDrive = Get-VBRTapeDrive
                    $TapeMedium = Get-VBRTapeMedium
                    $inObj = [ordered] @{
                        'Number of Tape Servers' = $TapeServer.Count
                        'Number of Tape Library' = $TapeLibrary.Count
                        'Number of Tape MediaPool' = $TapeMediaPool.Count
                        'Number of Tape Vault' = $TapeVault.Count
                        'Number of Tape Drives' = $TapeDrive.Count
                        'Number of Tape Medium' = $TapeMedium.Count
                    }
                    $OutObj += [pscustomobject]$inobj
                }
                catch {
                    Write-PscriboMessage -IsWarning $_.Exception.Message
                }

                $TableParams = @{
                    Name = "Executive Summary - $(((Get-VBRServerSession).Server).ToString().ToUpper().Split(".")[0])"
                    List = $true
                    ColumnWidths = 50, 50
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
    end {}

}