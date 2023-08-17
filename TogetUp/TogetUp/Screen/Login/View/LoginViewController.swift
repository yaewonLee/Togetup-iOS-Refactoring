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

class LoginViewController: UIViewController {
    // MARK: - Properties
    let disposeBag = DisposeBag()
    
    // MARK: - UI Components

    @IBOutlet weak var kakaoLoginButton: UIButton!
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    // MARK: - @IBAction
    @IBAction func kakaoLoginButtontapped(_ sender: UIButton) {
        if (UserApi.isKakaoTalkLoginAvailable()) {
            UserApi.shared.rx.loginWithKakaoTalk()
                .subscribe(onNext:{ (oauthToken) in
                    print("loginWithKakaoTalk() success.")
                    print(oauthToken)
                }, onError: {error in
                    print(error)
                })
            .disposed(by: disposeBag)
        }
    }
    

}
