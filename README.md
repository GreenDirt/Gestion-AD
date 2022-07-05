# Gestion-AD
Plusieurs petits scripts dédiés à la gestion d'Active Directory dans un contexte défini(des paramètres sont à changer pour s'adapter à voter AD)

Création d'utilisateur : 
- Possibilité de créer manuellement un utilisateur, l'associer à une UO, à un groupe, puis l'associer à un dossier personnel stocké sur le serveur AD.
- Création automatique depuis un fichier CSV d'une forme définie et lui associer son dossier utilisateur
ExportDonneesAD :
- Exporte ou affiche les utilisateurs de l'AD et leurs infos associées
SauvegardeDonnéesUtilisateurs :
- Copie dans un dossier sur le serveur les données des dossiers utilisateur
- Fichier log crée à chaque exécution pour repérer des problèmes de copie(droits notamment)
- Ce script est fait pour être exécuté automatiquement et régulièrement(un dossier par jour est crée)
ScriptOuvertureSession :
- Monte simplement le dossier utilisateur distant, Active Directory supportant mal l'ajout automatique d'utilisateurs avec leur dossier personnel
