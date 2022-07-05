<#

Auteur : Hugo Boilloux
Date : 25/05/2022
Version : 1.1
Révisions : 
-
Description:
- Liste les membres d'un groupe Active Directory
- Liste les groupes associés à un utilisateur Active Directory

#>

$nomFichier = Read-Host "Entrez le nom du fichier à exporter"

$typeExport = Read-Host "Entrez la méthode de création des utilisateurs :`n1 : Membres d'un groupe`n2 : Groupes d'un utilisateur`n3 : Exporter l'ensemble des groupes`n4 : Exporter l'ensemble des utilisateurs`n-> choix "
if($typeExport -eq '1')
{
    $nomGroupe = Read-Host "Entrez le nom du groupe"
    $retourConsole = Get-ADGroupMember -Identity $nomGroupe | Format-Table Name, SamAccountName
    echo $retourConsole
    $retourExportable = Get-ADGroupMember -Identity $nomGroupe | Select-Object Name, SamAccountName
    $nomFichier = $nomFichier + ".csv"
    $retourExportable | Export-CSV -Path $nomFichier -Delimiter ";"
}
elseif($typeExport -eq '2')
{
    $login = Read-Host "Entrez le nom d'utilisateur dont il faut lister les groupes"
    $retour = (Get-ADUser $login -Properties memberof).MemberOf
    echo $retour
    $nomFichier = $nomFichier + ".txt"
    New-Item -ItemType File -Path $nomFichier
    Add-Content -Path $nomFichier -Value $retour
}
elseif($typeExport -eq '3')
{
    $retourConsole = Get-ADGroup -Filter * | Format-Table Name, SamAccountName
    echo $retourConsole
    $retourExportable = Get-ADGroup -Filter * | Select-Object Name, SamAccountName
    $nomFichier = $nomFichier + ".csv"
    $retourExportable | Export-CSV -Path $nomFichier -Delimiter ";"
}
elseif($typeExport -eq '4')
{
    $retourConsole = Get-ADUser -Filter * | Format-Table Name, SamAccountName
    echo $retourConsole
    $retourExportable = Get-ADUser -Filter * | Select-Object Name, SamAccountName
    $nomFichier = $nomFichier + ".csv"
    $retourExportable | Export-CSV -Path $nomFichier -Delimiter ";"
}
else
{
    $message = "Veuillez entrer une valeur attendue"
    echo $message
}