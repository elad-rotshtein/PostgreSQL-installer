##########################################
#                                       
# Encrypt-Password                                                                                
#                                       
##########################################

# save your key and encrypted password only to folders with highly restricted access permissions!!!
$keyDir = 'C:\encrypted_data'
$keyFileName = 'key.txt'
$PWDDir = $keyDir 
$PWDFileName = 'crypt.txt'

$keyPath = "$($keyDir + '\' + $keyFileName)"
$PWDPath = "$($PWDDir + '\' + $PWDFileName)"

$PWDFileSuccess = $true

try
{
    if (!(Test-Path $keyDir)) {
        New-Item -ItemType Directory -Path $keyDir
        write-host "Created folder at path $keyDir"
    }

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
$PWD = (Get-Credential -Message "Enter the password you wish to encrypt" -UserName "password only").Password | ConvertFrom-SecureString -key (get-content $keyPath)
$PWD | Out-File $PWDPath

# confrim creation of the password-containing file
if (!(Get-Content $PWDPath) -eq $PWD) {
    $PWDFileSuccess = $false
}

# confirm the password-containing file can be decrypted
try
{
    Get-Content $PWDPath | ConvertTo-SecureString -Key (get-content $keyPath) -ErrorAction stop | Out-Null
}
catch
{
    $message = $_
    Write-Warning "error recieved while attempting to decrypt password file: $message"
    $PWDFileSuccess = $false
}

if ($PWDFileSuccess) {
    Write-Host -ForegroundColor Green "password file created successfully at $PWDPath"
}
