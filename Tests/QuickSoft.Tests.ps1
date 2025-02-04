BeforeAll {
    # Import the module
    $ModulePath = Split-Path -Parent $PSScriptRoot
    Import-Module (Join-Path $ModulePath "QuickSoft.psd1") -Force
}

Describe "QuickSoft Module Tests" {
    Context "Module Loading" {
        It "Module should be loaded" {
            Get-Module QuickSoft | Should -Not -BeNull
        }
    }
}

AfterAll {
    Remove-Module QuickSoft -Force -ErrorAction SilentlyContinue
}