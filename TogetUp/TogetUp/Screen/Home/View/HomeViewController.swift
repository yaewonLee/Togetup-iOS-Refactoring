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
    @IBOutlet weak var avatarView: UIView!
    @IBOutlet weak var hangerButton: UIButton!
    @IBOutlet weak var avatarChooseCollectionView: UICollectionView!
    @IBOutlet weak var mainAvatarImageView: UIImageView!
    
    // MARK: - Properties
    private var fpc: FloatingPanelController!
    private var myFloatingPanelController: FloatingPannelViewController!
    private let viewModel = HomeViewModel()
    private let disposeBag = DisposeBag()
    private var selectedIndex: IndexPath?
    private var previousSelectedModel: AvatarResult?
    private var currentAvatarId = 1
    private var progressPercent = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(#function)
        setFloatingpanel()
        setUpUserData()
        bindAvatarCollectionView()
        customUI()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    // MARK: - Custom Methods
    private func customUI() {
        progressBar.layer.cornerRadius = 5
        
        progressBar.clipsToBounds = true
        progressBar.layer.borderWidth = 2
        progressBar.progress = Float(self.progressPercent) * 0.01
        
        progressBar.layer.sublayers![1].cornerRadius = 5
        progressBar.layer.sublayers![1].borderWidth = 2
        progressBar.subviews[1].clipsToBounds = true
        
        hangerButton.layer.cornerRadius = 22
        hangerButton.layer.borderWidth = 2
    }
    
    private func setUpUserData() {
        if let currentUserData = UserDataManager.shared.currentUserData {
            levelLabel.text = "Lv. \(currentUserData.userStat.level)"
            nameLabel.text = currentUserData.name
            currentAvatarId = currentUserData.avatarId
            progressPercent = currentUserData.userStat.expPercentage
        } else {
            print("사용자 데이터 없음")
        }
    }
    
    private func bindAvatarCollectionView() {
        avatarChooseCollectionView.delegate = self
        avatarChooseCollectionView.dataSource = nil
        let sharedAvatarsObservable = viewModel.loadAvatars()
            .map { $0.result }
            .share(replay: 1, scope: .whileConnected)
        
        sharedAvatarsObservable
            .map { $0 ?? [] }
            .bind(to: avatarChooseCollectionView.rx.items(cellIdentifier: AvatarCollectionViewCell.identifier, cellType: AvatarCollectionViewCell.self)) { index, model, cell in
                cell.setAttributes(with: model, isSelected: self.viewModel.selectedAvatar?.avatarId == model.avatarId, unlockLevel: model.unlockLevel)
            }
            .disposed(by: disposeBag)
        
        sharedAvatarsObservable
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] avatars in
                DispatchQueue.main.async { [weak self] in
                    self?.avatarChooseCollectionView.layoutIfNeeded()
                    self?.selectInitialAvatar(from: avatars ?? [])
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func selectInitialAvatar(from avatars: [AvatarResult]) {
        if let index = avatars.firstIndex(where: { $0.avatarId == currentAvatarId }) {
            let indexPath = IndexPath(row: index, section: 0)
            avatarChooseCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
            collectionView(avatarChooseCollectionView, didSelectItemAt: indexPath)
            
            if let avatar = avatars.first(where: { $0.avatarId == currentAvatarId }) {
                updateAvatarImageAndBackgroundColor(with: avatar)
            }
        }
    }
    
    private func selectInitialAvatarIfNeeded() {
        let avatars = viewModel.avatars
        if let index = avatars.firstIndex(where: { $0.avatarId == currentAvatarId }) {
            let indexPath = IndexPath(row: index, section: 0)
            avatarChooseCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
            collectionView(avatarChooseCollectionView, didSelectItemAt: indexPath)
        }
    }
    
    private func updateAvatarImageAndBackgroundColor(with model: AvatarResult) {
        let themeToImageName: [String: String] = [
            "신입 병아리": "main_chick",
            "눈을 반짝이는 곰돌이": "main_bear",
            "깜찍한 토끼": "main_rabbit",
            "먹보 판다": "main_panda",
            "비 오는날 강아지": "main_puppy",
            "철학자 너구리": "main_racoon"
        ]
        
        let themeToColorName: [String: String] = [
            "신입 병아리": "chick",
            "눈을 반짝이는 곰돌이": "bear",
            "깜찍한 토끼": "rabbit",
            "먹보 판다": "panda",
            "비 오는날 강아지": "puppy",
            "철학자 너구리": "racoon"
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
    
    private func showErrorAlertAndDismiss(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default) { _ in
            self.presentingViewController?.dismiss(animated: true)
        }
        alert.addAction(okAction)
        present(alert, animated: true)
    }
    
    @IBAction func showAvatarView(_ sender: Any) {
        self.tabBarController?.tabBar.isHidden = true
        hangerButton.isHidden = true
        fpc.hide(animated: false, completion: nil)
        avatarView.isHidden = false
        
        selectInitialAvatarIfNeeded()
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.tabBarController?.tabBar.isHidden = false
        hangerButton.isHidden = false
        fpc.show()
        avatarView.isHidden = true
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        print(selectedIndex?.row)
        viewModel.changeAvatar(avatarId: (selectedIndex?.row ?? 0) + 1)
            .subscribe(onSuccess: { [weak self] result in
                switch result {
                case .success:
                    if var currentUserData = UserDataManager.shared.currentUserData {
                        currentUserData.avatarId = (self?.selectedIndex?.row ?? 0) + 1
                        UserDataManager.shared.updateHomeData(data: currentUserData)
                    }
                    
                    self?.tabBarController?.tabBar.isHidden = false
                    self?.hangerButton.isHidden = false
                    self?.fpc.show()
                    self?.avatarView.isHidden = true
                case .failure(_):
                    self?.showErrorAlertAndDismiss(message: "잠시후 다시 시도해주세요")
                }
            })
            .disposed(by: disposeBag)
        
        
    }
}

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard !viewModel.avatars.isEmpty else {
            print("viewModel.avatars are empty")
            return
        }
        if let previousIndex = selectedIndex,
           let previousSelectedCell = collectionView.cellForItem(at: previousIndex) as? AvatarCollectionViewCell {
            previousSelectedCell.setAttributes(with: viewModel.avatars[previousIndex.row], isSelected: false, unlockLevel: viewModel.avatars[previousIndex.row].unlockLevel)
        }
        
        if let selectedCell = collectionView.cellForItem(at: indexPath) as? AvatarCollectionViewCell {
            let model = viewModel.avatars[indexPath.row]
            selectedCell.setAttributes(with: model, isSelected: true, unlockLevel: model.unlockLevel)
            viewModel.updateSelectedAvatar(at: indexPath.row)
            updateAvatarImageAndBackgroundColor(with: model)
        }
        selectedIndex = indexPath
    }
}
