//
//  GroupListCollectionViewCell.swift
//  TogetUp
//
//  Created by 이예원 on 2023/10/12.
//

import UIKit

class GroupListCollectionViewCell: UICollectionViewCell {
    static let identifier = "GroupListCollectionViewCell"

    @IBOutlet weak var iconLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var missionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = 12
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.black.cgColor
    }
    
    func setAttributes(with model: GroupListResult) {
        iconLabel.text = model.icon
        nameLabel.text = model.name
        missionLabel.text = model.mission
    }
}
