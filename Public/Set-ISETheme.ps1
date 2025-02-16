<#
.SYNOPSIS
    Sets predefined themes for the PowerShell ISE environment.

.DESCRIPTION
    This function modifies the PowerShell ISE color scheme using predefined themes.
    Available themes include Neon (bright, high-contrast) and Dark (VS Code-like).
    Includes option to reset to default ISE theme.

.PARAMETER Neon
    Applies the Neon theme with bright, high-contrast colors optimized for visibility.

.PARAMETER Dark
    Applies the Dark theme inspired by VS Code's dark theme for reduced eye strain.

.PARAMETER Reset
    Reverts the ISE theme back to default settings.

.EXAMPLE
    Set-ISETheme -Neon
    Applies the high-contrast Neon theme to the ISE.

.EXAMPLE
    Set-ISETheme -Dark
    Applies the VS Code-inspired Dark theme to the ISE.

.EXAMPLE
    Set-ISETheme -Reset
    Reverts the ISE theme back to default settings.

.NOTES
    Name: Set-ISETheme
    Author: AutomateSilent
    Version: 1.0.0
    Last Updated: 2025-02-16
#>
function Set-ISETheme {
    [CmdletBinding(DefaultParameterSetName = 'Theme')]
    param (
        [Parameter(ParameterSetName = 'Theme')]
        [switch]$Neon,

        [Parameter(ParameterSetName = 'Theme')]
        [switch]$Dark,

        [Parameter(ParameterSetName = 'Theme')]
        [switch]$Reset
    )

    begin {
        # Verify we're running in ISE
        if (-not $psISE) {
            Write-Error "This function can only be run within PowerShell ISE."
            return
        }
    }

    process {
        try {
            switch ($true) {
                $Neon {
                    # Main editor and console colors
                    $psISE.Options.ScriptPaneBackgroundColor = "#1A0F23"
                    $psISE.Options.ScriptPaneForegroundColor = "#E6E6E6"
                    $psISE.Options.ConsolePaneBackgroundColor = "#1A0F23"
                    $psISE.Options.ConsolePaneForegroundColor = "#E6E6E6"
                    $psISE.Options.ConsolePaneTextBackgroundColor = "#1A0F23"
                    
                    # Enhanced syntax highlighting with neon accents
                    $psISE.Options.TokenColors["Command"] = "#FFE666"
                    $psISE.Options.TokenColors["Variable"] = "#00FFFF"
                    $psISE.Options.TokenColors["String"] = "#FF6B9F"
                    $psISE.Options.TokenColors["Comment"] = "#7B4D8C"
                    $psISE.Options.TokenColors["Operator"] = "#FFFFFF"
                    $psISE.Options.TokenColors["Keyword"] = "#BB8DFF"
                    $psISE.Options.TokenColors["Type"] = "#50FFB0"
                    $psISE.Options.TokenColors["Number"] = "#B5CEA8"
                    $psISE.Options.TokenColors["Member"] = "#FF69B4"
                    $psISE.Options.TokenColors["GroupStart"] = "#C78FFF"
                    $psISE.Options.TokenColors["GroupEnd"] = "#C78FFF"
                    $psISE.Options.TokenColors["CommandParameter"] = "#C78FFF"
                    $psISE.Options.TokenColors["CommandArgument"] = "#FFD700"
                    
                    # Error and warning colors
                    $psISE.Options.ErrorForegroundColor = "#FF3366"
                    $psISE.Options.ErrorBackgroundColor = "#1A0F23"
                    $psISE.Options.WarningForegroundColor = "#FFCC00"
                    $psISE.Options.WarningBackgroundColor = "#1A0F23"
                    
                    # Fonts and text size
                    $psISE.Options.FontName = "Consolas"
                    $psISE.Options.FontSize = 10
                    
                    Write-Host "Neon theme applied successfully!" -ForegroundColor Magenta
                }
                $Dark {
                    # Main editor and console colors
                    $psISE.Options.ScriptPaneBackgroundColor = "#1E1E1E"
                    $psISE.Options.ScriptPaneForegroundColor = "#D4D4D4"
                    $psISE.Options.ConsolePaneBackgroundColor = "#1E1E1E"
                    $psISE.Options.ConsolePaneForegroundColor = "#D4D4D4"
                    $psISE.Options.ConsolePaneTextBackgroundColor = "#1E1E1E"
                    
                    # Enhanced syntax highlighting colors
                    $psISE.Options.TokenColors["Command"] = "#DCDCAA"
                    $psISE.Options.TokenColors["Variable"] = "#9CDCFE"
                    $psISE.Options.TokenColors["String"] = "#CE9178"
                    $psISE.Options.TokenColors["Comment"] = "#6A9955"
                    $psISE.Options.TokenColors["Operator"] = "#FFFFFF"
                    $psISE.Options.TokenColors["Keyword"] = "#BB8DFF"
                    $psISE.Options.TokenColors["Type"] = "#4EC9B0"
                    $psISE.Options.TokenColors["Number"] = "#B5CEA8"
                    $psISE.Options.TokenColors["Member"] = "#FF69B4"
                    $psISE.Options.TokenColors["GroupStart"] = "#9D7EFF"
                    $psISE.Options.TokenColors["GroupEnd"] = "#9D7EFF"
                    $psISE.Options.TokenColors["CommandParameter"] = "#9D7EFF"
                    $psISE.Options.TokenColors["CommandArgument"] = "#D6AF56"
                    
                    # Error and warning colors
                    $psISE.Options.ErrorForegroundColor = "#F85149"
                    $psISE.Options.ErrorBackgroundColor = "#1E1E1E"
                    $psISE.Options.WarningForegroundColor = "#CCA700"
                    $psISE.Options.WarningBackgroundColor = "#1E1E1E"
                    
                    # Fonts and text size
                    $psISE.Options.FontName = "Consolas"
                    $psISE.Options.FontSize = 10
                    
                    Write-Host "Dark theme applied successfully!" -ForegroundColor Green
                }
                $Reset {
                    # Reset to default ISE theme
                    $psISE.Options.RestoreDefaults()
                    Write-Host "ISE theme has been reset to default settings." -ForegroundColor Cyan
                }
                default {
                    Write-Error "Please specify a theme: -Neon, -Dark, or use -Reset to restore defaults."
                }
            }
        }
        catch {
            Write-Error "Failed to apply theme: $_"
        }
    }
}