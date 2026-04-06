using CustomerBankingPortal.Services;
using Microsoft.AspNetCore.Identity;

var builder = WebApplication.CreateBuilder(args);

// ── Services ───────────────────────────────────────────────────────────────────
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();

// Auth services
builder.Services.AddSingleton<IPasswordHasher<object>, PasswordHasher<object>>();
builder.Services.AddScoped<IAuthService, AuthService>();

// CORS – allow the Vite dev server during local development
builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy(policy =>
    {
        policy.WithOrigins("http://localhost:5173")
              .AllowAnyHeader()
              .AllowAnyMethod();
    });
});

// Problem Details (RFC 7807)
builder.Services.AddProblemDetails();

var app = builder.Build();

// ── Middleware ─────────────────────────────────────────────────────────────────
app.UseExceptionHandler();
app.UseStatusCodePages();
app.UseCors();
app.UseAuthorization();
app.MapControllers();

app.Run();
