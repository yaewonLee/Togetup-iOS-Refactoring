//
//  FloatingPannelViewController.swift
//  TogetUp
//
//  Created by 이예원 on 11/3/23.
//

import UIKit
import RxSwift
import RxCocoa

class FloatingPannelViewController: UIViewController {
    // MARK: - UI Components
    @IBOutlet weak var currentAlarmView: UIView!
    @IBOutlet weak var iconLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var alarmInfoLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLineCollectionView: UICollectionView!
    @IBOutlet weak var makeNewAlarmButton: UIButton!
    @IBOutlet weak var alarmEmptyLabel: UILabel!
    @IBOutlet weak var collectionViewContainerView: UIView!
    
    // MARK: - Properties
    private let viewModel = TimelineViewModel()
    private let disposeBag = DisposeBag()
    private var timeLineResult: TimeLineResult?
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        customUI()
        setCollectionViewFlowLayout()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchTimelineData()
    }
    
    // MARK: - Custom Method
    private func customUI() {
        self.view.layer.cornerRadius = 36
        self.view.layer.borderWidth = 2
        
        currentAlarmView.layer.cornerRadius = 12
        currentAlarmView.layer.borderWidth = 2
        makeNewAlarmButton.layer.cornerRadius = 22
        makeNewAlarmButton.layer.borderWidth = 2
        
        collectionViewContainerView.layer.cornerRadius = 12
        collectionViewContainerView.layer.borderWidth = 2
        
        NSLayoutConstraint.activate([
            collectionViewContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24)
        ])
    }
    
    private func bindViewModel() {
        viewModel.timelineData
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] result in
                switch result {
                case .success(let timelineResult):
                    if let timelineResult = timelineResult {
                        self?.updateUI(with: timelineResult)
                        self?.bindCollectionView(with: timelineResult.todayAlarmList ?? [])
                    }
                case .failure(let error):
                    print("Error: \(error)")
                }
            })
            .disposed(by: disposeBag)

        viewModel.dataLoaded
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                if let timelineResult = try? self.viewModel.timelineData.value().get() {
                    self.setNextAlarmUI(timelineResult: timelineResult)
                }
            })
            .disposed(by: disposeBag)
    }

    
    private func bindCollectionView(with alarms: [AlarmModel]) {
        timeLineCollectionView.delegate = nil
        timeLineCollectionView.dataSource = nil
        Observable.just(alarms)
            .bind(to: timeLineCollectionView.rx.items(cellIdentifier: TimelineCollectionViewCell.identifier, cellType: TimelineCollectionViewCell.self)) { [weak self] index, alarm, cell in
                cell.setAttributes(with: alarm)
                
                if let nextAlarmId = self?.viewModel.nextAlarmId, alarm.id == nextAlarmId {
                    cell.backgroundColor = UIColor(named: "primary050")
                } else {
                    cell.backgroundColor = .clear
                }
            }
            .disposed(by: disposeBag)
    }
    
    
    private func updateUI(with timelineResult: TimeLineResult) {
        updateDateLabel(timelineResponse: timelineResult)
        setNextAlarmUI(timelineResult: timelineResult)
        timeLineCollectionView.reloadData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.focusOnNextAlarm()
        }
    }
    
    private func focusOnNextAlarm() {
        guard let nextAlarmId = self.viewModel.nextAlarmId else { return }
        
        guard let todayAlarmList = try? viewModel.timelineData.value().get()?.todayAlarmList,
              !todayAlarmList.isEmpty else { return }
        
        if let index = todayAlarmList.firstIndex(where: { $0.id == nextAlarmId }) {
            let indexPath = IndexPath(row: index, section: 0)
            self.timeLineCollectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
        }
    }
    
    private func setCollectionViewFlowLayout() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: self.view.frame.width - 72, height: 70)
        layout.minimumLineSpacing = 16
        timeLineCollectionView.collectionViewLayout = layout
    }
    
    private func setNextAlarmUI(timelineResult: TimeLineResult?) {
        viewModel.checkIfTodayAlarmListIsEmpty()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { isEmpty in
                if isEmpty {
                    self.configureNextAlarmViewUIWithNoData()
                    self.alarmEmptyLabel.isHidden = false
                } else if let nextAlarm = timelineResult?.nextAlarm {
                    self.configureNextAlarmViewUIWithData(nextAlarm: nextAlarm)
                    self.alarmEmptyLabel.isHidden = true
                } else {
                    self.configureNextAlarmViewUIWithNoData()
                    self.alarmEmptyLabel.isHidden = true
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func configureNextAlarmViewUIWithNoData() {
        self.makeNewAlarmButton.isHidden = false
        self.alarmEmptyLabel.isHidden = false
        self.currentAlarmView.backgroundColor = UIColor(named: "primary050")
        self.iconLabel.text = "⏰"
        self.timeLabel.text = "예정된 알람이 없어요!"
        self.timeLabel.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 18)
        self.alarmInfoLabel.text = "알람을 설정해주세요"
    }
    
    private func configureNextAlarmViewUIWithData(nextAlarm: AlarmModel) {
        self.currentAlarmView.backgroundColor = UIColor(named: "secondary050")
        self.iconLabel.text = nextAlarm.icon
        let timeText = self.convert24HourTo12HourFormat(nextAlarm.alarmTime)
        self.timeLabel.text = timeText
        self.alarmInfoLabel.text = nextAlarm.name
        self.makeNewAlarmButton.isHidden = true
        self.timeLabel.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 26)
    }
    
    private func updateDateLabel(timelineResponse: TimeLineResult) {
        let dateString = timelineResponse.today
        let dayOfWeek = timelineResponse.dayOfWeek
        
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        
        if let date = inputFormatter.date(from: dateString) {
            let outputFormatter = DateFormatter()
            outputFormatter.locale = Locale(identifier: "ko_KR")
            outputFormatter.dateFormat = "yyyy년 M월 d일"
            
            let formattedDate = outputFormatter.string(from: date)
            let koreanDayOfWeek = convertDayOfWeekToKorean(dayOfWeek)
            dateLabel.text = "\(formattedDate) (\(koreanDayOfWeek))"
        }
    }
    
    private func convertDayOfWeekToKorean(_ dayOfWeek: String) -> String {
        let dayOfWeekMapping: [String: String] = [
            "MONDAY": "월",
            "TUESDAY": "화",
            "WEDNESDAY": "수",
            "THURSDAY": "목",
            "FRIDAY": "금",
            "SATURDAY": "토",
            "SUNDAY": "일"
        ]
        
        return dayOfWeekMapping[dayOfWeek] ?? ""
    }
    
    private func convert24HourTo12HourFormat(_ time: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "HH:mm:ss"
        
        if let date = inputFormatter.date(from: time) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "a h:mm"
            outputFormatter.amSymbol = "am"
            outputFormatter.pmSymbol = "pm"
            outputFormatter.locale = Locale(identifier: "en_US")
            
            return outputFormatter.string(from: date)
        } else {
            return time
        }
    }
    
    @IBAction func makeNewAlarmButtonTapped(_ sender: Any) {
        let alarmStoryBoard = UIStoryboard(name: "Alarm", bundle: nil)
        guard let vc = alarmStoryBoard.instantiateViewController(identifier: "EditAlarmViewController") as? EditAlarmViewController else { return }
        let navigationController = UINavigationController(rootViewController: vc)
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.isNavigationBarHidden = true
        navigationController.navigationBar.backgroundColor = .clear
        navigationController.interactivePopGestureRecognizer?.isEnabled = true
        
        present(navigationController, animated: true)
    }
}
