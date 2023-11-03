//
//  GroupBoardCollectionViewCell.swift
//  TogetUp
//
//  Created by 이예원 on 2023/10/21.
//

import UIKit
import Kingfisher

class GroupBoardCollectionViewCell: UICollectionViewCell {
    static let identifier = "GroupBoardCollectionViewCell"
    
    @IBOutlet weak var missionImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.missionImageView.layer.cornerRadius = 12
        self.missionImageView.layer.borderWidth = 2
        self.missionImageView.layer.borderColor = UIColor.black.cgColor
    }
    
    func setAttributes(with model: UserLog) {
        let imageUrl = URL(string: model.missionPicLink)
        let placeholderImage = UIImage(named: "missionDefault")
        if model.userCompleteType == "FAIL" {
            missionImageView.image = UIImage(named: "missionFail")
        } else if model.userCompleteType == "WAITING"{
            missionImageView.image = placeholderImage
        } else {
            missionImageView.kf.setImage(with: imageUrl, placeholder: placeholderImage)
        }
        nameLabel.text = model.userName
    }
}
