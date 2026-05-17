# Swap photo CV — utilitaire PowerShell

Petit script Windows pour remplacer la photo de profil du CV publié sur https://thierryvm.github.io/, en garantissant le **format attendu** (carré 800×800, JPEG qualité 90).

## Pourquoi ce script ?

Le CV affiche la photo via une balise `<img class="avatar" src="./images/portrait_CV.JPEG" width="180" height="180">`. Le navigateur fait un redimensionnement côté client, ce qui peut donner un rendu **flou** ou **granuleux** si la photo source est :

- de dimensions trop petites (< 360 px)
- de format rectangulaire non-carré (le `object-fit: cover` du CSS recadre arbitrairement)
- de qualité JPEG trop compressée

Ce script prend ta photo source (n'importe quel format), **crop carré centré**, **resize 800×800**, et sauvegarde en JPEG qualité 90 sous le bon nom de fichier.

## Pré-requis

- **Windows 10/11** avec PowerShell 5.1+ (intégré nativement) ou PowerShell 7+ (`pwsh`)
- Une photo source quelconque (JPEG, PNG, BMP, TIFF, GIF…)
- (Optionnel) Un compte GitHub connecté pour l'upload final via web UI

Aucune dépendance externe (ImageMagick, ffmpeg, etc.) — le script utilise `System.Drawing` qui est built-in dans .NET Framework / .NET Core sur Windows.

## Usage minimal

```powershell
# Depuis le dossier qui contient swap-photo.ps1
.\swap-photo.ps1 -SourcePath "C:\Users\thier\Pictures\nouvelle-photo.jpg"
```

Le fichier généré `portrait_CV.JPEG` apparaît dans le **même dossier que le script** par défaut.

## Options

| Paramètre | Type | Défaut | Description |
|---|---|---|---|
| `-SourcePath` | string | *(requis)* | Chemin absolu vers la photo source |
| `-OutputDir` | string | dossier du script | Dossier de sortie |
| `-Size` | int | `800` | Côté du carré final en pixels (200-4000) |
| `-Quality` | int | `90` | Qualité JPEG (50-100) |
| `-OutputName` | string | `portrait_CV.JPEG` | Nom du fichier de sortie |

## Exemples

```powershell
# Cas le plus simple — photo dans Pictures, output à côté du script
.\swap-photo.ps1 -SourcePath "$env:USERPROFILE\Pictures\selfie-2026.jpg"

# Output sur le Bureau pour drag-and-drop facile vers le navigateur
.\swap-photo.ps1 `
  -SourcePath "$env:USERPROFILE\Pictures\selfie-2026.jpg" `
  -OutputDir "$env:USERPROFILE\Desktop"

# Version plus haute résolution (1200x1200) si le CV est mis à jour pour
# afficher plus grand
.\swap-photo.ps1 `
  -SourcePath ".\selfie-2026.jpg" `
  -Size 1200 `
  -Quality 92
```

## Conseils pour une bonne photo source

Pour un rendu net, la photo source doit idéalement faire **au moins 1200×1200 px** avant traitement. Quelques conseils rapides :

- **Lumière naturelle** (près d'une fenêtre, jour). Évite le néon et le tungstène pur.
- **Fond uni** ou avec un peu de profondeur de champ (mode portrait smartphone).
- **Visage centré**, regard caméra ou légèrement de côté, sourire naturel ou expression neutre.
- **Tenue sobre** (pull, chemise) — éviter les motifs très chargés qui distraient.
- **Smartphone récent en mode portrait** (iPhone 12+, Pixel 6+, Galaxy S20+) suffit largement.
- **Recadre légèrement** si possible avant import : épaules + tête bien visibles, pas trop éloigné, pas trop serré.

Le script s'occupe du carré centré, mais si le sujet est **excentré dans la photo**, le crop carré peut couper un peu. Mieux vaut une source déjà bien cadrée.

## Workflow complet

1. **Prendre / sélectionner** une nouvelle photo (JPEG, PNG, peu importe)
2. **Lancer le script** :
   ```powershell
   .\swap-photo.ps1 -SourcePath "<chemin\vers\photo>"
   ```
3. **Vérifier le fichier généré** (ouvrir dans une visionneuse pour valider le rendu)
4. **Uploader sur GitHub** :
   - Ouvre https://github.com/thierryvm/thierryvm.github.io/upload/main/images
   - Glisse-dépose `portrait_CV.JPEG` dans la zone d'upload
   - Commit message : `chore(cv): update portrait photo`
   - Commit directly to main
5. **Vérifier le résultat live** sur https://thierryvm.github.io/ (~30 secondes de redéploiement GitHub Pages)

## Dépannage

### "Format d'image non supporté"

`System.Drawing` supporte JPEG, PNG, BMP, GIF, TIFF, ICO. Si tu as un HEIC (iPhone) ou WebP, convertis-le d'abord via :
- L'app **Photos** de Windows (Enregistrer sous → JPEG)
- Le site **squoosh.app** (browser-only, privé, gratuit)
- IrfanView / GIMP

### "Le sujet est coupé"

Le script fait un **crop carré centré sur la photo**, pas sur le visage. Si ton visage est dans le coin gauche de la photo source, il sera coupé. Recadre manuellement la source pour que le sujet soit au centre, puis relance le script.

### "L'image générée fait moins de 800×800"

Le script **agrandit** une photo source plus petite, ce qui dégrade la qualité visuelle. Si ta source fait moins de 800 px de côté, prends une nouvelle photo plus grande (idéalement ≥ 1200 px).

### "Le rendu est encore flou sur thierryvm.github.io"

Vide le cache de ton navigateur (`Ctrl+Shift+R` sous Windows) — GitHub Pages cache les images agressivement. Ou ajoute `?v=2` à l'URL pour forcer le rechargement.

## Limites volontaires

- Pas de manipulation Git automatique (pas de `git add/commit/push`). Le repo `thierryvm.github.io` n'est pas censé être cloné localement pour ce simple cas d'usage. L'upload se fait via la web UI GitHub, plus simple et plus sûr.
- Pas de détection automatique du visage (pas de crop intelligent). Pour ça, il faudrait dlib ou OpenCV — overkill pour cet usage perso.
- Pas de support WebP en source (System.Drawing ne le supporte pas nativement). Convertis ta source en JPEG d'abord si elle est en WebP.

## Auteur & licence

Script généré par **@cowork** (Cowork desktop, Anthropic Claude Opus) le 17 mai 2026.
Usage libre dans le cadre du repo `thierryvm.github.io` (perso, non commercial).
