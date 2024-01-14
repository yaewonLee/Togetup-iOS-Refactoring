//
//  GroupJoinViewController.swift
//  TogetUp
//
//  Created by 이예원 on 11/15/23.
//

import UIKit

class GroupJoinViewController: UIViewController {
    // MARK: - UI Components
    @IBOutlet weak var iconBackgroundView: UIView!
    @IBOutlet weak var missionBackgroundView: UIView!
    @IBOutlet weak var joinGroupButton: UIButton!
    @IBOutlet weak var exitButton: UIButton!
    
    // MARK: - Properties
    var code = ""
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        customUI()
    }
    
    private func customUI() {
        [missionBackgroundView, joinGroupButton].forEach { view in
            if let safeView = view {
                safeView.layer.cornerRadius = 12
                safeView.layer.borderWidth = 2
                safeView.layer.borderColor = UIColor.black.cgColor
            }
        }
        iconBackgroundView.layer.cornerRadius = 43
        iconBackgroundView.layer.borderWidth = 2
    }
}
