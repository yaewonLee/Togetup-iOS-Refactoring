//
//  SettingViewController.swift
//  TogetUp
//
//  Created by 이예원 on 2023/08/18.
//

import UIKit
import RxSwift
import KakaoSDKUser

class SettingViewController: UIViewController {
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var withdrawlButton: UIButton!
    
    let viewModel = SettingViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customUI()
    }
    
    private func customUI() {
        emptyView.layer.cornerRadius = 12
        emptyView.layer.borderWidth = 2
        emptyView.clipsToBounds = true
        
        logoutButton.layer.cornerRadius = 12
        withdrawlButton.layer.cornerRadius = 12
    }
    
    private func switchView() {
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") else {
            return
        }
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
    @IBAction func logout(_ sender: Any) {
        let sheet = UIAlertController(title: "알림", message: "로그아웃하시겠습니까?", preferredStyle: .alert)
        sheet.addAction(UIAlertAction(title: "취소", style: .default, handler: nil))
        let okAction = UIAlertAction(title: "로그아웃", style: .destructive) { _ in
            if UserDefaults.standard.string(forKey: "loginMethod") == "Kakao" {
                UserApi.shared.rx.logout()
                    .subscribe(onCompleted:{
                        print("logout() success.")
                        self.switchView()
                    }, onError: { error in
                        print(error.localizedDescription)
                    })
                    .disposed(by: self.disposeBag)
            }
        }
        sheet.addAction(okAction)
        present(sheet, animated: true)
    }
    
    @IBAction func withdrawl(_ sender: Any) {
        let sheet = UIAlertController(title: "알림", message: "탈퇴하시겠습니까?", preferredStyle: .alert)
        sheet.addAction(UIAlertAction(title: "취소", style: .default, handler: nil))
        let okAction = UIAlertAction(title: "탈퇴하기", style: .destructive) { _ in
            UserApi.shared.rx.unlink()
                .subscribe(onCompleted: { [weak self] in
                    print("unlink() success.")
                    self?.viewModel.deleteUser()
                        .subscribe(onNext: { [weak self] response in
                            print("User deleted successfully on our server.")
                            print(response.message)
                            if response.httpStatusCode == 200 {
                                self?.switchView()
                            }
                        }, onError: { error in
                            print("Failed to delete user on our server:", error)
                        }).disposed(by: self?.disposeBag ?? DisposeBag())
                }, onError: { error in
                    print(error.localizedDescription)
                })
                .disposed(by: self.disposeBag)
        }
        sheet.addAction(okAction)
        present(sheet, animated: true)
    }
  
}

