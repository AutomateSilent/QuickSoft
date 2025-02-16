using namespace System.Management.Automation

<#
.SYNOPSIS
    Initializes and configures quick directory navigation system for PowerShell.

.DESCRIPTION
    Start-QuickPath establishes a quick navigation system enabling rapid directory
    switching using short aliases. It supports persistent configuration through
    PowerShell profiles and provides cross-session availability.

    The function creates and manages an XML configuration file storing path aliases,
    implements tab completion for enhanced usability, and supports multiple user scopes.

.PARAMETER ConfigPath
    Specifies the location for the XML configuration file.
    Default: "$env:USERPROFILE\QuickSoft\quickpaths.xml"

.PARAMETER Scope
    Determines the persistence scope of the configuration:
    - CurrentSession: Active only in current PowerShell session
    - CurrentUser: Persists across all sessions for current user
    - AllUsers: System-wide persistence for all users
    Default: CurrentSession

.PARAMETER NoAlias
    Disables creation of the 'q' shorthand alias for quick access.

.EXAMPLE
    Start-QuickPath -Scope CurrentUser
    # Initializes Quick-Paths with persistence for current user

.EXAMPLE
    Start-QuickPath -ConfigPath "D:\Config\paths.xml" -Scope AllUsers
    # Sets up system-wide Quick-Paths with custom config location
.LINK
    https://github.com/AutomateSilent/QuickSoft
    
.NOTES
    Name: Start-QuickPath
    Author: AutomateSilent
    Version: 1.0.0
    Required Modules: None
#>
function Start-QuickPath {
    [CmdletBinding()]
    param (
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$ConfigPath = "$env:USERPROFILE\QuickSoft\quickpaths.xml",

        [Parameter()]
        [ValidateSet('CurrentSession', 'CurrentUser', 'AllUsers')]
        [string]$Scope = 'CurrentSession',

        [Parameter()]
        [switch]$NoAlias
    )

    begin {
        Write-Verbose "Initializing Quick-Paths with config path: $ConfigPath"
        $ErrorActionPreference = 'Stop'

        #region Helper Functions
        function Initialize-Configuration {
            [CmdletBinding()]
            param (
                [Parameter(Mandatory)]
                [ValidateNotNullOrEmpty()]
                [string]$Path
            )

            try {
                $configDir = Split-Path -Path $Path -Parent
                if (-not (Test-Path -Path $configDir)) {
                    $null = New-Item -Path $configDir -ItemType Directory -Force
                    Write-Verbose "Created directory: $configDir"
                }

                if (-not (Test-Path -Path $Path)) {
                    $defaultXml = @"
<?xml version="1.0" encoding="UTF-8"?>
<QuickPaths>
    <Configuration>
        <Source>$Path</Source>
        <LastUpdated>$((Get-Date).ToString('yyyy-MM-dd HH:mm:ss'))</LastUpdated>
    </Configuration>
    <Paths>
        <Path alias="desktop" location="$env:USERPROFILE\Desktop" />
        <Path alias="docs" location="$env:USERPROFILE\Documents" />
    </Paths>
</QuickPaths>
"@
                    $defaultXml | Out-File -FilePath $Path -Encoding UTF8 -Force
                    Write-Verbose "Created config file: $Path"
                }
            }
            catch {
                throw "Failed to initialize configuration: $_"
            }
        }

        function script:Backup-QuickPathsConfig {
            [CmdletBinding()]
            param (
                [Parameter(Mandatory)]
                [ValidateScript({ Test-Path $_ })]
                [string]$Path
            )
        
            try {
                $backupPath = "$Path.backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
                Copy-Item -Path $Path -Destination $backupPath -Force
                Write-Verbose "Created backup at: $backupPath"
                return $backupPath
            }
            catch {
                Write-Error "Backup failed: $_"
                return $null
            }
        }

        function script:Import-QuickPathsConfig {
            [CmdletBinding()]
            param(
                [Parameter(Mandatory)]
                [ValidateScript({
                    if (-not (Test-Path -Path $_)) {
                        throw "File not found: $_"
                    }
                    if (-not ($_ -match '\.xml$')) {
                        throw "File must be XML: $_"
                    }
                    try {
                        [xml]$content = Get-Content -Path $_ -ErrorAction Stop
                        if (-not ($content.QuickPaths -and $content.QuickPaths.Paths)) {
                            throw "Invalid Quick-Paths format"
                        }
                        return $true
                    }
                    catch {
                        throw "XML validation failed: $_"
                    }
                })]
                [string]$Path,
        
                [Parameter()]
                [ValidateSet('Merge', 'Replace', 'Skip')]
                [string]$Strategy = 'Skip'
            )
        
            try {
                Write-Verbose "Starting import process..."
                Write-Verbose "Source: $Path"
                Write-Verbose "Target: $script:QuickPathsFile"
                Write-Verbose "Strategy: $Strategy"
        
                # Create backup
                $backupPath = script:Backup-QuickPathsConfig -Path $script:QuickPathsFile
                if (-not $backupPath) {
                    throw "Backup creation failed"
                }
                Write-Verbose "Created backup at: $backupPath"
        
                # Load configurations
                [xml]$sourceConfig = Get-Content -Path $Path -Raw
                [xml]$targetConfig = Get-Content -Path $script:QuickPathsFile -Raw
        
                # Track changes
                $changes = @{
                    Added = 0
                    Replaced = 0
                    Skipped = 0
                    Merged = 0
                }
        
                # Process paths
                foreach ($sourcePath in $sourceConfig.QuickPaths.Paths.Path) {
                    $alias = $sourcePath.alias
                    $location = $sourcePath.location
                    Write-Verbose "Processing: $alias -> $location"
        
                    $existingPath = $targetConfig.QuickPaths.Paths.Path | 
                        Where-Object { $_.alias -eq $alias }
        
                    if ($existingPath) {
                        switch ($Strategy) {
                            'Replace' {
                                $existingPath.location = $location
                                $changes.Replaced++
                                Write-Verbose "Replaced: $alias"
                            }
                            'Merge' {
                                if ($existingPath.location -ne $location) {
                                    $newAlias = "${alias}_imported"
                                    $newPath = $targetConfig.CreateElement("Path")
                                    $newPath.SetAttribute("alias", $newAlias)
                                    $newPath.SetAttribute("location", $location)
                                    $targetConfig.QuickPaths.Paths.AppendChild($newPath)
                                    $changes.Merged++
                                    Write-Verbose "Merged as: $newAlias"
                                }
                            }
                            'Skip' {
                                $changes.Skipped++
                                Write-Verbose "Skipped: $alias"
                            }
                        }
                    }
                    else {
                        $newPath = $targetConfig.CreateElement("Path")
                        $newPath.SetAttribute("alias", $alias)
                        $newPath.SetAttribute("location", $location)
                        $targetConfig.QuickPaths.Paths.AppendChild($newPath)
                        $changes.Added++
                        Write-Verbose "Added: $alias"
                    }
                }
        
                # Save changes
                $targetConfig.Save($script:QuickPathsFile)
        
                # Display summary
                Write-Host "`nImport Summary:" -ForegroundColor Cyan
                Write-Host "Added:    $($changes.Added)" -ForegroundColor Green
                Write-Host "Replaced: $($changes.Replaced)" -ForegroundColor Yellow
                Write-Host "Merged:   $($changes.Merged)" -ForegroundColor Green
                Write-Host "Skipped:  $($changes.Skipped)" -ForegroundColor Yellow
                Write-Host "`nBackup created at: $backupPath" -ForegroundColor Cyan
        
                return $true
            }
            catch {
                Write-Error "Import failed: $_"
                if ($backupPath -and (Test-Path $backupPath)) {
                    Copy-Item -Path $backupPath -Destination $script:QuickPathsFile -Force
                    Write-Warning "Restored from backup: $backupPath"
                }
                return $false
            }
        }
        
       

        function Set-ProfileIntegration {
            [CmdletBinding()]
            [OutputType([bool])]
            param (
                [Parameter(Mandatory)]
                [ValidateSet('CurrentUser', 'AllUsers')]
                [string]$Scope,

                [Parameter(Mandatory)]
                [ValidateNotNullOrEmpty()]
                [string]$ConfigPath
            )

            try {
                # Get appropriate profile path
                $profilePath = switch ($Scope) {
                    'CurrentUser' { $PROFILE.CurrentUserAllHosts }
                    'AllUsers' { $PROFILE.AllUsersAllHosts }
                }

                # Ensure profile directory exists
                $profileDir = Split-Path -Path $profilePath -Parent
                if (-not (Test-Path -Path $profileDir)) {
                    $null = New-Item -Path $profileDir -ItemType Directory -Force
                }

                # Generate profile content
                $profileContent = @"
                Clear-Host
# Quick-Paths Configuration
# Added: $([DateTime]::Now.ToString('yyyy-MM-dd HH:mm:ss'))
`$script:QuickPathsFile = '$ConfigPath'
`$script:QuickPathsProfile = '$profilePath'
Write-Host "Profile loaded: " -NoNewline -ForegroundColor Gray; Write-Host "$profilePath" -ForegroundColor Cyan ;
Write-Host "    " -NoNewline; Write-Host "Computer: " -NoNewline -ForegroundColor Gray; Write-Host "$ENV:computername" -ForegroundColor Cyan;
Write-Host "    " -ForegroundColor Gray -NoNewline; Write-Host "$([DateTime]::Now.ToString('hh:mm tt'))" -ForegroundColor White;
# Initialize Quick-Paths
if (Get-Module -ListAvailable -Name QuickSoft) {
    Import-Module QuickSoft
    Show-QuickSoftBanner
    Start-QuickPath
    New-Alias -Name q -Value qp -Scope Global -Force
}
"@

                # Update or create profile
                if (Test-Path -Path $profilePath) {
                    $existing = Get-Content -Path $profilePath -Raw
                    if ($existing -notlike "*Quick-Paths Configuration*") {
                        Add-Content -Path $profilePath -Value "`n$profileContent" -Force
                    }
                }
                else {
                    Set-Content -Path $profilePath -Value $profileContent -Force
                }

                Write-Verbose "Profile updated: $profilePath"
                return $true
            }
            catch {
                Write-Error "Profile integration failed: $_"
                return $false
            }
        }
        #endregion Helper Functions
    }

    process {
        try {
            # Initialize core configuration
            Initialize-Configuration -Path $ConfigPath

            # Configure profile integration
            if ($Scope -ne 'CurrentSession') {
                $profileSuccess = Set-ProfileIntegration -Scope $Scope -ConfigPath $ConfigPath
                if (-not $profileSuccess) {
                    Write-Warning "Profile integration incomplete. Some features may be limited."
                }
            }

            # Set global configuration path
            $script:QuickPathsFile = $ConfigPath

            # Create session alias
            if (-not $NoAlias) {
                New-Alias -Name q -Value qp -Scope Global -Force
                Write-Verbose "Created 'q' alias"
            }

            # Display status
            Write-Host "    " -NoNewline; Write-Host "Quick-Paths initialized successfully!"  -ForegroundColor Green; 
            Write-Host "    " -NoNewline; Write-Host "Configuration: " -NoNewline -ForegroundColor Gray; Write-Host "$ConfigPath" -ForegroundColor Cyan ;
            if ($Scope -ne 'CurrentSession') {
                Write-Host "Profile configured for $Scope" -ForegroundColor Green
                Write-Host "    " -NoNewline; Write-Host "Profile path: " -NoNewline -ForegroundColor Gray; Write-Host "$($PROFILE.$($Scope+'AllHosts'))" -ForegroundColor Cyan ;
            }
            Write-Host "Type" -NoNewline -ForegroundColor Green; Write-Host " 'q help' " -ForegroundColor Yellow -NoNewline; Write-Host "for usage information" -ForegroundColor Green;
        }
        catch {
            Write-Error -Exception $_.Exception -Message "Quick-Paths initialization failed: $_"
            return
        }
    }
}

function global:qp {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [string]$Command,

        [Parameter(Position = 1)]
        [string]$Arg1,

        [Parameter(Position = 2)]
        [string]$Arg2,

        # Parameters for import command
        [Parameter()]
        [switch]$Merge,

        [Parameter()]
        [switch]$Replace,

        [Parameter()]
        [switch]$Skip
    )

    try {
        if (-not (Test-Path -Path $script:QuickPathsFile)) {
            throw "Configuration file not found at: $script:QuickPathsFile"
        }

        [xml]$config = Get-Content -Path $script:QuickPathsFile

        switch -Regex ($Command) {
            '^(add)$' {
                if (-not $Arg1 -or -not $Arg2) {
                    throw "Usage: q add <alias> <path>"
                }
                if (Test-Path -Path $Arg2) {
                    $Arg2 = (Resolve-Path -Path $Arg2).Path
                }
                $newPath = $config.CreateElement("Path")
                $newPath.SetAttribute("alias", $Arg1)
                $newPath.SetAttribute("location", $Arg2)
                $config.QuickPaths.Paths.AppendChild($newPath) | Out-Null
                $config.Save($script:QuickPathsFile)
                Write-Host "Added: $Arg1 -> $Arg2" -ForegroundColor Green
            }
            '^(rm|remove)$' {
                if (-not $Arg1) {
                    throw "Usage: q rm <alias>"
                }
                $pathToRemove = $config.QuickPaths.Paths.Path | 
                    Where-Object { $_.alias -eq $Arg1 }
                if ($pathToRemove) {
                    $config.QuickPaths.Paths.RemoveChild($pathToRemove) | Out-Null
                    $config.Save($script:QuickPathsFile)
                    Write-Host "Removed: $Arg1" -ForegroundColor Yellow
                }
            }
            '^(ls|list)$' {
                Write-Host "`nQuick Paths:" -ForegroundColor Cyan
                $config.QuickPaths.Paths.Path | Format-Table @{
                    Label = "Alias"
                    Expression = { $_.alias }
                    Width = 15
                }, @{
                    Label = "Location"
                    Expression = { $_.location }
                }
            }
            '^(open)$' {
                # Implementation of 'q open' command
                try {
                    $currentPath = Get-Location
                    Write-Verbose "Attempting to open File Explorer at location: $currentPath"
                    
                    # Validate current path exists
                    if (-not (Test-Path -Path $currentPath)) {
                        throw "Current path does not exist: $currentPath"
                    }
                    
                    # Start File Explorer process
                    $process = Start-Process -FilePath "explorer" -ArgumentList "." -ErrorAction Stop
                    
                    # Provide success feedback
                    Write-Host "Opened File Explorer in: $currentPath" -ForegroundColor Green
                    Write-Verbose "Process started successfully with ID: $($process.Id)"
                }
                catch {
                    # Detailed error handling
                    $errorMessage = "Failed to open File Explorer: $($_.Exception.Message)"
                    Write-Error -Message $errorMessage -Category OperationStopped
                    Write-Verbose "Stack Trace: $($_.Exception.StackTrace)"
                    
                    # Provide resolution steps
                    Write-Warning "Please ensure you have sufficient permissions and Explorer.exe is accessible"
                }
            }
           '^(backup)$' {
            $backupPath = script:Backup-QuickPathsConfig -Path $script:QuickPathsFile
                if ($backupPath) {
                    Write-Host "Backup created: $backupPath" -ForegroundColor Green
                }
            }
           '^(import)$' {
                # Parameter validation
                if (-not $Arg1) {
                    throw "Usage: q import <path> [-merge|-replace|-skip]"
                }

                # Resolve full path
                $importPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Arg1)
                Write-Verbose "Resolved import path: $importPath"

                # File validation
                if (-not (Test-Path -Path $importPath -PathType Leaf)) {
                    throw "Import file not found: $importPath"
                }

                # Strategy determination based on switches
                $strategy = 'Skip' # Default strategy
                if ($Merge) { $strategy = 'Merge' }
                elseif ($Replace) { $strategy = 'Replace' }

                Write-Verbose "Using merge strategy: $strategy"

                # Perform import
                $result = Import-QuickPathsConfig -Path $importPath -Strategy $strategy
                if (-not $result) {
                    throw "Import failed - check previous errors"
                }
            }

                        '^(help|\?)$' {

                Write-Host "Quick-Paths Commands:" -ForegroundColor Yellow
    
                # Navigation and Basic Commands
                Write-Host "    " -NoNewline; Write-Host "q " -NoNewline -ForegroundColor White; Write-Host "<alias>" -ForegroundColor Cyan -NoNewline; Write-Host " " -NoNewline; Write-Host "->" -ForegroundColor Yellow -NoNewline; Write-Host " Jump to location" -ForegroundColor Green
                Write-Host "    " -NoNewline; Write-Host "q add" -ForegroundColor White -NoNewline; Write-Host " " -NoNewline; Write-Host "<alias> <path>" -ForegroundColor Cyan -NoNewline; Write-Host " " -NoNewline; Write-Host "->" -ForegroundColor Yellow -NoNewline; Write-Host " Add new location" -ForegroundColor Green
                Write-Host "    " -NoNewline; Write-Host "q rm" -ForegroundColor White -NoNewline; Write-Host " " -NoNewline; Write-Host "<alias>" -ForegroundColor Cyan -NoNewline; Write-Host " " -NoNewline; Write-Host "->" -ForegroundColor Yellow -NoNewline; Write-Host " Remove location" -ForegroundColor Green
                Write-Host "    " -NoNewline; Write-Host "q ls" -ForegroundColor White -NoNewline; Write-Host " " -NoNewline; Write-Host "->" -ForegroundColor Yellow -NoNewline; Write-Host " List locations" -ForegroundColor Green
                Write-Host "    " -NoNewline; Write-Host "q open" -ForegroundColor White -NoNewline; Write-Host " " -NoNewline; Write-Host "->" -ForegroundColor Yellow -NoNewline; Write-Host " Open File Explorer in current directory" -ForegroundColor Green

                # Configuration Management
                Write-Host "`nConfig Management:" -ForegroundColor Yellow
                Write-Host "    " -NoNewline; Write-Host "q import" -ForegroundColor White -NoNewline; Write-Host " " -NoNewline; Write-Host "<path>" -ForegroundColor Cyan -NoNewline; Write-Host " " -NoNewline; Write-Host "->" -ForegroundColor Yellow -NoNewline; Write-Host " Import paths (skip duplicates)" -ForegroundColor Green
                Write-Host "    " -NoNewline; Write-Host "q import" -ForegroundColor White -NoNewline; Write-Host " " -NoNewline; Write-Host "<path> -merge" -ForegroundColor Cyan -NoNewline; Write-Host " " -NoNewline; Write-Host "->" -ForegroundColor Yellow -NoNewline; Write-Host " Import and rename duplicates" -ForegroundColor Green
                Write-Host "    " -NoNewline; Write-Host "q import" -ForegroundColor White -NoNewline; Write-Host " " -NoNewline; Write-Host "<path> -replace" -ForegroundColor Cyan -NoNewline; Write-Host " " -NoNewline; Write-Host "->" -ForegroundColor Yellow -NoNewline; Write-Host " Import and replace duplicates" -ForegroundColor Green
                Write-Host "    " -NoNewline; Write-Host "q backup" -ForegroundColor White -NoNewline; Write-Host " " -NoNewline; Write-Host "->" -ForegroundColor Yellow -NoNewline; Write-Host " Create configuration backup" -ForegroundColor Green
                
                # Help and Information
                Write-Host "    " -NoNewline; Write-Host "q help" -ForegroundColor White -NoNewline; Write-Host " " -NoNewline; Write-Host "->" -ForegroundColor Yellow -NoNewline; Write-Host " Show this help`n" -ForegroundColor Green
                
                Write-Host "Examples:" -ForegroundColor Yellow
                Write-Host "    " -NoNewline; Write-Host "q add" -ForegroundColor White -NoNewline; Write-Host " " -NoNewline; Write-Host "dev ." -ForegroundColor Cyan -NoNewline; Write-Host " " -NoNewline; Write-Host "->" -ForegroundColor Yellow -NoNewline; Write-Host " Add current directory" -ForegroundColor Green
                Write-Host "    " -NoNewline; Write-Host "q" -ForegroundColor White -NoNewline; Write-Host " " -NoNewline; Write-Host "dev" -ForegroundColor Cyan -NoNewline; Write-Host " " -NoNewline; Write-Host "->" -ForegroundColor Yellow -NoNewline; Write-Host " Jump to dev location" -ForegroundColor Green
                Write-Host "    " -NoNewline; Write-Host "q import" -ForegroundColor White -NoNewline; Write-Host " " -NoNewline; Write-Host "common-paths.xml -merge" -ForegroundColor Cyan -NoNewline; Write-Host " " -NoNewline; Write-Host "->" -ForegroundColor Yellow -NoNewline; Write-Host " Import configuration" -ForegroundColor Green
                Write-Host "    " -NoNewline; Write-Host "q backup" -ForegroundColor White -NoNewline; Write-Host " " -NoNewline; Write-Host "->" -ForegroundColor Yellow -NoNewline; Write-Host " Create backup before changes`n" -ForegroundColor Green
            }
            default {
                if ([string]::IsNullOrWhiteSpace($Command)) {
                    $config.QuickPaths.Paths.Path | Format-Table @{
                        Label = "Alias"; Expression = { $_.alias }; Width = 15
                    }, @{
                        Label = "Location"; Expression = { $_.location }
                    }
                    return
                }

                $targetPath = $config.QuickPaths.Paths.Path | 
                    Where-Object { $_.alias -eq $Command }
                if ($targetPath) {
                    Set-Location -Path $targetPath.location
                    Write-Host "-> $($targetPath.location)" -ForegroundColor Green
                }
                else {
                    throw "Unknown alias '$Command'. Use 'q ls' to see available paths."
                }
            }
        }
    }
    catch {
        Write-Error $_
    }
}

# Only update the tab completion part - no other changes needed
# Tab completion registration for Quick-Paths
Register-ArgumentCompleter -CommandName qp -ParameterName Command -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    
    try {
        # Get aliases from configuration
        [xml]$config = Get-Content -Path $script:QuickPathsFile
        
        # Define base commands including new 'open' command
        $commands = @(
            'add',    # Add new path
            'rm',     # Remove path
            'ls',     # List paths
            'list',   # Alternate list command
            'help',   # Show help
            'import', # Import configuration
            'backup', # Backup configuration
            'open'    # New command for opening Explorer
        )
        
        # Combine commands and aliases
        $completions = @($commands) + @($config.QuickPaths.Paths.Path.alias)
        
        # Handle import parameter completions
        if ($commandAst.CommandElements.Count -gt 1 -and 
            $commandAst.CommandElements[1].Value -eq 'import' -and
            $wordToComplete -like '-*') {
            
            @('-merge', '-replace', '-skip') | 
                Where-Object { $_ -like "$wordToComplete*" } | 
                ForEach-Object {
                    [CompletionResult]::new($_, $_, 'ParameterValue', $_)
                }
        }
        
        # Return matching completions
        $completions | 
            Where-Object { $_ -like "$wordToComplete*" } | 
            ForEach-Object {
                [CompletionResult]::new($_, $_, 'ParameterValue', $_)
            }
    }
    catch {
        Write-Verbose "Tab completion error: $_"
        # Silently fail for tab completion
    }
}
