$json = Get-Content "C:\Users\M23UF01\OneDrive - SI2M\IA\Prototype-App-ECE\data_output.json" -Raw | ConvertFrom-Json
Write-Output "JSON is valid"
Write-Output "Enterprises: $($json.groupe.entreprises.Count)"
foreach ($e in $json.groupe.entreprises) {
    Write-Output "  $($e.id) $($e.nom): $($e.salaries.Count) employees"
}
$total = 0; foreach($e in $json.groupe.entreprises){ $total += $e.salaries.Count }
Write-Output "Total employees: $total"
Write-Output "Resume effectif: $($json.resume.effectifTotal)"
Write-Output "Resume cadres: $($json.resume.cadres)"
Write-Output "Resume nonCadres: $($json.resume.nonCadres)"
Write-Output "Resume masse: $($json.resume.masseSalariale)"
Write-Output "Resume avg: $($json.resume.salaireMoyen)"
Write-Output "Resume arret days: $($json.resume.joursArretActifs)"
Write-Output "Resume cotisation: $($json.resume.cotisationMensuelle)"
Write-Output "Jan bordereau: $($json.cotisations.bordereaux[0].montantTotal)"
Write-Output "Feb bordereau: $($json.cotisations.bordereaux[1].montantTotal)"
Write-Output "Active arrets: $($json.arretsDetravail.arrets.Count)"
Write-Output "Historique: $($json.arretsDetravail.historique.Count)"

$cadres = 0; $nc = 0
foreach($ent in $json.groupe.entreprises) {
    foreach($s in $ent.salaries) {
        if ($s.statut -eq "cadre") { $cadres++ } else { $nc++ }
    }
}
Write-Output "Actual cadres: $cadres, non-cadres: $nc"

$sa=0;$su=0;$pr=0
foreach($ent in $json.groupe.entreprises) {
    foreach($s in $ent.salaries) {
        if ($s.affiliations.santeObligatoire) { $sa++ }
        if ($s.affiliations.surcoFacultative) { $su++ }
        if ($s.affiliations.prevoyance) { $pr++ }
    }
}
Write-Output "Actual sante: $sa, surco: $su, prev: $pr"

$days = 0
foreach($a in $json.arretsDetravail.arrets) { $days += $a.nbJours }
Write-Output "Active arret total days: $days"

$sitMap = @{}
foreach($ent in $json.groupe.entreprises) {
    foreach($s in $ent.salaries) {
        if (-not $sitMap.ContainsKey($s.situationFamiliale)) { $sitMap[$s.situationFamiliale] = 0 }
        $sitMap[$s.situationFamiliale]++
    }
}
foreach($k in $sitMap.Keys) { Write-Output "  ${k}: $($sitMap[$k])" }

# Check Jan detail sums
$jd = $json.cotisations.bordereaux[0].detail
$jSum = $jd.santeObligatoire + $jd.surcoFacultative + $jd.prevoyanceCadre + $jd.prevoyanceNonCadre
Write-Output "Jan detail sum: $jSum (target: $($json.cotisations.bordereaux[0].montantTotal))"

$fd = $json.cotisations.bordereaux[1].detail
$fSum = $fd.santeObligatoire + $fd.surcoFacultative + $fd.prevoyanceCadre + $fd.prevoyanceNonCadre
Write-Output "Feb detail sum: $fSum (target: $($json.cotisations.bordereaux[1].montantTotal))"
