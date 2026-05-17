# swap-photo.ps1
#
# Mini-utilitaire pour remplacer la photo de profil du CV thierryvm.github.io.
# Prend une image source (n'importe quel format supporté par .NET System.Drawing),
# la redimensionne en carré 800x800 centré, l'enregistre en JPEG qualité 90 sous
# le nom attendu par le repo (portrait_CV.JPEG), et affiche les instructions
# d'upload sur GitHub.
#
# Usage :
#   .\swap-photo.ps1 -SourcePath "C:\Users\thier\Pictures\nouvelle-photo.jpg"
#   .\swap-photo.ps1 -SourcePath "..." -OutputDir "C:\Users\thier\Desktop"
#
# Auteur : @cowork (Cowork desktop, Anthropic Claude Opus)
# Date   : 2026-05-17

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, HelpMessage = "Chemin absolu vers la photo source.")]
    [string]$SourcePath,

    [Parameter(HelpMessage = "Dossier de sortie. Defaut : meme dossier que swap-photo.ps1.")]
    [string]$OutputDir = $PSScriptRoot,

    [Parameter(HelpMessage = "Taille du carre final en pixels. Defaut : 800.")]
    [int]$Size = 800,

    [Parameter(HelpMessage = "Qualite JPEG (1-100). Defaut : 90.")]
    [int]$Quality = 90,

    [Parameter(HelpMessage = "Nom du fichier de sortie. Defaut : portrait_CV.JPEG.")]
    [string]$OutputName = "portrait_CV.JPEG"
)

$ErrorActionPreference = "Stop"

function Write-Step($message, $color = "Cyan") {
    Write-Host ""
    Write-Host "==> $message" -ForegroundColor $color
}

function Write-Success($message) {
    Write-Host "    [OK] $message" -ForegroundColor Green
}

function Write-Info($message) {
    Write-Host "    $message" -ForegroundColor Gray
}

function Write-Warn($message) {
    Write-Host "    [!]  $message" -ForegroundColor Yellow
}

# 1. Validations
Write-Step "Validation des entrees"

if (-not (Test-Path $SourcePath)) {
    Write-Host "    [X] La photo source est introuvable : $SourcePath" -ForegroundColor Red
    exit 1
}

$sourceFile = Get-Item $SourcePath
$sourceSizeKB = [math]::Round($sourceFile.Length / 1KB, 1)
Write-Success "Source : $($sourceFile.Name) ($sourceSizeKB KB)"

if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
    Write-Info "Dossier de sortie cree : $OutputDir"
}

$outputPath = Join-Path $OutputDir $OutputName
Write-Info "Cible : $outputPath"

if ($Size -lt 200 -or $Size -gt 4000) {
    Write-Host "    [X] Taille hors limites (200-4000 px) : $Size" -ForegroundColor Red
    exit 1
}

if ($Quality -lt 50 -or $Quality -gt 100) {
    Write-Host "    [X] Qualite hors limites (50-100) : $Quality" -ForegroundColor Red
    exit 1
}

# 2. Chargement de l'image source via System.Drawing
Write-Step "Chargement de la photo source"

Add-Type -AssemblyName System.Drawing

try {
    $sourceImage = [System.Drawing.Image]::FromFile($SourcePath)
}
catch {
    Write-Host "    [X] Format d'image non supporte ou fichier corrompu." -ForegroundColor Red
    Write-Host "    Detail : $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

$origWidth = $sourceImage.Width
$origHeight = $sourceImage.Height
Write-Success "Dimensions originales : ${origWidth}x${origHeight} px"

# 3. Calcul du crop carre centre
Write-Step "Crop carre centre + resize ${Size}x${Size}"

$cropSide = [math]::Min($origWidth, $origHeight)
$cropX = [math]::Floor(($origWidth - $cropSide) / 2)
$cropY = [math]::Floor(($origHeight - $cropSide) / 2)

Write-Info "Carre centre : (${cropX},${cropY}) ${cropSide}x${cropSide}"

# 4. Creation du bitmap final ${Size}x${Size}
$finalBitmap = New-Object System.Drawing.Bitmap $Size, $Size
$finalBitmap.SetResolution(72, 72)

$graphics = [System.Drawing.Graphics]::FromImage($finalBitmap)
$graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
$graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality

$srcRect = New-Object System.Drawing.Rectangle $cropX, $cropY, $cropSide, $cropSide
$dstRect = New-Object System.Drawing.Rectangle 0, 0, $Size, $Size
$graphics.DrawImage($sourceImage, $dstRect, $srcRect, [System.Drawing.GraphicsUnit]::Pixel)

# 5. Sauvegarde en JPEG avec qualite custom
Write-Step "Sauvegarde JPEG qualite $Quality"

$jpegCodec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.FormatID -eq [System.Drawing.Imaging.ImageFormat]::Jpeg.Guid }
$encoderParams = New-Object System.Drawing.Imaging.EncoderParameters 1
$qualityParam = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, [int64]$Quality)
$encoderParams.Param[0] = $qualityParam

$finalBitmap.Save($outputPath, $jpegCodec, $encoderParams)

# 6. Cleanup
$graphics.Dispose()
$finalBitmap.Dispose()
$sourceImage.Dispose()

$outputFile = Get-Item $outputPath
$outputSizeKB = [math]::Round($outputFile.Length / 1KB, 1)
Write-Success "Genere : $($outputFile.Name) ($outputSizeKB KB, ${Size}x${Size})"

# 7. Instructions upload
Write-Step "Etapes suivantes pour publier sur thierryvm.github.io" "Yellow"
Write-Host ""
Write-Host "    1. Ouvre dans ton navigateur :" -ForegroundColor White
Write-Host "       https://github.com/thierryvm/thierryvm.github.io/upload/main/images" -ForegroundColor Cyan
Write-Host ""
Write-Host "    2. Glisse-depose le fichier suivant dans la zone d'upload :" -ForegroundColor White
Write-Host "       $outputPath" -ForegroundColor Cyan
Write-Host ""
Write-Host "    3. Renomme-le en ``portrait_CV.JPEG`` si l'extension differe" -ForegroundColor White
Write-Host "       (case-sensitive, le repo utilise le nom exact ``portrait_CV.JPEG``)." -ForegroundColor White
Write-Host ""
Write-Host "    4. Commit message suggere :" -ForegroundColor White
Write-Host "       chore(cv): update portrait photo" -ForegroundColor Cyan
Write-Host ""
Write-Host "    5. ``Commit directly to main`` -> Commit changes" -ForegroundColor White
Write-Host ""
Write-Host "    6. GitHub Pages redeploie automatiquement en ~30 secondes." -ForegroundColor White
Write-Host "       Verifie le rendu live a : https://thierryvm.github.io/" -ForegroundColor Cyan
Write-Host ""

Write-Step "Done"
Write-Success "Photo prete pour upload."
Write-Host ""
