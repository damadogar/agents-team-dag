# Re-crea los junctions de vector hacia esta carpeta maestra (C:\DAG\Agents Team - DAG\agentes\vector).
# Uso: powershell -ExecutionPolicy Bypass -File "C:\DAG\Agents Team - DAG\agentes\vector\sincronizar.ps1"
# No requiere permisos de administrador (usa junctions de directorio).

$ErrorActionPreference = "Stop"
$master = "C:\DAG\Agents Team - DAG\agentes\vector"

$links = @(
    (Join-Path $env:USERPROFILE ".cursor\skills\vector"),
    (Join-Path $env:USERPROFILE ".claude\skills\vector"),
    (Join-Path $env:USERPROFILE ".claude-trabajo\skills\vector"),
    (Join-Path $env:USERPROFILE ".agents\skills\vector")
)

foreach ($l in $links) {
    $parent = Split-Path $l -Parent
    if (-not (Test-Path $parent)) { New-Item -ItemType Directory -Path $parent | Out-Null }
    if (Test-Path $l) { Remove-Item $l -Recurse -Force }
    cmd /c mklink /J "$l" "$master" | Out-Null
    $item = Get-Item $l -Force
    "{0} -> {1}" -f $l, $item.Target[0]
}

Write-Output "vector sincronizada. Origen unico: $master"
