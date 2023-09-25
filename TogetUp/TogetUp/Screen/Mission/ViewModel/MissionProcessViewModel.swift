//
//  MissionProcessViewModel.swift
//  TogetUp
//
//  Created by 이예원 on 2023/09/25.
//

import Foundation
import RxSwift
import Moya
import RxMoya
import UIKit

class MissionProcessViewModel {
    private let provider: MoyaProvider<MissionService>
    
    init(provider: MoyaProvider<MissionService> = MoyaProvider<MissionService>(plugins: [NetworkLogger()])) {
            self.provider = provider
        }
    
    func sendMissionImage(objectName: String, missionImage: UIImage) -> Observable<MissionDetectResponse> {
        return provider.rx.request(.missionDetection(objectName: objectName, missionImage: missionImage))
            .filterSuccessfulStatusCodes()
            .map(MissionDetectResponse.self)
            .asObservable()
    }
}

