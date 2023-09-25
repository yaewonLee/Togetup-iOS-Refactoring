//
//  URLConstant.swift
//  TogetUp
//
//  Created by 이예원 on 2023/08/31.
//

import Foundation

struct URLConstant {
    // MARK: - Base URL
    static let baseURL = "https://togetup.shop"
    
    // MARK: - Auth 로그인
    static let login = "/app/auth/login"
    
    // MARK: - User
    static let withdrawl = "/app/users"
    static let appleWithdrawl = "/app/users/apple"
    
    // MARK: - 알람
    static let getAlarmList = "/app/alarm"
    static let createAlarm = "/app/alarm"
    static let deleteAlarm = "/app/alarm/"
    static let editAlarm = "/app/alarm/"
    static let getSingleAlarm = "/app/alarm/"
    
    // MARK: - 미션
    static let missionDetection = "/app/mission/"
    static let getMissionList = "/app/mission/"
}
