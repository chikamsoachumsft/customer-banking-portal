# Customer Banking Portal

Contoso Financial customer self-service banking portal.

## Tech Stack

- **Frontend**: React 18, TypeScript, Vite, React Router
- **Backend**: .NET 8 Web API, Entity Framework Core, SQL Server
- **Auth**: ASP.NET Identity + JWT + MFA (SMS OTP / TOTP authenticator)

## Project Structure

```
src/
├── frontend/          # React SPA
│   └── src/
│       ├── components/  # Reusable UI components
│       └── pages/       # Route-level pages
└── backend/           # .NET 8 Web API
    ├── Controllers/     # API endpoints
    ├── Models/          # Domain entities & DTOs
    └── Services/        # Business logic
```

## Getting Started

```bash
# Backend
cd src/backend
dotnet run

# Frontend
cd src/frontend
npm install && npm run dev
```
