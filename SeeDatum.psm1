<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.PARAMETER Path
Parameter description

.PARAMETER Value
Parameter description

.EXAMPLE
C:\> $R = Get-Bytes -Value "Marc" | ConvertTo-UTF8 | ConvertTo-Character | ConvertTo-Binary -Format Quartet
C:\> $R.ForEach({[PSCustomObject]$_}) | Format-Table -AutoSize Character, DecimalByte, Unicode, Binary

Character DecimalByte Unicode Binary
--------- ----------- ------- ------
        M          77 U+004D  0100 1101
        a          97 U+0061  0110 0001
        r         114 U+0072  0111 0010
        c          99 U+0063  0110 0011

.NOTES
General notes
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
    process {
        if ($Path) {
            $Value = Get-Item $Path | Get-Content -Raw
        }

        $Value | ForEach-Object {
            [System.Text.Encoding]::UTF8.GetBytes($_)
        }  | ForEach-Object {
            Write-Output -InputObject @{'DecimalByte' = $_}
        } 
    }
}

function ConvertTo-Binary {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [PSCustomObject []]$ConvertedBytes,

        [Parameter(Mandatory = $false)]
        [ValidateSet("Octet", "Quartet")]
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