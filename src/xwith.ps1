#!/usr/bin/env pwsh
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest


function xwith {
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [hashtable] $Environment,

        [Parameter(Mandatory = $true, Position = 1)]
        [scriptblock] $ScriptBlock,

        [Parameter(Mandatory = $false, Position = 2, ValueFromRemainingArguments = $true)]
        [object[]] $ScriptBlockArgs = @(),

        [Parameter(Mandatory = $false, Position = 4, ValueFromPipeline = $true)]
        [object] $InputObject = $null
    )
    # Save the environment variables.
    [hashtable] $oldEnvironment = @{}
    foreach ($key in $Environment.Keys) {
        if (Test-Path Env:$key -ErrorAction SilentlyContinue) {
            $oldEnvironment[$key] = Get-EnvVar -Process -Name $key -Value
        }
    }

    try {
        # Override the environment variables.
        foreach ($key in $Environment.Keys) {
            if ($Environment[$key]) {
                Set-EnvVar -Process -Name $key -Value $Environment[$key]
            } else {
                Remove-EnvVar -Process -Name $key -ErrorAction SilentlyContinue
            }
        }

        # Invoke the script block.
        if ($InputObject) {
            $InputObject | Invoke-Command -ScriptBlock $ScriptBlock -ArgumentList $ScriptBlockArgs
        } else {
            & $ScriptBlock @ScriptBlockArgs
        }
    }
    finally {
        # Remove the overridden environment variables.
        foreach ($key in $Environment.Keys) {
            Remove-EnvVar -Process -Name $key -ErrorAction SilentlyContinue
        }

        # Restore the saved environment variables.
        foreach ($key in $oldEnvironment.Keys) {
            Set-EnvVar -Process -Name $key -Value $oldEnvironment[$key]
        }
    }
}
