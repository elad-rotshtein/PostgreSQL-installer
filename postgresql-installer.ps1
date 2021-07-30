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
    <#
    add comment
    #>
    param (
        [string]$Uri = 'https://sbp.enterprisedb.com/getfile.jsp?fileid=1257713',  
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

    Start-Sleep -Seconds 20

    try
    {
       Start-Process $destination -ArgumentList "--mode unattended --superaccount $superaccount --superpassword $superpassword --servicepassword $superpassword" -Wait -ErrorAction Stop
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