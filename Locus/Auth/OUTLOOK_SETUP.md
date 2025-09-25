# Outlook OAuth Setup Guide

This guide will help you set up Outlook OAuth authentication using Microsoft's MSAL (Microsoft Authentication Library) for your Locus app.

## Prerequisites

1. **Azure AD App Registration**: You need to register your app in Azure Active Directory
2. **MSAL SDK**: Microsoft Authentication Library for iOS

## Step 1: Azure AD App Registration

### 1.1 Create App Registration
1. Go to [Azure Portal](https://portal.azure.com)
2. Navigate to **Azure Active Directory** > **App registrations**
3. Click **New registration**
4. Fill in the details:
   - **Name**: `Locus iOS App` (or your preferred name)
   - **Supported account types**: Choose based on your needs:
     - `Accounts in this organizational directory only` (single tenant)
     - `Accounts in any organizational directory` (multi-tenant)
     - `Accounts in any organizational directory and personal Microsoft accounts` (recommended for Outlook)
   - **Redirect URI**: 
     - Platform: `iOS`
     - Bundle ID: `com.yourcompany.locus` (replace with your actual bundle ID)

### 1.2 Configure Authentication
1. In your app registration, go to **Authentication**
2. Under **Platform configurations**, ensure your iOS redirect URI is listed
3. Under **Advanced settings**:
   - Enable **Allow public client flows**: `Yes`
   - **Supported account types**: Should match your registration choice

### 1.3 API Permissions
1. Go to **API permissions**
2. Click **Add a permission**
3. Select **Microsoft Graph**
4. Add these permissions:
   - `User.Read` (Delegated) - Read user profile
   - `Mail.Read` (Delegated) - Read user's mail
   - `offline_access` (Delegated) - Maintain access to resources
5. Click **Grant admin consent** (if you have admin rights)

### 1.4 Get Client ID
1. Go to **Overview** in your app registration
2. Copy the **Application (client) ID** - you'll need this for the code

## Step 2: Add MSAL SDK to Xcode

### 2.1 Swift Package Manager (Recommended)
1. In Xcode, go to **File** > **Add Package Dependencies**
2. Enter the URL: `https://github.com/AzureAD/microsoft-authentication-library-for-objc`
3. Select **Up to Next Major Version** and choose the latest version
4. Click **Add Package**
5. Select **MSAL** and click **Add Package**

### 2.2 Alternative: CocoaPods
Add to your `Podfile`:
```ruby
pod 'MSAL'
```
Then run `pod install`

## Step 3: Configure Your App

### 3.1 Update OutlookAuthManager.swift
Replace the placeholder values in `OutlookAuthManager.swift`:

```swift
private let clientId = "YOUR_ACTUAL_CLIENT_ID_HERE" // From Azure AD app registration
private let authority = "https://login.microsoftonline.com/common" // or your specific tenant
```

### 3.2 Update Info.plist
Add the following to your `Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>msauth.$(PRODUCT_BUNDLE_IDENTIFIER)</string>
        </array>
    </dict>
</array>
```

### 3.3 Update Bundle ID
Ensure your app's Bundle Identifier matches what you registered in Azure AD.

## Step 4: Test the Integration

1. Build and run your app
2. Tap "Join with Outlook"
3. You should see the Microsoft login screen
4. After successful authentication, you should see a success message

## Troubleshooting

### Common Issues

1. **"Invalid redirect URI"**
   - Ensure the Bundle ID in Azure AD matches your app's Bundle Identifier
   - Check that the redirect URI format is correct: `msauth.{BUNDLE_ID}://auth`

2. **"Client ID not found"**
   - Verify you've replaced `YOUR_CLIENT_ID_HERE` with your actual Azure AD client ID
   - Ensure the client ID is correct in Azure AD

3. **"Insufficient permissions"**
   - Check that you've added the required API permissions in Azure AD
   - Ensure admin consent has been granted if required

4. **"MSAL SDK not integrated"**
   - Verify MSAL has been properly added via Swift Package Manager
   - Check that the import statement works: `#if canImport(MSAL)`

### Debug Tips

1. **Enable MSAL Logging** (for development):
   ```swift
   MSALGlobalConfig.loggerConfig.logLevel = .verbose
   MSALGlobalConfig.loggerConfig.logCallback = { (level, message, containsPII) in
       print("MSAL: \(message)")
   }
   ```

2. **Check Network Connectivity**: Ensure your device can reach `login.microsoftonline.com`

3. **Verify App Registration**: Double-check all settings in Azure AD match your app configuration

## Security Considerations

1. **Never commit client secrets**: The client ID is safe to include in your app, but never include client secrets
2. **Use HTTPS**: All communication with Microsoft Graph API uses HTTPS
3. **Token Storage**: MSAL handles secure token storage automatically
4. **Scope Limitation**: Only request the minimum permissions your app needs

## Additional Resources

- [MSAL iOS Documentation](https://docs.microsoft.com/en-us/azure/active-directory/develop/msal-ios)
- [Microsoft Graph API Documentation](https://docs.microsoft.com/en-us/graph/)
- [Azure AD App Registration Guide](https://docs.microsoft.com/en-us/azure/active-directory/develop/quickstart-register-app)

## Next Steps

After successful integration, you can:
1. Store user tokens securely using KeychainHelper
2. Make additional Microsoft Graph API calls
3. Implement sign-out functionality
4. Add more Microsoft Graph permissions as needed
