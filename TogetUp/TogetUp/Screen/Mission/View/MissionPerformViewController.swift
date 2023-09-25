//
//  MissionPerformViewController.swift
//  TogetUp
//
//  Created by 이예원 on 2023/09/24.
//

import UIKit
import RxSwift
import RxCocoa

class MissionPerformViewController: UIViewController {
    // MARK: - UI Components
    @IBOutlet weak var alarmAgainButton: UIButton!
    @IBOutlet weak var missionPerformButton: UIButton!
    @IBOutlet weak var iconBackgroundView: UIView!
    @IBOutlet weak var missionBackgroundView: UIView!
    @IBOutlet weak var currentDateLabel: UILabel!
    @IBOutlet weak var currentTimeLabel: UILabel!
    // MARK: - Properties
    let viewModel = MissionPerformViewModel()
    let disposeBag = DisposeBag()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        customUI()
        bindLabels()
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
    
    private func bindLabels() {
        viewModel.currentDate
            .bind(to: currentDateLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.currentTime
            .bind(to: currentTimeLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    
    // MARK: - @

}
