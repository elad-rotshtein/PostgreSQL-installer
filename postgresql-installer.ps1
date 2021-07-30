###################################################### 
#
# PostgreSQL-InstallerConfigurator
#
######################################################

# path of key and encrypted password files
$keyPath = 'C:\encrypted_data\key.txt'
$pwdPath = 'C:\encrypted_data\crypt.txt'

$transcript = "PostgreSQL-Installer.log"

# function defenition

function Install-PostgreSQL
{
    [CmdletBinding()]
    <#
    add comment
    #>
    param (
        [string]$Uri          = 'https://sbp.enterprisedb.com/getfile.jsp?fileid=1257713',  
        [string]$destination  = "$($env:USERPROFILE)\Desktop\PostgreSQL_Installer.exe",
        [string]$superaccount = 'postgres',
        [boolean]$noUi      = $true,
        [Parameter(mandatory)][string]$pwdPath,
        [Parameter(mandatory)][string]$keyPath
    )
    
    try
    {
    #Invoke-WebRequest -Uri $Uri -OutFile $destination -ErrorAction stop
    }
    catch
    {
    throw "Error received while attempting to download installer from $uri. Error: $($error[0])"
    }

    try
    {
        $superpassword = Get-Content $pwdPath | ConvertTo-SecureString -Key (get-content $keyPath)
    }
    catch
    {
    throw "Error received while attempting to get and decrypt the password from $pwdPath with key from $keyPath. Error: $($error[0])"
    }
    try
    {
       Start-Process $destination -ArgumentList (@("--mode unattended", "--superaccount $superaccount", "--superpassword $superpassword", "--servicepassword $superpassword")`
       + @("--unattendedmodeui none") * $noUi) -Wait -ErrorAction Stop
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
        Install-PostgreSQL -superaccount 'aidocapp' -pwdPath $pwdPath -keyPath $keyPath -noUi $false
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