try {
    $ldapIntegrityValue = (Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\ldap' -ErrorAction Stop).LdapClientIntegrity
    switch ($ldapIntegrityValue) {
        0 { 'None' }
        1 { 'Negotiate signing' }
        2 { 'Require signing' }
    }
}
catch {
    # This will suppress errors if the registry key or value does not exist,
    # resulting in no output, which is a clean failure state.
}