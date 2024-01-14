//
//  GroupListViewController.swift
//  TogetUp
//
//  Created by 이예원 on 2023/08/18.
//

import UIKit
import RxSwift
import RxCocoa

class GroupListViewController: UIViewController, UIGestureRecognizerDelegate, UITextFieldDelegate {
    // MARK: - UI Components
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var inviteCodeView: UIView!
    @IBOutlet weak var inviteTextField: UITextField!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var okButton: UIButton!
    
    // MARK: - Properties
    private let viewModel = GroupListViewModel()
    private let disposeBag = DisposeBag()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setCollectionViewFlowLayout()
        setCollectionView()
        customUI()
        setTextFieldGesture()
        
        //  self.performSegue(withIdentifier: "toGroupBoardSegue", sender: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    // MARK: - Custom Method
    private func customUI() {
        inviteCodeView.layer.cornerRadius = 16
        inviteCodeView.layer.borderWidth = 2
        inviteTextField.layer.cornerRadius = 12
        inviteTextField.layer.borderWidth = 2
        cancelButton.layer.cornerRadius = 20
        cancelButton.layer.borderWidth = 2
        okButton.layer.cornerRadius = 20
        okButton.layer.borderWidth = 2
    }
    
    private func setCollectionView() {
        collectionView.delegate = nil
        collectionView.dataSource = nil
        
        viewModel.getGroupList()
            .map { $0.result.compactMap { $0 } }
            .bind(to: collectionView.rx.items(cellIdentifier: GroupListCollectionViewCell.identifier,
                                              cellType: GroupListCollectionViewCell.self)) { index, model, cell in
                cell.setAttributes(with: model)
            }
              .disposed(by: disposeBag)
        
        collectionView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                self?.collectionView.deselectItem(at: indexPath, animated: true)
                if let cell = self?.collectionView.cellForItem(at: indexPath) as? GroupListCollectionViewCell,
                   let roomId = cell.roomId {
                    self?.performSegue(withIdentifier: "toGroupBoardSegue", sender: roomId)
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func setTextFieldGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard(_:)))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toGroupBoardSegue", let destinationVC = segue.destination as? GroupBoardViewController, let roomId = sender as? Int {
            destinationVC.roomId = roomId
        }
    }
    
    private func setCollectionViewFlowLayout() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: collectionView.bounds.width - 40, height: 68)
        layout.minimumLineSpacing = 16
        collectionView.collectionViewLayout = layout
    }
    
    // MARK: - @
    @objc func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @IBAction func inviteButton(_ sender: Any) {
        inviteCodeView.isHidden = false
    }
    
    @IBAction func cancelInviteCodeButton(_ sender: Any) {
        inviteCodeView.isHidden = true
    }
    
    @IBAction func okButtonTapped(_ sender: Any) {
        let code = inviteTextField.text
        guard let vc = storyboard?.instantiateViewController(identifier: "GroupJoinViewController") as? GroupJoinViewController else { return }
        vc.code = code ?? ""
    }
}
