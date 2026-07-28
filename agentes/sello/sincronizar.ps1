# Re-crea los junctions de Sello hacia esta carpeta maestra (C:\DAG\Agents Team - DAG\agentes\sello).
# Uso: powershell -ExecutionPolicy Bypass -File "C:\DAG\Agents Team - DAG\agentes\sello\sincronizar.ps1"
# No requiere permisos de administrador (usa junctions de directorio).

$ErrorActionPreference = "Stop"
$master = "C:\DAG\Agents Team - DAG\agentes\sello"

$links = @(
    (Join-Path $env:USERPROFILE ".cursor\skills\sello"),
    (Join-Path $env:USERPROFILE ".claude\skills\sello"),
    (Join-Path $env:USERPROFILE ".claude-trabajo\skills\sello"),
    (Join-Path $env:USERPROFILE ".agents\skills\sello")
)

foreach ($l in $links) {
    $parent = Split-Path $l -Parent
    if (-not (Test-Path $parent)) { New-Item -ItemType Directory -Path $parent | Out-Null }
    if (Test-Path $l) { Remove-Item $l -Recurse -Force }
    cmd /c mklink /J "$l" "$master" | Out-Null
    $item = Get-Item $l -Force
    "{0} -> {1}" -f $l, $item.Target[0]
}

Write-Output "Sello sincronizada. Origen unico: $master"
