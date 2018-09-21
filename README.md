# save_system
Script de sauvegarde en Bash pour un system linux
## Getting Started
  Le script effectue une sauvegarde incrémentale tous les jours (à définir avec Cron) et une fois
  un nouveau mois de commencé, crée un sauvegarde complète et supprime les sauvegardes incrementales précédentes.
  
## Prerequisites
Changer les variables :<br />
  extern_media // emplacement du média de sauvegarde<br />
  to_save_sys // dossier à sauvegarder pour la sauvegarde du système "/etc /usr/local /opt" par défaut<br />
  to_save_user // dossier de sauvegarde pour les utilisateurs /home par défaut.<br />
  exclude // fichier d'exclusion (tar -X)<br />
  
## Running
  Rappel , il est nécessaire d'avoir les droits correspondant pour la création de fichier dans le media
  et également dans les dossiers / et /home ...

----------------------------------------------------------EN-----------------------------------------------------------------------

# save_system
Save script in bash for a Linux system
## Getting Started
  This script does an incremental save everyday (to define autolaunch with Cron) and when a new month
  begins, the script makes a complet save and erases previous incremental saves. 
  
## Prerequisites
Change variables :<br />
  extern_media // extern media where put saves <br />
  to_save_sys // Which dir of system to save "/etc /usr/local /opt" by default<br />
  to_save_user // Which dir of users to save "/home" by default<br />
  exclude // Exclude file of tar -X<br />
  
## Running
  Remember that , you need to be an admin or at least to have the right permissions to write, execute and read in 
  the external media and all dir that you want to save.
