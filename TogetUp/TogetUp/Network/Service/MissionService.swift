//
//  MissionService.swift
//  TogetUp
//
//  Created by 이예원 on 2023/09/11.
//

import Foundation
import Moya
import UIKit

enum MissionService {
    case getMissionList(missionId: Int)
    case missionDetectionResult(missionName: String, object: String?, missionImage: UIImage)
    case missionComplete(param: MissionCompleteRequest)
}

extension MissionService: TargetType {
    var baseURL: URL {
        return URL(string: URLConstant.baseURL)!
    }
    
    var path: String {
        switch self {
        case .getMissionList(let missionId):
            return URLConstant.getMissionList + "\(missionId)"
        case .missionDetectionResult(let missionName, let object, _):
            return URLConstant.missionDetection + "\(missionName)/result"
        case .missionComplete:
            return URLConstant.missionComplete
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getMissionList:
            return .get
        case .missionDetectionResult, .missionComplete:
            return .post
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .getMissionList:
            return .requestPlain
        case .missionDetectionResult(_, let object, let missionImage):
            guard let imageData = missionImage.jpegData(compressionQuality: 1.0) else {
                return .requestPlain
            }
            let imagePart = MultipartFormData(provider: .data(imageData), name: "missionImage", fileName: "missionImage.jpg", mimeType: "image/jpeg")
            
            var parameters: [String: Any] = [:]
            if let objectValue = object {
                parameters["object"] = objectValue
            }
            
            return .uploadCompositeMultipart([imagePart], urlParameters: parameters)
        case .missionComplete(let param):
            return .requestJSONEncodable(param)
        }
    }
    
    var headers: [String : String]? {
        let token = KeyChainManager.shared.getToken()
        return [
            "Authorization": "Bearer \(token ?? "")",
            "Content-Type": "application/json"
        ]
    }
}

