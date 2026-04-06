namespace CustomerBankingPortal.Models;

public class LoginResponse
{
    /// <summary>
    /// Opaque token used to identify this login attempt when completing MFA.
    /// </summary>
    public string MfaToken { get; set; } = string.Empty;
}
