# SeeDatum

Converts a file or string value into decimal bytes which then can be piped into: `ConvertTo-UTF8`, `ConvertTo-Binary` and/or `ConvertTo-Character`

[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/marckassay/SeeDatum/blob/master/LICENSE) [![PS Gallery](https://img.shields.io/badge/install-PS%20Gallery-blue.svg)](https://www.powershellgallery.com/packages/SeeDatum/)

## Instructions

To install, run the following command in PowerShell.

```powershell
$ Install-Module SeeDatum
```

## Usage

### Get-Bytes

This is the catalyst function for this module's ConvertTo functions.

```powershell
C:\> Get-Bytes -Value "Marc"

Name                           Value
----                           -----
DecimalByte                    77
DecimalByte                    97
DecimalByte                    114
DecimalByte                    99
```

### ConvertTo-UTF8

This function must be piped after `Get-Bytes`.

```powershell
C:\> Get-Bytes -Value "Marc" | ConvertTo-UTF8

Name                           Value
----                           -----
DecimalByte                    77
Unicode                        U+004D
DecimalByte                    97
Unicode                        U+0061
DecimalByte                    114
Unicode                        U+0072
DecimalByte                    99
Unicode                        U+0063
```

### ConvertTo-Binary

This function must be piped after `Get-Bytes`.  This function has a `Format` parameter that defaults to Octet.  The other option value is Quartets.

```powershell
C:\> Get-Bytes -Value "Marc" | ConvertTo-Binary

Name                           Value
----                           -----
Binary                         01001101
DecimalByte                    77
Binary                         01100001
DecimalByte                    97
Binary                         01110010
DecimalByte                    114
Binary                         01100011
DecimalByte                    99
```

Or formatted in Quartets
```powershell
C:\> Get-Bytes -Value "Marc" | ConvertTo-Binary -Format Quartets

Name                           Value
----                           -----
Binary                         0100 1101
DecimalByte                    77
Binary                         0110 0001
DecimalByte                    97
Binary                         0111 0010
DecimalByte                    114
Binary                         0110 0011
DecimalByte                    99
```

### ConvertTo-Character

This function must be piped after `Get-Bytes`.

```powershell
C:\> Get-Bytes -Value "Marc" | ConvertTo-Character

Name                           Value
----                           -----
DecimalByte                    77
Character                      M
DecimalByte                    97
Character                      a
DecimalByte                    114
Character                      r
DecimalByte                    99
Character                      c
```

### Get-Bytes | ConvertTo-UTF8 | ConvertTo-Binary | ConvertTo-Character

```powershell
C:\> Get-Bytes -Value "Marc" | `
        ConvertTo-UTF8 | `
        ConvertTo-Character | `
        ConvertTo-Binary -Format Quartets | `
        ForEach-Object{[PSCustomObject]$_} | `
        Format-Table -AutoSize Character, DecimalByte, Unicode, Binary

Character DecimalByte Unicode Binary
--------- ----------- ------- ------
        M          77 U+004D  0100 1101
        a          97 U+0061  0110 0001
        r         114 U+0072  0111 0010
        c          99 U+0063  0110 0011
```