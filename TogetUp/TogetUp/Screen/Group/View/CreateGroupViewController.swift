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
        if self.alarmName != "" {
            addAlarmButton.alpha = 0.1
            addAlarmButton.setTitle("", for: .normal)
            alarmTimeLabel.text = formatAlarmTime(self.alarmTime)
            alarmIconLabel.text = self.alarmIcon
        }
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
        
        let groupRequest = GroupAlarmRequest(name: self.alarmName, icon: self.alarmIcon, snoozeInterval: 0, snoozeCnt: 0, alarmTime: self.alarmTime, monday: self.monday, tuesday: self.tuesday, wednesday: self.wednesday, thursday: self.thursday, friday: self.friday, saturday: self.saturday, sunday: self.sunday, isSnoozeActivated: self.isSnoozeActivated, isVibrate: self.isVibrate, missionId: self.missionId, missionObjectId: paramMissionObjId, roomId: nil)
        let param = CreateGroupRequest(name: self.groupNameTextField.text ?? "", intro: self.introTextView.text ?? "", postAlarmReq: groupRequest)
        viewModel.postGroup(param: param)
            .subscribe(onNext: { response in
                print(response)
                self.navigationController?.popViewController(animated: true)
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
        self.alarmName = name
        self.alarmIcon = icon
        self.alarmTime = alarmTime
        self.monday = monday
        self.tuesday = tuesday
        self.wednesday = wednesday
        self.thursday = thursday
        self.friday = friday
        self.saturday = saturday
        self.sunday = sunday
        self.isSnoozeActivated = isSnoozeActivated
        self.isVibrate = isVibrate
        self.missionId = missionId
        self.missionObjectId = missionObjectId
        self.missionKr = missionKr
        
        viewModel.updateAlarmName(name: name)
        
        updateAlarmInfoView()
    }
    
    private func updateAlarmInfoView() {
        let weekdays = [monday, tuesday, wednesday, thursday, friday]
        let weekends = [saturday, sunday]
        
        var selectedDays: [String] = []
        
        if monday { selectedDays.append("월") }
        if tuesday { selectedDays.append("화") }
        if wednesday { selectedDays.append("수") }
        if thursday { selectedDays.append("목") }
        if friday { selectedDays.append("금") }
        if saturday { selectedDays.append("토") }
        if sunday { selectedDays.append("일") }
        
        switch selectedDays.count {
        case 0:
            alarmInfoLabel.text = "\(self.missionKr)"
        case 1:
            alarmInfoLabel.text = "\(selectedDays[0])요일마다 | \(self.missionKr)"
        case 2 where weekends.allSatisfy({ $0 }):
            alarmInfoLabel.text = "주말 | \(self.missionKr)"
        case 5 where weekdays.allSatisfy({ $0 }):
            alarmInfoLabel.text = "주중 | \(self.missionKr)"
        case 7:
            alarmInfoLabel.text = "매일 | \(self.missionKr)"
        default:
            alarmInfoLabel.text = "\(selectedDays.joined(separator: ", ")) | \(self.missionKr)"
            
        }
    }
}
