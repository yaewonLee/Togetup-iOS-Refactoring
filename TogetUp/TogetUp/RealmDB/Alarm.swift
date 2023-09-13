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
    @objc dynamic var isSnoozeActivated: Bool = false
    @objc dynamic var name: String = ""
    @objc dynamic var icon: String = ""
    @objc dynamic var isVibrate: Bool = false
    @objc dynamic var alarmTime: String = ""
    @objc dynamic var monday: Bool = false
    @objc dynamic var tuesday: Bool = false
    @objc dynamic var wednesday: Bool = false
    @objc dynamic var thursday: Bool = false
    @objc dynamic var friday: Bool = false
    @objc dynamic var saturday: Bool = false
    @objc dynamic var sunday: Bool = false
    //@objc dynamic var isActivated: Bool = false

    override static func primaryKey() -> String? {
        return "id"
    }
}
