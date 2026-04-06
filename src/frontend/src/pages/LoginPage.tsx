import { useState, FormEvent } from 'react'
import { useNavigate } from 'react-router-dom'

interface LoginForm {
  email: string
  password: string
}

export default function LoginPage() {
  const navigate = useNavigate()
  const [form, setForm] = useState<LoginForm>({ email: '', password: '' })
  const [error, setError] = useState<string | null>(null)
  const [loading, setLoading] = useState(false)

  async function handleSubmit(e: FormEvent) {
    e.preventDefault()
    setError(null)
    setLoading(true)

    try {
      const res = await fetch('/api/auth/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email: form.email, password: form.password }),
      })

      if (res.ok) {
        const data = await res.json()
        // Pass the MFA token to the MFA page via navigation state
        navigate('/mfa', { state: { mfaToken: data.mfaToken } })
      } else {
        // Generic error message – do not reveal which field was incorrect
        setError('The email or password you entered is incorrect.')
      }
    } catch {
      setError('Unable to connect. Please try again later.')
    } finally {
      setLoading(false)
    }
  }

  return (
    <main style={styles.container}>
      <div style={styles.card}>
        <h1 style={styles.heading}>Contoso Financial</h1>
        <h2 style={styles.subheading}>Sign in to your account</h2>

        <form onSubmit={handleSubmit} noValidate style={styles.form}>
          <div style={styles.field}>
            <label htmlFor="email" style={styles.label}>
              Email address
            </label>
            <input
              id="email"
              type="email"
              autoComplete="email"
              required
              value={form.email}
              onChange={(e) => setForm({ ...form, email: e.target.value })}
              style={styles.input}
              disabled={loading}
              aria-describedby={error ? 'login-error' : undefined}
            />
          </div>

          <div style={styles.field}>
            <label htmlFor="password" style={styles.label}>
              Password
            </label>
            <input
              id="password"
              type="password"
              autoComplete="current-password"
              required
              value={form.password}
              onChange={(e) => setForm({ ...form, password: e.target.value })}
              style={styles.input}
              disabled={loading}
              aria-describedby={error ? 'login-error' : undefined}
            />
          </div>

          {error && (
            <p id="login-error" role="alert" style={styles.error}>
              {error}
            </p>
          )}

          <button type="submit" disabled={loading} style={styles.button}>
            {loading ? 'Signing in…' : 'Sign in'}
          </button>
        </form>
      </div>
    </main>
  )
}

const styles: Record<string, React.CSSProperties> = {
  container: {
    minHeight: '100vh',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: '#f3f4f6',
    fontFamily: "'Segoe UI', system-ui, sans-serif",
  },
  card: {
    backgroundColor: '#ffffff',
    borderRadius: '8px',
    boxShadow: '0 2px 12px rgba(0,0,0,0.1)',
    padding: '2.5rem 2rem',
    width: '100%',
    maxWidth: '400px',
  },
  heading: {
    margin: 0,
    fontSize: '1.5rem',
    fontWeight: 700,
    color: '#1e3a5f',
    textAlign: 'center',
  },
  subheading: {
    margin: '0.5rem 0 1.5rem',
    fontSize: '1rem',
    fontWeight: 400,
    color: '#6b7280',
    textAlign: 'center',
  },
  form: {
    display: 'flex',
    flexDirection: 'column',
    gap: '1rem',
  },
  field: {
    display: 'flex',
    flexDirection: 'column',
    gap: '0.25rem',
  },
  label: {
    fontSize: '0.875rem',
    fontWeight: 500,
    color: '#374151',
  },
  input: {
    padding: '0.625rem 0.75rem',
    border: '1px solid #d1d5db',
    borderRadius: '6px',
    fontSize: '1rem',
    outline: 'none',
    transition: 'border-color 0.15s',
  },
  error: {
    margin: 0,
    padding: '0.625rem 0.75rem',
    backgroundColor: '#fef2f2',
    border: '1px solid #fecaca',
    borderRadius: '6px',
    color: '#dc2626',
    fontSize: '0.875rem',
  },
  button: {
    marginTop: '0.5rem',
    padding: '0.75rem',
    backgroundColor: '#1e3a5f',
    color: '#ffffff',
    border: 'none',
    borderRadius: '6px',
    fontSize: '1rem',
    fontWeight: 600,
    cursor: 'pointer',
    transition: 'background-color 0.15s',
  },
}
