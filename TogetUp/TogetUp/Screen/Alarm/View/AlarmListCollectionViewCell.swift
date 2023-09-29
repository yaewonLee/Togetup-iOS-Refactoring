//
//  AlarmListCollectionViewCell.swift
//  TogetUp
//
//  Created by 이예원 on 2023/09/12.
//

import UIKit

class AlarmListCollectionViewCell: UICollectionViewCell {
    static let identifier = "AlarmListCollectionViewCell"
    
    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var iconLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var alarmInfoLabel: UILabel!
    @IBOutlet weak var isActivated: UISwitch!
    
    var onDeleteTapped: (() -> Void)?
    var onToggleSwitch: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = 12
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.black.cgColor
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        onDeleteTapped = nil
        onToggleSwitch = nil
    }
        
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        onDeleteTapped?()
    }
    
    @IBAction func isActivatedTapped(_ sender: UISwitch) {
        if !sender.isOn {
            self.backGroundView.backgroundColor = UIColor(named: "neutral050")
            [alarmInfoLabel, timeLabel, iconLabel].forEach {
                $0?.alpha = 0.6
            }
        } else {
            self.backGroundView.backgroundColor = UIColor(named: "secondary050")
            [alarmInfoLabel, timeLabel, iconLabel].forEach {
                $0?.alpha = 1
            }
        }
        onToggleSwitch?()
    }
    
    func setAttributes(with model: Alarm) {
        iconLabel.text = model.icon
        isActivated.isOn = model.isActivated
        if !isActivated.isOn {
            self.backGroundView.backgroundColor = UIColor(named: "neutral050")
            [alarmInfoLabel, timeLabel, iconLabel].forEach {
                $0?.alpha = 0.6
            }
        } else {
            self.backGroundView.backgroundColor = UIColor(named: "secondary050")
            [alarmInfoLabel, timeLabel, iconLabel].forEach {
                $0?.alpha = 1
            }
        }

        var components = DateComponents()
        components.hour = model.alarmHour
        components.minute = model.alarmMinute

        let calendar = Calendar.current
        if let dateFromComponents = calendar.date(from: components) {
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
        
       // 모든 날짜가 true인지 확인
       if daysDict.allSatisfy({ $0.1 }) {
           alarmInfoLabel.text =
           "\(model.name), 매일 | \(model.missionName)"
       } else {
           let activeDaysTexts =
             daysDict.compactMap { $0.1 ? $0.0 : nil }.joined(separator: ", ")

           if activeDaysTexts.isEmpty {
               alarmInfoLabel.text =
               "\(model.name) | \(model.missionName)"
           } else {
               alarmInfoLabel.text =
               "\(model.name), \(activeDaysTexts) | \(model.missionName)"
           }
       }
    }
}
