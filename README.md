PostgreSQL-Installer

Automatic download, installation, and configuration of PostgreSQL 

INSTRUCTIONS
1. Use Encrypt-Password.ps1 to encrypt the password you to use for the superuser in the installation. Save the password file and key file to seperate locations with restricted permissions. The user account running the scripts should have access to these locations. This should be done once.
2. Set the locations of the two files created above in PostgreSQL-Installer. set other relevant variables like download URL and parameters.
3. Run PostgreSQL-Installer.ps1 to downlad, install, set the superuser's name  and password and create a new database with a specified name.
