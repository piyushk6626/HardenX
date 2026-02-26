$output = auditpol /get /subcategory:"User Account Management"
$settingLine = $output | Select-String -Pattern "User Account Management"
if ($null -ne $settingLine) {
    ($settingLine.Line.Trim() -split '\s{2,}')[-1]
}