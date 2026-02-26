(auditpol /get /subcategory:"Audit Policy Change") | ForEach-Object {
    if ($_ -match 'Audit Policy Change\s+(.+)') {
        $Matches[1].Trim()
    }
}