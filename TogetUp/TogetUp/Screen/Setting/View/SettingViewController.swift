//
//  SettingViewController.swift
//  TogetUp
//
//  Created by 이예원 on 2023/08/18.
//

import UIKit

class SettingViewController: UIViewController {

    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var withdrawlButton: UIButton!
    
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
    

}
