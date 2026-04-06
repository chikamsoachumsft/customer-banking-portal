This is a Contoso Financial customer self-service banking portal (React 18 + .NET 8).

## Conventions
- Frontend: TypeScript, functional components with hooks, React Router for navigation
- Backend: .NET 8 minimal APIs preferred, Entity Framework Core for data access
- API responses use standard Problem Details (RFC 7807) for errors
- All endpoints require JWT auth except /api/auth/login and /api/auth/register
- Use Given/When/Then format for test names
- Sensitive operations (transfers > $500, profile changes) require step-up MFA re-authentication
