//
//  GroupSettingViewController.swift
//  TogetUp
//
//  Created by 이예원 on 2023/10/19.
//

import UIKit
import RxSwift
import RxCocoa

class GroupSettingViewController: UIViewController {
    // MARK: - UI Components
    @IBOutlet weak var groupInfoView: UIView!
    @IBOutlet weak var groupIconLabel: UILabel!
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var groupIntroLabel: UILabel!
    @IBOutlet weak var createdDateLabel: UILabel!
    
    @IBOutlet weak var alarmInfoView: UIView!
    @IBOutlet weak var alarmNameLabel: UILabel!
    @IBOutlet weak var alarmTimeLabel: UILabel!
    @IBOutlet weak var alarmDayLabel: UILabel!
    
    @IBOutlet weak var memberView: UIView!
    @IBOutlet weak var editGroupInfoButton: UIButton!
    @IBOutlet weak var inviteButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var memberCountLabel: UILabel!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    // MARK: - Properties
    private let viewModel = GroupSettingViewModel()
    private let disposeBag = DisposeBag()
    var roomId = 0
    var members: [User] = []
    var code = ""
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        customUI()
        getGroupDetail()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    
    
    
    // MARK: - Custom Method
    private func customUI() {
        self.navigationController?.navigationBar.tintColor = .black
        
        [groupInfoView, alarmInfoView, memberView].forEach {view in
            if let safeView = view {
                safeView.layer.cornerRadius = 12
                safeView.layer.borderWidth = 2
            }
        }
        editGroupInfoButton.layer.cornerRadius = 18.5
        editGroupInfoButton.layer.borderWidth = 2
        inviteButton.layer.cornerRadius = 18.5
        inviteButton.layer.borderWidth = 2
    }
    
    private func bindMembersTableView() {
        Observable.just(members)
            .bind(to: tableView.rx.items(cellIdentifier: MemberTableViewCell.identifier, cellType: MemberTableViewCell.self)) { (row, member, cell) in
                cell.setAttributes(model: member)
                if row != 0 {
                    cell.meButton.isHidden = true
                    cell.managerButton.isHidden = true
                }
                if row == 2 {
                    cell.profileImageView.image = UIImage(named: "chickProfile")
                } else if row == 3 {
                    cell.profileImageView.image = UIImage(named: "pandaProfile")
                }
            }
            .disposed(by: disposeBag)
    }
    
    private func getGroupDetail() {
        viewModel.getGroupDetail(roomId: self.roomId)
            .subscribe(onNext: { response in
                guard let result = response.result else { return }
                
                self.code = result.roomData.invitationCode
                self.groupIconLabel.text = result.roomData.icon
                self.groupNameLabel.text = result.roomData.name
                self.groupIntroLabel.text = result.roomData.intro
                self.createdDateLabel.text = "개설일: \(result.roomData.createdAt)"
                
                self.alarmNameLabel.text = result.alarmData.missionKr
                self.alarmTimeLabel.text = result.alarmData.alarmTime
                self.alarmDayLabel.text = result.alarmData.alarmDay
                
                self.memberCountLabel.text = "\(result.userList.count)"
                self.tableViewHeight.constant = CGFloat(56 * result.userList.count)
                self.members = result.userList
                self.bindMembersTableView()
            }, onError: { error in
                print("Error fetching group detail: \(error)")
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Custom Method
    @IBAction func inviteButtonTapped(_ sender: UIButton) {
        let activityViewController = UIActivityViewController(activityItems: [self.code], applicationActivities: nil)
        activityViewController.excludedActivityTypes = [.addToReadingList, .assignToContact, .saveToCameraRoll, .markupAsPDF, .addToHomeScreen]
        
        activityViewController.popoverPresentationController?.sourceView = sender
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    // MARK: - @
    @IBAction func deleteMember(_ sender: UIButton) {
        let alertController = UIAlertController(title: nil, message: "그룹에서 나가시겠습니까?", preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "나가기", style: .cancel) { [self] _ in
            viewModel.deleteMember(roomId: self.roomId)
                .subscribe(onNext: { response in
                    self.navigationController?.popToRootViewController(animated: true)
                }, onError: { error in
                    print("DeleteMember error occurred: \(error.localizedDescription)")
                })
                .disposed(by: disposeBag)
        }
        let cancelAction = UIAlertAction(title: "취소", style: .default, handler: nil)
        
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)

        present(alertController, animated: true)
    }
}
