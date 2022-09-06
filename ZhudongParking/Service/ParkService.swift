//
//  ParkService.swift
//  ZhudongParking
//
//  Created by Tai Chin Huang on 2022/8/19.
//

import Foundation
import Alamofire
import SwiftyJSON

struct Plate {
    let platNo: String
}

class ParkService {
    
    static let shared = ParkService()
    private init() {}
    
    func getPlateNumberE(id: String, pwd: String, completion: @escaping Completion) {
        let url = API_URL + URL_PLATENUMBERE
        let parameters = [
            "member_id": id,
            "member_pwd": pwd
        ]
        let returnCode = ReturnCode.MALL_RETURN_SUCCESS.0
//        let returnCode = ReturnCode.RETURN_SUCCESS.0
        
        AF.request(url, method: .post, parameters: parameters).responseJSON { response in
            
            guard response.value != nil else {
                let errorMsg = "伺服器連線失敗"
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
                
                let datas = value["data"].arrayValue
                var plates: [Plate] = []
                for data in datas {
                    let plate = Plate(platNo: data["platNo"].stringValue)
                    plates.append(plate)
                }
                
                completion(true, plates as AnyObject)
            case .failure:
                let errorMsg = value["responseMessage"].stringValue
                completion(false, errorMsg as AnyObject)
            }
        }
        
    }
}
