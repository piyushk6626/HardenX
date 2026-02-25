$complexityLine = (net accounts | Select-String -Pattern 'Password must meet complexity requirements').Line

if ($complexityLine -like '*Yes') {
    'Enabled'
} else {
    'Disabled'
}