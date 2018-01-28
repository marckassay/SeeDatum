Import-Module -Name $PSScriptRoot\..\SeeDatum -Verbose -Force

Describe "Test Get-Bytes" {
    Context "with file" {
        InModuleScope SeeDatum {
            # Using Pester's TestDrive: https://github.com/pester/Pester/wiki/TestDrive
            Copy-Item -Path "resource\index.html" -Destination "TestDrive:\"
        
            It "Should contain DecimalByte key and expected values" -TestCases @(
                @{  Path = "TestDrive:\index.html" }) {
                Param($Path)

                $Results = Get-Bytes -Path $Path | Select-Object -First 3

                $Results[0].ToString() | Should -eq 'System.Collections.Hashtable'
                $Results[0].ContainsKey('DecimalByte') | Should -Be $true

                $Results[0].DecimalByte | Should -Be 60
                $Results[1].DecimalByte | Should -Be 104
                $Results[2].DecimalByte | Should -Be 116
            }
        }
    }
    Context "with string" {
        InModuleScope SeeDatum {        
            It "Should contain DecimalByte key and expected values" -TestCases @(
                @{  Value = "Marc" }) {
                Param($Value)

                $Results = Get-Bytes -Value $Value | Select-Object
                
                $Results[0].ToString() | Should -eq 'System.Collections.Hashtable'
                $Results[0].ContainsKey('DecimalByte') | Should -Be $true

                $Results[0].DecimalByte | Should -Be 77
                $Results[1].DecimalByte | Should -Be 97
                $Results[2].DecimalByte | Should -Be 114
                $Results[3].DecimalByte | Should -Be 99
            }
        }
    }
}

Describe "Test ConvertTo-Binary" {
    Context "with Octet format" {
        InModuleScope SeeDatum {
            # Using Pester's TestDrive: https://github.com/pester/Pester/wiki/TestDrive
            Copy-Item -Path "resource\index.html" -Destination "TestDrive:\"
        
            It "Should contain DecimalByte key, Binary key and expected values" -TestCases @(
                @{  Path = "TestDrive:\index.html" }) {
                Param($Path)

                $Results = Get-Bytes -Path $Path | ConvertTo-Binary | Select-Object -First 3

                $Results[0].ToString() | Should -eq 'System.Collections.Hashtable'
                $Results[0].ContainsKey('DecimalByte') | Should -Be $true
                $Results[0].ContainsKey('Binary') | Should -Be $true

                $Results[0].Binary | Should -Be '00111100'
                $Results[1].Binary | Should -Be '01101000'
                $Results[2].Binary | Should -Be '01110100'
            }
        }
    }
    Context "with Quartets format" {
        InModuleScope SeeDatum {
            # Using Pester's TestDrive: https://github.com/pester/Pester/wiki/TestDrive
            Copy-Item -Path "resource\index.html" -Destination "TestDrive:\"
        
            It "Should contain DecimalByte key, Binary key and expected values" -TestCases @(
                @{  Path = "TestDrive:\index.html" }) {
                Param($Path)

                $Results = Get-Bytes -Path $Path | ConvertTo-Binary -Format Quartets | Select-Object -First 3
                
                $Results[0].ToString() | Should -eq 'System.Collections.Hashtable'
                $Results[0].ContainsKey('DecimalByte') | Should -Be $true
                $Results[0].ContainsKey('Binary') | Should -Be $true

                $Results[0].Binary | Should -Be '0011 1100'
                $Results[1].Binary | Should -Be '0110 1000'
                $Results[2].Binary | Should -Be '0111 0100'
            }
        }
    }
}

Describe "Test ConvertTo-UTF8" {
    Context "from file" {
        InModuleScope SeeDatum {
            # Using Pester's TestDrive: https://github.com/pester/Pester/wiki/TestDrive
            Copy-Item -Path "resource\index.html" -Destination "TestDrive:\"
        
            It "Should contain DecimalByte key, Unicode key and expected values" -TestCases @(
                @{  Path = "TestDrive:\index.html" }) {
                Param($Path)

                $Results = Get-Bytes -Path $Path | ConvertTo-UTF8 | Select-Object -First 3

                $Results[0].ToString() | Should -eq 'System.Collections.Hashtable'
                $Results[0].ContainsKey('DecimalByte') | Should -Be $true
                $Results[0].ContainsKey('Unicode') | Should -Be $true

                $Results[0].Unicode | Should -Be 'U+003C'
                $Results[1].Unicode | Should -Be 'U+0068'
                $Results[2].Unicode | Should -Be 'U+0074'
            }
        }
    }
}

Describe "Test ConvertTo-Character" {
    Context "from string" {
        InModuleScope SeeDatum {        
            It "Should contain DecimalByte key, Character key and expected values" {

                $Results = Get-Bytes -Value 'Marc' | ConvertTo-Character
                
                $Results[0].ToString() | Should -eq 'System.Collections.Hashtable'
                $Results[0].ContainsKey('DecimalByte') | Should -Be $true
                $Results[0].ContainsKey('Character') | Should -Be $true

                $Results[0].Character | Should -Be 'M'
                $Results[1].Character | Should -Be 'a'
                $Results[2].Character | Should -Be 'r'
                $Results[3].Character | Should -Be 'c'
            }
        }
    }
}
Describe "Test Get-Bytes | ConvertTo-UTF8 | ConvertTo-Binary | ConvertTo-Character" {
    Context "from string" {
        InModuleScope SeeDatum { 
            It "Should contain DecimalByte key, Unicode key, Binary key, Character key and expected values" {
                $Results = Get-Bytes -Value 'Marc' | ConvertTo-UTF8 | ConvertTo-Binary -Format Quartets | ConvertTo-Character
                
                $Results[0].ToString() | Should -eq 'System.Collections.Hashtable'
                $Results[0].ContainsKey('DecimalByte') | Should -Be $true
                $Results[0].ContainsKey('Unicode') | Should -Be $true
                $Results[0].ContainsKey('Binary') | Should -Be $true
                $Results[0].ContainsKey('Character') | Should -Be $true

                $Results[0].Unicode | Should -Be 'U+004D'
                $Results[1].Unicode | Should -Be 'U+0061'
                $Results[2].Unicode | Should -Be 'U+0072'
                $Results[3].Unicode | Should -Be 'U+0063'

                $Results[0].Binary | Should -Be '0100 1101'
                $Results[1].Binary | Should -Be '0110 0001'
                $Results[2].Binary | Should -Be '0111 0010'
                $Results[3].Binary | Should -Be '0110 0011'

                $Results[0].Character | Should -Be 'M'
                $Results[1].Character | Should -Be 'a'
                $Results[2].Character | Should -Be 'r'
                $Results[3].Character | Should -Be 'c'
            }
        }
    }
}
