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

class EditAlarmViewController: UIViewController, UIGestureRecognizerDelegate, UITextFieldDelegate, MCEmojiPickerDelegate {
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
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var addEmojiButton: UIButton!
    @IBOutlet weak var deleteEmojiButton: UIButton!
    @IBOutlet weak var alarmNameCountLabel: UILabel!
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private var alarmTimeString = ""
    private var viewModel = EditAlarmViewModel()
    private var missionKoreanName = "사람"
    private var missionIcon = "👤"
    private var missionId = 2
    private var missionObjectId: Int? = 1
    private var alarmHour = 0
    private var alarmMinute = 0
    var alarmId: Int?
    var navigatedFromScreen = "CreateAlarm"
    //navigatedFromScreen = "AlarmList", "CreateAlarm", "CreateGroupAlarm"
    var missionEndpoint = "person"
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        customUI()
        setUpRepeatButtons()
        addKeyboardTapGesture()
        addMissionNotificationCenter()
        setUpScreenStatus()
        configureAlarmNameTextField()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    // MARK: - Custom Method
    private func addMissionNotificationCenter() {
        NotificationCenter.default.addObserver(self, selector: #selector(missionSelected(_:)), name: .init("MissionSelected"), object: nil)
    }
    
    private func addKeyboardTapGesture() {
        alarmNameTextField.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard(_:)))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    private func setUpScreenStatus() {
        if navigatedFromScreen == "AlarmList", let id = alarmId {
            loadAlarmData(id: id)
            self.addEmojiButton.setImage(UIImage(named: "iconExist"), for: .normal)
            setUpDatePicker()
        } else {
            setUpDatePicker()
        }
    }
    
    private func loadAlarmData(id: Int) {
        viewModel.getSingleAlarm(alarmId: id)
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] alarmResponse in
                self?.updateUI(with: alarmResponse)
            }, onFailure: { [weak self] error in
                self?.showErrorAlertAndDismiss(message: "잠시후 다시 시도해주세요")
            })
            .disposed(by: disposeBag)
    }
    
    private func updateUI(with response: GetSingleAlarmResponse) {
        guard let result = response.result else { return }
        
        configureMission(with: result)
        
        alarmNameTextField.text = result.name
        alarmIconLabel.text = result.icon
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        if let alarmTimeString = response.result?.alarmTime,
           let alarmTimeDate = formatter.date(from: alarmTimeString) {
            timePicker.date = alarmTimeDate
        }
        
        isVibrate.isOn = result.isVibrate
        sunday.isSelected = result.sunday
        monday.isSelected = result.monday
        tuesday.isSelected = result.tuesday
        wednesday.isSelected = result.wednesday
        thursday.isSelected = result.thursday
        friday.isSelected = result.friday
        saturday.isSelected = result.saturday
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
        
        if navigatedFromScreen == "CreateAlarm" {
            let currentTime = Date()
            let oneMinuteLater = Calendar.current.date(byAdding: .minute, value: 1, to: currentTime)
            timePicker.date = oneMinuteLater ?? currentTime
        }
        
        if navigatedFromScreen == "CreateAlarm" || navigatedFromScreen == "CreateGroupAlarm" {
            self.deleteAlarmBtn.isHidden = true
        } else {
            self.deleteAlarmBtn.isHidden = false
        }
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
        self.addEmojiButton.setImage(UIImage(named: "iconExist"), for: .normal)
        self.deleteEmojiButton.isHidden = false
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
    }
    
    private func configureMission(with result: GetAlarmResult) {
        if let missionResId = result.getMissionRes?.id, missionResId == 1 {
            missionTitleLabel.text = "직접 등록 미션"
            missionIconLabel.text = "📷"
            self.missionId = 1
            self.missionObjectId = nil
        } else if let missionObjectRes = result.getMissionObjectRes {
            missionTitleLabel.text = missionObjectRes.kr
            missionIconLabel.text = missionObjectRes.icon
            self.missionId = result.getMissionRes?.id ?? 0
            self.missionObjectId = missionObjectRes.id
            self.missionEndpoint = missionObjectRes.name
            self.missionKoreanName = missionObjectRes.kr
        }
    }
    
    private func createAlarmRequestParam() -> CreateOrEditAlarmRequest {
        var paramMissionObjId: Int? = missionObjectId
        if self.missionId == 1 && self.missionObjectId == 1 {
            paramMissionObjId = nil
        }
        let alarmIcon = self.alarmIconLabel.text?.isEmpty ?? true ? "⏰" : self.alarmIconLabel.text!
        let alarmName = self.alarmNameTextField.text?.isEmpty ?? true ? "알람" : self.alarmNameTextField.text!
        
        return CreateOrEditAlarmRequest(
            missionId: self.missionId,
            missionObjectId: paramMissionObjId,
            name: alarmName,
            icon: alarmIcon,
            isVibrate: isVibrate.isOn,
            alarmTime: self.alarmTimeString,
            monday: monday.isSelected,
            tuesday: tuesday.isSelected,
            wednesday: wednesday.isSelected,
            thursday: thursday.isSelected,
            friday: friday.isSelected,
            saturday: saturday.isSelected,
            sunday: sunday.isSelected,
            isActivated: true,
            roomId: nil
        )
    }
    
    private func createAlarm(with param: CreateOrEditAlarmRequest) {
        viewModel.postAlarm(param: param, missionEndpoint: self.missionEndpoint, missionKoreanName: self.missionKoreanName)
            .subscribe(onSuccess: { [weak self] result in
                switch result {
                case .success:
                    self?.presentingViewController?.dismiss(animated: true)
                case .failure(_):
                    self?.showErrorAlert(message: "잠시후 다시 시도해주세요")
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func editAlarm(with param: CreateOrEditAlarmRequest) {
        viewModel.editAlarm(param: param, missionEndpoint: self.missionEndpoint, missionKoreanName: missionKoreanName, alarmId: self.alarmId ?? 0)
            .subscribe(onSuccess: { [weak self] result in
                switch result {
                case .success:
                    self?.presentingViewController?.dismiss(animated: true)
                case .failure(_):
                    self?.showErrorAlert(message: "잠시후 다시 시도해주세요")
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func getMissionEndPoint(alarmId: Int) -> String? {
        let realm = try! Realm()
        return realm.object(ofType: Alarm.self, forPrimaryKey: alarmId)?.missionEndpoint
    }
    
    private func showErrorAlertAndDismiss(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default) { _ in
            self.presentingViewController?.dismiss(animated: true)
        }
        alert.addAction(okAction)
        present(alert, animated: true)
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        present(alert, animated: true)
    }
    
    private func truncateMaxLength(text: String) -> String {
        return String(text.prefix(10))
    }
    
    
    private func updateLabelColorAndText(truncatedText: String, originalText: String) {
        alarmNameCountLabel.text = "\(truncatedText.count)/10"
        alarmNameCountLabel.textColor = originalText.count > 10 ? UIColor(named: "error500") : UIColor(named: "neutral500")
    }
    
    private func configureAlarmNameTextField() {
        alarmNameTextField.rx.text.orEmpty
            .map { [weak self] text -> String in
                let truncatedText = self?.truncateMaxLength(text: text) ?? ""
                DispatchQueue.main.async {
                    self?.updateLabelColorAndText(truncatedText: truncatedText, originalText: text)
                }
                return truncatedText
            }
            .bind(to: alarmNameTextField.rx.text)
            .disposed(by: disposeBag)
    }
    
    // MARK: - @
    @IBAction func deleteEmoji(_ sender: UIButton) {
        self.alarmIconLabel.text = ""
        self.addEmojiButton.setImage(UIImage(named: "addAlarmIconBasic"), for: .normal)
        self.deleteEmojiButton.isHidden = true
    }
    
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
        let param = createAlarmRequestParam()
        if navigatedFromScreen == "AlarmList" {
            self.editAlarm(with: param)
        } else if navigatedFromScreen == "CreateAlarm" {
            self.createAlarm(with: param)
        }
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
        self.missionKoreanName = kr
    }
    
    @IBAction func missionEditButton(_ sender: Any) {
        guard let vc = storyboard?.instantiateViewController(identifier: "MissionListViewController") as? MissionListViewController else { return }
        
        vc.customMissionDataHandler = {[weak self] missionKoreanName, missionIcon, missionId, missionObjectId in
            self?.missionTitleLabel.text = missionKoreanName
            self?.missionKoreanName = missionKoreanName
            self?.missionIconLabel.text = missionIcon
            self?.missionId = missionId
            self?.missionObjectId = missionObjectId
            self?.missionEndpoint = ""
        }
        
        vc.modalPresentationStyle = .fullScreen
        navigationController?.isNavigationBarHidden = false
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.pushViewController(vc, animated: true)
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
    
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        let alertController = UIAlertController(title: nil, message: "알람을 삭제하시겠습니까?", preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "삭제", style: .default) { [weak self] _ in
            guard let self = self, let alarmId = self.alarmId else { return }
            
            self.viewModel.deleteAlarm(alarmId: alarmId)
                .subscribe(onSuccess: { [weak self] result in
                    switch result {
                    case .success:
                        self?.presentingViewController?.dismiss(animated: true)
                    case .failure(_):
                        self?.showErrorAlert(message: "잠시후 다시 시도해주세요")
                    }
                })
                .disposed(by: disposeBag)
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
}
