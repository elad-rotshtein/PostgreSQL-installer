###################################################### 
#
# PostgreSQL-InstallerConfigurator
# 
# must run as administrator
#
######################################################


# provide the path for the key and encrypted password files
$keyPath = 'C:\encrypted_data\key.txt'
$pwdPath = 'C:\encrypted_data\crypt.txt'

$pgVer     = "13" # as expressed in the directory of an installed copy and the service name. most often floored.
$pgPath = "$($env:ProgramFiles)\PostgreSQL\$pgVer"

$databaseName = 'aidocapp'
$transcript = "$($env:USERPROFILE)\Desktop\PostgreSQL-Installer.$(Get-Date -Format 'dd.mm.yy')og"

# function defenition

function Install-PostgreSQL
{
    
    <#
    add comment
    #>
    
    [CmdletBinding()]

    param (
        [string]$Uri          = 'https://sbp.enterprisedb.com/getfile.jsp?fileid=1257713',  
        [string]$destination  = "$($env:USERPROFILE)\Desktop\PostgreSQL_Installer.exe", # where to save the installer exe
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



    $serviceStatus = (Get-Service -Name "postgresql*$pgVer" -ErrorAction Stop ).Status 
    

    if ($serviceStatus -eq 'Running')
    {
        
        
        Write-Host "PostgreSQL service is up and running! ( :" -ForegroundColor Green


        # backing up and editing pg_hba.conf to allow local passwordless connections. reverting to back up at the end of the script.
        try
        {
            $pgHba = "$($pgpath)\data\pg_hba"
            Copy-Item -Path "$($pgHba).conf" -Destination "$($pgHba)_backup.conf"
            (Get-Content "$($pgHba).conf" ) -replace '(host\s+all\s+all\s+)((127.0.0.1/32\s+)|(::1/128\s+))\w.+$', '$1$2trust' | Out-File -FilePath "$($pgHba).conf" -Encoding ASCII
        }
        catch
        {
            throw "Error received while attempting to backup and edit $($pgHba).conf. Stopping without creating database $($databaseName). Error: $($error[0])"
        }


        # creating new database
        try
        {
            & "$($pgPath)\bin\createdb.exe" -w -h 127.0.0.1 -U aidocapp $databaseName
        }
        catch
        {
            throw "Error received while attempting to create database named $databaseName. Error: $($error[0])"

        }


        if ((& "$($pgPath)\bin\psql.exe" -w -h 127.0.0.1 -U aidocapp -c "\l") -match 'aidocapp\s+\|\s+aidocapp')
        {
            Write-Host "Database $databaseName successfully created!" -ForegroundColor Green 
        }


    }
    elseif ($serviceStatus)
    {
        Write-Warning "The PostgreSQL service exists but isn't running. It's: $($ServiceStatus). Stopping without creating database $databaseName"
    }
    else
    {
        Write-Warning "Couldn't find a service who's name matches postgresql*$($pgVer). Stopping without creating database $databaseName"
    }
    
     
}
finally
{
    Copy-Item -Path "$($pgHba)_backup.conf" -Destination "$($pgHba).conf"
    Stop-Transcript
}
