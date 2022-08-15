//
//  PayResultViewController.swift
//  ZhudongParking
//
//  Created by 陳Mike on 2022/7/19.
//

import UIKit
protocol PayResultViewControllerDelegate: AnyObject {
    func payAction(_ viewController: PayResultViewController)
    func recordAction(_ viewController: PayResultViewController)
}

class PayResultViewController: UIViewController {
    @IBOutlet weak var resultImage: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var successRecordButton: UIButton!
    @IBOutlet weak var failView: UIView!
    @IBOutlet weak var failResultButton: UIButton!
    @IBOutlet weak var payButton: UIButton!
    @IBAction func recordAction(_ sender: Any) {
        delegate?.recordAction(self)
    }
    @IBAction func payAction(_ sender: Any) {
        delegate?.payAction(self)
    }
    
    weak var delegate: PayResultViewControllerDelegate?
    var isFailed = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        successRecordButton.backgroundColor = Theme.blueColor
        payButton.backgroundColor = Theme.blueColor
        failResultButton.layer.borderColor = Theme.blueColor.cgColor
        failResultButton.layer.borderWidth = 0.5
        
        if isFailed {
            failView.isHidden = false
            resultImage.image = UIImage(named: "fail")
            messageLabel.text = "訂單未成立，請重新付款！"
        }
    }
    
}
