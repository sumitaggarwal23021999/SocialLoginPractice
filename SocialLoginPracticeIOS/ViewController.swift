
import UIKit
import FBSDKLoginKit
import GoogleSignIn
import AuthenticationServices

class ViewController: UIViewController {
    let signInConfig = GIDConfiguration(clientID: "185973371280-7ff6d3an53tgqu2bcd1fvd9d5urk1816.apps.googleusercontent.com")
    @IBOutlet weak var btnFacebook: FBLoginButton!
    @IBOutlet weak var appleLoginButton: ASAuthorizationAppleIDButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        appleLoginButton.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
        if let token = AccessToken.current,
                !token.isExpired {
            let request = FBSDKLoginKit.GraphRequest(graphPath: "me", parameters: ["fields": "email,name"], tokenString: token.tokenString, version: nil, httpMethod: .get)
            request.start {(connection, result, error) in
                debugPrint("\(result)")
            }
                // User is logged in, do work such as go to next view controller.
        } else {
            btnFacebook.permissions = ["public_profile", "email"]
            btnFacebook.delegate = self
        }
    }
    @IBAction func btnGoogleSignInTapped(_ sender: Any) {
        GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: self) { user, error in
            guard error == nil else { return }
            guard let user = user else { return }

            let emailAddress = user.profile?.email

            let fullName = user.profile?.name
            let givenName = user.profile?.givenName
            let familyName = user.profile?.familyName

            let profilePicUrl = user.profile?.imageURL(withDimension: 320)
        }
    }
    
    @IBAction func handleAuthorizationAppleIDButtonPress() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
        
}

extension ViewController: LoginButtonDelegate {
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        let token = result?.token?.tokenString
        let request = FBSDKLoginKit.GraphRequest(graphPath: "me", parameters: ["fields": "email,name"], tokenString: token, version: nil, httpMethod: .get)
        request.start {(connection, result, error) in
            debugPrint("\(result)")
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        debugPrint("Logout tapped")
    }
}

extension ViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        view.window!
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        debugPrint("Apple login failed")
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            
            // Create an account in your system.
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
            
            // For the purpose of this demo app, store the `userIdentifier` in the keychain.
//            self.saveUserInKeychain(userIdentifier)
            
            // For the purpose of this demo app, show the Apple ID credential information in the `ResultViewController`.
//            self.showResultViewController(userIdentifier: userIdentifier, fullName: fullName, email: email)
        
        case let passwordCredential as ASPasswordCredential:
        
            // Sign in using an existing iCloud Keychain credential.
            let username = passwordCredential.user
            let password = passwordCredential.password
            
            // For the purpose of this demo app, show the password credential as an alert.
            DispatchQueue.main.async {
//                self.showPasswordCredentialAlert(username: username, password: password)
            }
            
        default:
            break
        }
    }
}

