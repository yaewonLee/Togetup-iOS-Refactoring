//
//  GroupAlarmListCollectionViewCell.swift
//  TogetUp
//
//  Created by 이예원 on 2023/10/21.
//

import UIKit

class GroupAlarmListCollectionViewCell: UICollectionViewCell {
    static let identifier = "GroupAlarmListCollectionViewCell"

    @IBOutlet weak var iconLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var alarmInfoLabel: UILabel!
    @IBOutlet weak var groupNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = 12
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.black.cgColor
    }
    
    func setAttributes(with model: GetAlarmResult) {
        iconLabel.text = model.icon
        groupNameLabel.text = model.roomRes?.name
        
        let inputTimeString = model.alarmTime
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "HH:mm:ss"

        let calendar = Calendar.current
        if let dateFromComponents = inputFormatter.date(from: inputTimeString) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "a h:mm"
            outputFormatter.amSymbol = "am"
            outputFormatter.pmSymbol = "pm"

            let timeString = outputFormatter.string(from: dateFromComponents)
            timeLabel.text = timeString
        } else {
            print("Failed to create date from components.")
        }
        
        let daysDict: [(String, Bool)] =
          [("월", model.monday), ("화", model.tuesday), ("수", model.wednesday),
           ("목", model.thursday), ("금", model.friday), ("토", model.saturday),
           ("일",model.sunday)]
                
        let selectedDays = daysDict.compactMap { $0.1 ? $0.0 : nil }

        if selectedDays.isEmpty {
            alarmInfoLabel.text = "\(model.name) | \(model.getMissionObjectRes?.kr ?? "")"
        } else if selectedDays.allSatisfy({ ["월", "화", "수", "목", "금"].contains($0) }) && selectedDays.count == 5 {
            alarmInfoLabel.text = "\(model.name), 주중 | \(model.getMissionObjectRes?.kr ?? "")"
        } else if selectedDays == ["토", "일"] {
            alarmInfoLabel.text = "\(model.name), 주말 | \(model.getMissionObjectRes?.kr ?? "")"
        } else if selectedDays.count == 7 {
            alarmInfoLabel.text = "\(model.name), 매일 | \(model.getMissionObjectRes?.kr ?? "")"
        } else if selectedDays.count == 1 {
            alarmInfoLabel.text = "\(model.name), \(selectedDays[0])요일마다 | \(model.getMissionObjectRes?.kr ?? "")"
        } else {
            alarmInfoLabel.text = "\(model.name), \(selectedDays.joined(separator: ", ")) | \(model.getMissionObjectRes?.kr ?? "")"
        }
    }    
}
