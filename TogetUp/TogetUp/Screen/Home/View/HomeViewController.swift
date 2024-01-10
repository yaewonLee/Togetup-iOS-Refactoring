//
//  HomeViewController.swift
//  TogetUp
//
//  Created by 이예원 on 2023/08/18.
//

import UIKit
import FloatingPanel
import RxSwift
import RxCocoa

class HomeViewController: UIViewController, FloatingPanelControllerDelegate {
    // MARK: - UI Components
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var coinView: UIView!
    @IBOutlet weak var pointLabel: UILabel!
    @IBOutlet weak var avatarView: UIView!
    @IBOutlet weak var hangerButton: UIButton!
    @IBOutlet weak var avatarChooseCollectionView: UICollectionView!
    @IBOutlet weak var mainAvatarImageView: UIImageView!
    
    // MARK: - Properties
    var fpc: FloatingPanelController!
    var myFloatingPanelController: FloatingPannelViewController!
    private let viewModel = HomeViewModel()
    private let disposeBag = DisposeBag()
    private var selectedIndex: IndexPath?
    var previousSelectedModel: AvatarResult?
    var currentAvatarId = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customUI()
        setFloatingpanel()
        setUpUserData()
        setCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    // MARK: - Custom Methods
    private func customUI() {
        progressBar.layer.cornerRadius = 5
        
        progressBar.clipsToBounds = true
        progressBar.layer.borderWidth = 2
        
        progressBar.layer.sublayers![1].cornerRadius = 5
        progressBar.layer.sublayers![1].borderWidth = 2
        progressBar.subviews[1].clipsToBounds = true
        
        coinView.layer.cornerRadius = 14
        hangerButton.layer.cornerRadius = 22
        hangerButton.layer.borderWidth = 2
    }
    
    private func setUpUserData() {
        if let currentUserData = UserDataManager.shared.currentUserData {
            levelLabel.text = "Lv. \(currentUserData.userStat.level)"
            pointLabel.text = "\(currentUserData.userStat.point)"
            nameLabel.text = currentUserData.name
            currentAvatarId = currentUserData.avatarId
        } else {
            print("사용자 데이터 없음")
        }
    }
    
    private func setCollectionView() {
        avatarChooseCollectionView.delegate = self
        avatarChooseCollectionView.dataSource = nil
        
        viewModel.loadAvatars()
            .map { $0.result }
            .observe(on: MainScheduler.instance)
            .bind(to: avatarChooseCollectionView.rx.items(cellIdentifier: AvatarCollectionViewCell.identifier, cellType: AvatarCollectionViewCell.self)) { index, model, cell in
                cell.setAttributes(with: model, isSelected: false)
            }
            .disposed(by: disposeBag)
        
        viewModel.loadAvatars()
            .map { $0.result }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] result in
                if !result.isEmpty {
                    let initialIndex = IndexPath(row: (self?.currentAvatarId ?? 1) - 1, section: 0)
                    self?.avatarChooseCollectionView.selectItem(at: initialIndex, animated: false, scrollPosition: [])
                    self?.collectionView(self!.avatarChooseCollectionView, didSelectItemAt: initialIndex)
                    self?.selectedIndex = initialIndex
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func updateAvatarImageAndBackgroundColor(with model: AvatarResult) {
        let themeToImageName: [String: String] = [
            "신입 병아리": "main_chick",
            "눈을 반짝이는 곰돌이": "main_bear",
            "깜찍한 토끼": "main_rabbit"
        ]
        
        let themeToColorName: [String: String] = [
            "신입 병아리": "chick",
            "눈을 반짝이는 곰돌이": "bear",
            "깜찍한 토끼": "rabbit"
        ]
        
        if let imageName = themeToImageName[model.theme], let colorName = themeToColorName[model.theme] {
            mainAvatarImageView.image = UIImage(named: imageName)
            self.view.backgroundColor = UIColor(named: colorName)
        }
    }
    
    private func setFloatingpanel() {
        fpc = FloatingPanelController()
        fpc.delegate = self
        myFloatingPanelController = (storyboard?.instantiateViewController(withIdentifier: "FloatingPannelViewController") as! FloatingPannelViewController)
        
        fpc.layout = CustomFloatingPanelLayout()
        fpc.surfaceView.appearance.backgroundColor = .clear
        fpc.set(contentViewController: myFloatingPanelController)
        fpc.addPanel(toParent: self, animated: true)
    }
    
    
    @IBAction func showAvatarView(_ sender: Any) {
        self.tabBarController?.tabBar.isHidden = true
        hangerButton.isHidden = true
        fpc.hide(animated: false, completion: nil)
        avatarView.isHidden = false
        
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.tabBarController?.tabBar.isHidden = false
        hangerButton.isHidden = false
        fpc.show()
        avatarView.isHidden = true
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        // TODO: - 서버에 selectedIndex patch
        
        if let selectedIndex = selectedIndex {
            let selectedAvatarId = selectedIndex.row + 1
            
            if var currentUserData = UserDataManager.shared.currentUserData {
                currentUserData.avatarId = selectedAvatarId
                UserDataManager.shared.updateUser(user: currentUserData)
            }
        }
        
        self.tabBarController?.tabBar.isHidden = false
        hangerButton.isHidden = false
        fpc.show()
        avatarView.isHidden = true
    }
    
}

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard !viewModel.avatars.isEmpty else { return }
        
        if let previousIndex = selectedIndex,
           let previousSelectedCell = collectionView.cellForItem(at: previousIndex) as? AvatarCollectionViewCell {
            previousSelectedCell.setAttributes(with: viewModel.avatars[previousIndex.row], isSelected: false)
        }
        
        if let selectedCell = collectionView.cellForItem(at: indexPath) as? AvatarCollectionViewCell {
            let model = viewModel.avatars[indexPath.row]
            selectedCell.setAttributes(with: model, isSelected: true)
            viewModel.updateSelectedAvatar(at: indexPath.row)
            updateAvatarImageAndBackgroundColor(with: model)
        }
        
        selectedIndex = indexPath
    }
}

class CustomFloatingPanelLayout: FloatingPanelLayout {
    var position: FloatingPanelPosition {
        return .bottom
    }
    
    var initialState: FloatingPanelState {
        return .tip
    }
    
    var anchors: [FloatingPanelState : FloatingPanelLayoutAnchoring] {
        return [
            .full: FloatingPanelLayoutAnchor(absoluteInset: 80,  edge: .top, referenceGuide: .safeArea),
            .half: FloatingPanelLayoutAnchor(absoluteInset: 175, edge: .bottom, referenceGuide: .safeArea),
            .tip: FloatingPanelLayoutAnchor(absoluteInset: 175, edge: .bottom, referenceGuide: .safeArea)
        ]
    }
    
    func backdropAlpha(for state: FloatingPanelState) -> CGFloat {
        return state == .full ? 0.3 : 0.0
    }
}


