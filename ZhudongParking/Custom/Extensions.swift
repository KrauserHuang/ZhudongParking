//
//  Extensions.swift
//
//  Created by 陳昱宏 on 2021/1/4.
//

import Foundation
import UIKit

extension UIView {
//    設定圓角
    func roundCorners(radius: CGFloat, maskedCorners: CACornerMask? = nil){
        self.layer.cornerRadius = radius
        self.clipsToBounds = true
        if let mask = maskedCorners {
            self.layer.maskedCorners = mask
        }
    }
}

extension UITableView {
//    動畫reloadData
    func reloadDataSmoothly() {
        UIView.setAnimationsEnabled(false)
        CATransaction.begin()

        CATransaction.setCompletionBlock {
            UIView.setAnimationsEnabled(true)
        }

        reloadData()
        beginUpdates()
        endUpdates()

        CATransaction.commit()
    }
}

extension UIImage {
//    重設Size
    func imageResized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
//    將layer畫成UIImage
    static func layerImage(from layer: CALayer) -> UIImage {
        UIGraphicsBeginImageContext(layer.frame.size)

        layer.render(in: UIGraphicsGetCurrentContext()!)

        let outputImage = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()

        return outputImage!
    }
//    畫tintColor
    func tinted(with color: UIColor, isOpaque: Bool = false) -> UIImage? {
        let format = imageRendererFormat
        format.opaque = isOpaque
        return UIGraphicsImageRenderer(size: size, format: format).image { _ in
            color.set()
            withRenderingMode(.alwaysTemplate).draw(at: .zero)
        }
    }
//    產生QRCode
    static func generateQRCode(str: String, size: CGSize) -> UIImage? {
        let data = str.data(using: .utf8, allowLossyConversion: false)
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setValue(data, forKey: "inputMessage")
//        設定錯誤修正等級LMQH
        filter?.setValue("L", forKey: "inputCorrectionLevel")
//        產生QRCode圖片
        guard let qrcodeImage = filter?.outputImage else {return nil}
        let scale = size.width / qrcodeImage.extent.width
//        將產生的QRCode放大
        let newImage = qrcodeImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        return UIImage(ciImage: newImage)
    }
    
    func grayScaleImage() -> UIImage {
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let width =  Int(self.size.width)
        let height = Int(self.size.height)
        let context = CGContext(data: nil, width: width, height: height,bitsPerComponent: 8,bytesPerRow: 0, space: colorSpace, bitmapInfo: CGBitmapInfo().rawValue)!
        
        context.draw(cgImage!, in: CGRect(origin: .zero, size: size))
        let imageRef = context.makeImage()
        let newImage = UIImage(cgImage: imageRef!)
        return newImage
    }
}

extension UINavigationController {

    public func pushViewController(_ viewController: UIViewController, animated: Bool, completion: @escaping (() -> Void)) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        pushViewController(viewController, animated: animated)
        CATransaction.commit()
    }
    
    public func popViewController(animated: Bool, completion: @escaping (() -> Void)) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        popViewController(animated: animated)
        CATransaction.commit()
    }
    
    public func popToRootViewController(animated: Bool, completion: @escaping (() -> Void)) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        popToRootViewController(animated: animated)
        CATransaction.commit()
    }
}

extension UIViewController {
    func setNavigationTitle(_ title: String, backButtonTitle: String = "") {
        self.title = title
        navigationItem.backButtonTitle = backButtonTitle
    }
}

extension UIAlertController {
//    簡易版alert
    static func simpleOKAlert(title: String, message: String, buttonTitle: String, canCancel: Bool = false, action: ((UIAlertAction)->())?) -> UIAlertController {
        let alert = UIAlertController(title: title, message:message, preferredStyle:.alert)
        let action = UIAlertAction(title: buttonTitle, style: .default, handler: action)
        alert.addAction(action)
        if canCancel {
            let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            alert.addAction(cancel)
        }
        return alert
    }
}

extension UILabel {
//    文字設定底線
    func setUnderLine(){
        let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue, .foregroundColor: self.tintColor!] as [NSAttributedString.Key : Any]
        let underlineAttributedString = NSAttributedString(string: self.text!, attributes: underlineAttribute)
        self.attributedText = underlineAttributedString
    }
}

extension UITextField {
    func setBottomBorder() {
        self.borderStyle = .none
        self.layer.backgroundColor = UIColor.white.cgColor
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0.0
    }
}

extension UIBarButtonItem {
    func addSimpleBadge(){
        guard let view = self.value(forKey: "view") as? UIView else {return}
        let badgeLayer = CAShapeLayer()
        badgeLayer.fillColor = UIColor.white.cgColor
        badgeLayer.path = UIBezierPath(roundedRect: CGRect(x: view.frame.width - 20, y: 5, width: 10, height: 10), cornerRadius: 7).cgPath
        view.layer.addSublayer(badgeLayer)
    }
    
    func removeSimpleBadge(){
        guard let view = self.value(forKey: "view") as? UIView else {return}
        view.layer.sublayers?.last?.removeFromSuperlayer()
    }
}

extension URLComponents {
//    尋找特定值
    func searchValue(for key: String) -> String? {
        guard let items = queryItems else{return nil}
        for item in items {
            if item.name == key, let value = item.value {
                return value
            }
        }
        return nil
    }
}

extension Date {
    func countOfDaysInMonth() -> Int {
        let calendar = Calendar(identifier:Calendar.Identifier.gregorian)
        let range = calendar.range(of: .day, in: .month, for: self)
        return range?.count ?? 0
    }
}

extension Int {
//    回傳金額格式String
    func convertToMoney() -> String {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 0
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: self)) ?? ""
    }
}

extension String {
//    清除電話中特殊符號
    func purePhoneNumber() -> String {
        var result = ""
        for c in self.description {
            guard c != "(", c != ")", c != "-", c != " " else{continue}
            result.append(c)
        }
        return result
    }
    
//    func decryptAES() -> String {
//        return MyKeyChain.decryptString(self)
//    }
//    func encryptAES() -> String {
//        return MyKeyChain.encryptString(self)
//    }
}

extension Dictionary {
//    轉成[String: String]的格式
    func castToStrStr() -> [String: String] {
        var result: [String: String] = [:]
        for k in self.keys {
            if let key = k as? String, let value = self[k] as? String {
                result.updateValue(value, forKey: key)
            }
        }
        return result
    }
}

class Observe<T> {
    var value: T {
        didSet{
            valueChanged?(value)
        }
    }
    init(_ value: T) {
        self.value = value
    }
    var valueChanged: ((T)->())?
}

func printf(function: String = #function ,_ items: Any..., separator: String = " ", terminator: String = "\n") {
    print(function)
    for i in 0..<items.count {
        if i > 0 {
            print(separator, terminator: "")
        }
        print(items[i],terminator: "")
    }
    print(terminator, terminator: "")
}
