[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$InputPath,
    [string]$OutputPath,
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$supportedExtensions = @(
    '.pdf', '.docx', '.pptx', '.xlsx', '.xls', '.html', '.htm',
    '.csv', '.json', '.xml', '.txt', '.zip', '.epub', '.jpg',
    '.jpeg', '.png', '.wav', '.mp3'
)
$venvRoot = Join-Path $env:LOCALAPPDATA 'LiangHao\tools\markitdown\.venv'
$markitdown = Join-Path $venvRoot 'Scripts\markitdown.exe'

if (-not (Test-Path -LiteralPath $markitdown -PathType Leaf)) {
    throw 'MarkItDown 尚未安裝。請先執行本 Skill 的 scripts\install.ps1。'
}

$inputItem = Get-Item -LiteralPath $InputPath -Force -ErrorAction Stop
if ($inputItem.PSIsContainer) { throw "輸入必須是檔案：$InputPath" }
if ($supportedExtensions -notcontains $inputItem.Extension.ToLowerInvariant()) {
    throw "不支援的副檔名：$($inputItem.Extension)"
}

if (-not $OutputPath) {
    $OutputPath = [IO.Path]::ChangeExtension($inputItem.FullName, '.md')
}
$outputFullPath = [IO.Path]::GetFullPath($OutputPath)
$outputParent = Split-Path -Parent $outputFullPath
if (-not (Test-Path -LiteralPath $outputParent -PathType Container)) {
    throw "輸出目錄不存在：$outputParent"
}
if (Test-Path -LiteralPath $outputFullPath) {
    if (-not $Force) { throw "輸出檔已存在；如需覆寫請加上 -Force：$outputFullPath" }
    $existing = Get-Item -LiteralPath $outputFullPath -Force
    if ($existing.PSIsContainer -or ($existing.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) {
        throw "拒絕覆寫非一般檔案：$outputFullPath"
    }
}

& $markitdown $inputItem.FullName -o $outputFullPath
if ($LASTEXITCODE -ne 0) { throw "MarkItDown 轉換失敗，結束碼：$LASTEXITCODE" }

$outputItem = Get-Item -LiteralPath $outputFullPath -Force -ErrorAction Stop
if ($outputItem.Length -eq 0) { throw "轉換結果為空檔案：$outputFullPath" }
Write-Output $outputItem.FullName
