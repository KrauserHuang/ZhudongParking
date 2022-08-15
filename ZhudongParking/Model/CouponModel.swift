//
//  CouponModel.swift
//  ZhudongParking
//
//  Created by 陳Mike on 2022/7/29.
//

import Foundation

class Coupon {
    let pid: String
    let mid: String
    let coupon_no: String
    let using_flag: String
    let using_date: String
    let coupon_id: String
    let coupon_name: String
    let coupon_type: String
    let coupon_description: String
    let coupon_startdate: String
    let coupon_enddate: String
    let coupon_status: String
//    滿額使用
    let coupon_rule: Int
//    折扣方式  1:折扣金額  2:折扣%
    let coupon_discount: String
//    折扣額
    let discount_amount: Int
    let coupon_storeid: String
    let coupon_for: String
    let coupon_picture: String
    
    init(from dict: [String: Any]) {
        let tempDict = dict.castToStrStr()
        
        self.coupon_name = tempDict["coupon_name"] ?? ""
        self.coupon_description = tempDict["coupon_description"] ?? ""
        self.coupon_startdate = tempDict["coupon_startdate"] ?? ""
        self.coupon_enddate = tempDict["coupon_enddate"] ?? ""
        self.coupon_rule = Int(tempDict["coupon_rule"] ?? "0") ?? 0
        self.coupon_discount = tempDict["coupon_discount"] ?? ""
        self.discount_amount = Int(tempDict["discount_amount"] ?? "0") ?? 0
        self.coupon_for = tempDict["coupon_for"] ?? ""
        self.mid = tempDict["mid"] ?? ""
        self.pid = tempDict["pid"] ?? ""
        self.coupon_status = tempDict["coupon_status"] ?? ""
        self.coupon_type = tempDict["coupon_type"] ?? ""
        self.using_flag = tempDict["using_flag"] ?? ""
        self.coupon_storeid = tempDict["coupon_storeid"] ?? ""
        self.coupon_no = tempDict["coupon_no"] ?? ""
        self.using_date = dict["using_date"] as? String ?? ""
        self.coupon_id = tempDict["coupon_id"] ?? ""
        self.coupon_picture = tempDict["coupon_picture"] ?? ""
        
    }
//    檢查coupon的可用性
    func checkAvailable()->CouponStatus {
        if self.using_flag == "1" {
            return .Used
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let start = dateFormatter.date(from: self.coupon_startdate)
        var end = dateFormatter.date(from: self.coupon_enddate)
        end?.addTimeInterval(60*60*24-1)
        if let start = start, let end = end, Date() < start || Date() > end {
            return .OutDate
        }
        if self.coupon_status == "2" {
            return .Unavailable
        }
        return .Available
    }
}

enum CouponStatus {
    case Available
    case Used
    case OutDate
    case Unavailable
}
