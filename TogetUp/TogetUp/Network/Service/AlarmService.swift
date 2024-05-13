//
//  AlarmService.swift
//  TogetUp
//
//  Created by 이예원 on 2023/09/04.
//

import Foundation
import Moya


enum AlarmService {
    case createAlarm(param: CreateOrEditAlarmRequest)
    case getAlarmList(type: String)
    case deleteAlarm(alarmId: Int)
    case getSingleAlarm(alarmId: Int)
    case editAlarm(alarmId: Int, param: CreateOrEditAlarmRequest)
    case deactivateAlarms(alarmIds: [Int])
}

extension AlarmService: TargetType {
    var baseURL: URL {
        return URL(string: URLConstant.baseURL)!
    }
    
    var path: String {
        switch self {
        case .createAlarm, .getAlarmList:
            return URLConstant.createAlarm
        case .deleteAlarm(let id), .getSingleAlarm(let id), .editAlarm(let id, _):
            return URLConstant.deleteAlarm + "\(id)"
        case .deactivateAlarms:
            return URLConstant.deactivateAlarms
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .createAlarm:
            return .post
        case .getAlarmList:
            return .get
        case .deleteAlarm:
            return .delete
        case .getSingleAlarm:
            return .get
        case .editAlarm, .deactivateAlarms:
            return .patch
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .createAlarm(let param):
            return .requestJSONEncodable(param)
        case .getAlarmList(let type):
            return .requestParameters(parameters: ["type" : type], encoding: URLEncoding.queryString)
        case .deleteAlarm:
            return .requestPlain
        case .getSingleAlarm(let id):
            return .requestParameters(parameters: ["alarmId" : id], encoding: URLEncoding.default)
        case .editAlarm(_, let param):
            return .requestJSONEncodable(param)
        case .deactivateAlarms(let alarmIds):
            return .requestJSONEncodable(["alarmIds": alarmIds])
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .createAlarm, .getAlarmList, .deleteAlarm, .getSingleAlarm, .editAlarm, .deactivateAlarms:
            let token = KeyChainManager.shared.getToken()
            return [
                "Authorization": "Bearer \(token ?? "")",
                "Content-Type": "application/json"
            ]
        }
    }
}
