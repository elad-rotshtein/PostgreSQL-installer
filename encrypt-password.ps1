#########################################
#
# Encrypt-Password
#
# Elad Rotshtein
#
#########################################

$keyDir = 'C:\encrypted_data'
$keyFileName = 'key.txt'
$PWDDir = $keyDir 
$PWDFileName = 'crypt.txt'

if (!(Test-Path $keyDir)) {
    New-Item -ItemType Directory -Path $keyDir
    write-host "Created folder at path $keyDir"
}
  

$newKey = New-Object Byte[] 32
[Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($newKey)

# createing a file to store the key
Set-Content -Path "$($keyDir + '\' +$keyFileName)" -Value $newKey

# convert the secure string to an encrypted standard string with with the new key and store in file
(Get-Credential -Message "Enter the password you wish to encrypt" -UserName "password only").Password | ConvertFrom-SecureString -key ($newKey) | set-content "$($PWDDir + '\' + $PWDFileName)"
