//
//  LoginViewModel.swift
//  TogetUp
//
//  Created by 이예원 on 2023/09/01.
//

import Foundation
import Moya
import RxSwift
import RxMoya

struct LoginViewModel {
    private let provider: MoyaProvider<LoginService>
    private let networkManager = NetworkManager()
    
    init() {
        self.provider = MoyaProvider<LoginService>(plugins: [NetworkLogger()])
    }

    func loginReqeust(param: LoginRequest) -> Single<Result<Void, Error>> {
        return networkManager.handleAPIRequest(provider.rx.request(.login(param: param)), dataType: LoginResponse.self)
            .flatMap { result -> Single<Result<Void, Error>> in
                switch result {
                case .success(let response):
                    self.saveUserInfo(response: response)
                    return .just(.success(()))
                case .failure(let error):
                    return .just(.failure(error))
                }
            }
    }
    
    private func saveUserInfo(response: LoginResponse) {
        guard let result = response.result else {
            print("유저 정보 저장 실패")
            return
        }
        KeyChainManager.shared.saveToken(result.accessToken)
        KeyChainManager.shared.saveUserInformation(name: result.userName ?? "", email: result.email ?? "")
        let userStatus = UserStatus(level: result.userStat.level, expPercentage: result.userStat.expPercentage)
        let userData = HomeData(avatarId: result.avatarId, name: result.userName ?? "", userStat: userStatus)
        UserDataManager.shared.updateHomeData(data: userData)
    }
}


