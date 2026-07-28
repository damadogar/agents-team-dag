# Re-crea los junctions de docpower hacia esta carpeta maestra (C:\DAG\Agents Team - DAG\agentes\docpower).
# Uso: powershell -ExecutionPolicy Bypass -File "C:\DAG\Agents Team - DAG\agentes\docpower\sincronizar.ps1"
# No requiere permisos de administrador (usa junctions de directorio).

$ErrorActionPreference = "Stop"
$master = "C:\DAG\Agents Team - DAG\agentes\docpower"

$links = @(
    (Join-Path $env:USERPROFILE ".cursor\skills\docpower"),
    (Join-Path $env:USERPROFILE ".claude\skills\docpower"),
    (Join-Path $env:USERPROFILE ".claude-trabajo\skills\docpower"),
    (Join-Path $env:USERPROFILE ".agents\skills\docpower")
)

foreach ($l in $links) {
    $parent = Split-Path $l -Parent
    if (-not (Test-Path $parent)) { New-Item -ItemType Directory -Path $parent | Out-Null }
    if (Test-Path $l) { Remove-Item $l -Recurse -Force }
    cmd /c mklink /J "$l" "$master" | Out-Null
    $item = Get-Item $l -Force
    "{0} -> {1}" -f $l, $item.Target[0]
}

Write-Output "docpower sincronizada. Origen unico: $master"
