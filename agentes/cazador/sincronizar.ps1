# Re-crea los junctions de cazador hacia esta carpeta maestra (C:\DAG\Agents Team - DAG\agentes\cazador).
# Uso: powershell -ExecutionPolicy Bypass -File "C:\DAG\Agents Team - DAG\agentes\cazador\sincronizar.ps1"
# No requiere permisos de administrador (usa junctions de directorio).

$ErrorActionPreference = "Stop"
$master = "C:\DAG\Agents Team - DAG\agentes\cazador"

$links = @(
    (Join-Path $env:USERPROFILE ".cursor\skills\cazador"),
    (Join-Path $env:USERPROFILE ".claude\skills\cazador"),
    (Join-Path $env:USERPROFILE ".claude-trabajo\skills\cazador"),
    (Join-Path $env:USERPROFILE ".agents\skills\cazador")
)

foreach ($l in $links) {
    $parent = Split-Path $l -Parent
    if (-not (Test-Path $parent)) { New-Item -ItemType Directory -Path $parent | Out-Null }
    if (Test-Path $l) { Remove-Item $l -Recurse -Force }
    cmd /c mklink /J "$l" "$master" | Out-Null
    $item = Get-Item $l -Force
    "{0} -> {1}" -f $l, $item.Target[0]
}

Write-Output "cazador sincronizada. Origen unico: $master"
