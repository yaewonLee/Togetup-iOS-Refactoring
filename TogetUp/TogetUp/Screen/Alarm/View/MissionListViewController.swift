//
//  MissionListViewController.swift
//  TogetUp
//
//  Created by 이예원 on 2023/08/28.
//

import UIKit

class MissionListViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var customMissionDataHandler: ((String, Int, String) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let leftBarButton = UIBarButtonItem(image: UIImage(named: "chevron-left"), style: .plain, target: self, action: #selector(back(_ :)))
        self.navigationItem.leftBarButtonItem = leftBarButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    @IBAction func objectMissionBtn(_ sender: UIButton) {
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "ObjectMissionListViewController") as? MissionListDetailViewController else { return }
        vc.missionId = 2
        
        navigationController?.isNavigationBarHidden = false
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func faceMission(_ sender: UIButton) {
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "ObjectMissionListViewController") as? MissionListDetailViewController else { return }
        vc.missionId = 3
        
        navigationController?.isNavigationBarHidden = false
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func customMissionSelected(_ sender: Any) {
        customMissionDataHandler?("직접 등록 미션", 1, "📷")
        self.navigationController?.popViewController(animated: true)
    }
}
