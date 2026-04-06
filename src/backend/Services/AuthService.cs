using CustomerBankingPortal.Models;
using Microsoft.AspNetCore.Identity;

namespace CustomerBankingPortal.Services;

public interface IAuthService
{
    /// <summary>
    /// Validates the provided credentials.
    /// Returns a short-lived MFA token when credentials are correct, or null when they are not.
    /// </summary>
    Task<LoginResponse?> ValidateCredentialsAsync(LoginRequest request);
}

public class AuthService : IAuthService
{
    private readonly IPasswordHasher<object> _hasher;

    // In-memory seed users for development / demo purposes.
    // Production would validate against ASP.NET Identity / EF Core.
    private readonly IReadOnlyList<(string Email, string PasswordHash)> _users;

    public AuthService(IPasswordHasher<object> hasher)
    {
        _hasher = hasher;
        // DEMO ONLY: hardcoded seed user for local development.
        // Replace with real ASP.NET Identity / database lookups before deploying to any non-development environment.
        _users =
        [
            ("user@contoso.com", hasher.HashPassword(new object(), "P@ssw0rd!"))
        ];
    }

    public Task<LoginResponse?> ValidateCredentialsAsync(LoginRequest request)
    {
        var match = _users.FirstOrDefault(u =>
            string.Equals(u.Email, request.Email, StringComparison.OrdinalIgnoreCase));

        if (match == default)
        {
            return Task.FromResult<LoginResponse?>(null);
        }

        var result = _hasher.VerifyHashedPassword(new object(), match.PasswordHash, request.Password);
        if (result == PasswordVerificationResult.Failed)
        {
            return Task.FromResult<LoginResponse?>(null);
        }

        // Issue a cryptographically random, opaque MFA session token.
        var tokenBytes = new byte[32];
        System.Security.Cryptography.RandomNumberGenerator.Fill(tokenBytes);
        var mfaToken = Convert.ToBase64String(tokenBytes);
        return Task.FromResult<LoginResponse?>(new LoginResponse { MfaToken = mfaToken });
    }
}
