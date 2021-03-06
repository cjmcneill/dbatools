﻿function Invoke-DbatoolsRenameHelper {
    <#
        .SYNOPSIS
            Older dbatools command names have been changed. This script helps keep up.

        .DESCRIPTION
            Older dbatools command names have been changed. This script helps keep up.

        .PARAMETER InputObject
            A piped in object from Get-ChildItem

        .PARAMETER Encoding
            Specifies the file encoding. The default is UTF8.

            Valid values are:
            -- ASCII: Uses the encoding for the ASCII (7-bit) character set.
            -- BigEndianUnicode: Encodes in UTF-16 format using the big-endian byte order.
            -- Byte: Encodes a set of characters into a sequence of bytes.
            -- String: Uses the encoding type for a string.
            -- Unicode: Encodes in UTF-16 format using the little-endian byte order.
            -- UTF7: Encodes in UTF-7 format.
            -- UTF8: Encodes in UTF-8 format.
            -- Unknown: The encoding type is unknown or invalid. The data can be treated as binary.

        .PARAMETER EnableException
            By default, when something goes wrong we try to catch it, interpret it and give you a friendly warning message.
            This avoids overwhelming you with "sea of red" exceptions, but is inconvenient because it basically disables advanced scripting.
            Using this switch turns this "nice by default" feature off and enables you to catch exceptions with your own try/catch.

        .PARAMETER WhatIf
            Shows what would happen if the command were to run. No actions are actually performed

        .PARAMETER Confirm
            Prompts you for confirmation before executing any changing operations within the command

        .NOTES
            Author: Chrissy LeMaire (@cl), netnerds.net
            Website: https://dbatools.io
            Copyright: (C) Chrissy LeMaire, clemaire@gmail.com
            License: MIT https://opensource.org/licenses/MIT

        .LINK
            https://dbatools.io/Invoke-DbatoolsRenameHelper

        .EXAMPLE
            Get-ChildItem C:\temp\ps\*.ps1 -Recurse | Invoke-DbatoolsRenameHelper

            Checks to see if any ps1 file in C:\temp\ps matches an old command name.
            If so, then the command name within the text is updated and the resulting changes are written to disk in UTF-8.

        .EXAMPLE
            Get-ChildItem C:\temp\ps\*.ps1 -Recurse | Invoke-DbatoolsRenameHelper -Encoding Ascii -WhatIf

            Shows what would happen if the command would run. If the command would run and there were matches,
            the resulting changes would be written to disk as Ascii encoded.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [parameter(Mandatory, ValueFromPipeline)]
        [System.IO.FileInfo[]]$InputObject,
        [ValidateSet('ASCII', 'BigEndianUnicode', 'Byte', 'String', 'Unicode', 'UTF7', 'UTF8', 'Unknown')]
        [string]$Encoding = 'UTF8',
        [switch]$EnableException
    )
    process {
        foreach ($file in $InputObject) {
            foreach ($name in $script:renames) {
                if ((Select-String -Pattern $name.AliasName -Path $file)) {
                    if ($Pscmdlet.ShouldProcess($file, "Replacing $($name.AliasName) with $($name.Definition)")) {
                        (Get-Content -Path $file -Raw).Replace($name.AliasName, $name.Definition) | Set-Content -Path $file -Encoding $Encoding
                        [pscustomobject]@{
                            Path = $file
                            Command = $name.AliasName
                            ReplacedWith = $name.Definition
                        }
                    }
                }
            }
        }
    }
}