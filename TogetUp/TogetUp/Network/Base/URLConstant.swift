//
//  URLConstant.swift
//  TogetUp
//
//  Created by 이예원 on 2023/08/31.
//

import Foundation

struct URLConstant {
    // MARK: - Base URL
    static let baseURL = "https://togetup.shop/app/"
    
    // MARK: - Auth 로그인
    static let login = "auth/login"
    
    // MARK: - User
    static let withdrawl = "users"
    static let appleWithdrawl = "users/apple"
    static let sendFcmToken = "users/fcm-token"
    static let getAvatarList = "users/avatars"
    static let changeAvatar = "users/avatars"
    
    // MARK: - 알람
    static let getAlarmList = "alarm"
    static let createAlarm = "alarm"
    static let deleteAlarm = "alarm/"
    static let editAlarm = "alarm/"
    static let getSingleAlarm = "alarm/"
    
    // MARK: - 미션
    static let missionDetection = "mission/"
    static let getMissionList = "mission/"
    static let missionComplete = "mission/complete"
    
    // MARK: - 그룹
    static let getGroupList = "room/"
    static let createGroup = "room/"
    static let getMissionLog = "room/user/mission-log"
    static let getGroupDetail = "room/"
    static let joinGroup = "room/join/"
    static let deleteMember = "room/"
    static let getGroupDetailWithCode = "room/information"
    
    // MARK: - 홈
    static let getTimeline = "home/brief-board/alarm/timeline"
}
