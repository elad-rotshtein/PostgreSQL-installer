#########################################
#                                       #
# Encrypt-Password                      #
#                                       #
# Elad Rotshtein                        #
#                                       #
#########################################

$keyDir = 'C:\encrypted_data'
$keyFileName = 'key.txt'
$PWDDir = $keyDir 
$PWDFileName = 'crypt.txt'

$keyFilePath = "$($keyDir + '\' + $keyFileName)"
$PWDFilePath = "$($PWDDir + '\' + $PWDFileName)"

$PWDFileSuccess = $true


if (!(Test-Path $keyDir)) {
    New-Item -ItemType Directory -Path $keyDir
    write-host "Created folder at path $keyDir"
}

$newKey = New-Object Byte[] 32
[Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($newKey)

# createing a file to store the key
Set-Content -Path $keyFilePath -Value $newKey

# confrim creation of the key-containing file
if ("$(Get-Content $keyFilePath)" -eq "$newKey") {
    Write-Host -ForegroundColor Green "Key file created successfully at $keyFilePath"
}
else {
    Write-Warning "could'nt verify the creation of a valid key file at $keyFilePath"
}

# prompt user for password, convert the secure string to an encrypted standard string with with the new key and store in file
$PWD = (Get-Credential -Message "Enter the password you wish to encrypt" -UserName "password only").Password | ConvertFrom-SecureString -key ($newKey)
$PWD | Out-File $PWDFilePath

# confrim creation of password-containing file
if (!(Get-Content $PWDFilePath) -eq $PWD) {
    $PWDFileSuccess = $false
}

# confirm the password-containing file can be dexrypted
try
{
    Get-Content $PWDFilePath | ConvertTo-SecureString -Key (get-content $keyFilePath) -ErrorAction stop | Out-Null
}
catch
{
    $message = $_
    Write-Warning "error recieved while attempting to decrypt password file: $message"
    $PWDFileSuccess = $false
}

if ($PWDFileSuccess) {
    Write-Host -ForegroundColor Green "password file created successfully at $PWDFilePath"
}
