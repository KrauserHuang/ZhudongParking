//
//  AdminService.swift
//  ZhudongParking
//
//  Created by Tai Chin Huang on 2022/8/18.
//

import Foundation
import Alamofire
import SwiftyJSON

class AdminService {
    
    static let shared = AdminService()
    private init() {}
    
//    func applyCoupon(id: String, pwd: String, no: String, completion: @escaping () -> Void) {
//        let url = API_URL + URL_APPLYCOUPON
//        let parameters = [
//            "member_id": id,
//            "member_pwd": pwd,
//            "coupon_no": no
//        ]
//        WebAPI.shared.request(urlStr: url, parameters: parameters) { isSuccess, data, error in
//            guard isSuccess,
//                  let data = data else {
//                return
//            }
//        }
//    }
    func applyCoupon(id: String, pwd: String, no: String, completion: @escaping Completion) {
        let url = API_URL + URL_APPLYCOUPON
        let parameters = [
            "member_id": id,
            "member_pwd": pwd,
            "coupon_no": no
        ]
        let returnCode = ReturnCode.MALL_RETURN_SUCCESS.0
        
        AF.request(url, method: .post, parameters: parameters).response { response in
            
            guard response.value != nil else {
                let errorMsg = ""
                completion(false, errorMsg as AnyObject)
                return
            }
            
            let value = JSON(response.value!)
            print(#function)
            print(value)
            
            switch response.result {
                
            case .success:
                guard value["code"].stringValue == returnCode else {
                    let errorMsg = value["responseMessage"].stringValue
                    completion(false, errorMsg as AnyObject)
                    return
                }
                
                let message = value["responseMessage"].stringValue
                completion(true, message as AnyObject)
            case .failure:
                let errorMsg = value["responseMessage"].stringValue
                completion(false, errorMsg as AnyObject)
            }
        }
    }
}
