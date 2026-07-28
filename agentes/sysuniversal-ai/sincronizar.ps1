# Re-crea los junctions de SysUniversal-AI hacia esta carpeta maestra (C:\DAG\Agents Team - DAG\agentes\sysuniversal-ai).
# Uso: powershell -ExecutionPolicy Bypass -File "C:\DAG\Agents Team - DAG\agentes\sysuniversal-ai\sincronizar.ps1"
# No requiere permisos de administrador (usa junctions de directorio).

$ErrorActionPreference = "Stop"
$master = "C:\DAG\Agents Team - DAG\agentes\sysuniversal-ai"

$links = @(
    (Join-Path $env:USERPROFILE ".cursor\skills\sysuniversal-ai"),
    (Join-Path $env:USERPROFILE ".claude\skills\sysuniversal-ai"),
    (Join-Path $env:USERPROFILE ".claude-trabajo\skills\sysuniversal-ai"),
    (Join-Path $env:USERPROFILE ".agents\skills\sysuniversal-ai")
)

foreach ($l in $links) {
    $parent = Split-Path $l -Parent
    if (-not (Test-Path $parent)) { New-Item -ItemType Directory -Path $parent | Out-Null }
    if (Test-Path $l) { Remove-Item $l -Recurse -Force }
    cmd /c mklink /J "$l" "$master" | Out-Null
    $item = Get-Item $l -Force
    "{0} -> {1}" -f $l, $item.Target[0]
}

Write-Output "SysUniversal-AI sincronizada. Origen unico: $master"
