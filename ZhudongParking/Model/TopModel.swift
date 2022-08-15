//
//  TopModel.swift
//  ZhudongParking
//
//  Created by 陳Mike on 2022/8/15.
//

import UIKit.UIImage

class Banner {
//    id
    let bid: String
    let banner_subject: String
    let banner_date: String
    let banner_enddate: String
    let banner_descript: String
//    廣告連結
    var banner_link: String
//    廣告圖
    var banner_picture: UIImage? {
        didSet{
            self.renewImage?()
            self.renewImage = nil
        }
    }
//    圖片更新用closuere
    var renewImage: (()->())?
    
    init(from dict: [String: Any]) {
        let tempDict = dict.castToStrStr()
        
        self.bid = tempDict["bid"] ?? ""
        self.banner_subject = tempDict["banner_subject"] ?? ""
        self.banner_descript = tempDict["banner_descript"] ?? ""
        self.banner_date = tempDict["banner_date"] ?? ""
        self.banner_enddate = tempDict["banner_enddate"] ?? ""
        let banner_link = tempDict["banner_link"] ?? ""
        if banner_link == "http://" {
            self.banner_link = ""
        }else{
            self.banner_link = banner_link
        }
//        讀取圖片
        let banner_picture = tempDict["banner_picture"] ?? ""
        WebAPI.shared.requestImage(urlString: PIC_URL + banner_picture) { image in
            self.banner_picture = image
        }
    }
}
