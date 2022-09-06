//
//  ButtonFactory.swift
//  ZhudongParking
//
//  Created by Tai Chin Huang on 2022/8/18.
//

import UIKit

func makeIconButton(imageName: String,
                    imageColor: UIColor? = nil,
                    imageWidth: Int,
                    imageHeight: Int,
                    backgroundColor: UIColor = .clear,
                    cornerRadius: CGFloat = 0,
                    borderWidth: CGFloat = 0,
                    borderColor: UIColor = .clear) -> UIButton {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    
    var image = UIImage(named: imageName)?.imageResized(to: CGSize(width: imageWidth,
                                                                   height: imageHeight))
    
    if let imageColor = imageColor {
        image = image?.withTintColor(imageColor)
    }
    
    button.setImage(image, for: .normal)
    
    button.backgroundColor = backgroundColor
    button.addCornerRadius(cornerRadius)
    button.layer.borderWidth = borderWidth
    button.layer.borderColor = borderColor.cgColor
    return button
}
