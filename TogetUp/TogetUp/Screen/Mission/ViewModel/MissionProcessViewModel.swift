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
    private let networkManager = NetworkManager()
    private let disposeBag = DisposeBag()
    
    init(provider: MoyaProvider<MissionService> = MoyaProvider<MissionService>(plugins: [NetworkLogger()])) {
        self.provider = provider
    }
    
    func sendMissionImage(objectName: String, missionImage: UIImage) -> Observable<MissionDetectResponse> {
        return provider.rx.request(.missionDetection(objectName: objectName, missionImage: missionImage))
            .filterSuccessfulStatusCodes()
            .map(MissionDetectResponse.self)
            .asObservable()
    }
    
    func completeMission(param: MissionCompleteRequest, completion: @escaping (Result<MissionCompleteResponse, Error>) -> Void) {
        networkManager.handleAPIRequest(provider.rx.request(.missionComplete(param: param)), dataType: MissionCompleteResponse.self)
            .subscribe(onSuccess: { result in
                switch result {
                case .success(let response):
                    completion(.success(response))
                    if let userStat = response.result?.userStat {
                        UserDataManager.shared.updateUserStatus(level: userStat.level, expPercentage: userStat.expPercentage)
                        ThemeManager.shared.updateIsNewForAvatar(withUnlockLevel: userStat.level, isNew: true)
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }, onFailure: { error in
                completion(.failure(error))
            })
            .disposed(by: disposeBag)
    }
}

