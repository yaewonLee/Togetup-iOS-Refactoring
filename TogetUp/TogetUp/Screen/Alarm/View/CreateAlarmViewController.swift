//
//  CreateAlarmViewController.swift
//  TogetUp
//
//  Created by 이예원 on 2023/08/23.
//

import UIKit

class CreateAlarmViewController: UIViewController {
    // MARK: - UI Components
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var missionView: UIView!
    @IBOutlet weak var deleteAlarmBtn: UIButton!
    @IBOutlet var dayOfWeekButtons: [UIButton]!
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        customUI()
        setUpRepeatButtons()
    }
    
    
    
    // MARK: - Custom Method
    private func customUI() {
        dayOfWeekButtons.forEach {
            $0.layer.cornerRadius = 18
        }
        emptyView.clipsToBounds = true
        emptyView.layer.cornerRadius = 24
        emptyView.layer.borderWidth = 2
        emptyView.layer.maskedCorners =  [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        missionView.layer.cornerRadius = 12
        missionView.layer.borderWidth = 2
        missionView.layer.borderColor = UIColor.black.cgColor
        
        deleteAlarmBtn.layer.cornerRadius = 12
    }
    
    private func setUpRepeatButtons() {
        self.dayOfWeekButtons.forEach {
            $0.addTarget(self, action: #selector(dayOfWeekButtonTapped(_ :)), for: .touchUpInside)
        }
    }
    
    
    // MARK: - @objc
    @objc private func dayOfWeekButtonTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
    }
    
    @IBAction func back(_ sender: Any) {
            self.presentingViewController?.dismiss(animated: true)
    }
    
    @IBAction func missionEditBtn(_ sender: UIButton) {
        guard let vc = storyboard?.instantiateViewController(identifier: "MissionListViewController") as? MissionListViewController else { return }
        let navigationController = UINavigationController(rootViewController: vc)
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.isNavigationBarHidden = false

        present(navigationController, animated: true)
    }
    
}
