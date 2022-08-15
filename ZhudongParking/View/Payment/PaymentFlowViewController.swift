//
//  PaymentFlowViewController.swift
//  ZhudongParking
//
//  Created by 陳Mike on 2022/7/19.
//

import UIKit

class PaymentFlowViewController: UIViewController {
    
    var initFlag = true
    var records = [String]()
    var plateNo = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = .clear
        view.isOpaque = false
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if initFlag {
            showView()
            initFlag = false
        }else{
            dismiss(animated: false)
        }
    }
    
    func showView(){
//        var records = [String]()
//        if let str = UserDefaults.standard.string(forKey: "plateRecord") {
//            let temp = str.split(separator: ",")
//            for c in temp {
//                records.append("\(c)")
//            }
//        }
        if records.isEmpty {
            let controller = InputPlateViewController()
            controller.delegate = self
            controller.setNavigationTitle("竹東停車幫幫忙")
            pushViewController(controller, animated: true)
        }else{
            let controller = UIStoryboard(name: "InputRecordTableViewController", bundle: nil).instantiateViewController(withIdentifier: "InputRecordTableViewController") as! InputRecordTableViewController
            controller.delegate = self
            controller.setNavigationTitle("竹東停車幫幫忙")
            controller.records = records
            pushViewController(controller, animated: true)
        }
    }
    
    func pushViewController(_ viewController: UIViewController, animated: Bool) {
        navigationController?.pushViewController(viewController, animated: animated)
    }
}

extension PaymentFlowViewController: InputPlateViewControllerDelegate {
    func nextAction(_ viewController: InputPlateViewController, plateNo: String) {
        showNeedPayPage(plateNo: plateNo)
        
//        var records = [String]()
//        if let str = UserDefaults.standard.string(forKey: "plateRecord") {
//            let temp = str.split(separator: ",")
//            for c in temp {
//                records.append("\(c)")
//            }
//            if records.contains(plateNo) {return}
//        }
//        records.append(plateNo)
//        let str = records.joined(separator: ",")
//        UserDefaults.standard.set(str, forKey: "plateRecord")
    }
    func showNeedPayPage(plateNo: String) {
        let controller = UIStoryboard(name: "NeedPayTableViewController", bundle: nil).instantiateViewController(withIdentifier: "NeedPayTableViewController") as! NeedPayTableViewController
        controller.delegate = self
        controller.setNavigationTitle("竹東停車幫幫忙")
        controller.plateNo = plateNo
        pushViewController(controller, animated: true)
        self.plateNo = plateNo
    }
}

extension PaymentFlowViewController: InputRecordTableViewControllerDelegate {
    func otherAction(_ viewController: InputRecordTableViewController) {
        let controller = InputPlateViewController()
        controller.delegate = self
        controller.setNavigationTitle("竹東停車幫幫忙")
        pushViewController(controller, animated: true)
    }
    func queryAction(_ viewController: InputRecordTableViewController, plateNo: String) {
        showNeedPayPage(plateNo: plateNo)
    }
}

extension PaymentFlowViewController: NeedPayTableViewControllerDelegate {
    func payAction(_ viewController: NeedPayTableViewController, bill: BillRecord) {
        let url = API_URL + URL_LOCKBILLE
        let parameters: [String:Any] = ["plate_number":plateNo, "bill_no":bill.serial]
        WebAPI.shared.request(urlStr: url, parameters: parameters, method: "GET") { isSuccess, data, error in
            if let data = data {
                print(String(data: data, encoding: .utf8))
            }
            self.showPayBillPage(bill: bill)
        }
    }
    func showPayBillPage(bill: BillRecord){
        guard let user = UserService.shared.user else{return}
        let parameters: [String:Any] = ["member_id":user.member_id, "amount":bill.amount, "plate_number":plateNo, "bill_no":bill.serial, "description":bill.description]
        var paraStr = ""
        for parameter in parameters {
            if paraStr != "" {
                paraStr += "&"
            }
            paraStr += "\(parameter.key)=\(parameter.value)"
        }
        let urlStr = PAY_URL + URL_PAYBILLE + "?" + paraStr
        guard let urlString = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: urlString) else{
            let alert = UIAlertController.simpleOKAlert(title: "", message: "繳費網址錯誤", buttonTitle: "確定", action: nil)
            present(alert, animated: true)
            return}
        UIApplication.shared.open(url, options: [:]) { _ in
            self.navigationController?.popToRootViewController(animated: false)
        }
    }
}

extension PaymentFlowViewController: PaymentTypeSelectViewControllerDelegate {
    func paymentSleectAction(_ viewController: PaymentTypeSelectViewController, type: PaymentType) {
        let controller = PayResultViewController()
        controller.setNavigationTitle("繳費")
        controller.isFailed = Int.random(in: 0...1) == 0
        controller.delegate = self
        pushViewController(controller, animated: true)
    }
}

extension PaymentFlowViewController: PayResultViewControllerDelegate {
    func payAction(_ viewController: PayResultViewController) {
        navigationController?.popViewController(animated: true)
    }
    func recordAction(_ viewController: PayResultViewController) {
        let controller = UIStoryboard(name: "PayRecordTableViewController", bundle: nil).instantiateViewController(withIdentifier: "PayRecordTableViewController") as! PayRecordTableViewController
        controller.setNavigationTitle("繳費紀錄")
        controller.delegate = self
        pushViewController(controller, animated: true)
    }
}

extension PaymentFlowViewController: PayRecordTableViewControllerDelegate {
    func detailAction(_ viewController: PayRecordTableViewController, record: PayRecord) {
        let controller = PayDetailViewController()
        controller.setNavigationTitle("繳費紀錄")
        controller.orderNo = record.bill_no
        pushViewController(controller, animated: true)
    }
}
