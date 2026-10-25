Add-Type -AssemblyName System.Drawing

$srcDir = "image"
$destDir = "realisations_img"

if (-not (Test-Path $destDir)) {
    New-Item -ItemType Directory -Path $destDir | Out-Null
}

function Get-JpegCodec {
    foreach ($codec in [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders()) {
        if ($codec.MimeType -eq "image/jpeg") {
            return $codec
        }
    }
    return $null
}

$jpegCodec = Get-JpegCodec
$encoderParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
$encoderParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, [long]82)

$files = Get-ChildItem -Path $srcDir -File | Where-Object { $_.Extension -match '\.(jpg|jpeg|png)$' }

$items = @()
$counter = 1

foreach ($file in $files) {
    try {
        $sourcePath = $file.FullName
        $img = [System.Drawing.Image]::FromFile($sourcePath)
        
        $origW = $img.Width
        $origH = $img.Height
        $maxDim = 1000
        
        $newW = $origW
        $newH = $origH
        
        if ($origW -gt $maxDim -or $origH -gt $maxDim) {
            if ($origW -gt $origH) {
                $newW = $maxDim
                $newH = [int](($origH * $maxDim) / $origW)
            } else {
                $newH = $maxDim
                $newW = [int](($origW * $maxDim) / $origH)
            }
        }
        
        $bmp = New-Object System.Drawing.Bitmap($newW, $newH)
        $g = [System.Drawing.Graphics]::FromImage($bmp)
        $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
        $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
        $g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
        
        $rect = New-Object System.Drawing.Rectangle(0, 0, $newW, $newH)
        $g.DrawImage($img, $rect)
        
        # Clean slug name
        $slug = "visuel-" + ($counter.ToString("D2"))
        $destFile = "$destDir\$slug.jpg"
        
        $bmp.Save($destFile, $jpegCodec, $encoderParams)
        
        $g.Dispose()
        $bmp.Dispose()
        $img.Dispose()
        
        $fileSize = (Get-Item $destFile).Length
        
        # Determine category & title
        $nameLower = $file.Name.ToLower()
        $category = "campagnes"
        $categoryName = "Campagne & Affiche"
        $title = $file.BaseName
        
        if ($nameLower -match 'logo') {
            $category = "logos"
            $categoryName = "Logo & Identité"
        } elseif ($nameLower -match '12m2|20m|21m|panneau') {
            $category = "grands-formats"
            $categoryName = "Grand Format / Panneau"
        } elseif ($nameLower -match 'whatsapp|-exe--post') {
            $category = "social-media"
            $categoryName = "Communication Digitale"
        } elseif ($nameLower -match 'formation|couture|soutien|prospectus') {
            $category = "evenements"
            $categoryName = "Événement & Formation"
        }
        
        # Humanize title
        if ($nameLower -match 'ford territory') { $title = "Affichage Panneau · Ford Territory" }
        elseif ($nameLower -match 'ford isuzu') { $title = "Affichage Panneau · Ford & Isuzu D-Max" }
        elseif ($nameLower -match 'everest') { $title = "Affichage Panneau · Ford Everest" }
        elseif ($nameLower -match 'glory-marh') { $title = "Identité Visuelle · Glory Marh" }
        elseif ($nameLower -match 'shop-queen') { $title = "Création Logotype · Shop Queen" }
        elseif ($nameLower -match 'abs market') { $title = "Communication · ABS Market Place" }
        elseif ($nameLower -match 'abs benin') { $title = "Campagne · ABS Bénin" }
        elseif ($nameLower -match 'cif') { $title = "Campagne Publicitaire · CIF" }
        elseif ($nameLower -match 'tpe') { $title = "Affiche Institutionnelle · TPE" }
        elseif ($nameLower -match 'pâtisserie|patisserie') { $title = "Affiche Promotionnelle · Formation Pâtisserie" }
        elseif ($nameLower -match 'fabrication') { $title = "Affiche · Formation Pratique" }
        elseif ($nameLower -match 'repation|portable') { $title = "Affiche · Formation GSM & Ordinateurs" }
        elseif ($nameLower -match 'couture') { $title = "Communication · Couture & Esthétique" }
        elseif ($nameLower -match 'lundicitation') { $title = "Visuel Social Media · Lundi Citation" }
        elseif ($nameLower -match 'excellence') { $title = "Affiche · Célébration de l'Excellence" }
        elseif ($nameLower -match 'dpmb') { $title = "Support Visuel · DPMB" }
        else {
            if ($category -eq "social-media") { $title = "Visuel Communication Social Media #$counter" }
            elseif ($category -eq "logos") { $title = "Conception Graphique Logo #$counter" }
            else { $title = "Création Graphique & Campagne #$counter" }
        }
        
        $items += [PSCustomObject]@{
            id = $counter
            slug = $slug
            file = "$destDir/$slug.jpg"
            title = $title
            category = $category
            categoryName = $categoryName
            origName = $file.Name
            origSize = $file.Length
            compressedSize = $fileSize
            width = $newW
            height = $newH
        }
        
        Write-Output "[$counter] Processed $($file.Name) -> $slug.jpg ($([math]::Round($fileSize/1KB, 1)) KB vs $([math]::Round($file.Length/1MB, 2)) MB)"
        $counter++
    } catch {
        Write-Warning "Failed on $($file.Name): $_"
    }
}

$items | ConvertTo-Json -Depth 4 | Set-Content "realisations.json" -Encoding UTF8
Write-Output "Done! Processed $($items.Count) images."
