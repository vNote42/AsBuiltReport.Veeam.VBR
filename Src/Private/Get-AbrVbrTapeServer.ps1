
function Get-AbrVbrTapeServer {
    <#
    .SYNOPSIS
        Used by As Built Report to retrieve Veeam Tape Server Information
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
        Write-PscriboMessage "Discovering Veeam VBR Tape Server information from $System."
    }

    process {
        try {
            if ((Get-VBRTapeServer).count -gt 0) {
                Section -Style Heading3 'Tape Servers' {
                    Paragraph "The following section provides summary information on Tape Servers."
                    BlankLine
                    $OutObj = @()
                    if ((Get-VBRServerSession).Server) {
                        $TapeObjs = Get-VBRTapeServer
                        try {
                            foreach ($TapeObj in $TapeObjs) {
                                Write-PscriboMessage "Discovered $($TapeObj.Name) Type Server."
                                $inObj = [ordered] @{
                                    'Name' = $TapeObj.Name
                                    'Description' = $TapeObj.Description
                                    'Status' = Switch ($TapeObj.IsAvailable) {
                                        'True' {'Available'}
                                        'False' {'Unavailable'}
                                        default {$TapeObj.IsUnavailable}
                                    }
                                }
                                $OutObj += [pscustomobject]$inobj
                            }

                            if ($HealthCheck.Tape.Status) {
                                $OutObj | Where-Object { $_.'Status' -eq 'Unavailable'} | Set-Style -Style Warning -Property 'Status'
                            }

                            $TableParams = @{
                                Name = "Tape Server - $(((Get-VBRServerSession).Server).ToString().ToUpper().Split(".")[0])"
                                List = $false
                                ColumnWidths = 25, 50, 25
                            }

                            if ($Report.ShowTableCaptions) {
                                $TableParams['Caption'] = "- $($TableParams.Name)"
                            }
                            $OutObj | Sort-Object -Property 'Name' | Table @TableParams
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
    end {}

}