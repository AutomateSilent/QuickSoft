BeforeAll {
    # Import the module
    $ModulePath = Split-Path -Parent $PSScriptRoot
    Import-Module (Join-Path $ModulePath "QuickSoft.psd1") -Force
}

Describe "Get-Software" {
    Context "Function Availability" {
        It "Get-Software command should be available" {
            Get-Command -Name Get-Software -ErrorAction SilentlyContinue | Should -Not -BeNull
        }
    }

    Context "Parameter Validation" {
        $command = Get-Command -Name Get-Software

        It "Should have a Name parameter" {
            $command.Parameters.ContainsKey('Name') | Should -Be $true
        }
    }

    # Basic functionality test - this will always pass as it just checks if the function returns something
    Context "Basic Functionality" {
        It "Should return software information" {
            $result = Get-Software
            $result | Should -Not -BeNull
        }
    }
}

AfterAll {
    Remove-Module QuickSoft -ErrorAction SilentlyContinue
}