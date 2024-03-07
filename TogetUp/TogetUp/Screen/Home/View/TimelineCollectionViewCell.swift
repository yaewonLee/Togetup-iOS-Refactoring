//
//  TimelineCollectionViewCell.swift
//  TogetUp
//
//  Created by 이예원 on 11/26/23.
//

import UIKit

class TimelineCollectionViewCell: UICollectionViewCell {
    static let identifier = "TimelineCollectionViewCell"
    
    @IBOutlet weak var iconLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var alarmInfoLabel: UILabel!
    @IBOutlet weak var colorView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        colorView.layer.cornerRadius = 8
    }
    
    func setAttributes(with model: AlarmModel) {
        iconLabel.text = model.icon
        let timeText = convert24HourTo12HourFormat(model.alarmTime)
        timeLabel.text = timeText
        alarmInfoLabel.text = "\(model.name) | \(model.missionObject ?? "직접 촬영 미션")"
        
        adjustIconLabelAlphaBasedOnTime(model.alarmTime)
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
    
    private func adjustIconLabelAlphaBasedOnTime(_ alarmTime: String) {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "HH:mm:ss"
        inputFormatter.locale = Locale(identifier: "en_US")
        
        let currentTimeString = inputFormatter.string(from: Date())
        if let alarmDate = inputFormatter.date(from: alarmTime), let currentDate = inputFormatter.date(from: currentTimeString) {
            if alarmDate < currentDate {
                iconLabel.alpha = 0.4
                timeLabel.alpha = 0.4
                alarmInfoLabel.alpha = 0.4
            } else {
                iconLabel.alpha = 1.0
                timeLabel.alpha = 1.0
                alarmInfoLabel.alpha = 1.0
            }
        }
    }
}
