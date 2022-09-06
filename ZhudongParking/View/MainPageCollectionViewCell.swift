//
//  MainPageCollectionViewCell.swift
//  ZhudongParking
//
//  Created by Tai Chin Huang on 2022/8/17.
//

import UIKit

class MainPageCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var categoryLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        contentView.addShadow()
        outerView.addShadow(cornerRadius: 5, shadowOffset: CGSize(width: 2, height: -2))
//        outerView.addCornerRadius(10)
//        outerView.backgroundColor = .red
    }
    
    func configure(with model: MainPageItem) {
        imageView.image = UIImage(named: model.imageName)
        categoryLabel.text = model.title
        outerView.backgroundColor = model.backgroundColor
    }
}
