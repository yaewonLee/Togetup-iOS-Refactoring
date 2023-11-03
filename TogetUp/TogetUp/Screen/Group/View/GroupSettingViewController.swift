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
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        getGroupDetail()
        customUI()
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
        let urlScheme = "TogetUp://"
        let url = URL(string: urlScheme)!
        
        let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        activityViewController.excludedActivityTypes = [.addToReadingList, .assignToContact, .saveToCameraRoll, .markupAsPDF]

        activityViewController.popoverPresentationController?.sourceView = sender
        self.present(activityViewController, animated: true, completion: nil)
    }

}
