import Foundation
import UIKit

#if canImport(GoogleSignIn)
import GoogleSignIn
#endif

final class GoogleAuthManager {
    struct Result {
        let userId: String
        let email: String?
        let fullName: String?
        let idToken: String?
        let accessToken: String?
    }

    func signIn(presentingWindow: UIWindow?, completion: @escaping (Result) -> Void, onError: @escaping (Error) -> Void) {
        #if canImport(GoogleSignIn)
        guard let presentingWindow else {
            onError(NSError(domain: "GoogleAuth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Missing presenting window"]))
            return
        }
        guard let rootVC = presentingWindow.rootViewController else {
            onError(NSError(domain: "GoogleAuth", code: -2, userInfo: [NSLocalizedDescriptionKey: "Missing root view controller"]))
            return
        }
        GIDSignIn.sharedInstance.signIn(withPresenting: rootVC) { result, error in
            if let error { onError(error); return }
            guard let user = result?.user else {
                onError(NSError(domain: "GoogleAuth", code: -3, userInfo: [NSLocalizedDescriptionKey: "No user returned"]))
                return
            }
            let idToken = user.idToken?.tokenString
            let accessToken = user.accessToken.tokenString
            let r = Result(userId: user.userID ?? "", email: user.profile?.email, fullName: user.profile?.name, idToken: idToken, accessToken: accessToken)
            completion(r)
        }
        #else
        onError(NSError(domain: "GoogleAuth", code: -999, userInfo: [NSLocalizedDescriptionKey: "GoogleSignIn SDK not integrated yet. Add via Swift Package Manager: https://github.com/google/GoogleSignIn-iOS"]))
        #endif
    }
} 