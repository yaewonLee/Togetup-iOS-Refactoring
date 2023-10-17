//
//  CreateGroupViewController.swift
//  TogetUp
//
//  Created by 이예원 on 2023/10/13.
//

import UIKit
import RxSwift
import RxCocoa
import RxGesture

class CreateGroupViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    // MARK: - UI Components
    @IBOutlet weak var groupNameView: UIView!
    @IBOutlet weak var introView: UIView!
    @IBOutlet weak var addAlarmButton: UIButton!
    @IBOutlet weak var postGroupButton: UIButton!
    @IBOutlet weak var groupNameTextField: UITextField!
    @IBOutlet weak var groupNameTextCountLabel: UILabel!
    @IBOutlet weak var introTextView: UITextView!
    @IBOutlet weak var introTextViewCountLabel: UILabel!
    
    @IBOutlet weak var alarmInfoView: UIView!
    @IBOutlet weak var alarmIconLabel: UILabel!
    @IBOutlet weak var alarmTimeLabel: UILabel!
    @IBOutlet weak var alarmInfoLabel: UILabel!
    
    // MARK: - Properties
    private let viewModel = CreateGroupViewModel()
    private let disposeBag = DisposeBag()
    var alarmName = ""
    var alarmIcon = ""
    var alarmTime = ""
    var monday = false
    var tuesday = false
    var wednesday = false
    var thursday = false
    var friday = false
    var saturday = false
    var sunday = false
    var isSnoozeActivated = false
    var isVibrate = false
    var missionId = 2
    var missionObjectId: Int? = 1
    var missionKr = ""
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        customUI()
        groupNameTextField.delegate = self
        introTextView.delegate = self
        
        setupBindings()
        setUpGestures()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.tintColor = .black
    }
    
    // MARK: - Custom Method
    private func customUI() {
        [groupNameView, introView, addAlarmButton, alarmInfoView, postGroupButton].forEach { view in
            if let safeView = view {
                safeView.layer.cornerRadius = 12
                safeView.layer.borderWidth = 2
                safeView.layer.borderColor = UIColor.black.cgColor
            }
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        introTextViewCountLabel.text = "\(textView.text.count)/50"
    }
    
    private func setupBindings() {
        viewModel.alarmData
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] alarmData in
                self?.addAlarmButton.alpha = 0.1
                self?.addAlarmButton.setTitle("", for: .normal)
                self?.alarmIconLabel.text = alarmData.icon
                self?.alarmTimeLabel.text = alarmData.alarmTime
                
                if let formattedTime = self?.formatAlarmTime(alarmData.alarmTime) {
                    self?.alarmTimeLabel.text = formattedTime
                } else {
                    self?.alarmTimeLabel.text = alarmData.alarmTime
                }
                
                let infoText = self?.computeAlarmInfoText(from: alarmData) ?? ""
                self?.alarmInfoLabel.text = infoText
                
            })
            .disposed(by: disposeBag)
        
        viewModel.isPostGroupButtonEnabled
            .bind(to: postGroupButton.rx.isEnabled)
            .disposed(by: disposeBag)
        viewModel.isPostGroupButtonEnabled
            .map { $0 ? UIColor(named: "primary400") : UIColor(named: "primary100") }
            .bind(to: postGroupButton.rx.backgroundColor)
            .disposed(by: disposeBag)
        
        groupNameTextField.rx.text
            .bind(to: viewModel.groupName)
            .disposed(by: disposeBag)
    }
    
    private func setUpGestures() {
        groupNameTextField.addTarget(self, action: #selector(groupNameDidChange(_:)), for: .editingChanged)
        self.view.rx.tapGesture()
                .when(.recognized)
                .subscribe(onNext: { [weak self] _ in
                    self?.view.endEditing(true)
                })
                .disposed(by: disposeBag)
    }
    
    private func formatAlarmTime(_ time: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        if let date = dateFormatter.date(from: time) {
            dateFormatter.dateFormat = "a h:mm"
            let formattedString = dateFormatter.string(from: date)
            return formattedString.lowercased()
        }
        return nil
    }
    
    // MARK: - @
    @IBAction func groupNameDidChange(_ sender: UITextField) {
        if let text = sender.text {
            groupNameTextCountLabel.text = "\(text.count)/10"
        }
    }
    
    @IBAction func addAlarmButtonTapped(_ sender: UIButton) {
        let alarmStoryboard = UIStoryboard(name: "Alarm", bundle: nil)
        guard let vc = alarmStoryboard.instantiateViewController(identifier: "EditAlarmViewController") as? EditAlarmViewController else {
            return
        }
        vc.delegate = self
        vc.navigatedFromScreen = "CreateGroupAlarm"
        let navigationController = UINavigationController(rootViewController: vc)
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.isNavigationBarHidden = true
        navigationController.navigationBar.backgroundColor = .clear
        navigationController.interactivePopGestureRecognizer?.isEnabled = true
        
        present(navigationController, animated: true)
    }
    
    @IBAction func createButtonTapped(_ sender: UIButton) {
        var paramMissionObjId: Int? = self.missionObjectId
        if self.missionId == 1 {
            paramMissionObjId = nil
        }
        
        let groupRequest = GroupAlarmRequest(name: self.alarmName, icon: self.alarmIcon, snoozeInterval: 0, snoozeCnt: 0, alarmTime: self.alarmTime, monday: self.monday, tuesday: self.tuesday, wednesday: self.wednesday, thursday: self.thursday, friday: self.friday, saturday: self.saturday, sunday: self.sunday, isSnoozeActivated: self.isSnoozeActivated, isVibrate: self.isVibrate, missionId: self.missionId, missionObjectId: paramMissionObjId)
        let param = CreateGroupRequest(name: self.groupNameTextField.text ?? "", intro: self.introTextView.text ?? "", postAlarmReq: groupRequest)
        viewModel.postGroup(param: param)
            .subscribe(onNext: { response in
                print(response)
                
            }, onError: { error in
                print(error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }
}

protocol EditAlarmDelegate: AnyObject {
    func didUpdateAlarm(name: String, icon: String, alarmTime: String, monday: Bool, tuesday: Bool, wednesday: Bool, thursday: Bool, friday: Bool, saturday: Bool, sunday: Bool, isSnoozeActivated: Bool, isVibrate: Bool, missionId: Int, missionObjectId: Int?, missionKr: String)
}

extension CreateGroupViewController: EditAlarmDelegate {
    func didUpdateAlarm(name: String, icon: String, alarmTime: String, monday: Bool, tuesday: Bool, wednesday: Bool, thursday: Bool, friday: Bool, saturday: Bool, sunday: Bool, isSnoozeActivated: Bool, isVibrate: Bool, missionId: Int, missionObjectId: Int?, missionKr: String) {
        viewModel.updateAlarm(name: name, icon: icon, alarmTime: alarmTime, monday: monday, tuesday: tuesday, wednesday: wednesday, thursday: thursday, friday: friday, saturday: saturday, sunday: sunday, isSnoozeActivated: isSnoozeActivated, isVibrate: isVibrate, missionId: missionId, missionObjectId: missionObjectId, missionKr: missionKr)
    }
    
    private func computeAlarmInfoText(from data: AlarmData) -> String {
        let weekdaysData = Array(data.weekdays[0...4])
        let weekendsData = Array(data.weekdays[5...6])
        var selectedDays: [String] = []
        
        if data.weekdays[0] { selectedDays.append("월") }
        if data.weekdays[1] { selectedDays.append("화") }
        if data.weekdays[2] { selectedDays.append("수") }
        if data.weekdays[3] { selectedDays.append("목") }
        if data.weekdays[4] { selectedDays.append("금") }
        if data.weekdays[5] { selectedDays.append("토") }
        if data.weekdays[6] { selectedDays.append("일") }
        
        switch selectedDays.count {
        case 0:
            return "\(data.missionKr)"
        case 1:
            return "\(selectedDays[0])요일마다 | \(data.missionKr)"
        case 2 where weekendsData.allSatisfy({ $0 }):
            return "주말 | \(data.missionKr)"
        case 5 where weekdaysData.allSatisfy({ $0 }):
            return "주중 | \(data.missionKr)"
        case 7:
            return "매일 | \(data.missionKr)"
        default:
            return "\(selectedDays.joined(separator: ", ")) | \(data.missionKr)"
        }
    }
}
