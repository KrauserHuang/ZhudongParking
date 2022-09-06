//
//  UIColor+Extension.swift
//  ZhudongParking
//
//  Created by Tai Chin Huang on 2022/9/1.
//

import UIKit
// MARK: - Basic rgb optimization
extension UIColor {
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat = 1.0) -> UIColor {
        return UIColor(red: red / 255, green: green / 255, blue: blue / 255, alpha: alpha)
    }
}
// MARK: - Hex string to UIColor
extension UIColor {
    static func convertHexStringToUIColor(hexString: String, alpha: CGFloat = 1.0) -> UIColor {
        // trimmingCharacters -> 修剪不必要的字元，.whitespacesAndNewlines -> 空白跟換行符號
        var hexStringFormatted = hexString.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        // hasPrefix -> 檢查hexStringFormatted是否有前綴(#)，有的話將它拿掉
        if hexStringFormatted.hasPrefix("#") {
            hexStringFormatted = String(hexStringFormatted.dropFirst())
        }
        assert(hexStringFormatted.count == 6, "Invalid hex code used.")
        // UInt64等同Int64，只是將範圍從負數移到整數去
        var rgbValue: UInt64 = 0
        // Scanner用於掃描指定字串，scanHexInt64掃描字符串前綴是否是0x/0X，並回傳true/false
        // 將0x後面符合16進制數的字符串轉化成10進制，可運用於UIColor關於16進制的轉化
        guard Scanner(string: hexStringFormatted).scanHexInt64(&rgbValue) else { return .gray }
        return UIColor(red: CGFloat((rgbValue & 0xFF00000) >> 16) / 255.0,
                       green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                       blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                       alpha: alpha)
    }
}
// MARK: - Customize gradient background
extension UIColor {
    static func theGradientBackground(backgroundView: UIView, hexColor1: String, hexColor2: String) -> UIView {
        // 先將hexColor轉換成對的格式
        let color1: UIColor = self.convertHexStringToUIColor(hexString: hexColor1)
        let color2: UIColor = self.convertHexStringToUIColor(hexString: hexColor2)
        // backgroundView加入gradientLayer
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = backgroundView.bounds
        gradientLayer.colors = [color1.cgColor, color2.cgColor]
        backgroundView.layer.insertSublayer(gradientLayer, at: 0)
        return backgroundView
    }
}
