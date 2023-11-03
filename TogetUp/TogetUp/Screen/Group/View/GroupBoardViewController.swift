//
//  GroupBoardViewController.swift
//  TogetUp
//
//  Created by 이예원 on 2023/10/17.
//

import UIKit
import FSCalendar
import RxSwift
import RxCocoa

class GroupBoardViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    // MARK: - UI Components
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var bgView: UIImageView!
    @IBOutlet weak var alienImageView: UIImageView!
    @IBOutlet weak var bearImageView: UIImageView!
    @IBOutlet weak var rocketImageView: UIImageView!
    
    // MARK: - Properties
    private let viewModel = GroupBoardViewModel()
    private let disposeBag = DisposeBag()
    var roomId = 25
    var localDateTime: String?
    var navigationTitle = "그룹이름"
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCalendar()
        getCurrentDate()
        setCollectionViewFlowLayout()
        setCollectionView()
        //setNavigationTitle()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.tintColor = .black
        setNavigationTitle()
    }
    
    // MARK: - Custom Method
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSettingView",
           let destinationVC = segue.destination as? GroupSettingViewController,
           let roomId = sender as? Int {
            destinationVC.roomId = roomId
        }
    }
    
    private func setNavigationTitle() {
        viewModel.titleSubject
            .asObserver()
            .subscribe(onNext: { [weak self] title in
                self?.navigationItem.title = title
            })
            .disposed(by: disposeBag)
    }
    
    private func setCollectionViewFlowLayout() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: (collectionView.bounds.width - 8)/2, height: (collectionView.bounds.width - 8)/2 + 32)
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 8
        collectionView.collectionViewLayout = layout
    }
    
    private func setCollectionView() {
        collectionView.delegate = nil
        collectionView.dataSource = nil
        
        viewModel.getMissionLog(roomId: roomId, localDateTime: localDateTime!)
            .map { $0.result.userLogList }
            .bind(to: collectionView.rx.items(cellIdentifier: GroupBoardCollectionViewCell.identifier, cellType: GroupBoardCollectionViewCell.self)) { index, model, cell in
                cell.setAttributes(with: model)
                if model.userCompleteType == "NOT_MISSION" {
                    [self.collectionView, self.bgView, self.alienImageView, self.bearImageView, self.rocketImageView].forEach { view in
                        if let safeView = view {
                            view?.isHidden = true
                        }
                    }
                } else {
                    [self.collectionView, self.bgView, self.alienImageView, self.bearImageView, self.rocketImageView].forEach { view in
                        if let safeView = view {
                            view?.isHidden = false
                        }
                    }
                }
            }
            .disposed(by: disposeBag)
    }
    
    private func getCurrentDate() {
        let currentDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayString = formatter.string(from: currentDate)
        self.localDateTime = todayString
    }
    
    private func setUpCalendar() {
        calendar.delegate = self
        calendar.dataSource = self
        calendar.scope = .week
        
        buttonView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        buttonView.layer.cornerRadius = 12
        
        // 상단 요일 변경
        calendar.appearance.caseOptions = [.weekdayUsesSingleUpperCase]
        calendar.appearance.weekdayTextColor = UIColor(named: "neutral300")
        calendar.appearance.titleSelectionColor = .black
        calendar.appearance.weekdayFont = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 12)
        // 숫자들 글자 폰트 및 사이즈 지정
        calendar.appearance.titleFont = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 18)
        // 캘린더 테두리
        calendar.placeholderType = .none
        //헤더 관련 속성
        calendar.appearance.headerTitleColor = .clear
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.calendarHeightConstraint.constant = bounds.height
        self.view.layoutIfNeeded()
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        if calendar.selectedDates.contains(date) {
            return UIColor.black
        }
        return nil
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let selectedDate = formatter.string(from: date)
        self.localDateTime = selectedDate
        setCollectionView()
    }
    
    // MARK: - @
    @IBAction func settingButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "toSettingView", sender: roomId)
    }
}
