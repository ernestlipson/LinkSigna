# Email OTP Integration for Interpreter Signup

This document explains how the [email_otp package](https://pub.dev/packages/email_otp) has been integrated into the interpreter signup flow.

## Overview

The email OTP integration provides secure email verification for interpreter signup, ensuring that interpreters provide valid email addresses before completing their registration.

## Configuration

### 1. Package Configuration (main.dart)

The email_otp package is configured in `lib/main.dart`:

```dart
EmailOTP.config(
  appName: 'LinkSigna',
  otpType: OTPType.numeric,
  expiry: 300000, // 5 minutes
  emailTheme: EmailTheme.v6,
  appEmail: 'noreply@linksigna.com',
  otpLength: 6,
);
```

### 2. Configuration Options

- **appName**: The name displayed in OTP emails
- **otpType**: Type of OTP (numeric, alphabetic, or alphanumeric)
- **expiry**: OTP expiration time in milliseconds (5 minutes)
- **emailTheme**: Pre-built email template theme (v6)
- **appEmail**: Sender email address
- **otpLength**: Length of the OTP code (6 digits)

## Implementation

### 1. Controller (InteerpreterController)

The controller manages the OTP flow with the following methods:

- `sendOtp()`: Sends OTP to the provided email
- `resendOtp()`: Resends OTP if needed
- `verifyOtp()`: Verifies the entered OTP code
- `submit()`: Final submission after email verification

### 2. UI Flow

1. **Email Input**: User enters their email address
2. **Send OTP**: User clicks "Send Verification Code" button
3. **OTP Input**: After OTP is sent, verification code input field appears
4. **Verify OTP**: User enters the 6-digit code and clicks "Verify Code"
5. **Resend Option**: User can resend OTP if needed
6. **Complete Signup**: After verification, user can complete signup

### 3. State Management

The controller uses GetX observables to manage state:

- `isOtpSent`: Whether OTP has been sent
- `isOtpVerified`: Whether OTP has been verified
- `isSendingOtp`: Loading state for sending OTP
- `isVerifyingOtp`: Loading state for verifying OTP

## Features

### 1. Email Validation
- Real-time email format validation
- Prevents sending OTP to invalid email addresses

### 2. Loading States
- Visual feedback during OTP sending and verification
- Disabled buttons during processing

### 3. Error Handling
- Comprehensive error messages for various scenarios
- User-friendly snackbar notifications

### 4. Resend Functionality
- Users can resend OTP if they don't receive it
- Prevents spam by showing loading state

### 5. Security
- OTP expires after 5 minutes
- 6-digit numeric codes for better security
- Email verification required before account creation

## Usage

### For Users

1. Navigate to interpreter signup
2. Enter name and email
3. Click "Send Verification Code"
4. Check email for 6-digit code
5. Enter code and click "Verify Code"
6. Accept terms and complete signup

### For Developers

The integration is modular and can be easily extended:

```dart
// Send OTP
await EmailOTP.sendOTP(email: userEmail);

// Verify OTP
bool isValid = EmailOTP.verifyOTP(otp: userEnteredOTP);

// Check if OTP is expired
bool isExpired = EmailOTP.isExpired();

// Get the generated OTP (for testing)
String otp = EmailOTP.getOTP();
```

## Customization

### 1. Email Template

You can customize the email template using `EmailOTP.setTemplate()`:

```dart
EmailOTP.setTemplate(
  template: '''
  <div style="background-color: #f4f4f4; padding: 20px;">
    <h1>{{appName}}</h1>
    <p>Your OTP is <strong>{{otp}}</strong></p>
    <p>This OTP is valid for 5 minutes.</p>
  </div>
  ''',
);
```

### 2. SMTP Configuration

For custom email sending, configure SMTP settings:

```dart
EmailOTP.setSMTP(
  host: 'your-smtp-server.com',
  emailPort: EmailPort.port587,
  secureType: SecureType.tls,
  username: 'your-email@domain.com',
  password: 'your-password',
);
```

## Testing

### 1. Development Testing

During development, you can get the generated OTP:

```dart
print(EmailOTP.getOTP()); // Prints the generated OTP
```

### 2. Production Testing

- Use real email addresses for testing
- Check email delivery and formatting
- Verify OTP expiration functionality

## Security Considerations

1. **Rate Limiting**: Consider implementing rate limiting for OTP requests
2. **Email Validation**: Always validate email format before sending OTP
3. **OTP Expiry**: OTPs expire after 5 minutes for security
4. **Error Messages**: Avoid revealing sensitive information in error messages

## Troubleshooting

### Common Issues

1. **OTP Not Received**: Check spam folder, verify email address
2. **Invalid OTP**: Ensure correct 6-digit code, check for typos
3. **Expired OTP**: Request new OTP if current one has expired
4. **Email Format**: Ensure email follows valid format

### Debug Information

Enable debug logging to troubleshoot issues:

```dart
// Add debug prints in controller methods
print('Sending OTP to: ${emailController.text}');
print('Verifying OTP: ${otpController.text}');
```

## Future Enhancements

1. **SMS OTP**: Add SMS verification as an alternative
2. **Biometric Verification**: Integrate device-based authentication
3. **Multi-factor Authentication**: Combine email OTP with other methods
4. **Custom Email Templates**: Create branded email templates
5. **Analytics**: Track OTP success/failure rates 