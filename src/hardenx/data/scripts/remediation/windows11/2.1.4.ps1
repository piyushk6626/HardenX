[CmdletBinding()]
param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$IdentityList
)

# C# definition for LSA API calls
$cSharpCode = @"
using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Security.Principal;
using System.Text;

public static class Lsa
{
    [DllImport("advapi32.dll", PreserveSig = true)]
    private static extern uint LsaOpenPolicy(
        ref LSA_UNICODE_STRING SystemName,
        ref LSA_OBJECT_ATTRIBUTES ObjectAttributes,
        uint DesiredAccess,
        out IntPtr PolicyHandle
    );

    [DllImport("advapi32.dll", SetLastError = true, PreserveSig = true)]
    private static extern uint LsaAddAccountRights(
        IntPtr PolicyHandle,
        IntPtr AccountSid,
        LSA_UNICODE_STRING[] UserRights,
        uint CountOfRights
    );

    [DllImport("advapi32.dll", SetLastError = true, PreserveSig = true)]
    private static extern uint LsaRemoveAccountRights(
        IntPtr PolicyHandle,
        IntPtr AccountSid,
        bool AllRights,
        LSA_UNICODE_STRING[] UserRights,
        uint CountOfRights
    );

    [DllImport("advapi32.dll", SetLastError = true, PreserveSig = true)]
    private static extern uint LsaEnumerateAccountsWithUserRight(
        IntPtr PolicyHandle,
        ref LSA_UNICODE_STRING UserRight,
        out IntPtr EnumerationBuffer,
        out uint CountReturned
    );

    [DllImport("advapi32.dll")]
    private static extern int LsaClose(IntPtr ObjectHandle);

    [DllImport("advapi32.dll")]
    private static extern uint LsaNtStatusToWinError(uint status);
    
    [DllImport("advapi32.dll")]
    private static extern int LsaFreeMemory(IntPtr Buffer);

    [StructLayout(LayoutKind.Sequential)]
    private struct LSA_UNICODE_STRING
    {
        public ushort Length;
        public ushort MaximumLength;
        public IntPtr Buffer;
    }

    [StructLayout(LayoutKind.Sequential)]
    private struct LSA_OBJECT_ATTRIBUTES
    {
        public int Length;
        public IntPtr RootDirectory;
        public LSA_UNICODE_STRING ObjectName;
        public uint Attributes;
        public IntPtr SecurityDescriptor;
        public IntPtr SecurityQualityOfService;
    }
    
    [StructLayout(LayoutKind.Sequential)]
    private struct LSA_ENUMERATION_INFORMATION
    {
        public IntPtr Sid;
    }

    private const uint POLICY_VIEW_LOCAL_INFORMATION = 0x00000001;
    private const uint POLICY_LOOKUP_NAMES = 0x00000800;
    private const uint POLICY_CREATE_ACCOUNT = 0x00000010;
    private const uint POLICY_SET_DEFAULT_QUOTA_LIMITS = 0x00000100;

    public const uint Access = POLICY_VIEW_LOCAL_INFORMATION | POLICY_LOOKUP_NAMES | POLICY_CREATE_ACCOUNT | POLICY_SET_DEFAULT_QUOTA_LIMITS;

    private static void InitLsaString(ref LSA_UNICODE_STRING lsaString, string value)
    {
        if (value == null)
        {
            lsaString.Buffer = IntPtr.Zero;
            lsaString.Length = 0;
            lsaString.MaximumLength = 0;
            return;
        }
        lsaString.Buffer = Marshal.StringToHGlobalUni(value);
        lsaString.Length = (ushort)(value.Length * sizeof(char));
        lsaString.MaximumLength = (ushort)((value.Length + 1) * sizeof(char));
    }

    public static SecurityIdentifier[] GetAccountsWithRight(string right)
    {
        var sids = new List<SecurityIdentifier>();
        var lsaObjectAttributes = new LSA_OBJECT_ATTRIBUTES();
        lsaObjectAttributes.Length = 0;
        var systemName = new LSA_UNICODE_STRING();
        IntPtr policyHandle = IntPtr.Zero;
        uint status = LsaOpenPolicy(ref systemName, ref lsaObjectAttributes, Access, out policyHandle);
        if (status != 0) throw new Exception("LsaOpenPolicy failed: " + LsaNtStatusToWinError(status));

        try
        {
            var userRight = new LSA_UNICODE_STRING();
            InitLsaString(ref userRight, right);
            IntPtr buffer = IntPtr.Zero;
            uint count = 0;
            status = LsaEnumerateAccountsWithUserRight(policyHandle, ref userRight, out buffer, out count);
            Marshal.FreeHGlobal(userRight.Buffer);
            if (status == 0)
            {
                var anInfo = new LSA_ENUMERATION_INFORMATION();
                for (int i = 0; i < count; i++)
                {
                    IntPtr p = new IntPtr(buffer.ToInt64() + i * Marshal.SizeOf(anInfo));
                    anInfo = (LSA_ENUMERATION_INFORMATION)Marshal.PtrToStructure(p, anInfo.GetType());
                    sids.Add(new SecurityIdentifier(anInfo.Sid));
                }
                LsaFreeMemory(buffer);
            }
        }
        finally
        {
            LsaClose(policyHandle);
        }
        return sids.ToArray();
    }
    
    public static void SetRight(SecurityIdentifier sid, string right)
    {
        var lsaObjectAttributes = new LSA_OBJECT_ATTRIBUTES();
        lsaObjectAttributes.Length = 0;
        var systemName = new LSA_UNICODE_STRING();
        IntPtr policyHandle = IntPtr.Zero;
        uint status = LsaOpenPolicy(ref systemName, ref lsaObjectAttributes, Access, out policyHandle);
        if (status != 0) throw new Exception("LsaOpenPolicy failed: " + LsaNtStatusToWinError(status));
        
        try
        {
            var userRight = new LSA_UNICODE_STRING();
            InitLsaString(ref userRight, right);
            byte[] sidBytes = new byte[sid.BinaryLength];
            sid.GetBinaryForm(sidBytes, 0);
            IntPtr sidPtr = Marshal.AllocHGlobal(sidBytes.Length);
            Marshal.Copy(sidBytes, 0, sidPtr, sidBytes.Length);
            
            try
            {
                status = LsaAddAccountRights(policyHandle, sidPtr, new LSA_UNICODE_STRING[] { userRight }, 1);
                if (status != 0) throw new Exception("LsaAddAccountRights failed: " + LsaNtStatusToWinError(status));
            }
            finally
            {
                Marshal.FreeHGlobal(sidPtr);
                Marshal.FreeHGlobal(userRight.Buffer);
            }
        }
        finally
        {
            LsaClose(policyHandle);
        }
    }
    
    public static void RemoveRight(SecurityIdentifier sid, string right)
    {
        var lsaObjectAttributes = new LSA_OBJECT_ATTRIBUTES();
        lsaObjectAttributes.Length = 0;
        var systemName = new LSA_UNICODE_STRING();
        IntPtr policyHandle = IntPtr.Zero;
        uint status = LsaOpenPolicy(ref systemName, ref lsaObjectAttributes, Access, out policyHandle);
        if (status != 0) throw new Exception("LsaOpenPolicy failed: " + LsaNtStatusToWinError(status));
        
        try
        {
            var userRight = new LSA_UNICODE_STRING();
            InitLsaString(ref userRight, right);
            byte[] sidBytes = new byte[sid.BinaryLength];
            sid.GetBinaryForm(sidBytes, 0);
            IntPtr sidPtr = Marshal.AllocHGlobal(sidBytes.Length);
            Marshal.Copy(sidBytes, 0, sidPtr, sidBytes.Length);
            
            try
            {
                status = LsaRemoveAccountRights(policyHandle, sidPtr, false, new LSA_UNICODE_STRING[] { userRight }, 1);
                if (status != 0) throw new Exception("LsaRemoveAccountRights failed: " + LsaNtStatusToWinError(status));
            }
            finally
            {
                Marshal.FreeHGlobal(sidPtr);
                Marshal.FreeHGlobal(userRight.Buffer);
            }
        }
        finally
        {
            LsaClose(policyHandle);
        }
    }
}
"@

try {
    $ErrorActionPreference = 'Stop'
    Add-Type -TypeDefinition $cSharpCode

    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw "This script must be run with Administrator privileges."
    }

    $privilege = 'SeInteractiveLogonRight'

    # Get and remove all existing accounts with this right
    $currentSids = [Lsa]::GetAccountsWithRight($privilege)
    foreach ($sid in $currentSids) {
        [Lsa]::RemoveRight($sid, $privilege)
    }

    # Split the input list, trim whitespace, and filter out empty entries
    $identities = $IdentityList.Split(',').Trim() | Where-Object { $_ }

    if ($identities.Count -eq 0) {
        # If the list is empty, we've already cleared the policy. We're done.
        return $true
    }
    
    # Add new accounts
    foreach ($identity in $identities) {
        $account = New-Object System.Security.Principal.NTAccount($identity)
        $sid = $account.Translate([System.Security.Principal.SecurityIdentifier])
        [Lsa]::SetRight($sid, $privilege)
    }

    return $true
}
catch {
    return $false
}
