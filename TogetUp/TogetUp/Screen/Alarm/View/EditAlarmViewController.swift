//
//  EditAlarmViewController.swift
//  TogetUp
//
//  Created by 이예원 on 2023/08/23.
//

import UIKit
import RxSwift
import MCEmojiPicker
import RealmSwift

class EditAlarmViewController: UIViewController, UIGestureRecognizerDelegate, MCEmojiPickerDelegate, UITextFieldDelegate {
    // MARK: - UI Components
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var missionView: UIView!
    @IBOutlet weak var deleteAlarmBtn: UIButton!
    @IBOutlet var dayOfWeekButtons: [UIButton]!
    @IBOutlet weak var sunday: UIButton!
    @IBOutlet weak var monday: UIButton!
    @IBOutlet weak var tuesday: UIButton!
    @IBOutlet weak var wednesday: UIButton!
    @IBOutlet weak var thursday: UIButton!
    @IBOutlet weak var friday: UIButton!
    @IBOutlet weak var saturday: UIButton!
    @IBOutlet weak var missionIconLabel: UILabel!
    @IBOutlet weak var missionTitleLabel: UILabel!
    @IBOutlet weak var alarmNameTextField: UITextField!
    @IBOutlet weak var alarmIconLabel: UILabel!
    @IBOutlet weak var isVibrate: UISwitch!
    @IBOutlet weak var isRepeat: UISwitch!
    @IBOutlet weak var timePicker: UIDatePicker!
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private var alarmTimeString = ""
    private var viewModel = EditAlarmViewModel()
    private var missionTitle = "사람"
    private var missionIcon = "👤"
    private var missionId = 2
    private var missionObjectId: Int? = 1
    
    private var alarmHour = 0
    private var alarmMinute = 0
    
    var alarmId: Int?
    var isFromAlarmList = false
    var missionEndpoint = ""
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        customUI()
        setUpRepeatButtons()
        alarmNameTextField.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard(_:)))
        self.view.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(missionSelected(_:)), name: .init("MissionSelected"), object: nil)
        setUpDatePicker()
        if isFromAlarmList, let id = alarmId {
            loadAlarmData(id: id)
        }
        if isFromAlarmList {
            deleteAlarmBtn.isHidden = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    // MARK: - Custom Method
    private func loadAlarmData(id: Int) {
        viewModel.getSingleAlarm(id: id)
            .observe(on: MainScheduler.instance)
            .subscribe(
                onSuccess: { [weak self] alarmResult in
                    switch alarmResult {
                    case .success(let alarm):
                        self?.updateUI(with: alarm)
                    case .failure(let error):
                        print("Error retrieving alarm:", error)
                    }
                },
                onFailure: { error in
                    print(error.localizedDescription)
                }
            )
            .disposed(by: disposeBag)
    }
    
    private func updateUI(with response: GetSingleAlarmResponse) {
        alarmNameTextField.text = response.result?.name
        alarmIconLabel.text = response.result?.icon
        missionTitleLabel.text = response.result?.getMissionObjectRes?.kr
        missionIconLabel.text = response.result?.getMissionObjectRes?.icon
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        if let alarmTimeString = response.result?.alarmTime,
           let alarmTimeDate = formatter.date(from: alarmTimeString) {
            timePicker.date = alarmTimeDate
        }
        isVibrate.isOn = response.result!.isVibrate
        isRepeat.isOn = response.result!.isSnoozeActivated
        sunday.isSelected = response.result!.sunday
        monday.isSelected = response.result!.monday
        tuesday.isSelected = response.result!.tuesday
        wednesday.isSelected = response.result!.wednesday
        thursday.isSelected = response.result!.thursday
        friday.isSelected = response.result!.friday
        saturday.isSelected = response.result!.saturday
    }
    
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func didGetEmoji(emoji: String) {
        self.alarmIconLabel.text = emoji
    }
    
    private func setUpDatePicker() {
        setStandardizedAlarmTime(from: timePicker.date)
    }
    
    private func setStandardizedAlarmTime(from date: Date) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: date)

        self.alarmHour = components.hour ?? 0
        self.alarmMinute = components.minute ?? 0

        self.alarmTimeString = String(format: "%02d:%02d", self.alarmHour, self.alarmMinute)
        print(alarmTimeString)
    }
    
    // MARK: - @
    @objc func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @IBAction func EditEmojiButtonTapped(_ sender: UIButton) {
        let viewController = MCEmojiPickerViewController()
        viewController.delegate = self
        viewController.sourceView = sender
        present(viewController, animated: true)
    }
    
    @IBAction func datePickerChanged(_ sender: UIDatePicker) {
        setStandardizedAlarmTime(from: sender.date)
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        var paramMissionObjId: Int? = missionObjectId
        if self.missionId == 1 && self.missionObjectId == 1 {
            paramMissionObjId = nil
        }
        
        let alarmIcon = self.alarmIconLabel.text?.isEmpty ?? true ? "⏰" : self.alarmIconLabel.text!
        let alarmName = self.alarmNameTextField.text?.isEmpty ?? true ? "알람" : self.alarmNameTextField.text!
        
        let param = CreateOrEditAlarmRequest(missionId: self.missionId, missionObjectId: paramMissionObjId, isSnoozeActivated: isRepeat.isOn, name: alarmName, icon: alarmIcon, isVibrate: isVibrate.isOn, alarmTime: self.alarmTimeString, monday: monday.isSelected, tuesday: tuesday.isSelected, wednesday: wednesday.isSelected, thursday: thursday.isSelected, friday: friday.isSelected, saturday: saturday.isSelected, sunday: sunday.isSelected, isActivated: true, roomId: nil, snoozeInterval: 0, snoozeCnt: 0)
        
        let apiRequest: Single<Result<CreateEditDeleteAlarmResponse, CreateAlarmError>> = isFromAlarmList ? viewModel.editAlarm(alarmId: self.alarmId!, param: param) : viewModel.postAlarm(param: param)
        
        apiRequest.subscribe(
            onSuccess: { result in
                switch result {
                case .success(let response):
                    print(response)
                    // Realm에 알람 정보 업데이트
                    self.viewModel.saveOrUpdateAlarmInRealm(
                        id: response.result ?? 0,
                        missionId: self.missionId,
                        missionObjectId: self.missionObjectId!,
                        isSnoozeActivated: self.isRepeat.isOn,
                        name: alarmName,
                        icon: alarmIcon,
                        isVibrate: self.isVibrate.isOn,
                        alarmHour:  self.alarmHour,
                        alarmMinute: self.alarmMinute,
                        days: [self.monday.isSelected, self.tuesday.isSelected, self.wednesday.isSelected, self.thursday.isSelected, self.friday.isSelected, self.saturday.isSelected, self.sunday.isSelected],
                        isActivated: true,
                        missionName: self.missionTitleLabel.text!,
                        missionEndpoint: self.missionEndpoint
                    )
                    
                    self.presentingViewController?.dismiss(animated: true)
                    
                case .failure(let error):
                    switch error {
                    case .network(let moyaError):
                        print("Network error:", moyaError.localizedDescription)
                        
                    case .server(let statusCode):
                        print("Server returned status code:", statusCode)
                    }
                }
            },
            onFailure: { error in
                print(error.localizedDescription)
            }
        ).disposed(by: self.disposeBag)
    }
    
    @objc func missionSelected(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let icon = userInfo["icon"] as? String,
              let kr = userInfo["kr"] as? String,
              let missionObjectId = userInfo["missionObjectId"] as? Int,
              let missionId = userInfo["missionId"] as? Int,
              let missionName = userInfo["name"] as? String else {
            return
        }
        
        self.missionTitleLabel.text = kr
        self.missionIconLabel.text = icon
        self.missionObjectId = missionObjectId
        self.missionId = missionId
        self.missionEndpoint = missionName
    }
    
    @objc private func dayOfWeekButtonTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
    }
    
    @IBAction func back(_ sender: Any) {
        let alertController = UIAlertController(title: nil, message: "알람을 저장하지 않고 나가시겠습니까?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "확인", style: .default) { _ in
            self.presentingViewController?.dismiss(animated: true)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func missionEditButton(_ sender: Any) {
        guard let vc = storyboard?.instantiateViewController(identifier: "MissionListViewController") as? MissionListViewController else { return }
        
        vc.customMissionDataHandler = {[weak self] missionTitle, missionIcon, missionId, missionObjectId in
            self?.missionTitleLabel.text = missionTitle
            self?.missionIconLabel.text = missionIcon
            self?.missionId = missionId
            self?.missionObjectId = missionObjectId
        }
        
        vc.modalPresentationStyle = .fullScreen
        navigationController?.isNavigationBarHidden = false
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        let alertController = UIAlertController(title: nil, message: "알람을 삭제하시겠습니까?", preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "삭제", style: .default) { [weak self] _ in
            guard let self = self, let alarmId = self.alarmId else { return }
            
            self.viewModel.deleteAlarm(alarmId: alarmId)
                .subscribe(onSuccess: { _ in
                    self.presentingViewController?.dismiss(animated: true)
                }, onFailure: { error in
                    if let alarmError = error as? CreateAlarmError {
                        switch alarmError {
                        case .network:
                            self.showAlert(message: "잠시후 다시 시도해주세요")
                        case .server(let statusCode):
                            print(statusCode)
                            self.showAlert(message: "잠시후 다시 시도해주세요")
                        }
                    }
                })
                .disposed(by: self.disposeBag)
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        present(alert, animated: true)
    }
}
