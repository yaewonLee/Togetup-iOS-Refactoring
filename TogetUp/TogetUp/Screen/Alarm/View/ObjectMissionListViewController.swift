//
//  ObjectMissionListViewController.swift
//  TogetUp
//
//  Created by 이예원 on 2023/08/28.
//

import UIKit
import RxSwift

class ObjectMissionListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate {
    @IBOutlet weak var tableView: UITableView!
        
    private var objectMissionArray = ["사람", "자전거", "자동차", "오토바이", "버스", "기차",
                              "신호등", "고양이", "강아지", "백팩", "핸드백", "넥타이",
                              "스케이트보드", "테니스 라켓", "병", "와인잔", "컵", "포크", "나이프", "숟가락", "그릇", "바나나", "사과", "샌드위치", "오렌지", "브로콜리", "당근", "핫도그", "피자", "도넛", "케이크", "의자", "소파", "화분에 심은 식물", "침대", "식탁", "화장실", "텔레비전", "노트", "마우스", "리모컨", "키보드", "휴대전화", "전자레인지", "오븐", "토스터","싱크대", "냉장고", "책", "시계", "꽃병", "헤어 드라이어", "칫솔"]
    private let emojis = ["👤", "🚲", "🚗", "🛵", "🚌", "🚂", "🚥", "🐱", "🐶", "🎒", "👜", "👔", "🛹", "🎾", "🍾", "🍷", "☕️", "🍴", "🔪", "🥄", "🍽", "🍌", "🍎", "🥪", "🍊", "🥦", "🥕", "🌭", "🍕", "🍩", "🎂", "🪑", "🛋️", "🪴", "🛏️", "🍽", "🚽", "📺", "📓", "🖱️", "📱", "⌨️", "📱", "🍲", "🧁", "🍞", "🚰", "🧊", "📚", "⏰", "🌷", "💇‍♀️", "🪥"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        if #available(iOS 15, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        
        let leftBarButton = UIBarButtonItem(image: UIImage(named: "chevron-left"), style: .plain, target: self, action: #selector(back(_ :)))
        self.navigationItem.leftBarButtonItem = leftBarButton
        navigationController?.interactivePopGestureRecognizer?.delegate = self

    }
    
    @objc func back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 12
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return objectMissionArray.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let missionTitle = objectMissionArray[indexPath.section]
        let missionId = indexPath.section + 2
        let missionIcon = emojis[indexPath.section]
        
        NotificationCenter.default.post(name: NSNotification.Name("objectMissionSelected"), object: nil, userInfo: ["title": missionTitle, "id": missionId, "icon": missionIcon])

        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ObjectMissionTableViewCell", for: indexPath) as! ObjectMissionTableViewCell
        cell.titleLabel.text = objectMissionArray[indexPath.section]
        cell.iconLabel.text = emojis[indexPath.section]
        return cell
    }
}

class ObjectMissionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = 12
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1).cgColor
    }
}
