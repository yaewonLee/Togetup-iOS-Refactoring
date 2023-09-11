//
//  MissionListDetailViewController.swift
//  TogetUp
//
//  Created by 이예원 on 2023/08/28.
//

import UIKit
import RxSwift
import RxCocoa

class MissionListDetailViewController: UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet weak var collectionView: UICollectionView!
    private let viewModel = ObjectMissionViewModel()
    private let disposeBag = DisposeBag()
    var missionId = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customNavigation()
        setCollectionViewFlowLayout()
        setCollectionView()
    }
    
    private func setCollectionViewFlowLayout() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: collectionView.bounds.width, height: 82)
        layout.minimumLineSpacing = 12
        collectionView.collectionViewLayout = layout
    }
    
    private func setCollectionView() {
        viewModel.getMissionList(missionId: self.missionId)
                    .map { $0.result.missionObjectResList }
                    .bind(to: collectionView.rx.items(cellIdentifier: ObjectMissionCollectionViewCell.identifier, cellType: ObjectMissionCollectionViewCell.self)) { row, element, cell in
                        cell.setAttributes(with: element)
                    }
                    .disposed(by: disposeBag)
        
        collectionView.rx.modelSelected(MissionObjectResList.self)
            .subscribe(onNext: { mission in
                NotificationCenter.default.post(name: .init("MissionSelected"), object: nil, userInfo: ["icon": mission.icon, "kr": mission.kr, "id": mission.id])
                self.navigationController?.popToRootViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    private func customNavigation() {
        let leftBarButton = UIBarButtonItem(image: UIImage(named: "chevron-left"), style: .plain, target: self, action: #selector(back(_ :)))
        self.navigationItem.leftBarButtonItem = leftBarButton
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    @objc func back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}


