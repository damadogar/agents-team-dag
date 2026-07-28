# Re-crea los junctions de peakformance hacia esta carpeta maestra (C:\DAG\Agents Team - DAG\agentes\peakformance).
# Uso: powershell -ExecutionPolicy Bypass -File "C:\DAG\Agents Team - DAG\agentes\peakformance\sincronizar.ps1"
# No requiere permisos de administrador (usa junctions de directorio).

$ErrorActionPreference = "Stop"
$master = "C:\DAG\Agents Team - DAG\agentes\peakformance"

$links = @(
    (Join-Path $env:USERPROFILE ".cursor\skills\peakformance"),
    (Join-Path $env:USERPROFILE ".claude\skills\peakformance"),
    (Join-Path $env:USERPROFILE ".claude-trabajo\skills\peakformance"),
    (Join-Path $env:USERPROFILE ".agents\skills\peakformance")
)

foreach ($l in $links) {
    $parent = Split-Path $l -Parent
    if (-not (Test-Path $parent)) { New-Item -ItemType Directory -Path $parent | Out-Null }
    if (Test-Path $l) { Remove-Item $l -Recurse -Force }
    cmd /c mklink /J "$l" "$master" | Out-Null
    $item = Get-Item $l -Force
    "{0} -> {1}" -f $l, $item.Target[0]
}

Write-Output "peakformance sincronizada. Origen unico: $master"
