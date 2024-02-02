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
    private let disposeBag = DisposeBag()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
