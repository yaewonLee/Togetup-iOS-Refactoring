//
//  GroupListViewController.swift
//  TogetUp
//
//  Created by 이예원 on 2023/08/18.
//

import UIKit
import RxSwift
import RxCocoa

class GroupListViewController: UIViewController {
    // MARK: - UI Components
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Properties
    private let viewModel = GroupListViewModel()
    private let disposeBag = DisposeBag()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setCollectionViewFlowLayout()
        setCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    // MARK: - Custom Method
    private func setCollectionView() {
        collectionView.delegate = nil
        collectionView.dataSource = nil
        
        viewModel.loginReqeust()
            .map { $0.result.compactMap { $0 } }
            .bind(to: collectionView.rx.items(cellIdentifier: GroupListCollectionViewCell.identifier,
                                              cellType: GroupListCollectionViewCell.self)) { index, model, cell in
                cell.setAttributes(with: model)
            }
            .disposed(by: disposeBag)
        
    }
    private func customUI() {
        
    }
    
    private func setCollectionViewFlowLayout() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: collectionView.bounds.width - 40, height: 68)
        layout.minimumLineSpacing = 16
        collectionView.collectionViewLayout = layout
    }
    // MARK: - @
    
}
