# Re-crea los junctions de Brujula hacia esta carpeta maestra (C:\DAG\Agents Team - DAG\agentes\brujula).
# Uso: powershell -ExecutionPolicy Bypass -File "C:\DAG\Agents Team - DAG\agentes\brujula\sincronizar.ps1"
# No requiere permisos de administrador (usa junctions de directorio).

$ErrorActionPreference = "Stop"
$master = "C:\DAG\Agents Team - DAG\agentes\brujula"

$links = @(
    (Join-Path $env:USERPROFILE ".cursor\skills\brujula"),
    (Join-Path $env:USERPROFILE ".claude\skills\brujula"),
    (Join-Path $env:USERPROFILE ".claude-trabajo\skills\brujula"),
    (Join-Path $env:USERPROFILE ".agents\skills\brujula")
)

foreach ($l in $links) {
    $parent = Split-Path $l -Parent
    if (-not (Test-Path $parent)) { New-Item -ItemType Directory -Path $parent | Out-Null }
    if (Test-Path $l) { Remove-Item $l -Recurse -Force }
    cmd /c mklink /J "$l" "$master" | Out-Null
    $item = Get-Item $l -Force
    "{0} -> {1}" -f $l, $item.Target[0]
}

Write-Output "Brujula sincronizada. Origen unico: $master"
