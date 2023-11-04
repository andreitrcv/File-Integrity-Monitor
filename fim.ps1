$EmailFrom = "your_email@domain.com"
$EmailTo = "email@domain.com"
$Subject = "A file has been changed !!"

$AppPassword = ConvertTo-SecureString -String 'app_password' -AsPlainText -Force
$Credential = New-Object -TypeName PSCredential -ArgumentList $EmailFrom, $AppPassword

Function Calculate-File-Hash($filepath) {
    $filehash = Get-FileHash -Path $filepath -Algorithm SHA512
    return $filehash
}

Function Check-If-Baseline-Exists(){
    return $baselineExists = Test-Path -Path .\baseline.txt
} # Return true if exists, false if it doesn't.

Function Erase-Baseline-If-Already-Exists() {

    if (Check-If-Baseline-Exists) {
        # Delete it
        Remove-Item -Path .\baseline.txt
    }
}

Function New-Baseline-Calculate-Hashes($files){

    # For each file, calculate the hash, and write to baseline.txt
    foreach ($f in $files) {
        $hash = Calculate-File-Hash $f.FullName
        "$($hash.Path)|$($hash.Hash)" | Out-File -FilePath .\baseline.txt -Append
    }
}

Function CreateBody($nameFile){
    return "The file $nameFile has been changed !"
}

Function SendMail($nameFile){
    $Body = CreateBody $nameFile
    Send-MailMessage -From $EmailFrom -To $EmailTo -Subject $Subject -Body $Body -SmtpServer "smtp.outlook.com" -Port 587 -UseSsl -Credential $Credential
}



Write-Host ""
Write-Host "What would you like to do?"
Write-Host ""
Write-Host "    A) Collect new Baseline?"
Write-Host "    B) Begin monitoring files with saved Baseline?"
Write-Host ""
$response = Read-Host -Prompt "Please enter 'A' or 'B'"
Write-Host ""

if ($response -eq "A".ToUpper()) {
    # Delete baseline.txt if it already exists
    Erase-Baseline-If-Already-Exists


    # Collect all files in the target folder
    $files = Get-ChildItem -Path .\Files

    # Calculate Hash from the target files and store in baseline.txt
    New-Baseline-Calculate-Hashes($files)

    
}

elseif ($response -eq "B".ToUpper()) {
    
    if (-not (Check-If-Baseline-Exists)){
        Write-Host "A baseline does not exist, please run again the program and collect data." -ForegroundColor Red
        exit 1
    }

    $fileHashDictionary = @{}

    # Load file|hash from baseline.txt and store them in a dictionary
    $filePathsAndHashes = Get-Content -Path .\baseline.txt
    
    foreach ($f in $filePathsAndHashes) {
         $fileHashDictionary.add($f.Split("|")[0],$f.Split("|")[1])
    }

    # Begin (continuously) monitoring files with saved Baseline
    while ($true) {
        Start-Sleep -Seconds 15
        
        $files = Get-ChildItem -Path .\Files

        foreach ($f in $files) {
            $hash = Calculate-File-Hash $f.FullName

            # Notify if a new file has been created
            if ($fileHashDictionary[$hash.Path] -eq $null) {
                # A new file has been created!
                Write-Host "$($hash.Path) has been created!" -ForegroundColor Green
            }
            else {
                # Notify if a file has been changed
                if ($fileHashDictionary[$hash.Path] -eq $hash.Hash) {
                    # The file has not changed
                }
                else {
                    # File has been compromised!, notify the user
                    SendMail($f.FullName)
                    Write-Host "$($hash.Path) has changed!!!" -ForegroundColor Yellow
                }
            }
        }

        foreach ($key in $fileHashDictionary.Keys) {
            $baselineFileStillExists = Test-Path -Path $key
            if (-Not $baselineFileStillExists) {
                # One of the baseline files must have been deleted, notify the user
                Write-Host "$($key) has been deleted!" -ForegroundColor DarkRed -BackgroundColor Gray
            }
        }
    }
}