﻿[CmdletBinding()]
param(
    [string]$PythonPath,
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$toolRoot = Join-Path $env:LOCALAPPDATA 'LiangHao\tools\markitdown'
$venvRoot = Join-Path $toolRoot '.venv'
$venvPython = Join-Path $venvRoot 'Scripts\python.exe'

function Find-Python {
    if ($PythonPath) {
        if (-not (Test-Path -LiteralPath $PythonPath -PathType Leaf)) {
            throw "找不到指定的 Python：$PythonPath"
        }
        return (Get-Item -LiteralPath $PythonPath).FullName
    }

    $candidates = @()
    $pythonCommand = Get-Command python.exe -ErrorAction SilentlyContinue
    if ($pythonCommand) { $candidates += $pythonCommand.Source }

    $localPrograms = Join-Path $env:LOCALAPPDATA 'Programs\Python'
    if (Test-Path -LiteralPath $localPrograms -PathType Container) {
        $candidates += Get-ChildItem -LiteralPath $localPrograms -Directory -Filter 'Python*' |
            Sort-Object Name -Descending |
            ForEach-Object { Join-Path $_.FullName 'python.exe' }
    }

    $codexRuntime = Join-Path $env:USERPROFILE '.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe'
    $candidates += $codexRuntime

    foreach ($candidate in ($candidates | Select-Object -Unique)) {
        if (-not (Test-Path -LiteralPath $candidate -PathType Leaf)) { continue }
        try {
            & $candidate -c 'import sys; raise SystemExit(0 if sys.version_info >= (3, 10) else 1)'
            if ($LASTEXITCODE -eq 0) { return (Get-Item -LiteralPath $candidate).FullName }
        } catch {
            continue
        }
    }
    throw '找不到可執行的 Python 3.10 以上版本。請使用 -PythonPath 指定 python.exe。'
}

if ($Force -and (Test-Path -LiteralPath $venvRoot)) {
    $item = Get-Item -LiteralPath $venvRoot -Force
    if (-not $item.PSIsContainer -or ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) {
        throw "拒絕移除非一般目錄：$venvRoot"
    }
    Remove-Item -LiteralPath $venvRoot -Recurse
}

$python = Find-Python
if (-not (Test-Path -LiteralPath $venvPython -PathType Leaf)) {
    New-Item -ItemType Directory -Path $toolRoot -Force | Out-Null
    & $python -m venv $venvRoot
    if ($LASTEXITCODE -ne 0) { throw '建立 MarkItDown 虛擬環境失敗。' }
}

& $venvPython -m pip install --upgrade pip
if ($LASTEXITCODE -ne 0) { throw '更新 pip 失敗。' }
& $venvPython -m pip install 'markitdown[pdf,docx,pptx,xlsx,xls]==0.1.7'
if ($LASTEXITCODE -ne 0) { throw '安裝 MarkItDown 失敗。' }
& $venvPython -m markitdown --version
if ($LASTEXITCODE -ne 0) { throw 'MarkItDown 安裝後驗證失敗。' }

Write-Output "MarkItDown 已安裝：$venvRoot"
