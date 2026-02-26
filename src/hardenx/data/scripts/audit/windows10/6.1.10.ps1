(auditpol /get /subcategory:"Removable Storage") | ForEach-Object {
    if ($_ -match "Removable Storage") {
        ($_).Trim() -split '\s{2,}' | Select-Object -Last 1
    }
}