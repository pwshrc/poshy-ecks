#!/usr/bin/env pwsh
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest


<#
.SYNOPSIS
    Executes the specified script block in the specified directory.
#>
function xin {
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string] $Path,

        [Parameter(Mandatory = $true, Position = 1)]
        [scriptblock] $ScriptBlock,

        [Parameter(Mandatory = $false, Position = 2, ValueFromRemainingArguments = $true)]
        [object[]] $ScriptBlockArgs = @(),

        [Parameter(Mandatory = $false, Position = 4, ValueFromPipeline = $true)]
        [object] $InputObject = $null
    )

    Push-Location $Path | Out-Null
    try {
        # Invoke the script block.
        if ($InputObject) {
            $InputObject | Invoke-Command -ScriptBlock $ScriptBlock -ArgumentList $ScriptBlockArgs
        } else {
            & $ScriptBlock @ScriptBlockArgs
        }
    } finally {
        Pop-Location | Out-Null
    }
}
