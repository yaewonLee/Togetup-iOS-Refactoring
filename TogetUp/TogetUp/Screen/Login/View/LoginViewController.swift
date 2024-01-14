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
    // MARK: - Properties
    private let viewModel = LoginViewModel()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    // MARK: - Apple Login
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            print("===========loginWithApple() success.=============")
            let userIdentifier = appleIDCredential.user
            KeyChainManager.shared.saveUserIdentifier(userIdentifier)
            let fullName = (appleIDCredential.fullName?.familyName ?? "") + (appleIDCredential.fullName?.givenName ?? "")
            
            if let email = appleIDCredential.email {
                KeyChainManager.shared.saveUserInformation(name: fullName, email: email)
                print("애플 로그인 이름과 이메일 키체인에 저장")
            }
            
            guard
                let authorizationCode = appleIDCredential.authorizationCode,
                let identityToken = appleIDCredential.identityToken,
                let authString = String(data: authorizationCode, encoding: .utf8),
                let tokenString = String(data: identityToken, encoding: .utf8)
            else { return }
            
            print("authString: \(authString)")
            print("tokenString: \(tokenString)")
            
            UserDefaults.standard.set("Apple", forKey: "loginMethod")
            var userName: String?
            let nameAndEmailInfoFromKeychain = KeyChainManager.shared.getUserInformation()
            print("nameAndEmailInfoFromKeychain: \(nameAndEmailInfoFromKeychain)")
            if nameAndEmailInfoFromKeychain.name != nil {
                userName = nameAndEmailInfoFromKeychain.name
            }
                        
            let loginRequest = LoginRequest(oauthAccessToken: tokenString, loginType: "APPLE", userName: userName)
            self.sendLoginRequest(with : loginRequest)
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
                    UserDefaults.standard.set("Kakao", forKey: "loginMethod")
                    let loginRequest = LoginRequest(oauthAccessToken : oauthToken.accessToken,
                                                    loginType : "KAKAO")
                    print(oauthToken.accessToken)
                    self.sendLoginRequest(with : loginRequest)
                }, onError: {error in
                    print(error.localizedDescription)
                    print("카카오톡 설치 필요")
                })
                .disposed(by: disposeBag)
        } else {
            UserApi.shared.rx.loginWithKakaoAccount()
                .subscribe(onNext:{ (oauthToken) in
                    print("===========loginWithKakaoAccount() success.===========")
                    let loginRequest = LoginRequest(oauthAccessToken : oauthToken.accessToken, loginType : "KAKAO")
                    self.sendLoginRequest(with : loginRequest)
                }, onError: {error in
                    print(error.localizedDescription)
                })
                .disposed(by: disposeBag)
        }
    }
    
    private func sendLoginRequest(with request : LoginRequest) {
        viewModel.loginReqeust(param:request)
            .subscribe(onNext:{ [weak self] response in
                print("*************** 회원가입 성공 ***************")
                if let result = response.result {
                    KeyChainManager.shared.saveToken(result.accessToken)
                    KeyChainManager.shared.saveUserInformation(name: result.userName ?? "", email: result.email ?? "")
                    let userStaus = UserStatus(level: result.userStat.level, experience: result.userStat.experience, point: result.userStat.point)
                    let userData = UserData(avatarId: result.avatarId, name: result.userName ?? "", email: result.email ?? "", userStat: userStaus)
                    UserDataManager.shared.updateUser(user: userData)
                    print(response)
                } else {
                    print("아바타 정보 저장 실패")
                }
                
                self?.switchView()
            }, onError:{ error in
                let alertController = UIAlertController(title: nil, message: "잠시후 다시 시도해주세요", preferredStyle: .actionSheet)
                let cancelAction = UIAlertAction(title: "확인", style: .cancel, handler: nil)
                alertController.addAction(cancelAction)
                print(error.localizedDescription)
            }).disposed(by:self.disposeBag)
    }
}
