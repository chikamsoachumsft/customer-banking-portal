import { useLocation, useNavigate } from 'react-router-dom'
import { useEffect } from 'react'

export default function MfaPage() {
  const location = useLocation()
  const navigate = useNavigate()
  const mfaToken = (location.state as { mfaToken?: string } | null)?.mfaToken

  // If someone navigates here directly without a token, send them back to login
  useEffect(() => {
    if (!mfaToken) {
      navigate('/login', { replace: true })
    }
  }, [mfaToken, navigate])

  if (!mfaToken) return null

  return (
    <main style={styles.container}>
      <div style={styles.card}>
        <h1 style={styles.heading}>Contoso Financial</h1>
        <h2 style={styles.subheading}>Two-factor authentication</h2>
        <p style={styles.message}>
          A verification code has been sent to your registered device. Enter the
          code below to complete sign-in.
        </p>
        {/* MFA code entry will be implemented in the next story */}
        <p style={styles.placeholder}>[MFA code entry coming soon]</p>
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
    margin: '0.5rem 0 1rem',
    fontSize: '1rem',
    fontWeight: 400,
    color: '#6b7280',
    textAlign: 'center',
  },
  message: {
    fontSize: '0.875rem',
    color: '#374151',
    textAlign: 'center',
    lineHeight: 1.5,
  },
  placeholder: {
    marginTop: '1rem',
    padding: '0.75rem',
    backgroundColor: '#f9fafb',
    border: '1px dashed #d1d5db',
    borderRadius: '6px',
    color: '#9ca3af',
    fontSize: '0.875rem',
    textAlign: 'center',
  },
}
