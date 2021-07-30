###################################################### 
#
# PostgreSQL-InstallerConfigurator
#
######################################################

$transcript = "PostgreSQL-Installer.log"

# path of key and encrypted password files
$keyPath = 'C:\encrypted_data\key.txt'
$PWDPath = 'C:\encrypted_data\crypt.txt'

# function defenition

function Install-PostgreSQL
{
    param (
        [string]$Uri = 'https://www.enterprisedb.com/postgresql-tutorial-resources-training?cid=48',  
        [string]$destination = 'PostgreSQL_Installer.exe',
        [string]$superaccount='postgres',
        [Parameter(mandatory)][string]$superpassword
    )
    
    try
    {
    Invoke-WebRequest -Uri $Uri -OutFile $destination -ErrorAction stop
    }
    catch
    {
    throw "Error received while attempting to download installer from $uri. Error: $($error[0])"
    }

    try
    {
       Start-Process $destination -ArgumentList  "--mode unattended --unattendedmodeui none --superaccount $superaccount --superpassword $superpassword" -Wait -ErrorAction Stop
    }
    catch
    {
    throw "Error received while attempting to run the installer. Error: $($error[0])"
    }
}




# main
Start-Transcript -path $transcript

try
{

    try
    {
    $superPassword = Get-Content $PwdPath | ConvertTo-SecureString -Key (get-content $keyPath)
    }
    catch
    {
    throw "Error received while attempting to get and decrypt the password. Error: $($error[0])"
    }
    
    try
    {
        Install-PostgreSQL -superaccount 'aidocapp' -superpassword $superPassword
    }
    catch
    {
    throw "Error received while using Install-PostgreSQL. Error: $($error[0])"
    }
}
finally
{
    Stop-Transcript
}