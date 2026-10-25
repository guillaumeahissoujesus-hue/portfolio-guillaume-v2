$raw = Get-Content -Path "realisations.json" -Raw -Encoding UTF8
$items = $raw | ConvertFrom-Json

$sb = New-Object System.Text.StringBuilder
[void]$sb.AppendLine("// Catalogue des réalisations de Guillaume Ahissou")
[void]$sb.AppendLine("var REALISATIONS_DATA = [")

$count = $items.Count
for ($i = 0; $i -lt $count; $i++) {
    $item = $items[$i]
    $comma = if ($i -lt ($count - 1)) { "," } else { "" }
    
    # Clean titles for display
    $title = $item.title
    $orig = $item.origName.ToLower()
    
    if ($orig -match '12m2 ford isuzu') {
        $title = "Affichage Grand Format (12 m²) · Ford & Isuzu D-Max"
    } elseif ($orig -match '12m2 ford territory') {
        $title = "Affichage Grand Format (12 m²) · Ford Territory"
    } elseif ($orig -match '20m45sur8m10') {
        $title = "Panneau Monumental (20,45 m x 8,10 m) · Ford Territory"
    } elseif ($orig -match '21m.+everest') {
        $title = "Affichage Grand Format (21 m²) · Ford Everest"
    } elseif ($orig -match '21m.+territory') {
        $title = "Affichage Grand Format (21 m²) · Ford Territory"
    } elseif ($orig -match 'abs market') {
        $title = "Campagne Visuelle · ABS Market Place"
    } elseif ($orig -match 'abs benin') {
        $title = "Identité Commerciale · ABS Bénin"
    } elseif ($orig -match 'cif') {
        $title = "Campagne Publicitaire & Affiche · CIF"
    } elseif ($orig -match 'tpe') {
        $title = "Affiche Institutionnelle · TPE"
    } elseif ($orig -match 'campagne2') {
        $title = "Campagne Visuelle & Promotionnelle"
    } elseif ($orig -match 'glory-marh') {
        $title = "Conception Logotype · Glory Marh"
    } elseif ($orig -match 'shop-queen') {
        $title = "Identité de Marque & Logo · Shop Queen"
    } elseif ($orig -match 'logo 41') {
        $title = "Conception Graphique · Logo 41"
    } elseif ($orig -match 'logo-shop') {
        $title = "Création Logotype · Shop"
    } elseif ($orig -match 'logo2') {
        $title = "Création Logotype & Emblème"
    } elseif ($orig -match 'oui23now') {
        $title = "Identité Graphique · Oui 23 Now"
    } elseif ($orig -match 'pâtisserie|patisserie') {
        $title = "Affiche Événementielle · Formation Pâtisserie"
    } elseif ($orig -match 'fabrication') {
        $title = "Affiche Promotionnelle · Formation Fabrication"
    } elseif ($orig -match 'repation|portable') {
        $title = "Affiche Formation · Réparation GSM & Informatique"
    } elseif ($orig -match 'couture') {
        $title = "Affiche Commerciale · Couture & Esthétique"
    } elseif ($orig -match 'lundicitation') {
        $title = "Communication Social Media · Lundi Citation"
    } elseif ($orig -match 'excellence') {
        $title = "Affiche Corporate · Célébration de l'Excellence"
    } elseif ($orig -match 'dpmb') {
        $title = "Support Institutionnel · DPMB"
    } elseif ($orig -match 'mokette') {
        $title = "Conception Graphique · Mokette Don"
    } elseif ($orig -match 'produits') {
        $title = "Présentation Visuelle Produits"
    } elseif ($orig -match 'pub7') {
        $title = "Affiche Commerciale & Publicité"
    } elseif ($orig -match 'af de soutien') {
        $title = "Affiche Événementielle & Soutien"
    } elseif ($orig -match 'prospectus') {
        $title = "Prospectus & Dépliant Commercial"
    } else {
        if ($item.category -eq 'social-media') {
            $title = "Visuel Communication Digitale & Réseaux Sociaux #" + $item.id
        } elseif ($item.category -eq 'logos') {
            $title = "Création Graphique Logo #" + $item.id
        } else {
            $title = "Création Visuelle & Communication #" + $item.id
        }
    }
    
    $escapedTitle = $title.Replace('"', '\"')
    $escapedCategoryName = $item.categoryName.Replace('"', '\"')
    
    [void]$sb.AppendLine("  {")
    [void]$sb.AppendLine("    id: $($item.id),")
    [void]$sb.AppendLine("    slug: `"$($item.slug)`",")
    [void]$sb.AppendLine("    file: `"$($item.file)`",")
    [void]$sb.AppendLine("    title: `"$escapedTitle`",")
    [void]$sb.AppendLine("    category: `"$($item.category)`",")
    [void]$sb.AppendLine("    categoryName: `"$escapedCategoryName`",")
    [void]$sb.AppendLine("    width: $($item.width),")
    [void]$sb.AppendLine("    height: $($item.height)")
    [void]$sb.AppendLine("  }$comma")
}

[void]$sb.AppendLine("];")

[System.IO.File]::WriteAllText((Join-Path (Get-Location) "realisations-data.js"), $sb.ToString(), [System.Text.Encoding]::UTF8)
Write-Output "Successfully wrote realisations-data.js with $count items!"
