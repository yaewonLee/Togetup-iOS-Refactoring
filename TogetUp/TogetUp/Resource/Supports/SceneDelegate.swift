//
//  SceneDelegate.swift
//  TogetUp
//
//  Created by 이예원 on 2023/08/14.
//

import UIKit
import RxKakaoSDKAuth
import KakaoSDKAuth
import AuthenticationServices
import RxSwift
import KakaoSDKUser
import RxKakaoSDKUser
import KakaoSDKCommon
import RealmSwift

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func navigateToMissionPerformViewController(with alarmId: Int) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let missionPerformVC = storyboard.instantiateViewController(withIdentifier: "MissionPerformViewController") as? MissionPerformViewController {
            let realmInstance = try! Realm()
            if let alarm = realmInstance.objects(Alarm.self).filter("id == \(alarmId)").first {
                try! realmInstance.write {
                    alarm.isAlarmed = true
                }
                
                missionPerformVC.alarmIcon = alarm.icon
                missionPerformVC.alarmName = alarm.name
                missionPerformVC.missionObject = alarm.missionName
                missionPerformVC.objectEndpoint = alarm.missionEndpoint
                missionPerformVC.missionId = alarm.missionId
                missionPerformVC.alarmId = alarm.id
                
                let navigationController = UINavigationController(rootViewController: missionPerformVC)
                window?.rootViewController = navigationController
                window?.makeKeyAndVisible()
            }
        }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            if (AuthApi.isKakaoTalkLoginUrl(url)) {
                _ = AuthController.rx.handleOpenUrl(url: url)
            }
        }
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        guard let realm = try? Realm() else { return }
        let currentTime = Date()
        let calendar = Calendar.current
        let currentComponents = calendar.dateComponents([.hour, .minute], from: currentTime)
        
        let activeAlarms = realm.objects(Alarm.self).filter("isActivated == true AND isAlarmed == false")
        
        for alarm in activeAlarms {
            if let completedTime = alarm.completedTime,
               currentTime.timeIntervalSince(completedTime) <= 60 {
                continue
            }
            
            if calendar.component(.hour, from: alarm.getAlarmTime() ?? Date()) == currentComponents.hour &&
                calendar.component(.minute, from: alarm.getAlarmTime() ?? Date()) == currentComponents.minute {
                navigateToMissionPerformViewController(with: alarm.id)
                break
            }
        }
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    
}

