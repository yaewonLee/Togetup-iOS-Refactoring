//
//  GroupListViewController.swift
//  TogetUp
//
//  Created by 이예원 on 2023/08/18.
//

import UIKit

class GroupListViewController: UIViewController {
    @IBOutlet weak var UIView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIView.layer.cornerRadius = 12
        self.navigationController?.navigationBar.isHidden = true
    }
}
