//
//  CreateAlarmViewController.swift
//  TogetUp
//
//  Created by 이예원 on 2023/08/23.
//

import UIKit
import RxSwift
import MCEmojiPicker

class CreateAlarmViewController: UIViewController, UIGestureRecognizerDelegate, MCEmojiPickerDelegate, UITextFieldDelegate {
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
    private var missionId = 0
    private var alarmTime = ""
    private var alarmName = "알람"
    private var alarmIcon = "⏰"
    private var viewModel = CreateAlarmViewModel()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        customUI()
        setUpRepeatButtons()
        alarmNameTextField.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard(_:)))
        self.view.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(missionSelected(_:)), name: NSNotification.Name("objectMissionSelected"), object: nil)
        setUpDatePicker()
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func didGetEmoji(emoji: String) {
        self.alarmIconLabel.text = emoji
    }

    private func setUpDatePicker() {
        let selectedDate = timePicker.date
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let timeString = formatter.string(from: selectedDate)
        self.alarmTime = timeString
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
        let selectedDate = sender.date
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let timeString = formatter.string(from: selectedDate)
        self.alarmTime = timeString
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        if missionId == 0 {
            let sheet = UIAlertController(title: "미션을 선택해주세요", message: nil, preferredStyle: .alert)
            sheet.addAction(UIAlertAction(title: "확인", style: .cancel))
            present(sheet, animated: true)
        } else {
            if alarmNameTextField.text == "" { alarmNameTextField.text = alarmName }
            if alarmIconLabel.text == "" { alarmIconLabel.text = alarmIcon }
            
            let param = CreateAlarmRequest(missionId: missionId, name: alarmNameTextField.text ?? "알람", icon: alarmIconLabel.text ?? "⏰", isVibrate: isVibrate.isOn, alarmTime: self.alarmTime, monday: monday.isSelected, tuesday: tuesday.isSelected, wednesday: wednesday.isSelected, thursday: thursday.isSelected, friday: friday.isSelected, saturday: saturday.isSelected, sunday: sunday.isSelected, isActivated: true)
            
            viewModel.createAlarm(param: param)
                .subscribe(
                    onSuccess:{ result in
                        switch result {
                        case .success(let response):
                            print(response)
                            self.presentingViewController?.dismiss(animated:true)
                        case .failure(let error):
                            switch error {
                            case .network(let moyaError):
                                print("Network error:", moyaError.localizedDescription)

                            case .server(let statusCode):
                                print("Server returned status code:", statusCode)
                            }
                        }
                    },
                    onFailure:{ error in
                        print(error.localizedDescription)
                    }
                )
                .disposed(by:self.disposeBag)
        }
    }

    
    
    @objc func missionSelected(_ notification: Notification) {
        if let userInfo = notification.userInfo as? [String : Any],
           let title = userInfo["title"] as? String,
           let id = userInfo["id"] as? Int,
           let icon = userInfo["icon"] as? String {
            
            self.missionTitleLabel.text = title
            self.missionIconLabel.text = icon
            self.missionId = id
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
            self?.missionId = id
        }
        
        vc.modalPresentationStyle = .fullScreen
        navigationController?.isNavigationBarHidden = false
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
