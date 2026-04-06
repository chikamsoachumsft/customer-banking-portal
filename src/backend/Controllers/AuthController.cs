using CustomerBankingPortal.Models;
using CustomerBankingPortal.Services;
using Microsoft.AspNetCore.Mvc;

namespace CustomerBankingPortal.Controllers;

[ApiController]
[Route("api/auth")]
public class AuthController : ControllerBase
{
    private readonly IAuthService _authService;

    public AuthController(IAuthService authService)
    {
        _authService = authService;
    }

    /// <summary>
    /// POST /api/auth/login
    /// Validates email + password credentials.
    /// On success returns an MFA challenge token; on failure returns a generic 401 that
    /// does not reveal which field (email or password) was incorrect.
    /// </summary>
    [HttpPost("login")]
    public async Task<IActionResult> Login([FromBody] LoginRequest request)
    {
        if (!ModelState.IsValid)
        {
            // Return a generic 401 instead of a 400 with field details so that
            // callers cannot determine which field failed validation.
            return Unauthorized(new ProblemDetails
            {
                Title = "Invalid credentials",
                Status = StatusCodes.Status401Unauthorized,
                Detail = "The email or password you entered is incorrect."
            });
        }

        var response = await _authService.ValidateCredentialsAsync(request);
        if (response is null)
        {
            return Unauthorized(new ProblemDetails
            {
                Title = "Invalid credentials",
                Status = StatusCodes.Status401Unauthorized,
                Detail = "The email or password you entered is incorrect."
            });
        }

        return Ok(response);
    }
}
