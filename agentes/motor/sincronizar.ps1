# Re-crea los junctions de Motor hacia esta carpeta maestra (C:\DAG\Agents Team - DAG\agentes\motor).
# Uso: powershell -ExecutionPolicy Bypass -File "C:\DAG\Agents Team - DAG\agentes\motor\sincronizar.ps1"
# No requiere permisos de administrador (usa junctions de directorio).

$ErrorActionPreference = "Stop"
$master = "C:\DAG\Agents Team - DAG\agentes\motor"

$links = @(
    (Join-Path $env:USERPROFILE ".cursor\skills\motor"),
    (Join-Path $env:USERPROFILE ".claude\skills\motor"),
    (Join-Path $env:USERPROFILE ".claude-trabajo\skills\motor"),
    (Join-Path $env:USERPROFILE ".agents\skills\motor")
)

foreach ($l in $links) {
    $parent = Split-Path $l -Parent
    if (-not (Test-Path $parent)) { New-Item -ItemType Directory -Path $parent | Out-Null }
    if (Test-Path $l) { Remove-Item $l -Recurse -Force }
    cmd /c mklink /J "$l" "$master" | Out-Null
    $item = Get-Item $l -Force
    "{0} -> {1}" -f $l, $item.Target[0]
}

Write-Output "Motor sincronizada. Origen unico: $master"
