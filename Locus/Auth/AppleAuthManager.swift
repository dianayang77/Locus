import Foundation
import AuthenticationServices
import UIKit

final class AppleAuthManager: NSObject {
    struct Result {
        let userIdentifier: String
        let fullName: PersonNameComponents?
        let email: String?
        let identityToken: String?
        let authorizationCode: String?
    }

    private var completion: ((Result) -> Void)?
    private var errorHandler: ((Error) -> Void)?

    func signIn(completion: @escaping (Result) -> Void, onError: @escaping (Error) -> Void) {
        print("🍎 AppleAuthManager: signIn called")
        self.completion = completion
        self.errorHandler = onError

        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        print("🍎 AppleAuthManager: Created authorization request")

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        print("🍎 AppleAuthManager: About to perform requests")
        controller.performRequests()
    }
}

extension AppleAuthManager: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        print("🍎 AppleAuthManager: Authorization completed successfully")
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else { 
            print("🍎 AppleAuthManager: Failed to get Apple ID credential")
            return 
        }

        let userId = credential.user
        print("🍎 AppleAuthManager: User ID: \(userId)")
        KeychainHelper.standard.set(userId, key: "appleUserIdentifier")

        let token = credential.identityToken.flatMap { String(data: $0, encoding: .utf8) }
        let code = credential.authorizationCode.flatMap { String(data: $0, encoding: .utf8) }

        let result = Result(
            userIdentifier: userId,
            fullName: credential.fullName,
            email: credential.email,
            identityToken: token,
            authorizationCode: code
        )
        print("🍎 AppleAuthManager: Calling completion handler")
        completion?(result)
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("🍎 AppleAuthManager: Authorization failed with error: \(error.localizedDescription)")
        print("🍎 AppleAuthManager: Error details: \(error)")
        errorHandler?(error)
    }
}

extension AppleAuthManager: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // Try to use the foreground active scene's key window
        if let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }),
           let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
            return window
        }
        // Fallbacks
        if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
            return window
        }
        return ASPresentationAnchor()
    }
} 