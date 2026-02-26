$state = ((netsh advfirewall show privateprofile setting successconnections) -match 'Log successful connections').Trim() -split '\s+' | Select-Object -Last 1
switch ($state) {
    'Enable'  { 'Yes' }
    'Disable' { 'No' }
}