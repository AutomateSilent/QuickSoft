# Template for function tests
BeforeAll {
    $ModulePath = Split-Path -Parent $PSScriptRoot
    Import-Module (Join-Path $ModulePath "QuickSoft.psd1") -Force
}

Describe "Function-Name" {
    Context "Parameter Validation" {
        BeforeAll {
            $Command = Get-Command -Name Function-Name
        }

        It "Has proper CmdletBinding attribute" {
            $Command.CmdletBinding | Should -Be $true
        }

        It "Has proper parameter attributes" {
            $Command.Parameters['ParameterName'].Attributes | 
                Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] } |
                Should -Not -BeNull
        }

        It "Supports wildcards for search parameters" {
            $Command.Parameters['SearchParam'].Attributes |
                Where-Object { $_ -is [System.Management.Automation.SupportsWildcardsAttribute] } |
                Should -Not -BeNull
        }
    }

    Context "Help Content" {
        BeforeAll {
            $Help = Get-Help -Name Function-Name -Full
        }

        It "Has synopsis" {
            $Help.Synopsis | Should -Not -BeNullOrEmpty
        }

        It "Has description" {
            $Help.Description | Should -Not -BeNullOrEmpty
        }

        It "Has examples" {
            $Help.Examples | Should -Not -BeNullOrEmpty
        }

        It "Has all parameter descriptions" {
            $Help.Parameters.Parameter.Description | Should -Not -BeNullOrEmpty
        }
    }

    Context "Error Handling" {
        It "Handles invalid input gracefully" {
            { Function-Name -InvalidParam } | Should -Throw
        }

        It "Provides meaningful error messages" {
            $ErrorMessage = $null
            try {
                Function-Name -InvalidParam
            }
            catch {
                $ErrorMessage = $_.Exception.Message
            }
            $ErrorMessage | Should -Not -BeNullOrEmpty
        }
    }
}

AfterAll {
    Remove-Module QuickSoft -ErrorAction SilentlyContinue
}