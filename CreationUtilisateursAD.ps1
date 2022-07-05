<#

Auteur : Hugo Boilloux
Date : 25/05/2022
Version : 1.1
Description :
Script interactif de création manuelle ou par fichier CSV de création d'utilisateur AD, 
d'ajout à un groupe et une Unité d'Orgnanisation, ainsi que de liaison à un dossier utilisateur distant
Notes :
- Adaptez le code à l'active directory
Révisions : 
- Ajout d'une procédure pour vérifier la présence de doublons
#> 

function CreateAD_User {
    param (
        [string]$prenom,
        [string]$nom,
        [string]$login,
        [string]$email,
        [string]$mdp
    )
    $nomPrenom = $prenom + " " + $nom
    if(Get-ADUser  -F {SamAccountName -eq $login}) #On teste si l'utilisateur existe déja
    {
        $message = "Avertissement : L'utilisateur " + $login + " existe déja"
        echo $message
    }
    else
    {
        New-ADUser -Name $nomPrenom -Surname $nom -GivenName $prenom -SamAccountName $login -UserPrincipalName $login@axeplane.loc -EmailAddress $email -ChangePasswordAtLogon $true -Enabled $true -AccountPassword (ConvertTo-SecureString -AsPlainText $mdp -Force)
    }

    if(Get-ADUser  -F {SamAccountName -eq $login}) #On vérifie que l'utilisateur est bien crée
    {
        $message = "**L'utilisateur " + $login + " à bien été crée**"
        echo $message
    }
    else
    {
        $message = "Erreur : L'utilisateur " + $login + " n'a pas pu être crée"
        Throw $message
    }
}

function ajoutUO {
    param (
        [string] $login,
        [string] $nomUO
    )
    if(Get-ADOrganizationalUnit -Filter 'Name -like $nomUO')
    {
        $AD_ObjectUtilisateur = (Get-ADUser -Identity $login).distinguishedName
        $nomCompletUO = "OU=" + $nomUO + ",OU=Utilisateurs,DC=axeplane,DC=loc" #Le chemin complet est nécessaire pour le deplacement
        Move-ADObject -Identity $AD_ObjectUtilisateur -TargetPath $nomCompletUO
        $message = $login + " déplacé dans l'UO " + $UO
        echo $message
    }
    else
    {
        $message = "Erreur : Impossible de trouver l'Unité d'Organisation donnée"
        echo $message
    }
}

function ajoutDossierStockage {
    param (
        [string]$login
    )
    
    #Creation du repertoire local
    $emplacement = "E:\PartagesPersonnelsUtilisateurs\" + $login
    
    New-Item $emplacement -Type Directory
    
    ##Attribution des droits corrects au dossier
    $nomCompte = "AXEPLANELOC\" + $login
    $compte = New-Object System.Security.Principal.NTAccount($nomCompte)
    $Acl = Get-Acl -Path $emplacement          #On récupere les Acl actuelles
    $Acl.SetOwner($compte)                     #On change le propriétaire
    $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($nomCompte,"FullControl","Allow")#Regle d'autorisation d'acces pour l'user
    $Acl.SetAccessRule($AccessRule)
    $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("AXEPLANELOC\Administrateur","FullControl","Allow")#Regle d'autorisation d'acces pour l'admin
    $Acl.SetAccessRule($AccessRule)
    Set-Acl -Path $emplacement -AclObject $Acl #On applique les Acl modifiées
    ##
    $nomPartage = $login + "`$"
    New-SmbShare -Name $nomPartage -Path $emplacement -FullAccess $login, "AXEPLANELOC\Administrateur"  #Création du partage/Acces au partage seulement pour l'utilisateur
    #Attribution du partage à l'utilisateur
    $AD_ObjectUtilisateur = (Get-ADUser -Identity $login).distinguishedName
    $emplacementReseau = "\\SRV-AD-0422\" + $nomPartage
    
    Set-ADUser -Identity $login -HomeDrive z -HomeDirectory $emplacementReseau

    
}

$typeCreation = Read-Host "Entrez la méthode de création des utilisateurs :`n1 : Manuellement`n2 : Fichier au format CSV`n-> choix "

if($typeCreation -eq 1)
{
    echo "-------------------"
    $prenom = Read-Host "Entrez le prénom de l'utilisateur"
    $nom = Read-Host "Entrez le nom de l'utilisateur"
    $login = Read-Host "Entrez l'identifiant de l'utilisateur"
    $email = Read-Host "Entrez l'adresse e-mail de l'utilisateur"
    $mdp = Read-Host "Entrez le mot de passe de l'utilisateur"

    CreateAD_User -prenom $prenom -nom $nom -login $login -email $email -mdp $mdp

    $ajoutGroupe = Read-Host "Souhaitez-vous associer l'utilisateur à un groupe ? o/N"

    if($ajoutGroupe -eq 'o' -or $ajoutGroupe -eq "oui")
    {
        $groupe  = Read-Host "Entrez le nom du groupe"
        Add-ADGroupMember -Identity $groupe -Members $login
        echo "**Utilisateur ajouté au groupe**"
    }

    $ajoutUO = Read-Host "Souhaitez-vous placer l'utilisateur dans une Unité d'Organisation ? o/N"
    if($ajoutUO -eq 'o' -or $ajoutUO -eq "oui")
    {
        $nomUO = Read-Host "Entrez le nom de l'UO"
        ajoutUO -login $login -nomUO $nomUO
    }

    $ajoutDossierPersonnel = Read-Host "Souhaitez-vous associer un dossier personnel à l'utilisateur ? o/N"
    if($ajoutDossierPersonnel -eq 'o' -or $ajoutDossierPersonnel -eq "oui")
    {
        ajoutDossierStockage -login $login
    }
}
elseif($typeCreation -eq 2)
{
    $nomFichier = Read-Host "Entrez le nom du fichier"
    $fichierCSV = Import-csv -Delimiter ',' -Path $nomFichier
    foreach($User in $fichierCSV)
    {
        $prenom = $User.Prenom
        $nom = $User.Nom
        $login = $User.Login
        $email = $User.Mail
        $mdp = "Azerty+1"
        $service = $User.Service

        #Procédure pour éviter les doublons
        $idsCorrespondant = @()
        foreach($UserVerif in $fichierCSV)
        {
            if($login -eq $UserVerif.Login)
            {
                $idsCorrespondant += $UserVerif.ID
            }
        }
        if($idsCorrespondant.count -gt 1)#Superieur à
        {
            $idFinal = 0
            foreach($ID in $idsCorrespondant)
            {
                if($ID -gt $User.ID)
                {
                    $idFinal += 1
                }
            }
            if(-not $idFinal  -eq 0)
            {
                $login = $login + $idFinal.ToString()
            }
        }
        ####

        #Création de l'utilisateur
        if($prenom -eq "" -or $nom -eq "" -or $login -eq "")
        {
            echo "Fin de l'ajout"
            break
        }
        CreateAD_User -prenom $prenom -nom $nom -login $login -email $email -mdp $mdp
        ####

        #Ajout au groupe
        $nomGroupe = "GU_" + $service
        Add-ADGroupMember -Identity $nomGroupe -Members $login
        $message = $login + " ajouté au groupe " + $nomGroupe
        echo $message

        #Ajout à l'Unité d'Organisation
        $nomUO = "UO_" + $service
        ajoutUO -login $login -nomUO $nomUO

        ajoutDossierStockage -login $login
        echo "------------------------------"
    }
}
else
{
    echo "Erreur : Veuillez entrer un choix correct"
}