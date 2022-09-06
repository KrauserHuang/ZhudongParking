//
//  CouponAlertViewController.swift
//  ZhudongParking
//
//  Created by Tai Chin Huang on 2022/8/29.
//

import UIKit

class CouponAlertViewController: UIViewController {

    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    
    var coupon: Coupon?
    var user = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let user = UserService.shared.user {
            self.user = user
        }

        initView()
    }
    
    func initView() {
        
        backgroundView.backgroundColor = .black
        backgroundView.alpha = 0.6
        
        confirmButton.setTitle("確認", for: .normal)
        
        alertView.addCornerRadius(12)
        
        setupCoupon()
    }
    
    func setupCoupon() {
        guard let coupon = coupon else { return }
        titleLabel.text = ""
        nameLabel.text = coupon.coupon_name
        endDateLabel.text = "使用期限：\(coupon.coupon_enddate)"
        
        let content = "m_id=\(user.member_id)&coupon_no=\(coupon.coupon_no)"
        generateQRCode(content)
    }
    
    //    產生QRCode
    func generateQRCode(_ content: String) {
        let data = content.data(using: .isoLatin1, allowLossyConversion: false)
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setValue(data, forKey: "inputMessage")
        //        設定錯誤修正等級LMQH
        filter?.setValue("L", forKey: "inputCorrectionLevel")
        //        產生QRCode圖片
        guard let qrcodeImage = filter?.outputImage else {return}
        let scale = imageView.frame.width / qrcodeImage.extent.width
        //        將產生的QRCode放大
        let newImage = qrcodeImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        imageView.image = UIImage(ciImage: newImage)
    }
    
    @IBAction func confirmButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}
