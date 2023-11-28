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
    private let provider: MoyaProvider<UserService>    
    var avatars: [AvatarResult] = []
    var selectedAvatar: AvatarResult?

    init() {
        self.provider = MoyaProvider<UserService>(plugins: [NetworkLogger()])
    }
    
    func loadAvatars() -> Observable<AvatarResponse> {
        return provider.rx.request(.getAvatarList)
            .filterSuccessfulStatusCodes()
            .map(AvatarResponse.self)
            .do(onSuccess: { [weak self] response in
                self?.avatars = response.result
            })
            .asObservable()
    }

    func updateSelectedAvatar(at index: Int) {
        selectedAvatar = avatars[index]
    }
}

