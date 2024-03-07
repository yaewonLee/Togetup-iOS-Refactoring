//
//  HomeViewModel.swift
//  TogetUp
//
//  Created by 이예원 on 11/27/23.
//

import Foundation
import RxSwift
import Moya
import RxMoya

class HomeViewModel {
    private let provider = MoyaProvider<UserService>()
    var avatars: [AvatarResult] = []
    var selectedAvatar: AvatarResult?
    private let networkManager = NetworkManager()

    func loadAvatars() -> Observable<AvatarResponse> {
        return provider.rx.request(.getAvatarList)
            .filterSuccessfulStatusCodes()
            .map(AvatarResponse.self)
            .do(onSuccess: { [weak self] response in
                self?.avatars = response.result ?? []
            })
            .asObservable()
    }
    
    func changeAvatar(avatarId: Int) -> Single<Result<Void, Error>> {
        return networkManager.handleAPIRequest(provider.rx.request(.changeAvatar(avatarId: avatarId)), dataType: AvatarResponse.self)
            .flatMap { result -> Single<Result<Void, Error>> in
                switch result {
                case .success(_):
                    return .just(.success(()))
                case .failure(let error):
                    return .just(.failure(error))
                }
            }
    }

    func updateSelectedAvatar(at index: Int) {
        selectedAvatar = avatars[index]
    }
}
