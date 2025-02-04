<#
.SYNOPSIS
    Applies a dark theme to the PowerShell ISE editor.

.COMPONENT
    QuickSoft

.DESCRIPTION
    Customizes the PowerShell ISE color scheme with a dark theme optimized for readability.
    Includes custom colors for different code elements like functions, properties, and syntax.

.EXAMPLE
    Set-ISEDarkTheme
    Applies the dark theme to the current PowerShell ISE session.

.NOTES
    Name: Set-ISEDarkTheme
    Author: AutomateSilent
    Version: 1.0.0
    Last Updated: 2025-01-31
    Requires: PowerShell ISE
#>
function Set-ISEDarkTheme {
    [CmdletBinding()]
    param()

    # Check if running in ISE
    if (-not $psISE) {
        Write-Error "This function can only be run in PowerShell ISE."
        return
    }

    try {
        # Main editor and console colors
        $psISE.Options.ScriptPaneBackgroundColor = "#1E1E1E"      
        $psISE.Options.ScriptPaneForegroundColor = "#D4D4D4"      
        $psISE.Options.ConsolePaneBackgroundColor = "#1E1E1E"     
        $psISE.Options.ConsolePaneForegroundColor = "#D4D4D4"     
        $psISE.Options.ConsolePaneTextBackgroundColor = "#1E1E1E" 

        # Enhanced syntax highlighting colors
        $psISE.Options.TokenColors["Command"] = "#DCDCAA"         # Built-in cmdlets
        $psISE.Options.TokenColors["Variable"] = "#9CDCFE"        # Variables
        $psISE.Options.TokenColors["String"] = "#CE9178"          # Strings
        $psISE.Options.TokenColors["Comment"] = "#6A9955"         # Comments
        $psISE.Options.TokenColors["Operator"] = "#FFFFFF"        # Operators
        $psISE.Options.TokenColors["Keyword"] = "#BB8DFF"         # Keywords
        $psISE.Options.TokenColors["Type"] = "#4EC9B0"           # Types
        $psISE.Options.TokenColors["Number"] = "#B5CEA8"         # Numbers
        $psISE.Options.TokenColors["Member"] = "#FF69B4"         # Properties
        $psISE.Options.TokenColors["GroupStart"] = "#9D7EFF"      # Opening brackets
        $psISE.Options.TokenColors["GroupEnd"] = "#9D7EFF"        # Closing brackets
        $psISE.Options.TokenColors["CommandParameter"] = "#9D7EFF" # Parameters
        $psISE.Options.TokenColors["CommandArgument"] = "#D6AF56" # Function names

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
    catch {
        Write-Error "Failed to apply dark theme: $_"
    }
}