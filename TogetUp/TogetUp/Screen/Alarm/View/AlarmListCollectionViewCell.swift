//
//  AlarmListCollectionViewCell.swift
//  TogetUp
//
//  Created by 이예원 on 2023/09/12.
//

import UIKit

class AlarmListCollectionViewCell: UICollectionViewCell {
    static let identifier = "AlarmListCollectionViewCell"
    
    @IBOutlet weak var iconLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var alarmInfoLabel: UILabel!
    @IBOutlet weak var isActivated: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = 12
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.black.cgColor
    }
    
    func setAttributes(with model: GetAlarmListResult) {
        iconLabel.text = model.icon
        
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "HH:mm:ss"
        
        if let date = inputFormatter.date(from: model.alarmTime) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "a h:mm"
            outputFormatter.amSymbol = "am"
            outputFormatter.pmSymbol = "pm"
            
            timeLabel.text = outputFormatter.string(from: date)
        } else {
            print("Invalid time format")
        }
        
        let daysDict: [String: Bool] = ["월": model.monday, "화": model.tuesday, "수": model.wednesday, "목": model.thursday, "금": model.friday, "토": model.saturday, "일": model.sunday]
        let activeDays = daysDict.compactMap { $0.value ? $0.key : nil }
        let daysText = activeDays.joined(separator: ", ")
        
        if let missionObjectKr = model.getMissionObjectRes?.kr {
            alarmInfoLabel.text = "\(model.name)\(daysText) | \(missionObjectKr)"
        } else {
            alarmInfoLabel.text = "\(model.name), \(daysText)"
        }
    }
}
