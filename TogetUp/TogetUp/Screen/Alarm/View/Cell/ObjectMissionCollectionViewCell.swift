//
//  ObjectMissionCollectionViewCell.swift
//  TogetUp
//
//  Created by 이예원 on 2023/09/11.
//

import UIKit

class ObjectMissionCollectionViewCell: UICollectionViewCell {
    static let identifier = "ObjectMissionCollectionViewCell"
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = 12
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.black.cgColor
    }
    
    func setAttributes(with model: MissionObjectResList) {
        titleLabel.text = model.kr
        iconLabel.text = model.icon
    }
}
