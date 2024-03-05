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
    
    // MARK: - Properties
    private let viewModel = FloatingPanelViewModel()
    private let disposeBag = DisposeBag()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        customUI()
        setCollectionViewFlowLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bindViewModel()
        setCollectionView()
    }
    
    // MARK: - Custom Method
    private func customUI() {
        self.view.layer.cornerRadius = 36
        self.view.layer.borderWidth = 2
        
        //timeLineCollectionView.layer.cornerRadius = 12
       // timeLineCollectionView.layer.borderWidth = 2
      //  timeLineCollectionView.clipsToBounds = true
        currentAlarmView.layer.cornerRadius = 12
        currentAlarmView.layer.borderWidth = 2
    }
    
    private func setCollectionView() {
        self.timeLineCollectionView.delegate = nil
        self.timeLineCollectionView.dataSource = nil

        viewModel.getTimeLine()
            .map { $0.result?.todayAlarmList ?? [] }
            .observe(on: MainScheduler.instance)
            .bind(to: timeLineCollectionView.rx.items(cellIdentifier: TimelineCollectionViewCell.identifier, cellType: TimelineCollectionViewCell.self)) { index, model, cell in
                cell.setAttributes(with: model)
            }
            .disposed(by: disposeBag)
    }
    
    private func setCollectionViewFlowLayout() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: timeLineCollectionView.bounds.width, height: 70)
        layout.minimumLineSpacing = 16
        timeLineCollectionView.collectionViewLayout = layout
    }
    
    private func bindViewModel() {
        viewModel.getTimeLine()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] timelineResponse in
                self?.updateDateLabel(timelineResponse: timelineResponse)
                self?.setNextAlarmUI(timelineResponse: timelineResponse)
            }, onError: { error in
                print("Error: \(error)")
            })
            .disposed(by: disposeBag)
    }
    
    private func setNextAlarmUI(timelineResponse: TimelineResponse) {
        iconLabel.text = timelineResponse.result?.nextAlarm?.icon
        let timeText = convert24HourTo12HourFormat(timelineResponse.result?.nextAlarm?.alarmTime ?? "")
        timeLabel.text = timeText
        alarmInfoLabel.text = timelineResponse.result?.nextAlarm?.name
    }
    
    private func updateDateLabel(timelineResponse: TimelineResponse) {
        guard let dateString = timelineResponse.result?.today,
              let dayOfWeek = timelineResponse.result?.dayOfWeek else {
            dateLabel.text = ""
            return
        }
        
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
}
