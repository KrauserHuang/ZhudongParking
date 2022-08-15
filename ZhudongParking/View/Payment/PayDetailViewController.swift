//
//  PayDetailViewController.swift
//  ZhudongParking
//
//  Created by 陳Mike on 2022/7/20.
//

import UIKit

class PayDetailViewController: UIViewController {
    @IBOutlet weak var payNoLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var payMoneyLabel: UILabel!
    @IBOutlet weak var payMethodLabel: UILabel!
    @IBOutlet weak var payStatusLabel: UILabel!
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var parkingPlaceLabel: UILabel!
    @IBOutlet weak var parkingTimeLabel: UILabel!
    @IBOutlet weak var parkingMoneyLabel: UILabel!

    var orderNo = ""
    var record: PayRecord? {
        didSet{
            setRecordView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        borderView.layer.borderWidth = 0.5
        borderView.layer.cornerRadius = 5
        fetchRecord()
    }
    
    func fetchRecord(){
        guard let user = UserService.shared.user else{return}
        let url = API_URL + URL_BILLINFOE
        let parameters: [String:Any] = ["member_id":user.member_id, "member_pwd":user.member_pwd, "bill_no":orderNo]
        WebAPI.shared.request(urlStr: url, parameters: parameters) { isSuccess, data, error in
            guard isSuccess, let data = data, let results = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]], let result = results.first else{return}
            self.record = .init(from: result)
        }
    }
    
    func setRecordView(){
        guard let record = record else{return}
        payNoLabel.text = record.bill_no
        timeLabel.text = record.bill_updated_at
        payMoneyLabel.text = record.bill_pay
        payMethodLabel.text = record.pay_type
        payStatusLabel.text = record.pay_status
        
        parkingPlaceLabel.text = "竹東鎮公所停車格"
        parkingTimeLabel.text = record.bill_date
        parkingMoneyLabel.text = "NT$" + record.bill_pay
        
    }
    
}
