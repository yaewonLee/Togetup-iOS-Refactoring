//
//  SceneDelegate.swift
//  TogetUp
//
//  Created by 이예원 on 2023/08/14.
//

import UIKit
import RxKakaoSDKAuth
import KakaoSDKAuth
import AuthenticationServices
import RxSwift
import KakaoSDKUser
import RxKakaoSDKUser
import KakaoSDKCommon

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    let disposeBag = DisposeBag()
    var window: UIWindow?
    
    private func changeView(name: String, withIdentifier identifier: String) {
        DispatchQueue.main.async {
            let mainStoryboard = UIStoryboard(name: name, bundle: nil)
            let loginViewController = mainStoryboard.instantiateViewController(withIdentifier: identifier)
            
            self.window?.rootViewController = loginViewController
            self.window?.makeKeyAndVisible()
        }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            if (AuthApi.isKakaoTalkLoginUrl(url)) {
                _ = AuthController.rx.handleOpenUrl(url: url)
            }
        }
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if UserDefaults.standard.string(forKey: "loginMethod") == "Apple" {
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            appleIDProvider.getCredentialState(forUserID: KeyChainManager.shared.getUserIdentifier()!) { (credentialState, error) in
                switch credentialState {
                case .authorized:
                    self.changeView(name: "Main", withIdentifier: "TabBarViewController")
                    
                case .revoked, .notFound:
                    self.changeView(name: "Main", withIdentifier: "LoginViewController")
                default:
                    print(error?.localizedDescription as Any)
                }
            }
        } else if UserDefaults.standard.string(forKey: "loginMethod") == "Kakao"{
            if (AuthApi.hasToken()) {
                UserApi.shared.rx.accessTokenInfo()
                    .subscribe(onSuccess:{ (_) in
                        self.changeView(name: "Main", withIdentifier: "TabBarViewController")
                    }, onFailure: {error in
                        if let sdkError = error as? SdkError, sdkError.isInvalidTokenError() == true  {
                            self.changeView(name: "Main", withIdentifier: "LoginViewController")
                        } else {
                            print(error.localizedDescription)
                        }
                    })
                    .disposed(by: disposeBag)
            } else {
                self.changeView(name: "Main", withIdentifier: "LoginViewController")
            }
        }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
        
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    
}

