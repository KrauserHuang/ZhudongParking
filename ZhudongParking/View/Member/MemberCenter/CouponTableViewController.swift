//
//  CouponTableViewController.swift
//  ZhudongParking
//
//  Created by 陳Mike on 2022/7/15.
//

import UIKit
import CoreImage.CIFilterBuiltins

class CouponTableViewController: UITableViewController {

    var couponList = [Coupon]() {
        didSet{
            tableView.reloadData()
        }
    }
    
    private var couponAlert = CouponAlert()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        將畫面下拉補足tabbar標籤的空缺
        view.frame.origin = CGPoint(x: 0, y: 44)
        
    }
    
    @objc func dismissAlert() {
        couponAlert.dismissAlert()
    }
    
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)

        if let QRFilter = CIFilter(name: "CIQRCodeGenerator") {
            QRFilter.setValue(data, forKey: "inputMessage")

            guard let QRImage = QRFilter.outputImage else { return nil }
            return UIImage(ciImage: QRImage)
        }
        return nil
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return couponList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CouponTableViewCell", for: indexPath) as! CouponTableViewCell
        cell.coupon = couponList[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let coupon = couponList[indexPath.row]
        // TODO: couponImage怎麼轉成QRCode
        if coupon.checkAvailable() == .Available {
//            couponAlert.showAlert(title: "",
//                                  couponName: coupon.coupon_name,
//                                  couponImage: coupon.coupon_picture,
//                                  couponEndDate: "使用期限：\(coupon.coupon_enddate)",
//                                  buttonTitle: "OK",
//                                  on: self)
            let vc = CouponAlertViewController()
            vc.coupon = coupon
            vc.modalPresentationStyle = .overFullScreen
            vc.modalTransitionStyle = .crossDissolve
            present(vc, animated: true)
        }
    }
}

class CouponTableViewCell: UITableViewCell {
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var descriptLabel: UILabel!
    @IBOutlet weak var limitLabel: UILabel!
    
    var coupon: Coupon? {
        didSet{
            setCouponView()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        borderView.layer.shadowOpacity = 0.5
        borderView.layer.shadowOffset = .init(width: 1, height: 1)
        borderView.layer.cornerRadius = 5
        setCouponView()
    }
    
    func setCouponView(){
//        descriptLabel?.text = coupon?.coupon_description
        descriptLabel?.text = coupon?.coupon_name
        limitLabel?.text = "兌換期限：" + (coupon?.coupon_enddate ?? "無")
    }
}
