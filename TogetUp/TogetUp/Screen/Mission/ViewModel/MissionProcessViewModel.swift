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
    private let provider = MoyaProvider<MissionService>()
    private let networkManager = NetworkManager()
    private let disposeBag = DisposeBag()
    
    func sendMissionImage(missionName: String, object: String?, missionImage: UIImage) -> Observable<MissionDetectResponse> {
        let request = provider.rx.request(.missionDetectionResult(missionName: missionName, object: object, missionImage: missionImage))
        return networkManager.handleAPIRequest(request, dataType: MissionDetectResponse.self)
            .flatMap { result -> Single<MissionDetectResponse> in
                switch result {
                case .success(let response):
                    print(response)
                    return .just(response)
                case .failure(let error):
                    print(error.localizedDescription)
                    return .error(error)
                }
            }
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

