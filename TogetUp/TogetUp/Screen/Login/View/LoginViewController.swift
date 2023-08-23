//
//  LoginViewController.swift
//  TogetUp
//
//  Created by 이예원 on 2023/08/16.
//

import UIKit
import RxSwift
import KakaoSDKUser
import RxKakaoSDKUser
import AuthenticationServices
import KeychainAccess



class LoginViewController: UIViewController, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
//            let authorizationCode = appleIDCredential.authorizationCode
//            let identityToken = appleIDCredential.identityToken
            let userIdentifier = appleIDCredential.user
            let name = appleIDCredential.fullName
            let email = appleIDCredential.email
            
            print(name, email)
            UserDefaults.standard.set("Apple", forKey: "loginMethod")

            KeyChainManager.shared.saveUserIdentifier(userIdentifier)
            switchView()
            
          //  print("=============authorizationCode: \(authorizationCode)==================")
          //  print("===============identityToken: \(identityToken)============")
            print("==========user: \(userIdentifier)==========")
   
            if  let authorizationCode = appleIDCredential.authorizationCode,
                            let identityToken = appleIDCredential.identityToken,
                            let authString = String(data: authorizationCode, encoding: .utf8),
                            let tokenString = String(data: identityToken, encoding: .utf8) {
                            print("authorizationCode: \(authorizationCode)")
                            print("identityToken: \(identityToken)")
                            print("authString: \(authString)")
                            print("tokenString: \(tokenString)")
                        }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Apple login error: \(error)")
    }
    
    private func switchView() {
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "TabBarViewController") else {
            return
        }
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
    
    
    // MARK: - @IBAction
    @IBAction func appleLoginButtonTapped(_ sender: UIButton) {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    @IBAction func kakaoLoginButtontapped(_ sender: UIButton) {
        if (UserApi.isKakaoTalkLoginAvailable()) {
            UserApi.shared.rx.loginWithKakaoTalk()
                .subscribe(onNext:{ (oauthToken) in
                    print("===========loginWithKakaoTalk() success.=============")
                    print(oauthToken)
                    UserDefaults.standard.set("Kakao", forKey: "loginMethod")
                    self.switchView()
                }, onError: {error in
                    print(error.localizedDescription)
                    print("카카오톡 설치 필요")
                })
                .disposed(by: disposeBag)
        }
    }
}
