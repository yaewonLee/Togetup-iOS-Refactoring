//
//  Alarm.swift
//  TogetUp
//
//  Created by 이예원 on 2023/09/12.
//

import Foundation
import RealmSwift

class Alarm: Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var missionId: Int = 0
    @objc dynamic var missionObjectId: Int = 0
    @objc dynamic var name: String = ""
    @objc dynamic var icon: String = ""
    @objc dynamic var isVibrate: Bool = false
    @objc dynamic var alarmHour: Int = 0
    @objc dynamic var alarmMinute: Int = 0
    @objc dynamic var monday: Bool = false
    @objc dynamic var tuesday: Bool = false
    @objc dynamic var wednesday: Bool = false
    @objc dynamic var thursday: Bool = false
    @objc dynamic var friday: Bool = false
    @objc dynamic var saturday: Bool = false
    @objc dynamic var sunday: Bool = false
    @objc dynamic var isActivated: Bool = false
    @objc dynamic var missionName: String = ""
    @objc dynamic var missionEndpoint: String = ""
    @objc dynamic var completedTime: Date? = nil
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func getAlarmTime() -> Date? {
        var dateComponents = DateComponents()
        dateComponents.hour = self.alarmHour
        dateComponents.minute = self.alarmMinute
        
        let currentDate = Date()
        
        if let alarmDate = Calendar.current.date(bySettingHour: self.alarmHour, minute: self.alarmMinute, second: 0, of: currentDate) {
            return alarmDate
        } else {
            return nil
        }
    }
    
    func isRepeatAlarm() -> Bool {
            return monday || tuesday || wednesday || thursday || friday || saturday || sunday
        }
}
