# File-Integrity-Monitor with Email Alerts


This PowerShell script serves as a file integrity monitor that continuously checks for changes in files within a specified folder and sends email alerts if any unauthorized modifications or file additions occur. It provides an extra layer of security by maintaining a baseline of file hashes and notifying you when discrepancies are detected.

Usage:
Configure the script by setting the following variables at the beginning of the script:

  $EmailFrom: Your email address for sending alerts.
  $EmailTo: The recipient's email address for receiving alerts.
  $Subject: The subject line of the email alerts.
  $AppPassword: Your email account's application-specific password.
  
Run the script and choose one of the following options:
  A) Collect new Baseline: Creates a new baseline of file hashes in the specified folder. Use this option when first setting up the monitor.
  B) Begin monitoring files with saved Baseline: Initiates real-time monitoring using the previously collected baseline. This option continuously checks for file changes and sends email alerts if any unauthorized modifications or file additions occur.
