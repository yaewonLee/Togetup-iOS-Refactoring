//
//  AlarmScheduleManager.swift
//  TogetUp
//
//  Created by 이예원 on 2023/09/26.
//

import Foundation
import UserNotifications
import RealmSwift
import AudioToolbox

class AlarmScheduleManager {
    static let shared = AlarmScheduleManager()
    
    func scheduleNotification(for alarmId: Int) {
        let realm = try? Realm()
        guard let alarm = realm?.object(ofType: Alarm.self, forPrimaryKey: alarmId), alarm.isActivated else { return }
        
        let content = self.createNotificationContent(for: alarm)
        let notificationCenter = UNUserNotificationCenter.current()
        
        if alarm.isRepeatAlarm() {
            self.scheduleRepeatingAlarms(for: alarm, with: content, using: notificationCenter)
        } else {
            self.scheduleSingleAlarm(for: alarm, with: content, using: notificationCenter)
        }
    }
    
    private func createNotificationContent(for alarm: Alarm) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "알람이 울리고 있어요!"
        content.body = "\(alarm.missionName)찍기 미션을 수행해주세요!"
        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "alarmSound.mp3"))
        content.userInfo = ["alarmId": alarm.id]
        return content
    }
    
    private func scheduleSingleAlarm(for alarm: Alarm, with content: UNMutableNotificationContent, using notificationCenter: UNUserNotificationCenter) {
        DispatchQueue.main.async {
            var dateComponents = DateComponents()
            dateComponents.hour = alarm.alarmHour
            dateComponents.minute = alarm.alarmMinute
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let request = UNNotificationRequest(identifier: "\(alarm.id)", content: content, trigger: trigger)
            
            notificationCenter.add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error)")
                }
            }
        }
    }
    
    private func scheduleRepeatingAlarms(for alarm: Alarm, with content: UNMutableNotificationContent, using notificationCenter: UNUserNotificationCenter) {
        let weekdays = [
            (alarm.monday, 2), // 월
            (alarm.tuesday, 3), // 화
            (alarm.wednesday, 4), // 수
            (alarm.thursday, 5), // 목
            (alarm.friday, 6), // 금
            (alarm.saturday, 7), // 토
            (alarm.sunday, 1)  // 일
        ]
        
        weekdays.forEach { isScheduled, weekday in
            if isScheduled {
                scheduleAlarmOnWeekday(for: alarm, weekday: weekday, with: content, using: notificationCenter)
            }
        }
    }
    
    private func scheduleAlarmOnWeekday(for alarm: Alarm, weekday: Int, with content: UNMutableNotificationContent, using notificationCenter: UNUserNotificationCenter) {
        var dateComponents = DateComponents()
        dateComponents.hour = alarm.alarmHour
        dateComponents.minute = alarm.alarmMinute
        dateComponents.weekday = weekday
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "\(alarm.id)-\(weekday)", content: content, trigger: trigger)
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    private func fetchAlarmFromDatabase(alarmId: Int) -> Alarm? {
        let realm = try? Realm()
        return realm?.object(ofType: Alarm.self, forPrimaryKey: alarmId)
    }
    
    func checkScheduledNotifications(completion: @escaping (Int) -> Void) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let count = requests.count
            completion(count)
        }
    }
    
    func removeNotification(for alarmId: Int, completion: @escaping () -> Void) {
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { requests in
            let identifiersToRemove = requests.filter { request in
                request.identifier.starts(with: "\(alarmId)")
            }.map { $0.identifier }
            
            if !identifiersToRemove.isEmpty {
                center.removePendingNotificationRequests(withIdentifiers: identifiersToRemove)
                print("Removed all notifications for alarm ID: \(alarmId)")
            } else {
                print("No notifications found for alarm ID: \(alarmId)")
            }
            completion()
        }
    }
    
    func toggleAlarmActivation(for alarmId: Int) {
        let realm = try? Realm()
        guard let alarm = realm?.object(ofType: Alarm.self, forPrimaryKey: alarmId) else {
            print("Alarm with ID \(alarmId) not found in Realm")
            return
        }
        if alarm.isActivated {
            scheduleNotification(for: alarm.id)
        } else {
            removeNotification(for: alarmId) {}
        }
    }
    
    func refreshAllScheduledNotifications() {
        guard let allAlarms = fetchAllAlarmsFromDatabase() else { return }
        for alarm in allAlarms where alarm.isActivated {
            scheduleNotification(for: alarm.id)
        }
    }
    
    func removeAllScheduledNotifications() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
    }
    
    func fetchAllAlarmsFromDatabase() -> [Alarm]? {
        do {
            let realm = try Realm()
            let alarms = realm.objects(Alarm.self)
            return Array(alarms)
        } catch let error {
            print("Error accessing Realm: \(error)")
            return nil
        }
    }
    
    func printAllScheduledNotifications() {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getPendingNotificationRequests { requests in
            for request in requests {
                print("Notification ID: \(request.identifier)")
                if let trigger = request.trigger as? UNCalendarNotificationTrigger {
                    if let nextTriggerDate = trigger.nextTriggerDate() {
                        let description = self.dateDescription(from: nextTriggerDate)
                        print("Scheduled for: \(description)")
                    }
                } else {
                    print("Scheduled for a single time")
                }
            }
        }
    }
    
    private func dateDescription(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 dd일 HH시 mm분"
        return formatter.string(from: date)
    }
}

extension Alarm {
    func isActive(on weekday: Int) -> Bool {
        switch weekday {
        case 1: return sunday
        case 2: return monday
        case 3: return tuesday
        case 4: return wednesday
        case 5: return thursday
        case 6: return friday
        case 7: return saturday
        default: return false
        }
    }
}
