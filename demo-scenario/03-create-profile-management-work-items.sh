#!/usr/bin/env bash
# ==============================================================================
# Profile Management — ADO Work Item Creation Script
# ==============================================================================
# Creates the full Profile Management epic hierarchy in Azure DevOps:
#   1 Epic → 5 Features → 16 Product Backlog Items
#
# Prerequisites:
#   1. az login
#   2. az extension add --name azure-devops
#   3. az devops configure --defaults organization=https://dev.azure.com/canayorachu project=Contoso-SelfService-Portal
#
# Usage:
#   chmod +x 03-create-profile-management-work-items.sh
#   ./03-create-profile-management-work-items.sh
# ==============================================================================

set -euo pipefail

PROJECT="Contoso-SelfService-Portal"

echo "=========================================="
echo "Profile Management — ADO Work Item Creator"
echo "=========================================="
echo "Project: $PROJECT"
echo ""

# --------------------------------------------------------------------------
# EPIC: Profile Management
# --------------------------------------------------------------------------
echo "[1/22] Creating Epic: Profile Management..."
EPIC_ID=$(az boards work-item create \
  --type "Epic" \
  --title "Profile Management" \
  --description "Enable customers to securely view and update their personal profile information, communication preferences, and security settings through the self-service portal. All changes must comply with banking regulations (KYC/BSA, SOX, CAN-SPAM, TCPA, E-SIGN Act, NIST SP 800-63B) and maintain a complete, immutable audit trail. Profile management replaces phone-based profile updates and is a key driver for reducing call center volume." \
  --fields "Microsoft.VSTS.Common.Priority=2" \
  --fields "System.Tags=Profile; Phase-1; Q3-2026; Compliance; Security" \
  --project "$PROJECT" \
  --query "id" -o tsv)
echo "  ✅ Epic created: ID $EPIC_ID"

# --------------------------------------------------------------------------
# FEATURE 1: Contact Information Management
# --------------------------------------------------------------------------
echo ""
echo "[2/22] Creating Feature 1: Contact Information Management..."
FEAT1_ID=$(az boards work-item create \
  --type "Feature" \
  --title "Contact Information Management" \
  --description "Enable customers to view and update their email, phone, and mailing address with proper verification, validation, and regulatory compliance. All contact changes require step-up MFA, verification of the new contact method, notification to the old contact method, and a 72-hour cool-down before the new info can be used for account recovery. Syncs with Core Banking API (T24)." \
  --fields "Microsoft.VSTS.Common.Priority=1" \
  --fields "System.Tags=Profile; Contact-Info; Security; Phase-1" \
  --project "$PROJECT" \
  --query "id" -o tsv)
az boards work-item relation add --id "$FEAT1_ID" --relation-type "System.LinkTypes.Hierarchy-Reverse" --target-id "$EPIC_ID" --output none
echo "  ✅ Feature 1 created: ID $FEAT1_ID (parent: Epic $EPIC_ID)"

# PBI 1.1: Email Address Change with Verification
echo "[3/22] Creating PBI 1.1: Email Address Change with Verification..."
PBI11_ID=$(az boards work-item create \
  --type "Product Backlog Item" \
  --title "Email Address Change with Verification" \
  --description "As a banking customer, I want to update my email address with proper verification, so that my account communications go to my correct email and my account is protected from unauthorized email changes." \
  --fields "Microsoft.VSTS.Common.Priority=1" \
  --fields "Microsoft.VSTS.Scheduling.StoryPoints=8" \
  --fields "System.Tags=Profile; Contact-Info; Security; Verification; Phase-1" \
  --fields 'Microsoft.VSTS.Common.AcceptanceCriteria=<h3>AC 1: Step-Up MFA Before Email Change</h3><p><b>Given</b> I am authenticated and on the profile contact info page<br/><b>When</b> I click "Change Email Address"<br/><b>Then</b> the system prompts me to complete step-up MFA (SMS OTP, TOTP, or email OTP to current email)<br/><b>And</b> I cannot proceed until MFA is successfully completed within 5 minutes</p><h3>AC 2: Email Format Validation (RFC 5322)</h3><p><b>Given</b> I have completed step-up MFA<br/><b>When</b> I enter a new email address<br/><b>Then</b> the system validates the email against RFC 5322 format rules<br/><b>And</b> rejects addresses with invalid characters, missing @ symbol, or invalid domain format<br/><b>And</b> displays inline error: "Please enter a valid email address (e.g., name@example.com)"</p><h3>AC 3: Confirmation Link (24h Expiry)</h3><p><b>Given</b> I have entered a valid new email address<br/><b>When</b> the system processes the request<br/><b>Then</b> a confirmation link is sent to the NEW email (24h expiry)<br/><b>And</b> the profile shows "Pending Verification" badge<br/><b>And</b> the old email remains active until confirmed</p><h3>AC 4: Old Email Notification</h3><p><b>Given</b> an email change request is submitted<br/><b>When</b> the confirmation is sent to the new email<br/><b>Then</b> the OLD email receives: "A request to change your email was submitted on [date]. If this wasn't you, contact us at 1-800-CONTOSO."</p><h3>AC 5: 72-Hour Cool-Down</h3><p><b>Given</b> the new email is confirmed<br/><b>When</b> the change is activated<br/><b>Then</b> the new email cannot be used for account recovery for 72 hours</p><h3>AC 6: Rate Limiting (5/hr)</h3><p><b>Given</b> a customer attempts more than 5 email changes in 1 hour<br/><b>When</b> the 6th request is submitted<br/><b>Then</b> the system returns HTTP 429 with RFC 7807 Problem Details and Retry-After header</p><h3>AC 7: Core Banking API Sync</h3><p><b>Given</b> the email is confirmed<br/><b>When</b> the portal updates the email<br/><b>Then</b> it syncs to the core banking API with retry (3x, exponential backoff 2s/4s/8s)<br/><b>And</b> if all retries fail, the change is queued and the customer is notified</p>' \
  --project "$PROJECT" \
  --query "id" -o tsv)
az boards work-item relation add --id "$PBI11_ID" --relation-type "System.LinkTypes.Hierarchy-Reverse" --target-id "$FEAT1_ID" --output none
echo "  ✅ PBI 1.1 created: ID $PBI11_ID"

# PBI 1.2: Phone Number Change with SMS OTP Verification
echo "[4/22] Creating PBI 1.2: Phone Number Change with SMS OTP..."
PBI12_ID=$(az boards work-item create \
  --type "Product Backlog Item" \
  --title "Phone Number Change with SMS OTP Verification" \
  --description "As a banking customer, I want to update my phone number with SMS verification of the new number, so that my account security notifications reach me at my current phone number." \
  --fields "Microsoft.VSTS.Common.Priority=1" \
  --fields "Microsoft.VSTS.Scheduling.StoryPoints=8" \
  --fields "System.Tags=Profile; Contact-Info; Security; Verification; OTP; Phase-1" \
  --fields 'Microsoft.VSTS.Common.AcceptanceCriteria=<h3>AC 1: Step-Up MFA Before Phone Change</h3><p><b>Given</b> I am authenticated and on the profile page<br/><b>When</b> I click "Change Phone Number"<br/><b>Then</b> the system prompts step-up MFA using a method OTHER than SMS to current phone (TOTP or email OTP)</p><h3>AC 2: E.164 Format Validation</h3><p><b>Given</b> I completed MFA<br/><b>When</b> I enter a new phone number<br/><b>Then</b> the system validates E.164 format (+1XXXXXXXXXX for US)<br/><b>And</b> rejects VoIP-only numbers if detectable<br/><b>And</b> displays inline error for invalid format</p><h3>AC 3: 6-Digit SMS OTP (10min Expiry)</h3><p><b>Given</b> I entered a valid phone number<br/><b>When</b> I click "Send Verification Code"<br/><b>Then</b> a 6-digit OTP is sent to the NEW number (expires in 10 minutes)<br/><b>And</b> a countdown timer is displayed</p><h3>AC 4: 3 Failed OTP = Cancel</h3><p><b>Given</b> I received an OTP<br/><b>When</b> I enter an incorrect OTP 3 times<br/><b>Then</b> the phone change is cancelled and logged as a security event</p><h3>AC 5: Old Phone Notification</h3><p><b>Given</b> the phone change is verified<br/><b>When</b> the change is committed<br/><b>Then</b> an SMS is sent to the OLD phone: "Your phone number was changed. Call 1-800-CONTOSO if this wasn't you."</p><h3>AC 6: 72-Hour Cool-Down</h3><p><b>Given</b> the new phone is verified<br/><b>Then</b> it cannot be used for MFA or account recovery for 72 hours</p><h3>AC 7: Rate Limiting (3/24hr)</h3><p><b>Given</b> a customer attempts more than 3 phone changes in 24 hours<br/><b>Then</b> the system blocks further requests and flags for security review</p>' \
  --project "$PROJECT" \
  --query "id" -o tsv)
az boards work-item relation add --id "$PBI12_ID" --relation-type "System.LinkTypes.Hierarchy-Reverse" --target-id "$FEAT1_ID" --output none
echo "  ✅ PBI 1.2 created: ID $PBI12_ID"

# PBI 1.3: Mailing Address Change with USPS Validation
echo "[5/22] Creating PBI 1.3: Mailing Address Change with USPS Validation..."
PBI13_ID=$(az boards work-item create \
  --type "Product Backlog Item" \
  --title "Mailing Address Change with USPS Validation" \
  --description "As a banking customer, I want to update my mailing address with address validation, so that my statements and correspondence arrive at my correct address." \
  --fields "Microsoft.VSTS.Common.Priority=1" \
  --fields "Microsoft.VSTS.Scheduling.StoryPoints=8" \
  --fields "System.Tags=Profile; Contact-Info; Address; USPS; KYC; Phase-1" \
  --fields 'Microsoft.VSTS.Common.AcceptanceCriteria=<h3>AC 1: Step-Up MFA Before Address Change</h3><p><b>Given</b> I am authenticated<br/><b>When</b> I click "Change Mailing Address"<br/><b>Then</b> the system requires step-up MFA</p><h3>AC 2: USPS Address Validation</h3><p><b>Given</b> I completed MFA and entered a new US address<br/><b>When</b> I submit<br/><b>Then</b> the system validates via USPS Address Validation API<br/><b>And</b> shows the standardized address for confirmation<br/><b>And</b> if invalid, shows error with option to re-enter or override with explicit confirmation</p><h3>AC 3: KYC for Interstate Moves</h3><p><b>Given</b> the new address is in a different state<br/><b>When</b> the change is saved<br/><b>Then</b> it triggers BSA/KYC enhanced due diligence<br/><b>And</b> the change is "Pending Review" (1-2 business days)</p><h3>AC 4: Same-State Immediate Update</h3><p><b>Given</b> the new address is in the same state<br/><b>When</b> it passes USPS validation<br/><b>Then</b> the address updates immediately and syncs to core banking API</p><h3>AC 5: Audit Logging</h3><p><b>Given</b> any address change<br/><b>When</b> submitted<br/><b>Then</b> the system logs: customer ID, timestamp, old/new address, USPS result, interstate flag, approval status, IP address in the append-only audit log</p>' \
  --project "$PROJECT" \
  --query "id" -o tsv)
az boards work-item relation add --id "$PBI13_ID" --relation-type "System.LinkTypes.Hierarchy-Reverse" --target-id "$FEAT1_ID" --output none
echo "  ✅ PBI 1.3 created: ID $PBI13_ID"

# PBI 1.4: Profile View — Contact Information Display
echo "[6/22] Creating PBI 1.4: Profile View — Contact Information Display..."
PBI14_ID=$(az boards work-item create \
  --type "Product Backlog Item" \
  --title "Profile View — Contact Information Display" \
  --description "As a banking customer, I want to view my current contact information (email, phone, mailing address) on my profile page, so that I can verify my information is correct and identify what needs updating." \
  --fields "Microsoft.VSTS.Common.Priority=1" \
  --fields "Microsoft.VSTS.Scheduling.StoryPoints=5" \
  --fields "System.Tags=Profile; Contact-Info; UI; Phase-1" \
  --fields 'Microsoft.VSTS.Common.AcceptanceCriteria=<h3>AC 1: Page Load ≤ 2 Seconds</h3><p><b>Given</b> I am authenticated<br/><b>When</b> I navigate to Profile > Contact Information<br/><b>Then</b> the page loads within 2 seconds</p><h3>AC 2: Masked Display with Show/Hide</h3><p><b>Given</b> the page loads<br/><b>When</b> I view my email/phone<br/><b>Then</b> they are masked by default (j***@example.com, ***-***-1234)<br/><b>And</b> a "Show" button reveals full value (auto-hides after 30s)</p><h3>AC 3: Pending Change Badges</h3><p><b>Given</b> a field has a pending change<br/><b>When</b> the page loads<br/><b>Then</b> a "Pending Verification" or "Pending Review" badge is shown with submission date</p><h3>AC 4: Mobile Responsive</h3><p><b>Given</b> viewport width 320-767px<br/><b>When</b> the page renders<br/><b>Then</b> fields stack vertically, touch targets are ≥44x44px, no horizontal scroll</p><h3>AC 5: Screen Reader Compatible</h3><p><b>Given</b> a screen reader user<br/><b>When</b> navigating the page<br/><b>Then</b> all fields have labels, masked state is announced, pending badges are announced, heading hierarchy is correct (h1>h2>h3)</p>' \
  --project "$PROJECT" \
  --query "id" -o tsv)
az boards work-item relation add --id "$PBI14_ID" --relation-type "System.LinkTypes.Hierarchy-Reverse" --target-id "$FEAT1_ID" --output none
echo "  ✅ PBI 1.4 created: ID $PBI14_ID"

# --------------------------------------------------------------------------
# FEATURE 2: Communication Preferences & Consent Management
# --------------------------------------------------------------------------
echo ""
echo "[7/22] Creating Feature 2: Communication Preferences & Consent Management..."
FEAT2_ID=$(az boards work-item create \
  --type "Feature" \
  --title "Communication Preferences & Consent Management" \
  --description "Allow customers to manage their notification preferences and communication channel consent in compliance with CAN-SPAM, TCPA, and E-SIGN Act. Customers choose which types of communications they receive (transactional, security, marketing) and through which channels (email, SMS, push, in-app). Security alerts are always-on and cannot be disabled." \
  --fields "Microsoft.VSTS.Common.Priority=1" \
  --fields "System.Tags=Profile; Preferences; Consent; Compliance; Phase-1" \
  --project "$PROJECT" \
  --query "id" -o tsv)
az boards work-item relation add --id "$FEAT2_ID" --relation-type "System.LinkTypes.Hierarchy-Reverse" --target-id "$EPIC_ID" --output none
echo "  ✅ Feature 2 created: ID $FEAT2_ID (parent: Epic $EPIC_ID)"

# PBI 2.1: Notification Preference Management
echo "[8/22] Creating PBI 2.1: Notification Preference Management..."
PBI21_ID=$(az boards work-item create \
  --type "Product Backlog Item" \
  --title "Notification Preference Management" \
  --description "As a banking customer, I want to configure which notifications I receive and through which channels, so that I only get communications I find valuable through my preferred channels." \
  --fields "Microsoft.VSTS.Common.Priority=2" \
  --fields "Microsoft.VSTS.Scheduling.StoryPoints=5" \
  --fields "System.Tags=Profile; Preferences; Notifications; Phase-1" \
  --fields 'Microsoft.VSTS.Common.AcceptanceCriteria=<h3>AC 1: Preference Matrix</h3><p><b>Given</b> I am on Communication Preferences<br/><b>When</b> the page loads<br/><b>Then</b> a matrix is displayed with notification types (Account Alerts, Transaction Alerts, Security Alerts, Statements, Marketing, Product Recommendations) × channels (Email, SMS, Push, In-App)</p><h3>AC 2: Security Alerts Always On</h3><p><b>Given</b> the preference matrix is displayed<br/><b>When</b> I try to disable Security Alerts<br/><b>Then</b> the toggle is disabled with tooltip: "Security alerts cannot be turned off to protect your account."</p><h3>AC 3: Save Within 3 Seconds</h3><p><b>Given</b> I modify preferences<br/><b>When</b> I click "Save Preferences"<br/><b>Then</b> preferences save within 3 seconds with a success toast</p><h3>AC 4: Quiet Hours</h3><p><b>Given</b> I toggle "Quiet Hours" on<br/><b>Then</b> I can set start/end time in my timezone<br/><b>And</b> non-security SMS/push are held during quiet hours</p><h3>AC 5: Accessible Toggles</h3><p><b>Given</b> a screen reader<br/><b>When</b> tabbing through the matrix<br/><b>Then</b> each toggle announces: "[Type] via [Channel]: currently [on/off]"</p>' \
  --project "$PROJECT" \
  --query "id" -o tsv)
az boards work-item relation add --id "$PBI21_ID" --relation-type "System.LinkTypes.Hierarchy-Reverse" --target-id "$FEAT2_ID" --output none
echo "  ✅ PBI 2.1 created: ID $PBI21_ID"

# PBI 2.2: SMS & Marketing Consent Management
echo "[9/22] Creating PBI 2.2: SMS & Marketing Consent Management..."
PBI22_ID=$(az boards work-item create \
  --type "Product Backlog Item" \
  --title "SMS & Marketing Consent Management (TCPA/CAN-SPAM Compliance)" \
  --description "As a banking customer, I want to manage my SMS and marketing communication consent, so that I comply with my preferences and the bank complies with TCPA and CAN-SPAM regulations." \
  --fields "Microsoft.VSTS.Common.Priority=1" \
  --fields "Microsoft.VSTS.Scheduling.StoryPoints=5" \
  --fields "System.Tags=Profile; Consent; TCPA; CAN-SPAM; Compliance; Phase-1" \
  --fields 'Microsoft.VSTS.Common.AcceptanceCriteria=<h3>AC 1: TCPA SMS Consent Disclosure</h3><p><b>Given</b> I enable SMS notifications for any non-security category<br/><b>When</b> I toggle SMS on<br/><b>Then</b> a TCPA disclosure is displayed and I must check an explicit consent checkbox before saving</p><h3>AC 2: CAN-SPAM Marketing Opt-Out (10 days)</h3><p><b>Given</b> I opt out of marketing emails<br/><b>When</b> I save<br/><b>Then</b> the opt-out is recorded with timestamp and processed within 10 business days per CAN-SPAM</p><h3>AC 3: Consent Re-Opt-In</h3><p><b>Given</b> I previously opted out<br/><b>When</b> I opt back in<br/><b>Then</b> a fresh consent record is created (prior opt-out retained in audit log)</p><h3>AC 4: Consent Audit Trail</h3><p><b>Given</b> any consent change<br/><b>When</b> saved<br/><b>Then</b> the audit log records: customer ID, consent type, old/new value, timestamp, IP, user agent, consent text version</p><h3>AC 5: Consent History Download</h3><p><b>Given</b> I am on the consent page<br/><b>Then</b> a "Download My Consent History" link exports all records as PDF (E-SIGN Act compliant)</p>' \
  --project "$PROJECT" \
  --query "id" -o tsv)
az boards work-item relation add --id "$PBI22_ID" --relation-type "System.LinkTypes.Hierarchy-Reverse" --target-id "$FEAT2_ID" --output none
echo "  ✅ PBI 2.2 created: ID $PBI22_ID"

# PBI 2.3: E-SIGN Act Electronic Delivery Consent
echo "[10/22] Creating PBI 2.3: E-SIGN Act Electronic Delivery Consent..."
PBI23_ID=$(az boards work-item create \
  --type "Product Backlog Item" \
  --title "E-SIGN Act Electronic Delivery Consent" \
  --description "As a banking customer, I want to manage my consent for receiving statements and disclosures electronically, so that I can choose between paper and electronic delivery in compliance with the E-SIGN Act." \
  --fields "Microsoft.VSTS.Common.Priority=2" \
  --fields "Microsoft.VSTS.Scheduling.StoryPoints=3" \
  --fields "System.Tags=Profile; Consent; E-SIGN; Compliance; Phase-1" \
  --fields 'Microsoft.VSTS.Common.AcceptanceCriteria=<h3>AC 1: E-Delivery Status Display</h3><p><b>Given</b> I navigate to Electronic Delivery<br/><b>When</b> the page loads<br/><b>Then</b> the current consent status (Opted In/Out), consent date, and document types covered are displayed</p><h3>AC 2: Opt-In with E-SIGN Disclosure</h3><p><b>Given</b> I opt into e-delivery<br/><b>When</b> I toggle on<br/><b>Then</b> the E-SIGN disclosure is displayed and I must click explicit "I Agree" button<br/><b>And</b> the consent is recorded with full disclosure text version</p><h3>AC 3: Opt-Out Reverts to Paper</h3><p><b>Given</b> I opt out of e-delivery<br/><b>When</b> I confirm<br/><b>Then</b> paper delivery resumes within 3 business days<br/><b>And</b> I see: "Paper documents will be mailed to [address]. Paper delivery fees may apply."</p><h3>AC 4: SOX Audit Logging</h3><p><b>Given</b> any E-SIGN consent change<br/><b>When</b> saved<br/><b>Then</b> full consent record (disclosure text version, timestamp, IP, confirmation method) is stored in the SOX audit log with 7-year retention</p>' \
  --project "$PROJECT" \
  --query "id" -o tsv)
az boards work-item relation add --id "$PBI23_ID" --relation-type "System.LinkTypes.Hierarchy-Reverse" --target-id "$FEAT2_ID" --output none
echo "  ✅ PBI 2.3 created: ID $PBI23_ID"

# --------------------------------------------------------------------------
# FEATURE 3: Security Settings Management
# --------------------------------------------------------------------------
echo ""
echo "[11/22] Creating Feature 3: Security Settings Management..."
FEAT3_ID=$(az boards work-item create \
  --type "Feature" \
  --title "Security Settings Management" \
  --description "Allow customers to manage their account security settings including password changes, MFA enrollment and management, trusted device management, and active session management. All security settings changes require step-up MFA authentication and are logged in the SOX audit trail." \
  --fields "Microsoft.VSTS.Common.Priority=1" \
  --fields "System.Tags=Profile; Security; MFA; Authentication; Phase-1" \
  --project "$PROJECT" \
  --query "id" -o tsv)
az boards work-item relation add --id "$FEAT3_ID" --relation-type "System.LinkTypes.Hierarchy-Reverse" --target-id "$EPIC_ID" --output none
echo "  ✅ Feature 3 created: ID $FEAT3_ID (parent: Epic $EPIC_ID)"

# PBI 3.1: Password Change
echo "[12/22] Creating PBI 3.1: Password Change..."
PBI31_ID=$(az boards work-item create \
  --type "Product Backlog Item" \
  --title "Password Change" \
  --description "As a banking customer, I want to change my password from my profile settings, so that I can maintain strong account security." \
  --fields "Microsoft.VSTS.Common.Priority=1" \
  --fields "Microsoft.VSTS.Scheduling.StoryPoints=5" \
  --fields "System.Tags=Profile; Security; Password; NIST; Phase-1" \
  --fields 'Microsoft.VSTS.Common.AcceptanceCriteria=<h3>AC 1: Step-Up MFA Required</h3><p><b>Given</b> I click "Change Password"<br/><b>When</b> the form loads<br/><b>Then</b> step-up MFA is required first</p><h3>AC 2: NIST SP 800-63B Password Rules</h3><p><b>Given</b> the password change form<br/><b>When</b> I enter current password + new password + confirmation<br/><b>Then</b> the system validates: min 12 chars, 1 uppercase, 1 lowercase, 1 digit, 1 special char, not in HIBP breach corpus, not matching last 12 passwords</p><h3>AC 3: Other Sessions Terminated</h3><p><b>Given</b> password changed successfully<br/><b>When</b> the change commits<br/><b>Then</b> all other active sessions are terminated (except current)<br/><b>And</b> email + SMS notification sent</p><h3>AC 4: Inline Validation Errors</h3><p><b>Given</b> the password fails validation<br/><b>When</b> errors are detected<br/><b>Then</b> specific inline errors shown (e.g., "Password must be at least 12 characters", "This password has appeared in a data breach")</p><h3>AC 5: Lockout (5 failed = 30min)</h3><p><b>Given</b> I enter current password incorrectly 5 times<br/><b>Then</b> the form is locked for 30 minutes and logged as a security event</p>' \
  --project "$PROJECT" \
  --query "id" -o tsv)
az boards work-item relation add --id "$PBI31_ID" --relation-type "System.LinkTypes.Hierarchy-Reverse" --target-id "$FEAT3_ID" --output none
echo "  ✅ PBI 3.1 created: ID $PBI31_ID"

# PBI 3.2: MFA Enrollment & Management
echo "[13/22] Creating PBI 3.2: MFA Enrollment & Management..."
PBI32_ID=$(az boards work-item create \
  --type "Product Backlog Item" \
  --title "MFA Enrollment & Management" \
  --description "As a banking customer, I want to enroll in and manage my multi-factor authentication methods, so that I can secure my account and choose my preferred MFA method." \
  --fields "Microsoft.VSTS.Common.Priority=1" \
  --fields "Microsoft.VSTS.Scheduling.StoryPoints=8" \
  --fields "System.Tags=Profile; Security; MFA; TOTP; Phase-1" \
  --fields 'Microsoft.VSTS.Common.AcceptanceCriteria=<h3>AC 1: MFA Methods Display</h3><p><b>Given</b> I am on Security Settings > MFA<br/><b>Then</b> I see enrolled MFA methods (SMS, TOTP App, Email) with status (Active, Primary) and options to add/remove/change primary</p><h3>AC 2: TOTP App Enrollment</h3><p><b>Given</b> I click "Add Authenticator App"<br/><b>Then</b> a QR code is displayed (with text-based secret key alternative for accessibility)<br/><b>And</b> I enter a verification code from the app to confirm</p><h3>AC 3: SMS MFA Enrollment</h3><p><b>Given</b> I click "Add SMS"<br/><b>Then</b> I confirm the phone number, receive a 6-digit OTP (10min expiry), and enter it to enroll</p><h3>AC 4: Minimum 1 Method Required</h3><p><b>Given</b> I try to remove my last MFA method<br/><b>Then</b> the removal is blocked: "You must have at least one MFA method active."</p><h3>AC 5: Primary Method Change Notification</h3><p><b>Given</b> I change my primary MFA method<br/><b>Then</b> email + SMS notification: "Your default verification method was changed."</p><h3>AC 6: Accessible QR Code</h3><p><b>Given</b> a screen reader user<br/><b>Then</b> the text-based secret key is accessible, all status indicators announced, all actions have clear labels</p>' \
  --project "$PROJECT" \
  --query "id" -o tsv)
az boards work-item relation add --id "$PBI32_ID" --relation-type "System.LinkTypes.Hierarchy-Reverse" --target-id "$FEAT3_ID" --output none
echo "  ✅ PBI 3.2 created: ID $PBI32_ID"

# PBI 3.3: Trusted Device Management
echo "[14/22] Creating PBI 3.3: Trusted Device Management..."
PBI33_ID=$(az boards work-item create \
  --type "Product Backlog Item" \
  --title "Trusted Device Management" \
  --description "As a banking customer, I want to view and manage my trusted devices, so that I can ensure only my recognized devices have streamlined access to my account." \
  --fields "Microsoft.VSTS.Common.Priority=2" \
  --fields "Microsoft.VSTS.Scheduling.StoryPoints=5" \
  --fields "System.Tags=Profile; Security; Devices; Phase-1" \
  --fields 'Microsoft.VSTS.Common.AcceptanceCriteria=<h3>AC 1: Trusted Device List</h3><p><b>Given</b> I navigate to Trusted Devices<br/><b>Then</b> I see all trusted devices with: device name/type, last used date/time, IP (city/region), and "Remove" button</p><h3>AC 2: Remove Single Device</h3><p><b>Given</b> I click "Remove" on a device<br/><b>Then</b> step-up MFA is required, the trust token is revoked, and I see: "Device removed. MFA required next sign-in from this device."</p><h3>AC 3: Remove All Devices</h3><p><b>Given</b> I click "Remove All Trusted Devices"<br/><b>Then</b> MFA confirmation required, all trust tokens revoked, all device sessions terminated</p><h3>AC 4: 90-Day Staleness Warning</h3><p><b>Given</b> a device has not been used in 90 days<br/><b>Then</b> it is highlighted with "Not used in over 90 days — consider removing"</p>' \
  --project "$PROJECT" \
  --query "id" -o tsv)
az boards work-item relation add --id "$PBI33_ID" --relation-type "System.LinkTypes.Hierarchy-Reverse" --target-id "$FEAT3_ID" --output none
echo "  ✅ PBI 3.3 created: ID $PBI33_ID"

# PBI 3.4: Active Session Management
echo "[15/22] Creating PBI 3.4: Active Session Management..."
PBI34_ID=$(az boards work-item create \
  --type "Product Backlog Item" \
  --title "Active Session Management" \
  --description "As a banking customer, I want to view my active sessions and terminate any suspicious ones, so that I can protect my account if a session is compromised." \
  --fields "Microsoft.VSTS.Common.Priority=2" \
  --fields "Microsoft.VSTS.Scheduling.StoryPoints=5" \
  --fields "System.Tags=Profile; Security; Sessions; Phase-1" \
  --fields 'Microsoft.VSTS.Common.AcceptanceCriteria=<h3>AC 1: Active Session List</h3><p><b>Given</b> I navigate to Active Sessions<br/><b>Then</b> I see all active sessions (max 3) with: device/browser, IP (city/region), start time, last activity, and current session marked "This device"</p><h3>AC 2: Terminate Remote Session</h3><p><b>Given</b> I click "End Session" on a remote session<br/><b>Then</b> the session is immediately terminated, token invalidated, and I see: "Session ended. If you didn't recognize this session, change your password."</p><h3>AC 3: End All Other Sessions</h3><p><b>Given</b> I click "End All Other Sessions"<br/><b>Then</b> all sessions except current are terminated with confirmation message</p><h3>AC 4: Unusual Location Flagging</h3><p><b>Given</b> a session is from an unusual location (different country or >500 miles from typical)<br/><b>Then</b> it is flagged with a warning icon and "Unusual location" label</p>' \
  --project "$PROJECT" \
  --query "id" -o tsv)
az boards work-item relation add --id "$PBI34_ID" --relation-type "System.LinkTypes.Hierarchy-Reverse" --target-id "$FEAT3_ID" --output none
echo "  ✅ PBI 3.4 created: ID $PBI34_ID"

# --------------------------------------------------------------------------
# FEATURE 4: Profile Audit & Compliance
# --------------------------------------------------------------------------
echo ""
echo "[16/22] Creating Feature 4: Profile Audit & Compliance..."
FEAT4_ID=$(az boards work-item create \
  --type "Feature" \
  --title "Profile Audit & Compliance" \
  --description "Provide a complete, immutable audit trail for all profile changes to meet SOX compliance requirements (7-year retention, append-only). Enable customers to view their own change history. Trigger KYC re-verification when required by BSA. Support unauthorized change rollback." \
  --fields "Microsoft.VSTS.Common.Priority=1" \
  --fields "System.Tags=Profile; Audit; SOX; KYC; Compliance; Phase-1" \
  --project "$PROJECT" \
  --query "id" -o tsv)
az boards work-item relation add --id "$FEAT4_ID" --relation-type "System.LinkTypes.Hierarchy-Reverse" --target-id "$EPIC_ID" --output none
echo "  ✅ Feature 4 created: ID $FEAT4_ID (parent: Epic $EPIC_ID)"

# PBI 4.1: Profile Change History — Customer-Facing
echo "[17/22] Creating PBI 4.1: Profile Change History..."
PBI41_ID=$(az boards work-item create \
  --type "Product Backlog Item" \
  --title "Profile Change History — Customer-Facing Audit View" \
  --description "As a banking customer, I want to view a history of changes made to my profile, so that I can detect unauthorized changes and verify my own activity." \
  --fields "Microsoft.VSTS.Common.Priority=2" \
  --fields "Microsoft.VSTS.Scheduling.StoryPoints=5" \
  --fields "System.Tags=Profile; Audit; History; Phase-1" \
  --fields 'Microsoft.VSTS.Common.AcceptanceCriteria=<h3>AC 1: Paginated Change List</h3><p><b>Given</b> I click "Change History"<br/><b>Then</b> a paginated list (20/page) of all profile changes in reverse chronological order is displayed with: date/time, field changed, change type, status (Completed/Pending/Rolled Back), IP/device</p><h3>AC 2: Masked Historical Values</h3><p><b>Given</b> a contact info change entry<br/><b>Then</b> old/new values are shown masked (j***@old.com → j***@new.com)</p><h3>AC 3: Filtering</h3><p><b>Given</b> I use filter controls<br/><b>Then</b> I can filter by: date range, field type (Contact Info/Preferences/Security), status</p><h3>AC 4: Performance</h3><p><b>Given</b> up to 100 records<br/><b>Then</b> initial load within 2s, pagination within 1s</p><h3>AC 5: Report Suspicious Change</h3><p><b>Given</b> a suspicious entry<br/><b>When</b> I click "Report This Change"<br/><b>Then</b> a pre-filled support ticket is created: "A support ticket has been created. Our security team will review within 24 hours."</p>' \
  --project "$PROJECT" \
  --query "id" -o tsv)
az boards work-item relation add --id "$PBI41_ID" --relation-type "System.LinkTypes.Hierarchy-Reverse" --target-id "$FEAT4_ID" --output none
echo "  ✅ PBI 4.1 created: ID $PBI41_ID"

# PBI 4.2: SOX-Compliant Audit Logging (Backend)
echo "[18/22] Creating PBI 4.2: SOX-Compliant Audit Logging..."
PBI42_ID=$(az boards work-item create \
  --type "Product Backlog Item" \
  --title "SOX-Compliant Audit Logging for Profile Changes" \
  --description "As a compliance officer, I want all profile changes to be logged in an immutable, append-only audit log with 7-year retention, so that the bank meets SOX compliance requirements and can respond to regulatory audits." \
  --fields "Microsoft.VSTS.Common.Priority=1" \
  --fields "Microsoft.VSTS.Scheduling.StoryPoints=8" \
  --fields "System.Tags=Profile; Audit; SOX; Backend; Compliance; Phase-1" \
  --fields 'Microsoft.VSTS.Common.AcceptanceCriteria=<h3>AC 1: Comprehensive Audit Record</h3><p><b>Given</b> any profile field is changed<br/><b>When</b> the change is persisted<br/><b>Then</b> an audit record is written containing: event ID (UUID), customer ID, timestamp (UTC ISO 8601), event type, field changed, old value (encrypted at rest), new value (encrypted at rest), IP address, user agent, session ID, MFA method used, result (success/failure/pending)</p><h3>AC 2: Append-Only — No Modifications</h3><p><b>Given</b> an audit record exists<br/><b>When</b> any attempt is made to modify or delete it<br/><b>Then</b> the operation is rejected at API and database level</p><h3>AC 3: 7-Year Retention</h3><p><b>Given</b> audit records exist<br/><b>Then</b> all records are retained for minimum 7 years. Archival (not deletion) allowed after 7 years with compliance officer approval only.</p><h3>AC 4: Failures Also Logged</h3><p><b>Given</b> a profile change fails<br/><b>Then</b> the failure is STILL logged with error details — no gaps in the audit record</p><h3>AC 5: Fail-Closed</h3><p><b>Given</b> the audit logging service is unavailable<br/><b>When</b> a profile change is attempted<br/><b>Then</b> the change is BLOCKED. Customer sees: "Unable to process profile changes at this time."</p><h3>AC 6: Compliance Query Performance</h3><p><b>Given</b> a compliance officer queries the audit log<br/><b>Then</b> results within 5 seconds for up to 10,000 records, with CSV/JSON export</p>' \
  --project "$PROJECT" \
  --query "id" -o tsv)
az boards work-item relation add --id "$PBI42_ID" --relation-type "System.LinkTypes.Hierarchy-Reverse" --target-id "$FEAT4_ID" --output none
echo "  ✅ PBI 4.2 created: ID $PBI42_ID"

# PBI 4.3: Unauthorized Change Rollback
echo "[19/22] Creating PBI 4.3: Unauthorized Change Rollback..."
PBI43_ID=$(az boards work-item create \
  --type "Product Backlog Item" \
  --title "Unauthorized Profile Change Rollback" \
  --description "As a banking customer whose account may have been compromised, I want to quickly reverse unauthorized profile changes, so that an attacker cannot lock me out of my own account by changing my contact information." \
  --fields "Microsoft.VSTS.Common.Priority=2" \
  --fields "Microsoft.VSTS.Scheduling.StoryPoints=5" \
  --fields "System.Tags=Profile; Security; Rollback; Fraud; Phase-1" \
  --fields 'Microsoft.VSTS.Common.AcceptanceCriteria=<h3>AC 1: Rollback Link in Notifications (72h)</h3><p><b>Given</b> a contact info change is completed<br/><b>Then</b> the notification to the OLD contact includes a secure rollback link valid for 72 hours</p><h3>AC 2: Customer Self-Service Rollback</h3><p><b>Given</b> I click the rollback link within 72 hours<br/><b>Then</b> the field is reverted, my account is temporarily locked for security review, and I see confirmation</p><h3>AC 3: Expired Link</h3><p><b>Given</b> the rollback link is older than 72 hours<br/><b>Then</b> I see: "This link has expired. Contact support at 1-800-CONTOSO."</p><h3>AC 4: Agent Rollback (90 days)</h3><p><b>Given</b> a support agent initiates rollback within 90 days<br/><b>Then</b> the field is reverted, audit entry created with agent ID, customer notified</p><h3>AC 5: Rollback Audited</h3><p><b>Given</b> any rollback occurs<br/><b>Then</b> it is recorded in the audit log with: original change ID, rollback reason, initiated by (customer/agent), timestamp, restored value</p>' \
  --project "$PROJECT" \
  --query "id" -o tsv)
az boards work-item relation add --id "$PBI43_ID" --relation-type "System.LinkTypes.Hierarchy-Reverse" --target-id "$FEAT4_ID" --output none
echo "  ✅ PBI 4.3 created: ID $PBI43_ID"

# --------------------------------------------------------------------------
# FEATURE 5: Profile Accessibility & Responsive Design
# --------------------------------------------------------------------------
echo ""
echo "[20/22] Creating Feature 5: Profile Accessibility & Responsive Design..."
FEAT5_ID=$(az boards work-item create \
  --type "Feature" \
  --title "Profile Accessibility & Responsive Design" \
  --description "Ensure all profile management features meet WCAG 2.1 AA accessibility standards and provide a fully responsive experience across mobile (320-767px), tablet (768-1023px), and desktop (1024px+) viewports. This is both a legal requirement (ADA) and a business requirement (mobile-first banking customers)." \
  --fields "Microsoft.VSTS.Common.Priority=1" \
  --fields "System.Tags=Profile; Accessibility; WCAG; Responsive; Phase-1" \
  --project "$PROJECT" \
  --query "id" -o tsv)
az boards work-item relation add --id "$FEAT5_ID" --relation-type "System.LinkTypes.Hierarchy-Reverse" --target-id "$EPIC_ID" --output none
echo "  ✅ Feature 5 created: ID $FEAT5_ID (parent: Epic $EPIC_ID)"

# PBI 5.1: WCAG 2.1 AA Compliance
echo "[21/22] Creating PBI 5.1: WCAG 2.1 AA Compliance..."
PBI51_ID=$(az boards work-item create \
  --type "Product Backlog Item" \
  --title "WCAG 2.1 AA Compliance for Profile Pages" \
  --description "As a customer with a disability, I want the profile management pages to be fully accessible per WCAG 2.1 AA, so that I can independently manage my banking profile regardless of how I interact with the portal." \
  --fields "Microsoft.VSTS.Common.Priority=1" \
  --fields "Microsoft.VSTS.Scheduling.StoryPoints=5" \
  --fields "System.Tags=Profile; Accessibility; WCAG; Phase-1" \
  --fields 'Microsoft.VSTS.Common.AcceptanceCriteria=<h3>AC 1: Zero axe-core Violations</h3><p><b>Given</b> any profile page<br/><b>When</b> tested with axe-core<br/><b>Then</b> zero WCAG 2.1 AA violations are reported</p><h3>AC 2: Full Keyboard Navigation</h3><p><b>Given</b> a keyboard-only user<br/><b>Then</b> all elements reachable via Tab/Shift+Tab/Enter/Space/Arrow keys in logical order, visible focus indicators (≥2px, ≥3:1 contrast), no keyboard traps</p><h3>AC 3: Screen Reader Error Announcements</h3><p><b>Given</b> a validation error on any profile form<br/><b>Then</b> error is announced via aria-live="assertive", associated with field via aria-describedby, and focus moves to first error field</p><h3>AC 4: Color Contrast</h3><p><b>Given</b> any text on profile pages<br/><b>Then</b> normal text has ≥4.5:1 contrast, large text (18pt+) has ≥3:1 contrast</p><h3>AC 5: 200% Zoom Support</h3><p><b>Given</b> browser zoom at 200%<br/><b>Then</b> no content is clipped, overlapped, or requires horizontal scrolling</p><h3>AC 6: Preference Matrix Accessibility</h3><p><b>Given</b> a screen reader on the notification preference matrix<br/><b>Then</b> each toggle announces full context: "[Type] via [Channel]: [on/off]. Toggle to [turn on/off]."</p>' \
  --project "$PROJECT" \
  --query "id" -o tsv)
az boards work-item relation add --id "$PBI51_ID" --relation-type "System.LinkTypes.Hierarchy-Reverse" --target-id "$FEAT5_ID" --output none
echo "  ✅ PBI 5.1 created: ID $PBI51_ID"

# PBI 5.2: Responsive Design
echo "[22/22] Creating PBI 5.2: Responsive Design..."
PBI52_ID=$(az boards work-item create \
  --type "Product Backlog Item" \
  --title "Responsive Design for Profile Management" \
  --description "As a banking customer using my phone, I want the profile management pages to work seamlessly on my mobile device, so that I can manage my profile on the go." \
  --fields "Microsoft.VSTS.Common.Priority=1" \
  --fields "Microsoft.VSTS.Scheduling.StoryPoints=5" \
  --fields "System.Tags=Profile; Responsive; Mobile; UI; Phase-1" \
  --fields 'Microsoft.VSTS.Common.AcceptanceCriteria=<h3>AC 1: Mobile Layout (320-767px)</h3><p><b>Given</b> viewport 320-767px<br/><b>Then</b> single-column stacked layout, touch targets ≥44x44px with ≥8px spacing, no horizontal scrolling</p><h3>AC 2: Tablet Layout (768-1023px)</h3><p><b>Given</b> viewport 768-1023px<br/><b>Then</b> two-column layout where appropriate, full-width edit forms</p><h3>AC 3: Desktop Layout (1024px+)</h3><p><b>Given</b> viewport 1024px+<br/><b>Then</b> sidebar navigation for profile sections, content area to the right</p><h3>AC 4: Mobile Keyboard Types</h3><p><b>Given</b> mobile device form input<br/><b>Then</b> appropriate keyboard shown (email for email, numeric for phone/OTP, text for address)<br/><b>And</b> no layout shift when keyboard appears</p><h3>AC 5: Preference Matrix on Mobile</h3><p><b>Given</b> the notification matrix on narrow screens<br/><b>Then</b> it reformats into card-based layout (one type per card with channel toggles) instead of table</p>' \
  --project "$PROJECT" \
  --query "id" -o tsv)
az boards work-item relation add --id "$PBI52_ID" --relation-type "System.LinkTypes.Hierarchy-Reverse" --target-id "$FEAT5_ID" --output none
echo "  ✅ PBI 5.2 created: ID $PBI52_ID"

# --------------------------------------------------------------------------
# Summary
# --------------------------------------------------------------------------
echo ""
echo "=========================================="
echo "✅ ALL WORK ITEMS CREATED SUCCESSFULLY"
echo "=========================================="
echo ""
echo "Epic:     $EPIC_ID — Profile Management"
echo ""
echo "Feature 1: $FEAT1_ID — Contact Information Management"
echo "  PBI 1.1: $PBI11_ID — Email Address Change (8 SP)"
echo "  PBI 1.2: $PBI12_ID — Phone Number Change (8 SP)"
echo "  PBI 1.3: $PBI13_ID — Mailing Address Change (8 SP)"
echo "  PBI 1.4: $PBI14_ID — Profile View Display (5 SP)"
echo ""
echo "Feature 2: $FEAT2_ID — Communication Preferences & Consent"
echo "  PBI 2.1: $PBI21_ID — Notification Preferences (5 SP)"
echo "  PBI 2.2: $PBI22_ID — SMS/Marketing Consent (5 SP)"
echo "  PBI 2.3: $PBI23_ID — E-SIGN Consent (3 SP)"
echo ""
echo "Feature 3: $FEAT3_ID — Security Settings Management"
echo "  PBI 3.1: $PBI31_ID — Password Change (5 SP)"
echo "  PBI 3.2: $PBI32_ID — MFA Enrollment (8 SP)"
echo "  PBI 3.3: $PBI33_ID — Trusted Devices (5 SP)"
echo "  PBI 3.4: $PBI34_ID — Active Sessions (5 SP)"
echo ""
echo "Feature 4: $FEAT4_ID — Profile Audit & Compliance"
echo "  PBI 4.1: $PBI41_ID — Change History (5 SP)"
echo "  PBI 4.2: $PBI42_ID — SOX Audit Logging (8 SP)"
echo "  PBI 4.3: $PBI43_ID — Rollback (5 SP)"
echo ""
echo "Feature 5: $FEAT5_ID — Accessibility & Responsive Design"
echo "  PBI 5.1: $PBI51_ID — WCAG 2.1 AA (5 SP)"
echo "  PBI 5.2: $PBI52_ID — Responsive Design (5 SP)"
echo ""
echo "Total: 1 Epic, 5 Features, 16 PBIs, 95 Story Points"
