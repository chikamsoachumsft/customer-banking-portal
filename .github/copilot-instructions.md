This is a Contoso Financial customer self-service banking portal (React 18 + .NET 8).

## Domain Context

Before writing code, pull context from the ADO Wiki using the azure-devops MCP tools:

- **Project**: `Contoso-SelfService-Portal`
- **Wiki pages to read** (under `/Requirements-Context/`):
  - `Domain Glossary` — account types, balance definitions, transfer types, compliance terms. Use these exact terms in code (variable names, comments, UI labels).
  - `Architecture Context` — system landscape, existing APIs (Core Banking T24 endpoints), tech stack, security architecture, performance budgets.
  - `Requirements Standards` — how to structure acceptance criteria, story templates, estimation guidance.
  - `Definition of Ready` — checklist for sprint-ready work items.
  - `Acceptance Criteria Guide` — Given/When/Then conventions.

Use `wiki_list_pages` and `wiki_get_page` to fetch these before starting implementation.

## Architecture

```
src/
├── frontend/          # React 18 SPA (Vite + TypeScript)
│   └── src/
│       ├── components/  # Reusable UI (buttons, forms, cards, modals)
│       ├── pages/       # Route-level pages (Login, Dashboard, Transfers, etc.)
│       ├── hooks/       # Custom hooks (useAuth, useAccounts, useTransfers)
│       ├── services/    # API client functions (fetch wrappers)
│       └── types/       # TypeScript interfaces and types
└── backend/           # .NET 8 Web API
    ├── Controllers/     # API endpoints (thin — delegate to services)
    ├── Models/          # Domain entities and DTOs
    └── Services/        # Business logic (validation, orchestration)
```

## Coding Conventions

### Frontend
- TypeScript strict mode, no `any`
- Functional components with hooks, no class components
- React Router for navigation
- Fluent UI components where applicable
- Loading states use skeleton placeholders (not spinners)
- All forms use inline validation
- Accessibility: WCAG 2.1 AA — aria labels, keyboard navigation, focus management

### Backend
- .NET 8 minimal APIs preferred over controllers for new endpoints
- Entity Framework Core for data access
- API responses use Problem Details (RFC 7807) for errors
- All endpoints require JWT auth except `/api/auth/login` and `/api/auth/register`
- Sensitive operations (transfers > $500, profile changes) require step-up MFA
- Audit logging for all auth and financial operations

### Testing
- Use Given/When/Then format for test names
- Frontend: React Testing Library
- Backend: xUnit + FluentAssertions

### External APIs
- Core Banking (T24): REST + mTLS, rate limit 100 req/sec, response 200-800ms
- Bill Pay (Fiserv): REST, cut-off 4 PM ET
- Notifications (SendGrid): REST, template-based

## Key Domain Rules
- Available Balance = Ledger Balance - Pending Holds
- Internal transfers: real-time during business hours (6AM-9PM ET), queued outside
- Transfer limits: $2,500 per transaction, $5,000 daily
- New payees: 24-hour hold on first transfer
- Sessions: 15-minute sliding expiration, max 3 concurrent
- Account lockout: 5 failed attempts → 30 min lock
- Savings accounts: max 6 withdrawals/month (Reg D)
- Audit logs: append-only, 7-year retention (SOX)
