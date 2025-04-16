# Log all output to a local file
Start-Transcript -Path "$PSScriptRoot\uninstall.log"

# Uninstall the agent manager
$EyezAgentManager = get-wmiobject Win32_Product | Where-Object {$_.name -match "\bEyezAgentManager\b"}
$Arguments = @(
  "/x"
  $EyezAgentManager.IdentifyingNumber
  "/qn"
)
Start-Process "msiexec.exe" -ArgumentList $Arguments -Wait -NoNewWindow

# Uninstall the agent
$EyezAgent = get-wmiobject Win32_Product | Where-Object {$_.name -match "\bEyezAgent\b"}
$Arguments = @(
  "/x"
  $EyezAgent.IdentifyingNumber
  "/qn"
)
Start-Process "msiexec.exe" -ArgumentList $Arguments -Wait -NoNewWindow

Write-Host "Complete"
Stop-Transcript
