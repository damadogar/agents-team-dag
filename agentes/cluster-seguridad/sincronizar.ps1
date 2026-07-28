# Re-crea los junctions del Cluster Seguridad hacia esta carpeta maestra (C:\DAG\Agents Team - DAG\agentes\cluster-seguridad).
# Uso: powershell -ExecutionPolicy Bypass -File "C:\DAG\Agents Team - DAG\agentes\cluster-seguridad\sincronizar.ps1"
# No requiere permisos de administrador (usa junctions de directorio).

$ErrorActionPreference = "Stop"
$master = "C:\DAG\Agents Team - DAG\agentes\cluster-seguridad"

$links = @(
    (Join-Path $env:USERPROFILE ".cursor\skills\cluster-seguridad"),
    (Join-Path $env:USERPROFILE ".claude\skills\cluster-seguridad"),
    (Join-Path $env:USERPROFILE ".claude-trabajo\skills\cluster-seguridad"),
    (Join-Path $env:USERPROFILE ".agents\skills\cluster-seguridad")
)

foreach ($l in $links) {
    $parent = Split-Path $l -Parent
    if (-not (Test-Path $parent)) { New-Item -ItemType Directory -Path $parent | Out-Null }
    if (Test-Path $l) { Remove-Item $l -Recurse -Force }
    cmd /c mklink /J "$l" "$master" | Out-Null
    $item = Get-Item $l -Force
    "{0} -> {1}" -f $l, $item.Target[0]
}

Write-Output "Cluster Seguridad sincronizado. Origen unico: $master"
