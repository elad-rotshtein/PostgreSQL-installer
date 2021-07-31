###################################################### 
#
# PostgreSQL-InstallerConfigurator
#
######################################################

$pgVer     = "13" # as expressed in the directory of an installed copy and the service name. most often floored.
$pgBinPath = "$($env:ProgramFiles)\PostgreSQL\$($pgVer)\bin"

# provide the path for the key and encrypted password files
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
        [boolean]$noUi        = $true,
        [Parameter(mandatory)][string]$pwdPath,
        [Parameter(mandatory)][string]$keyPath
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
        $superpassword = Get-Content $pwdPath | ConvertTo-SecureString -Key (get-content $keyPath)
    }
    catch
    {
        throw "Error received while attempting to get and decrypt the password from $pwdPath with key from $keyPath. Error: $($error[0])"
    }
    try
    {
        Start-Process $destination -ArgumentList (@("--mode unattended", "--superaccount $superaccount",` 
        "--superpassword $([System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($superpassword)))",`
        "--servicepassword $([System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($superpassword)))")`
        + @("--unattendedmodeui none") * $noUi) -Wait -ErrorAction Stop
    }
    catch
    {
        throw "Error received while attempting to run the installer executable. Error: $($error[0])"
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

    if ((Get-Service -Name "postgresql*$pgVer").Status -eq 'Running')
    {
        Write-Host "PostgreSQL service is up and running!" -ForegroundColor Green
    }
    else
    {
        #hmm
    }

        
}
finally
{
    Stop-Transcript
}