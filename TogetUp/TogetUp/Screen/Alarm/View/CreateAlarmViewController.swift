//
//  CreateAlarmViewController.swift
//  TogetUp
//
//  Created by 이예원 on 2023/08/23.
//

import UIKit
import RxSwift

class CreateAlarmViewController: UIViewController, UIGestureRecognizerDelegate {
    // MARK: - UI Components
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var missionView: UIView!
    @IBOutlet weak var deleteAlarmBtn: UIButton!
    @IBOutlet var dayOfWeekButtons: [UIButton]!
    @IBOutlet weak var missionIconLabel: UILabel!
    @IBOutlet weak var missionTitleLabel: UILabel!
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        customUI()
        setUpRepeatButtons()
        
        NotificationCenter.default.addObserver(self, selector: #selector(missionSelected(_:)), name: NSNotification.Name("objectMissionSelected"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
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
    
    // MARK: - @
    @objc func missionSelected(_ notification: Notification) {
        if let userInfo = notification.userInfo as? [String : Any],
           let title = userInfo["title"] as? String,
           let id = userInfo["id"] as? Int,
           let icon = userInfo["icon"] as? String {
            
            self.missionTitleLabel.text = title
            self.missionIconLabel.text = icon
        }
    }
    
    @objc private func dayOfWeekButtonTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
    }
    
    @IBAction func back(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true)
    }
    
    @IBAction func missionEditButton(_ sender: Any) {
    guard let vc = storyboard?.instantiateViewController(identifier: "MissionListViewController") as? MissionListViewController else { return }
        
        vc.customMissionDataHandler = {[weak self] title, id, icon in
            self?.missionTitleLabel.text = title
            self?.missionIconLabel.text = icon
        }

        vc.modalPresentationStyle = .fullScreen
        navigationController?.isNavigationBarHidden = false
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
