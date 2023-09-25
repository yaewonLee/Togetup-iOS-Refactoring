//
//  MissionPerformViewController.swift
//  TogetUp
//
//  Created by 이예원 on 2023/09/24.
//

import UIKit

class MissionPerformViewController: UIViewController {
    // MARK: - UI Components
    @IBOutlet weak var alarmAgainButton: UIButton!
    @IBOutlet weak var missionPerformButton: UIButton!
    @IBOutlet weak var iconBackgroundView: UIView!
    @IBOutlet weak var missionBackgroundView: UIView!
    
    // MARK: - Properties
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        customUI()
    }
    
    // MARK: - Custom Method
    private func customUI() {
        self.alarmAgainButton.layer.cornerRadius = 15
        self.alarmAgainButton.layer.borderWidth = 2
        
        self.missionPerformButton.layer.cornerRadius = 12
        self.missionPerformButton.layer.borderWidth = 2
        
        self.iconBackgroundView.layer.cornerRadius = 170
        self.iconBackgroundView.layer.borderWidth = 2
        
        self.missionBackgroundView.layer.cornerRadius = 12
        self.missionBackgroundView.layer.borderWidth = 2
        
    }
    
    
    // MARK: - @

}
