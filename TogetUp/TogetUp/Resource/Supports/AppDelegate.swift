//
//  AppDelegate.swift
//  TogetUp
//
//  Created by 이예원 on 2023/08/14.
//

import UIKit
import RxKakaoSDKCommon
import UserNotifications
import RxSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    private let pushAlarmViewModel = PushAlarmViewModel()
    private let disposeBag = DisposeBag()
    
    var isLoggedIn: Bool {
        return KeyChainManager.shared.getToken() != nil
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        AppStatusManager.shared.clearSensitiveDataOnFirstLaunch()
        if let kakaoAppKey = Bundle.main.object(forInfoDictionaryKey: "KakaoAppKey") as? String {
            RxKakaoSDK.initSDK(appKey: kakaoAppKey)
        }
        
        UNUserNotificationCenter.current().delegate = self
        application.registerForRemoteNotifications()
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        guard let alarmId = userInfo["alarmId"] as? Int else { return }
        
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let sceneDelegate = scene.delegate as? SceneDelegate {
            sceneDelegate.navigateToMissionPerformViewController(with: alarmId)
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        guard let alarmId = userInfo["alarmId"] as? Int else { return }
        
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let sceneDelegate = scene.delegate as? SceneDelegate {
            sceneDelegate.navigateToMissionPerformViewController(with: alarmId)
        }
        completionHandler()
    }
}
