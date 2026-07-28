# Re-crea los junctions de palma hacia esta carpeta maestra (C:\DAG\Agents Team - DAG\agentes\palma).
# Uso: powershell -ExecutionPolicy Bypass -File "C:\DAG\Agents Team - DAG\agentes\palma\sincronizar.ps1"
# No requiere permisos de administrador (usa junctions de directorio).

$ErrorActionPreference = "Stop"
$master = "C:\DAG\Agents Team - DAG\agentes\palma"

$links = @(
    (Join-Path $env:USERPROFILE ".cursor\skills\palma"),
    (Join-Path $env:USERPROFILE ".claude\skills\palma"),
    (Join-Path $env:USERPROFILE ".claude-trabajo\skills\palma"),
    (Join-Path $env:USERPROFILE ".agents\skills\palma")
)

foreach ($l in $links) {
    $parent = Split-Path $l -Parent
    if (-not (Test-Path $parent)) { New-Item -ItemType Directory -Path $parent | Out-Null }
    if (Test-Path $l) { Remove-Item $l -Recurse -Force }
    cmd /c mklink /J "$l" "$master" | Out-Null
    $item = Get-Item $l -Force
    "{0} -> {1}" -f $l, $item.Target[0]
}

Write-Output "palma sincronizada. Origen unico: $master"
