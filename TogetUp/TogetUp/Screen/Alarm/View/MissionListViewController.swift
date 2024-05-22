//
//  MissionListViewController.swift
//  TogetUp
//
//  Created by 이예원 on 2023/08/28.
//

import UIKit

class MissionListViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var customMissionView: UIView!
    @IBOutlet weak var objectMissionView: UIView!
    @IBOutlet weak var faceMissionView: UIView!
    var customMissionDataHandler: ((String, String, Int, Int?) -> ())?
    override func viewDidLoad() {
        super.viewDidLoad()
        let leftBarButton = UIBarButtonItem(image: UIImage(named: "chevron-left"), style: .plain, target: self, action: #selector(back(_ :)))
        self.navigationItem.leftBarButtonItem = leftBarButton
        
        let views = [customMissionView, objectMissionView, faceMissionView]
        views.forEach { view in
            if let view = view {
                view.layer.cornerRadius = 12
                view.layer.borderWidth = 2
                view.layer.borderColor = UIColor.black.cgColor
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    @IBAction func objectMissionBtn(_ sender: UIButton) {
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "ObjectMissionListViewController") as? MissionListDetailViewController else { return }
        vc.missionId = 2
        
        vc.navigationController?.isNavigationBarHidden = false
        vc.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        vc.navigationController?.interactivePopGestureRecognizer?.delegate = self
        vc.navigationItem.title = "사물 인식 미션"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func faceMission(_ sender: UIButton) {
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "ObjectMissionListViewController") as? MissionListDetailViewController else { return }
        vc.missionId = 3
        
        vc.navigationController?.isNavigationBarHidden = false
        vc.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        vc.navigationController?.interactivePopGestureRecognizer?.delegate = self
        vc.navigationItem.title = "표정 인식 미션"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func customMissionSelected(_ sender: Any) {
        customMissionDataHandler?("직접 등록 미션", "📷", 1, nil)
        self.navigationController?.popViewController(animated: true)
    }
}
