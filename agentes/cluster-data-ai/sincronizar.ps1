# Re-crea los junctions del Cluster Data+IA hacia esta carpeta maestra (C:\DAG\Agents Team - DAG\agentes\cluster-data-ai).
# Uso: powershell -ExecutionPolicy Bypass -File "C:\DAG\Agents Team - DAG\agentes\cluster-data-ai\sincronizar.ps1"
# No requiere permisos de administrador (usa junctions de directorio).

$ErrorActionPreference = "Stop"
$master = "C:\DAG\Agents Team - DAG\agentes\cluster-data-ai"

$links = @(
    (Join-Path $env:USERPROFILE ".cursor\skills\cluster-data-ai"),
    (Join-Path $env:USERPROFILE ".claude\skills\cluster-data-ai"),
    (Join-Path $env:USERPROFILE ".claude-trabajo\skills\cluster-data-ai"),
    (Join-Path $env:USERPROFILE ".agents\skills\cluster-data-ai")
)

foreach ($l in $links) {
    $parent = Split-Path $l -Parent
    if (-not (Test-Path $parent)) { New-Item -ItemType Directory -Path $parent | Out-Null }
    if (Test-Path $l) { Remove-Item $l -Recurse -Force }
    cmd /c mklink /J "$l" "$master" | Out-Null
    $item = Get-Item $l -Force
    "{0} -> {1}" -f $l, $item.Target[0]
}

Write-Output "Cluster Data+IA sincronizado. Origen unico: $master"
