//
//  MemberTableViewCell.swift
//  TogetUp
//
//  Created by 이예원 on 2023/10/19.
//

import UIKit

class MemberTableViewCell: UITableViewCell {
    static let identifier = "MemberTableViewCell"

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var meButton: UIImageView!
    @IBOutlet weak var managerButton: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setAttributes(model: User) {
        nameLabel.text = model.userName
        levelLabel.text = "Lv.\(model.level)"
    }
}
