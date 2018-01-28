
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
    end {
        if ($Path) {
            Get-Item $Path | Get-Content -Raw | ForEach-Object -Process { [System.Text.Encoding]::UTF8.GetBytes($_) }
        }
        else {
            $Value | ForEach-Object -Process { [System.Text.Encoding]::UTF8.GetBytes($_) } | `
                ForEach-Object -Process { 
                $ConvertedBytes = ${DecimalByte: $_}
                Write-Output -InputObject $ConvertedBytes  -NoEnumerate
            }
        }
    }
}

function ConvertTo-Binary {
    [CmdletBinding()]
    [OutputType([string])]
    Param(
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [byte[]]$Bytes,

        [Parameter(Mandatory = $true)]
        [ValidateSet("Octet", "Quartet")]
        [ValidateNotNullOrEmpty()]
        [string]$Format = "Octet",

        [switch]$ShowDecimalNotation
    )
    process {
        $DecimalByte = $_
        $OriginalDecimalByte = $DecimalByte
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

        if ($ShowDecimalNotation.IsPresent -eq $false) {
            $BString = "$BString"
        }
        else { 
            $BString = "$BString".Insert(0, $("$OriginalDecimalByte".PadRight(4) + " : "))
        }

        $BString
    }
}
<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.PARAMETER Bytes
Parameter description

.PARAMETER ShowDecimalNotation
Parameter description

.EXAMPLE
Get-Bytes E:\index.html | ConvertTo-UTF8 -ShowDecimalNotation
Get-Item E:\index.html | Get-Bytes | ConvertTo-UTF8 -ShowDecimalNotation
Get-Bytes -Value "Marc" | ConvertTo-UTF8 -ShowDecimalNotation

.NOTES
General notes
#>
function ConvertTo-UTF8 {
    [CmdletBinding()]
    [OutputType([string])]
    Param(
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [byte[]]$Bytes,

        [switch]$ShowDecimalNotation
    )

    begin {
        [string[]]$HexDecimalTable = '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'
    }

    process {
        if ($_.DecimalByte)
        $Point = $_
        # BMP (Basic Multilingual Plane) only.
        if ($Point -lt 65536) {
            # $Subplane represents blocks of 4096 code points
            $Subplane = $HexDecimalTable[[Math]::Floor($Point / [Math]::Pow(16, 3) % 16)]
            # $256Block represents blocks of 256 code points
            $256Block = $HexDecimalTable[[Math]::Floor($Point / [Math]::Pow(16, 2) % 16)]
            $PointRow = $HexDecimalTable[[Math]::Floor($Point / 16) % 16]
            $PointCol = $HexDecimalTable[$Point % 16]
            $Unicode = "$Subplane$256Block$PointRow$PointCol".Insert(0, 'U+')

            if ($ShowDecimalNotation.IsPresent -eq $true) { 
                $Unicode = $Unicode.Insert(0, $("$Point".PadRight(4) + " : "))
            }
        }
        else {
            $Unicode = "U+FFFF"
        }
        $Out = @{Point = $Point
            Unicode = $Unicode
        } 
        $InformationPreference = 'Continue'
        Write-Information -MessageData $Out -PipelineVariable XXX
    }
}

function ConvertTo-Character {
    [CmdletBinding()]
    [OutputType([string])]
    Param(
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        $XXX,

        [switch]$Show
    )

    begin {

    }

    process {
        $XXX.Unicode
    }
}

Export-ModuleMember -Function Get-Bytes
Export-ModuleMember -Function ConvertTo-Binary
Export-ModuleMember -Function ConvertTo-UTF8
Export-ModuleMember -Function ConvertTo-Character