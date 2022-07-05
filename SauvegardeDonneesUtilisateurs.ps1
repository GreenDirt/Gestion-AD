<#

Auteur : Hugo Boilloux
Date : 25/05/2022
Version : 1.1
Révisions : 
-
Description :
Script de sauvegarde des dossiers utilisateur de l'AD avec gestion chronologique
Notes :
- Adaptez le code à l'active directory

#> 

$dateFormatee = Get-Date -UFormat "%m_%d_%Y"
$repertoireSauvegarde = "E:\Sauvegardes\" + $dateFormatee + "\"
if ( -not (Test-Path -Path $repertoireSauvegarde))          #Si pas de repertoire de sauvegarde on le crée
{
    New-Item -ItemType Directory -Path $repertoireSauvegarde
}
else                                                        #Si une sauvegarde à déja été faite on écrase la sauvegarde précédente en sauvegardant le fichier log
{
    $fichierLog = $repertoireSauvegarde + "logs.txt"
    Move-Item -Path $fichierLog -Destination "E:\"
    $listeDossiers = Get-ChildItem -Path $repertoireSauvegarde
    foreach($nom in $listeDossiers)
    {
        $nomComplet = $repertoireSauvegarde + $nom
        Remove-Item -Recurse $nomComplet
    }
    Move-Item -Path "E:\logs.txt" -Destination $repertoireSauvegarde
    
}

$fichierLog = $repertoireSauvegarde + "logs.txt"
if ( -not (Test-Path -Path $fichierLog))         #Si pas de fichier log on le crée
{
    New-Item -ItemType File -Path $fichierLog
}
$date =  Get-Date
$log = "Début de la sauvegarde du " + $date      #On log la date exacte
Add-Content -Path $fichierLog -Value $log


$repertoireDossiers = "E:\PartagesPersonnelsUtilisateurs\"
$listeDossiers = Get-ChildItem -Path $repertoireDossiers
foreach($nom in $listeDossiers)
{
    $lienComplet = $repertoireDossiers + $nom
    echo $lienComplet
    try
    {
        Copy-Item -Path $lienComplet -Destination $repertoireSauvegarde -Recurse
        $log = "Sauvegarde réussie de : " + $lienComplet
        echo $log
        Add-Content -Path $fichierLog -Value $log
    }
    catch
    {
        $log = "Erreur lors de la sauvegarde de " + $lienComplet
        echo $log
        Add-Content -Path $fichierLog -Value $log
    }
}
$log = "-------------Fin de la sauvegarde-------------"
echo $log
Add-Content -Path $fichierLog -Value $log