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
    @IBOutlet weak var avatarSpeechLabel: UILabel!
    
    // MARK: - Properties
    private var fpc: FloatingPanelController!
    private var myFloatingPanelController: FloatingPannelViewController!
    private let viewModel = HomeViewModel()
    private let disposeBag = DisposeBag()
    private var selectedIndex: IndexPath?
    private var previousSelectedModel: AvatarResult?
    private var currentAvatarId = 1
    private var progressPercent = 0.0
    private var lastSpokenAvatarId: Int?
    
    // MARK: - Life Cylcle
    override func viewDidLoad() {
        super.viewDidLoad()
        requestAuthorization()
        setFloatingpanel()
        setUpUserInitialData()
        bindAvatarCollectionView()
        customUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setUpUserInitialData()
        getAvatarSpeeches(avatarId: self.currentAvatarId)
    }
    
    // MARK: - Custom Methods
    private func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization (
            options: [.alert, .sound],
            completionHandler: { (granted, error) in
                if !granted {
                    self.showNotificationAlert()
                } else if granted {
                    self.getVersionCheck()
                }
            }
        )
    }
    
    private func getVersionCheck() {
        let currentVersion = AppVersionCheckManager.shared.getBuildVersion()
        viewModel.getVersionCheck(currentVersion: currentVersion)
            .subscribe(onSuccess: { response in
                guard let result = response.result else { return }
                if !result.isLatest {
                    self.showAlert(url: result.url!)
                }
            }, onFailure: { error in
                print(error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }
    
    func showAlert(url: String) {
        let sheet = UIAlertController(title: "최신 버전으로 업데이트가 가능합니다", message: "지금 업데이트 하시겠습니까?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "취소", style: .default)
        let okAction = UIAlertAction(title: "확인", style: .default) { _ in
            AppVersionCheckManager.shared.openAppStore(url: url)
            AppVersionCheckManager.shared.closeApp()
        }
        sheet.addAction(cancelAction)
        sheet.addAction(okAction)
        DispatchQueue.main.async {
            self.present(sheet, animated: true)
        }
    }
    
    private func showNotificationAlert() {
        let alertController = UIAlertController(title: "알림을 허용해 주세요", message: "알림을 허용하지 않으면 알람이 울리지 않을 수 있어요!", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "나중에", style: .default)
        let settingAction = UIAlertAction(title: "설정으로 이동", style: .default) {_ in
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
        alertController.addAction(cancelAction)
        alertController.addAction(settingAction)
        DispatchQueue.main.async {
            self.present(alertController, animated: true)
        }
    }
    
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
    
    private func setUpUserInitialData() {
        if let currentUserData = UserDataManager.shared.currentUserData {
            levelLabel.text = "Lv. \(currentUserData.userStat.level)"
            nameLabel.text = currentUserData.name
            currentAvatarId = currentUserData.avatarId
            progressPercent = currentUserData.userStat.expPercentage
        } else {
            print("사용자 데이터 없음")
        }
        
        lastSpokenAvatarId = currentAvatarId
        
        if let theme = ThemeManager.shared.themes.first(where: { $0.avatarId == currentAvatarId }) {
            mainAvatarImageView.image = UIImage(named: theme.mainAvatarName)
            self.view.backgroundColor = UIColor(named: theme.colorName)
        }
    }
    
    private func getAvatarSpeeches(avatarId: Int) {
        viewModel.getAvatarSpeech(avatarId: avatarId)
            .subscribe(onNext: { [weak self] speech in
                self?.avatarSpeechLabel.text = speech
            }, onError: { error in
                print("Error: \(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
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
                cell.setAttributes(with: model, isSelected: self.viewModel.selectedAvatar?.avatarId == model.avatarId)
            }
            .disposed(by: disposeBag)
        
        sharedAvatarsObservable
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] avatars in
                DispatchQueue.main.async { [weak self] in
                    self?.avatarChooseCollectionView.layoutIfNeeded()
                    self?.selectInitialAvatar()
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func selectInitialAvatar() {
        if let index = viewModel.avatars.firstIndex(where: { $0.avatarId == currentAvatarId }) {
            let indexPath = IndexPath(row: index, section: 0)
            avatarChooseCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
            collectionView(avatarChooseCollectionView, didSelectItemAt: indexPath)
            
            if let avatar = viewModel.avatars.first(where: { $0.avatarId == currentAvatarId }) {
                configureAvatars(with: avatar)
            }
        }
    }
    
    private func configureAvatars(with model: AvatarResult) {
        if let theme = ThemeManager.shared.themes.first(where: { $0.avatarId == model.avatarId }) {
            mainAvatarImageView.image = UIImage(named: theme.mainAvatarName)
            self.view.backgroundColor = UIColor(named: theme.colorName)
        }
    }
    
    private func configureAvatarSpeech(with model: AvatarResult) {
        if let theme = ThemeManager.shared.themes.first(where: { $0.avatarId == model.avatarId }) {
            self.avatarSpeechLabel.text = theme.defaultSpeech
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
    
    private func updateUIComponentsVisibility(isAvatarViewVisible: Bool) {
        self.tabBarController?.tabBar.isHidden = isAvatarViewVisible
        hangerButton.isHidden = isAvatarViewVisible
        if isAvatarViewVisible {
            fpc.hide()
        } else {
            fpc.show()
        }
        avatarView.isHidden = !isAvatarViewVisible
    }
    
    // MARK: - @
    @IBAction func showAvatarView(_ sender: Any) {
        updateUIComponentsVisibility(isAvatarViewVisible: true)
        if let currentUserData = UserDataManager.shared.currentUserData {
            currentAvatarId = currentUserData.avatarId
        }
        selectInitialAvatar()
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        updateUIComponentsVisibility(isAvatarViewVisible: false)
        if let currentUserData = UserDataManager.shared.currentUserData {
            let currentAvatarId = currentUserData.avatarId
            if let currentAvatarModel = viewModel.avatars.first(where: { $0.avatarId == currentAvatarId }) {
                configureAvatars(with: currentAvatarModel)
                configureAvatarSpeech(with: currentAvatarModel)
                if let newIndex = viewModel.avatars.firstIndex(where: { $0.avatarId == currentAvatarId }) {
                    let newIndexPath = IndexPath(row: newIndex, section: 0)
                    avatarChooseCollectionView.selectItem(at: newIndexPath, animated: false, scrollPosition: .centeredHorizontally)
                    selectedIndex = newIndexPath
                }
            }
        }
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
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
            previousSelectedCell.setAttributes(with: viewModel.avatars[previousIndex.row], isSelected: false)
        }
        
        if let selectedCell = collectionView.cellForItem(at: indexPath) as? AvatarCollectionViewCell {
            let model = viewModel.avatars[indexPath.row]
            selectedCell.setAttributes(with: model, isSelected: true)
            viewModel.updateSelectedAvatar(at: indexPath.row)
            configureAvatars(with: model)
            if lastSpokenAvatarId != model.avatarId {
                configureAvatarSpeech(with: model)
                lastSpokenAvatarId = model.avatarId
            }
        }
        selectedIndex = indexPath
    }
}
