//
//  PayRecordModel.swift
//  ZhudongParking
//
//  Created by 陳Mike on 2022/7/29.
//

import Foundation

class PayRecord {
    let member_id: String
    let bill_amount: String
    let bonus_point: String
    let discount_amount: String
    let store_id: String
    let pay_type: String
    let bill_updated_at: String
    let bill_status: String
    let pay_status: String
    let bill_date: String
    let bill_pay: String
    let coupon_no: String
    let bid: String
    let plateNo: String
    let bill_no: String
    
    init(from dict: [String:Any]){
        let temp = dict.castToStrStr()
        
        bid             = temp["bid"] ?? ""
        bill_no         = temp["bill_no"] ?? ""
        bill_date       = temp["bill_date"] ?? ""
        store_id        = temp["store_id"] ?? ""
        member_id       = temp["member_id"] ?? ""
        coupon_no       = temp["coupon_no"] ?? ""
        discount_amount = temp["discount_amount"] ?? ""
        bill_pay        = temp["bill_pay"] ?? ""
        bonus_point     = temp["bonus_point"] ?? ""
        bill_status     = temp["bill_status"] ?? ""
        bill_updated_at = temp["bill_updated_at"] ?? ""
        bill_amount     = temp["bill_amount"] ?? ""
        plateNo         = temp["plateNo"] ?? ""
        pay_status      = (temp["pay_status"] == "1") ? "已繳費" : "未繳費"
        
        let pay_type = temp["pay_type"] ?? ""
        switch pay_type {
        case "-1":
            self.pay_type = "未付款"
        case "1":
            self.pay_type = "Linepay"
        case "2":
            self.pay_type = "街口支付"
        case "3":
            self.pay_type = "信用卡支付"
        default:
            self.pay_type = pay_type
        }
        
    }
}

class BillRecord {
    let serial: String
    let amount: String
    let date: String
    let due_date: String
    let description: String
    var isSelect = false
    
    init(from dict: [String:Any]) {
        let temp = dict.castToStrStr()
        
        serial = temp["serial"] ?? ""
        let amoutInt = dict["amount"] as? Int
        let amount = (amoutInt == nil) ? "" : "\(amoutInt!)"
        self.amount = temp["amount"] ?? amount
        date = temp["date"] ?? ""
        due_date = temp["due_date"] ?? ""
        description = temp["description"] ?? ""
    }
}
