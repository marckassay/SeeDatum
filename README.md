# EndOfLine

Objective of this module is conversion of end-of-line (EOL) characters in UTF-8 files: CRLF to LF or LF to CRLF

[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/marckassay/EndOfLine/blob/master/LICENSE) [![PS Gallery](https://img.shields.io/badge/install-PS%20Gallery-blue.svg)](https://www.powershellgallery.com/packages/EndOfLine/)

## Features

* Imports `.gitignore` file for exclusion of files and directories, if there is a file.  You can use `SkipIgnoreFile` switch to prevent importing that file.  And you can switch `Exclude` to add additional items to be excluded.
* Simulate what will happen via `WhatIf` switch
* Outputs a report on all files.  The `Verbose` switch can be used too.

## Caveat

* At first, use the -WhatIf switch parameter to see what files will be modified.
* Files are expected to be encoded in UTF-8.  If encoded in anything else it will not be modified.
* There is a limitation of exclusion of items.   This module recurses a function that uses `Get-ChildItems` with its `Exclude` parameter.  Excluded items that get passed to `Exclude` must have the value the name (eg: log.txt, *.txt) only.  As-is the code will not recongize exlcuded items by sub path.

## Instructions

To install, run the following command in PowerShell.

```powershell
$ Install-Module EndOfLine
```

This module imports 'Encoding' by [Chris Kuech](https://github.com/chriskuech).

[![PS Gallery](https://img.shields.io/badge/Encoding-PS%20Gallery-blue.svg)](https://www.powershellgallery.com/packages/Encoding)

## Usage

### ConvertTo-LF

```powershell
ConvertTo-LF [-Path] <String[]> [[-Exclude] <String[]>]
[-SkipIgnoreFile] [-ExportReportData] [-WhatIf] [<CommonParameters>]
```

Converts CRLF to LF characters.
This function will recursively read all files within the `Path` unless excluded by `.gitignore` file.  If a file is not excluded it is read to see if the current EOL character is the same as requested.  If so it will not modify the file.  And if the file is encoded other then UTF-8, it will not be modified.

Example using the `WhatIf`, and `Verbose` switch.

```powershell
$ ConvertTo-LF -Path C:\repos\AiT -WhatIf -Verbose
```

For this example, if you agree when prompted files will be modified without import of `.gitignore` file.

```powershell
$ ConvertTo-LF -Path C:\repos\AiT -SkipIgnoreFile
```

If omitting `gitignore` file, it would be good to exclude modules too.

```powershell
$ ConvertTo-LF -Path C:\repos\AiT -Exclude .\node_modules\, .\out\ -SkipIgnoreFile
```

If you agree when prompted, files will be modified with import of `.gitignore` file if found.

```powershell
$ ConvertTo-LF -Path C:\repos\AiT
```

### ConvertTo-CRLF

```powershell
ConvertTo-CRLF [-Path] <String[]> [[-Exclude] <String[]>] 
[-SkipIgnoreFile] [-ExportReportData] [-WhatIf] [<CommonParameters>]
```

Converts LF to CRLF characters.
Besides the characters that will be replaced, all things that apply in `ConvertTo-LF` apply to this function too.