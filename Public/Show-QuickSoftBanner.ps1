<#
.SYNOPSIS
    Displays a stylized ASCII art banner for the QuickSoft PowerShell module with customizable version and repository information.

.DESCRIPTION
    Show-QuickSoftBanner creates and displays a professional ASCII art banner featuring
    the QuickSoft logo and module information. The banner includes dynamic content
    display for module version and GitHub repository details.
    
    The function implements color-coded elements for enhanced visibility:
    - Magenta: ASCII art gradient patterns
    - Cyan: Border elements and structural components
    - Yellow: Status indicators ([±], [⌂])
    - White: Parameter values and content text
    Font Name: Slant
    Link: https://patorjk.com/software/taag/#p=testall&f=3D%20Diagonal&t=Quick%20Soft

.PARAMETER ModuleVersion
    Specifies the current version number of the QuickSoft module.
    Default: (Get-Module -Name "QuickSoft").Version.ToString()

.PARAMETER link
    Specifies the GitHub repository URL for the QuickSoft project.
    Default: "github.com/AutomateSilent/QuickSoft"

.EXAMPLE
    Show-QuickSoftBanner
    # Displays the default QuickSoft banner with standard version and GitHub link

.NOTES
    Name: Show-QuickSoftBanner
    Version: 1.1.2
    Author: AutomateSilent
    LastModified: 2025-02-13

.LINK
    https://github.com/AutomateSilent/QuickSoft

.INPUTS
    None. This function does not accept pipeline input.

.OUTPUTS
    None. This function displays a colored banner to the host.
#>

function Show-QuickSoftBanner {
    [CmdletBinding()]
    param(
        [ValidateNotNullOrEmpty()]
        [string]$ModuleVersion = ((Get-Module -Name "QuickSoft").Version.ToString()),
        
        [ValidateNotNullOrEmpty()]
        [string]$Link = "github.com/AutomateSilent/QuickSoft"
    )


    try {
        $originalEncoding = $OutputEncoding
        $OutputEncoding = [System.Text.Encoding]::UTF8
        Write-Verbose "Successfully set UTF-8 encoding"
    }
    catch {
        Write-Warning "Unable to modify console encoding. Banner may display incorrectly."
    }

    try {
        $banner = @"
   +-------------------------------------------------------+
    |   * ____  *     _*     __  *   _____ *   * ______ * |
    | *  / __ \__ *__(_)___*/ /__ * / ___/____* / __/ /_  |
    |  */ / / / / / / / ___/ //_/ * \__ \/ __ \/ /_/ __/  |
    |  / /_/ / /_/ / / /__/ ,<*  * ___/ / /_/ / __/ /_ *  |
    |  \___\_\__,_/_/\___/_/|_| * /____/\____/_/  \__/  * |
    |-----------------------------------------------------|
    | [*] Module Version: $ModuleVersion                           |
    | [@] GitHub: $Link     |
    +-----------------------------------------------------+
"@
        
        # Process each line of the banner
        $bannerLines = $banner -split "`n"
        foreach ($currentLine in $bannerLines) {

            # Pattern matching for horizontal border lines
            if ($currentLine -match '^\s*\+\-+\+\s*$') {
                Write-Host $currentLine -ForegroundColor Magenta
                continue
            }
            

            
            <# Pattern matching for gradient lines
            if ($currentLine -match "^\s*\| [/#\\~]+\s*\|") {
                Write-Host $currentLine -ForegroundColor Magenta
                continue
            }
            #>

            # Pattern matching for information lines
            if ($currentLine -match "\[[\*\@]\]") {  # Using Unicode for ± and ⌂
                $line = $currentLine
                $pattern = "\[[^\]]*\]"
                $lastIndex = 0

                # Find all indicator patterns
                $regex = [regex]$pattern
                $indicators = $regex.Matches($line)

                # Process each segment
                foreach ($indicator in $indicators) {
                    # Write text before indicator
                    if ($indicator.Index -gt $lastIndex) {
                        $preText = $line.Substring($lastIndex, $indicator.Index - $lastIndex)
                        Write-Host $preText -NoNewline -ForegroundColor Cyan
                    }

                    # Write indicator
                    Write-Host $indicator.Value -NoNewline -ForegroundColor Yellow

                    $lastIndex = $indicator.Index + $indicator.Length

                    # Process value after indicator
                    $colonIndex = $line.IndexOf(':', $lastIndex)
                    if ($colonIndex -gt -1) {
                        # Write label
                        Write-Host $line.Substring($lastIndex, $colonIndex - $lastIndex + 1) -NoNewline -ForegroundColor Cyan
                        Write-Host " " -NoNewline -ForegroundColor Cyan

                        # Determine spacing based on line type
                        $spacing = if ($line -match "Version") {
                            "                                    ║"
                        }
                        else {
                            "              ║"
                        }

                        # Find value end position
                        $valueEndPos = $line.IndexOf($spacing, $colonIndex)
                        if ($valueEndPos -eq -1) { $valueEndPos = $line.Length }

                        # Write value and remaining content
                        $value = $line.Substring($colonIndex + 2, $valueEndPos - ($colonIndex + 2)).TrimEnd()
                        Write-Host $value -NoNewline -ForegroundColor White
                        
                        if ($valueEndPos -lt $line.Length) {
                            Write-Host $line.Substring($valueEndPos) -NoNewline -ForegroundColor Cyan
                        }
                    }
                }
                Write-Host ""
            }
            else {
                # Write regular lines
                Write-Host $currentLine -ForegroundColor White
            }
        }
    }
    catch {
        Write-Error "Failed to display QuickSoft banner: $_"
        Write-Debug "Error occurred at line: $($_.InvocationInfo.ScriptLineNumber)"
    }
     finally {
        # Restore original encoding if we modified it
        if ($originalEncoding) {
            try {
                $OutputEncoding = $originalEncoding
                Write-Verbose "Successfully restored original encoding"
            }
            catch {
                Write-Warning "Unable to restore original console encoding"
            }
        }
    }
}