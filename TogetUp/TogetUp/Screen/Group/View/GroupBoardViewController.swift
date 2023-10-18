//
//  GroupBoardViewController.swift
//  TogetUp
//
//  Created by 이예원 on 2023/10/17.
//

import UIKit
import FSCalendar

class GroupBoardViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCalendar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    private func setUpCalendar() {
        calendar.delegate = self
        calendar.dataSource = self
        calendar.scope = .week
                
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
}
