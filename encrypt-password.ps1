##########################################
#                                       
# Encrypt-Password                                                                                
# 
# receives a password and creates a file containing the password as an 
# encrypted string and another file containig the 256-bit AES key. 
#
##########################################

# save your key and encrypted password files to seprate, *secure* locations!
$keyDir = 'C:\encrypted_data'
$keyFileName = 'key.txt'
$pwdDir = $keyDir 
$pwdFileName = 'crypt.txt'

$keyPath = "$($keyDir + '\' + $keyFileName)"
$pwdPath = "$($pwdDir + '\' + $pwdFileName)"


foreach ($dir in @($keyDir, $pwdDir)){
    if (!(Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir
        write-host "Created folder at path $dir"
    }
}
try
{
    $newKey = New-Object Byte[] 32
    [Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($newKey)

    # createing a file to store the key
    Set-Content -Path $keyPath -Value $newKey

    # confrim creation of the key-containing file
    if ("$(Get-Content $keyPath)" -eq "$newKey") {
        Write-Host -ForegroundColor Green "Key file created successfully at $keyPath"
    }
    else {
        Write-Warning "could'nt verify the creation of a valid key file at $keyPath"
    }
}
finally
{
    Remove-Variable newKey
}

# prompt user for password, convert the secure string to an encrypted standard string with with the new key and store it in a file
$pwd = (Get-Credential -Message "Enter the password you wish to encrypt" -UserName "password only").Password | ConvertFrom-SecureString -key (get-content $keyPath)
$pwd | Out-File $pwdPath

# confrim the creation of the password-containing file
$pwdFileSuccess = $true
if (!(Get-Content $pwdPath) -eq $pwd) {
    $pwdFileSuccess = $false
}

# confirm the password-containing file can be decrypted
try
{
    Get-Content $pwdPath | ConvertTo-SecureString -Key (get-content $keyPath) -ErrorAction stop | Out-Null
}
catch
{
    $message = $_
    Write-Warning "Error recieved while attempting to decrypt password file: $message"
    $pwdFileSuccess = $false
}

if ($pwdFileSuccess) {
    Write-Host -ForegroundColor Green "password file created successfully at $pwdPath"
}
