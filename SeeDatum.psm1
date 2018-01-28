<#
.SYNOPSIS
Can parse a string or file and outputs the values as decimal bytes in a PSCustomObject.

.DESCRIPTION
This function is the catalyst function for all three ConvertTo functions; ConvertTo-Binary, ConvertTo-Character, ConvertTo-UTF8

.PARAMETER Path
A path to a file

.PARAMETER Value
A string value

.EXAMPLE
Parses a string and pipes its bytes thru ConvertTo functions.

C:\> $R = Get-Bytes -Value "Marc" | ConvertTo-UTF8 | ConvertTo-Character | ConvertTo-Binary -Format Quartets
C:\> $R.ForEach({[PSCustomObject]$_}) | Format-Table -AutoSize Character, DecimalByte, Unicode, Binary

Character DecimalByte Unicode Binary
--------- ----------- ------- ------
        M          77 U+004D  0100 1101
        a          97 U+0061  0110 0001
        r         114 U+0072  0111 0010
        c          99 U+0063  0110 0011

.EXAMPLE
Parses a file and pipes its bytes thru ConvertTo functions.

C:\> $R = Get-Bytes -Path C:\repo\AIT\.editorconfig | ConvertTo-UTF8 | ConvertTo-Character | ConvertTo-Binary -Format Quartets
C:\> $R.ForEach({[PSCustomObject]$_}) | Format-Table -AutoSize Character, DecimalByte, Unicode, Binary

Character DecimalByte Unicode Binary
--------- ----------- ------- ------
        #          35 U+0023  0010 0011
                   32 U+0020  0010 0000
        E          69 U+0045  0100 0101
        d         100 U+0064  0110 0100
        i         105 U+0069  0110 1001
        t         116 U+0074  0111 0100
        o         111 U+006F  0110 1111
        r         114 U+0072  0111 0010
        C          67 U+0043  0100 0011
        o         111 U+006F  0110 1111
        n         110 U+006E  0110 1110
        f         102 U+0066  0110 0110
        i         105 U+0069  0110 1001
        g         103 U+0067  0110 0111
                   32 U+0020  0010 0000

#>
function Get-Bytes {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $false,
            ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Path,

        [Parameter(Mandatory = $false,
            ValueFromPipeline = $false)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Value
    )
    begin {
        if ($Path) {
            $Value = Get-Item $Path | Get-Content -Raw
        }
    }
    process {
        $Value | ForEach-Object -Process {
            [System.Text.Encoding]::UTF8.GetBytes($_)
        }  | ForEach-Object -Process {
            Write-Output -InputObject @{'DecimalByte' = $_}
        } 
    }
}

<#
.SYNOPSIS
To be piped after Get-Bytes function and will output binary notation from those bytes.

.DESCRIPTION
Long description

.PARAMETER ConvertedBytes
Pipeline value from Get-Bytes.

.PARAMETER Format
To show binary notation in an Octet or Quartets.

.EXAMPLE
Get-Bytes -Path C:\repo\AIT\.editorconfig | ConvertTo-UTF8 | ConvertTo-Character | ConvertTo-Binary -Format Quartets

.EXAMPLE
Parses a file and pipes its bytes thru ConvertTo functions.

C:\> $R = Get-Bytes -Path C:\repo\AIT\.editorconfig | ConvertTo-UTF8 | ConvertTo-Character | ConvertTo-Binary -Format Quartets
C:\> $R.ForEach({[PSCustomObject]$_}) | Format-Table -AutoSize Character, DecimalByte, Unicode, Binary

Character DecimalByte Unicode Binary
--------- ----------- ------- ------
        #          35 U+0023  0010 0011
                   32 U+0020  0010 0000
        E          69 U+0045  0100 0101
        d         100 U+0064  0110 0100
        i         105 U+0069  0110 1001
        t         116 U+0074  0111 0100
        o         111 U+006F  0110 1111
        r         114 U+0072  0111 0010
        C          67 U+0043  0100 0011
        o         111 U+006F  0110 1111
        n         110 U+006E  0110 1110
        f         102 U+0066  0110 0110
        i         105 U+0069  0110 1001
        g         103 U+0067  0110 0111
                   32 U+0020  0010 0000

#>
function ConvertTo-Binary {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [PSCustomObject []]$ConvertedBytes,

        [Parameter(Mandatory = $false)]
        [ValidateSet("Octet", "Quartets")]
        [string]$Format = "Octet"
    )
    begin {
        $OFS = ''
    }
    process {
        if ($_.DecimalByte) {
            $DecimalByte = $_.DecimalByte
            $buffer = [byte[]]::new(8)
            $bufferLength = $buffer.Length - 1

            while ( $bufferLength -ne 0 ) {
                $Q = $DecimalByte % 2
                $buffer[$bufferLength--] = $Q
                $DecimalByte = [Math]::Floor($DecimalByte * .5)
            }
        
            if ($Format -eq "Octet") {
                $BString = "$buffer"
            }
            else {
                $BString = "$buffer".Substring(0, 4) + " " + "$buffer".Substring(4)
            }

            $_.Add('Binary', $BString)
            
            Write-Output -InputObject $ConvertedBytes 
        }
    }
}

<#
.SYNOPSIS
To be piped after Get-Bytes function and will output Unicode from those bytes.

.DESCRIPTION
Long description

.PARAMETER ConvertedBytes
Pipeline value from Get-Bytes.

.EXAMPLE
C:\> Get-Bytes -Path C:\temp\AIT\.editorconfig | ConvertTo-UTF8

Name                           Value
----                           -----
DecimalByte                    35
Unicode                        U+0023
DecimalByte                    32
Unicode                        U+0020
DecimalByte                    69
Unicode                        U+0045

#>
function ConvertTo-UTF8 {
    [CmdletBinding()]
    [OutputType([string])]
    Param(
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [PSCustomObject[]]$ConvertedBytes
    )
    begin {
        [string[]]$HexDecimalTable = '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'
    }
    process {
        if ($_.DecimalByte) {

            $Point = $_.DecimalByte
            # BMP (Basic Multilingual Plane) only.
            if ($Point -lt 65536) {
                # $Subplane represents blocks of 4096 code points
                $Subplane = $HexDecimalTable[[Math]::Floor($Point / [Math]::Pow(16, 3) % 16)]
                # $256Block represents blocks of 256 code points
                $256Block = $HexDecimalTable[[Math]::Floor($Point / [Math]::Pow(16, 2) % 16)]
                $PointRow = $HexDecimalTable[[Math]::Floor($Point / 16) % 16]
                $PointCol = $HexDecimalTable[$Point % 16]
                $Unicode = "$Subplane$256Block$PointRow$PointCol".Insert(0, 'U+')
            }
            else {
                $Unicode = "U+FFFF"
            }

            $_.Add('Unicode', $Unicode)
            
            Write-Output $ConvertedBytes
        }
    }
}

<#
.SYNOPSIS
To be piped after Get-Bytes function and will add a Character key to the pipeline variable.

.DESCRIPTION
Long description

.PARAMETER ConvertedBytes
Pipeline value from Get-Bytes.

.EXAMPLE
Parses a file and pipes its bytes thru ConvertTo functions.

C:\> $R = Get-Bytes -Path C:\repo\AIT\.editorconfig | ConvertTo-UTF8 | ConvertTo-Character | ConvertTo-Binary -Format Quartets
C:\> $R.ForEach({[PSCustomObject]$_}) | Format-Table -AutoSize Character, DecimalByte, Unicode, Binary

Character DecimalByte Unicode Binary
--------- ----------- ------- ------
        #          35 U+0023  0010 0011
                   32 U+0020  0010 0000
        E          69 U+0045  0100 0101
        d         100 U+0064  0110 0100
        i         105 U+0069  0110 1001
        t         116 U+0074  0111 0100
        o         111 U+006F  0110 1111
        r         114 U+0072  0111 0010
        C          67 U+0043  0100 0011
        o         111 U+006F  0110 1111
        n         110 U+006E  0110 1110
        f         102 U+0066  0110 0110
        i         105 U+0069  0110 1001
        g         103 U+0067  0110 0111
                   32 U+0020  0010 0000

#>
function ConvertTo-Character {
    [CmdletBinding()]
    [OutputType([string])]
    Param(
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [PSCustomObject[]]$ConvertedBytes
    )
    process {
        if ($_.DecimalByte) {
        
            $_.Add('Character', [System.Convert]::ToChar($_.DecimalByte))
        
            Write-Output $ConvertedBytes
        }
    }
}

Export-ModuleMember -Function Get-Bytes
Export-ModuleMember -Function ConvertTo-Binary
Export-ModuleMember -Function ConvertTo-UTF8
Export-ModuleMember -Function ConvertTo-Character