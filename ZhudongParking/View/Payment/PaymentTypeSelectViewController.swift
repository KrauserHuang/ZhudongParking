//
//  PaymentTypeSelectViewController.swift
//  ZhudongParking
//
//  Created by 陳Mike on 2022/7/19.
//

import UIKit
protocol PaymentTypeSelectViewControllerDelegate: AnyObject {
    func paymentSleectAction(_ viewController: PaymentTypeSelectViewController, type: PaymentType)
}

class PaymentTypeSelectViewController: UIViewController {
    @IBOutlet weak var linePayView: UIView!
    @IBOutlet weak var jkoView: UIView!
    @IBAction func payTypeAction(_ sender: UIButton) {
        switch sender.tag {
        case 1:
            delegate?.paymentSleectAction(self, type: .LINE_PAY)
        case 2:
            delegate?.paymentSleectAction(self, type: .JKO_PAY)
        default:
            break
        }
    }
    
    weak var delegate: PaymentTypeSelectViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        linePayView.layer.cornerRadius = linePayView.frame.height / 2
        linePayView.layer.borderWidth = 0.5
        jkoView.layer.cornerRadius = jkoView.frame.height / 2
        jkoView.layer.borderWidth = 0.5
    }
    
}

enum PaymentType: String {
    case CREDIT_CARD = "信用卡"
    case JKO_PAY = "街口支付"
    case LINE_PAY = "LINE Pay"
    case TAIWAN_PAY = "台灣Pay"
    case APPLE_PAY = "APPLE PAY"
    case GOOGLE_PAY = "GOOGLE PAY"
}
