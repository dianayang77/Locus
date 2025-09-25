import Foundation
import UIKit

#if canImport(MSAL)
import MSAL
#endif

final class OutlookAuthManager {
    struct Result {
        let userId: String
        let email: String?
        let fullName: String?
        let accessToken: String?
        let idToken: String?
    }
    
    // Microsoft App Registration details
    // You'll need to replace these with your actual app registration values
    private let clientId = "4c8d9669-3ba8-44ac-b8b5-a5bb3f483714" // Replace with your Azure AD app client ID
    private let authority = "https://login.microsoftonline.com/common" // Use common for multi-tenant
    
    func signIn(presentingWindow: UIWindow?, completion: @escaping (Result) -> Void, onError: @escaping (Error) -> Void) {
        #if canImport(MSAL)
        guard let presentingWindow else {
            onError(NSError(domain: "OutlookAuth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Missing presenting window"]))
            return
        }
        
        guard let rootVC = presentingWindow.rootViewController else {
            onError(NSError(domain: "OutlookAuth", code: -2, userInfo: [NSLocalizedDescriptionKey: "Missing root view controller"]))
            return
        }
        
        // Configure MSAL
        let redirectUri = "msauth.com.locusnetwork.Locus://auth"
        
        print("🔍 Debug: Client ID: \(clientId)")
        print("🔍 Debug: Redirect URI: \(redirectUri)")
        print("🔍 Debug: Authority: \(authority)")
        
        // Create MSAL config with proper authority
        guard let authorityURL = URL(string: authority) else {
            onError(NSError(domain: "OutlookAuth", code: -3, userInfo: [NSLocalizedDescriptionKey: "Invalid authority URL"]))
            return
        }
        
        let msalAuthority: MSALAADAuthority
        do {
            msalAuthority = try MSALAADAuthority(url: authorityURL)
        } catch {
            onError(NSError(domain: "OutlookAuth", code: -3, userInfo: [NSLocalizedDescriptionKey: "Failed to create MSAL authority: \(error.localizedDescription)"]))
            return
        }
        
        let config = MSALPublicClientApplicationConfig(clientId: clientId, redirectUri: redirectUri, authority: msalAuthority)
        
        let application: MSALPublicClientApplication
        do {
            application = try MSALPublicClientApplication(configuration: config)
        } catch {
            onError(NSError(domain: "OutlookAuth", code: -4, userInfo: [NSLocalizedDescriptionKey: "Failed to create MSAL application: \(error.localizedDescription)"]))
            return
        }
        
        // Define scopes for Outlook/Microsoft Graph
        let scopes = ["https://graph.microsoft.com/User.Read", "https://graph.microsoft.com/Mail.Read"]
        
        // Create webview parameters
        let webviewParameters = MSALWebviewParameters(authPresentationViewController: rootVC)
        
        // Create interactive token parameters
        let parameters = MSALInteractiveTokenParameters(scopes: scopes, webviewParameters: webviewParameters)
        parameters.promptType = .selectAccount
        
        // Perform interactive token acquisition
        application.acquireToken(with: parameters) { result, error in
            DispatchQueue.main.async {
                if let error = error {
                    onError(error)
                    return
                }
                
                guard let result = result else {
                    onError(NSError(domain: "OutlookAuth", code: -5, userInfo: [NSLocalizedDescriptionKey: "No result returned"]))
                    return
                }
                
                // Extract user information from the result
                let userId = result.account.identifier ?? ""
                let accessToken = result.accessToken
                
                // Get user profile information using Microsoft Graph
                self.getUserProfile(accessToken: accessToken) { profile, profileError in
                    if profileError != nil {
                        // Still return success with basic info if profile fetch fails
                        let basicResult = Result(
                            userId: userId,
                            email: nil,
                            fullName: nil,
                            accessToken: accessToken,
                            idToken: nil
                        )
                        completion(basicResult)
                        return
                    }
                    
                    let finalResult = Result(
                        userId: userId,
                        email: profile?["mail"] as? String ?? profile?["userPrincipalName"] as? String,
                        fullName: profile?["displayName"] as? String,
                        accessToken: accessToken,
                        idToken: nil
                    )
                    completion(finalResult)
                }
            }
        }
        #else
        onError(NSError(domain: "OutlookAuth", code: -999, userInfo: [NSLocalizedDescriptionKey: "MSAL SDK not integrated yet. Add via Swift Package Manager: https://github.com/AzureAD/microsoft-authentication-library-for-objc"]))
        #endif
    }
    
    #if canImport(MSAL)
    private func getUserProfile(accessToken: String, completion: @escaping ([String: Any]?, Error?) -> Void) {
        guard let url = URL(string: "https://graph.microsoft.com/v1.0/me") else {
            completion(nil, NSError(domain: "OutlookAuth", code: -6, userInfo: [NSLocalizedDescriptionKey: "Invalid Graph API URL"]))
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, NSError(domain: "OutlookAuth", code: -7, userInfo: [NSLocalizedDescriptionKey: "No data received"]))
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    completion(json, nil)
                } else {
                    completion(nil, NSError(domain: "OutlookAuth", code: -8, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON response"]))
                }
            } catch {
                completion(nil, error)
            }
        }.resume()
    }
    #endif
}
