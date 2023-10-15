//
//  CreateGroupViewController.swift
//  TogetUp
//
//  Created by 이예원 on 2023/10/13.
//

import UIKit

class CreateGroupViewController: UIViewController {
    // MARK: - UI Components
    @IBOutlet weak var groupNameView: UIView!
    @IBOutlet weak var introView: UIView!
    @IBOutlet weak var addAlarmButton: UIButton!
    @IBOutlet weak var postGroupButton: UIButton!
    
    // MARK: - Properties
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        customUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
    }
    // MARK: - Custom Method
    private func customUI() {
        [groupNameView, introView, addAlarmButton, postGroupButton].forEach { view in
            if let safeView = view {
                safeView.layer.cornerRadius = 12
                safeView.layer.borderWidth = 2
                safeView.layer.borderColor = UIColor.black.cgColor
            }
        }
    }

    // MARK: - @


}
