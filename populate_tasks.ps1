# populate_tasks.ps1
# Regenerates values.csv for every benchmark task folder with 20 rows at a fixed seed.
# Run this from the repo root or from anywhere - it uses the script's own location to find benchmark folder (Spatial Reasoning).
# Usage: .\populate_tasks.ps1
# Optional: .\populate_tasks.ps1 -Seed 99 -N 30

param(
    [int]$Seed = 42,
    [int]$N    = 30
)

$ScriptDir   = Split-Path -Parent $MyInvocation.MyCommand.Path
$BenchDir    = Join-Path $ScriptDir "src\spatialreasoning"
$Python      = "python"

function Run-Generator {
    param(
        [string]$Script,
        [string]$Folder,
        [string]$Dim,
        [string]$Mode
    )

    $args = @($Script, $Folder, $N, "--dim", $Dim, "--seed", $Seed)
    if ($Mode) { $args += @("--mode", $Mode) }

    Write-Host "  Populating $Folder ..."
    & $Python @args
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed: $Script $Folder"
        exit 1
    }
}

Push-Location $BenchDir

Write-Host ""
Write-Host "Populating rotation tasks (seed=$Seed, n=$N)"
Write-Host "----------------------------------------------"
Run-Generator "gen_rotations.py" "final_2d_rotations_single" "2" "single"
Run-Generator "gen_rotations.py" "final_2d_rotations_multi"  "2" "multi"
Run-Generator "gen_rotations.py" "final_3d_rotations_single" "3" "single"
Run-Generator "gen_rotations.py" "final_3d_rotations_multi"  "3" "multi"

Write-Host ""
Write-Host "Populating translation tasks (seed=$Seed, n=$N)"
Write-Host "------------------------------------------------"
Run-Generator "gen_translations.py" "final_2d_translations_single" "2" "single"
Run-Generator "gen_translations.py" "final_2d_translations_multi"  "2" "multi"
Run-Generator "gen_translations.py" "final_3d_translations_single" "3" "single"
Run-Generator "gen_translations.py" "final_3d_translations_multi"  "3" "multi"

Write-Host ""
Write-Host "Populating combined transformation tasks (seed=$Seed, n=$N)"
Write-Host "-------------------------------------------------------------"
Run-Generator "gen_combined.py" "final_2d_combined_transformations_multi" "2" ""
Run-Generator "gen_combined.py" "final_3d_combined_transformations_multi" "3" ""

Pop-Location

Write-Host ""
Write-Host "Done. All task folders populated."
