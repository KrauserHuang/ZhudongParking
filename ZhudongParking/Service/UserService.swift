//
//  UserService.swift
//  ZhudongParking
//
//  Created by 陳Mike on 2022/7/15.
//

import Foundation
import UIKit.UIImage

class User {
    var mid = ""
    var member_id = ""
    var member_pwd = ""
    var member_name = ""
    var member_type = 0
    var member_gender = -1
    var member_email = ""
    var member_birthday = ""
    var member_address = ""
    var member_phone = ""
    var member_picture: UIImage?{
        didSet{
            self.renewPicture?()
        }
    }
    var member_points = ""
    var bonuswillget = ""
//    var member_usingpoints = ""
    var member_status = -1
    var recommend_code = ""
//    商店序號
    var member_sid = ""
    var renewPicture: (()->())?
    
}

class UserService {
//    singleton
    static let shared = UserService()
    var renewUser: (()->())?
    var renewShop: (()->())?
//    確認已進行過登入動作(不論成功與否)
    private(set) var didLogIn = false
    private(set) var user: User?
    var autoLogin = false {
        didSet{
            UserDefaults.standard.set(autoLogin, forKey: "autoLogin")
        }
    }
    var fcmToken = ""
    
    
    init(){
        autoLogin = UserDefaults.standard.bool(forKey: "autoLogin")
        guard autoLogin, let account = UserDefaults.standard.string(forKey: "account"), let password = UserDefaults.standard.string(forKey: "password") else{
            didLogIn = true
            return}
        loadUser(id: account, pw: password)
    }
    
    private func loadUser(id: String, pw: String){
        printf("id:\(id),pw:\(pw)")
        let url = API_URL + URL_MEMBERINFO
        let parameter = "member_id=\(id)&member_pwd=\(pw)"
        WebAPI.shared.request(urlString: url, parameters: parameter) { isSuccess, data, error in
            print(#function)
            guard isSuccess, let data = data else {
                self.renewUser?()
                return
            }
            do{
                let results = try JSONSerialization.jsonObject(with: data, options: []) as! [[String: Any]]
                self.setUser(from: results.first ?? [:])
//                更新token
                if !self.didLogIn {
                    self.logIn(account: id, password: pw, forceLoad: false, completion: {_,_ in})
                }
            }catch{
                print(error)
                self.renewUser?()
            }
        }
    }
    private func setUser(from dict: [String: Any]){
        guard let mid = dict["mid"] as? String,
              let member_id = dict["member_id"] as? String,
              let member_pwd = dict["member_pwd"] as? String,
              let member_name = dict["member_name"] as? String
        else{
            self.renewUser?()
            return
        }
        let user = User()
        user.mid = mid
        user.member_id = member_id
        user.member_pwd = member_pwd
        user.member_name = member_name
//        以上變數必須有值，以下有預設值
        user.member_type = Int(dict["member_type"] as? String ?? "") ?? 0
        let member_totalpoints = Int(dict["member_totalpoints"] as? String ?? "") ?? 0
        let member_usingpoints = Int(dict["member_usingpoints"] as? String ?? "") ?? 0
        user.member_points = "\(member_totalpoints - member_usingpoints)"
        user.bonuswillget = dict["bonuswillget"] as? String ?? "0"
//        user.member_usingpoints = "\(member_usingpoints)"
        user.recommend_code = (dict["recommend_code"] as? String ?? "")
        user.member_gender = Int(dict["member_gender"] as? String ?? "") ?? user.member_gender
        user.member_email = (dict["member_email"] as? String ?? user.member_email)
        user.member_birthday = (dict["member_birthday"] as? String ?? user.member_birthday)
        user.member_address = (dict["member_address"] as? String ?? user.member_address)
        user.member_phone = (dict["member_phone"] as? String ?? user.member_phone)
        user.member_status = Int(dict["member_status"] as? String ?? "") ?? user.member_status
        user.member_sid = dict["member_sid"] as? String ?? ""
        
        if let member_picture = dict["member_picture"] as? String {
//            WebAPI.shared.requestImage(urlString: ROOT_URL + member_picture) { image in
//                self.user?.member_picture = image
//            }
        }
        self.user = user
        self.didLogIn = true
        renewUser?()
    }
    
    func reloadUser() {
        guard let user = user else{return}
        loadUser(id: user.member_id, pw: user.member_pwd)
    }
    
    func logIn(account: String, password: String, forceLoad: Bool = true, completion: @escaping (Bool, String)->()){
        guard account != "", password != "" else {
            completion(false, "帳密不可空白")
            return
        }
        let url = API_URL + URL_USERLOGIN
        let parameter = "member_id=\(account)&member_pwd=\(password)&FCM_Token=\(fcmToken)"
        WebAPI.shared.request(urlString: url, parameters: parameter) { isSuccess, data, error in
            if let data = data {
                printf(parameter)
                print(String(data: data, encoding: .utf8))
            }
            if isSuccess, forceLoad {
                UserDefaults.standard.set(account, forKey: "account")
                UserDefaults.standard.set(password, forKey: "password")
                self.loadUser(id: account, pw: password)
                self.renewUser = { completion(isSuccess, "") }
                return
            }
            var errorMsg = ""
            if let data = data, let results = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any], let msg = results["responseMessage"] as? String {
                errorMsg = msg
                if msg == "ID or password is wrong!" {
                    errorMsg = "帳號或密碼錯誤"
                }
            }
            completion(isSuccess, errorMsg)
        }
    }
    
    func logout(){
        if let user = user {
            let url = API_URL + URL_USERLOGOUT
            let parameter = "member_id=\(user.member_id)&member_pwd=\(user.member_pwd)"
            WebAPI.shared.request(urlString: url, parameters: parameter) { isSuccess, data, error in
                if let data = data {
                    print(String(data: data, encoding: .utf8))
                }
            }
        }
        user = nil
        UserDefaults.standard.removeObject(forKey: "account")
        UserDefaults.standard.removeObject(forKey: "password")
    }
    
    func signUp(_ newUser: User, completion: @escaping (Bool, String)->()){
        guard newUser.member_id != "", newUser.member_pwd != "", newUser.member_name != ""else {
            completion(false, "欄位不可空白")
            return
        }
        let url = API_URL + URL_USERREGISTER
        let parameters: [String: Any] = ["member_id":newUser.member_id, "member_pwd":newUser.member_pwd, "member_name":newUser.member_name, "member_email":newUser.member_email, "member_address":newUser.member_address]
        WebAPI.shared.request(urlStr: url, parameters: parameters) { isSuccess, data, error in
            if error != nil || !isSuccess {
                print(#function)
                print(error)
                print(data)
            }
            var errorMsg = ""
            if let data = data, let results = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any], let msg = results["responseMessage"] as? String {
                errorMsg = msg
            }
            completion(isSuccess, errorMsg)
        }
    }
    
    func editUser(_ newUser: User, completion: @escaping (Bool)->()) {
        guard let user = user else {return}
        let url = API_URL + URL_USEREDIT
        let parameter = "member_id=\(user.member_id)&" +
            "member_pwd=\(user.member_pwd)&" +
            "member_name=\(newUser.member_name)&" +
            "member_email=\(newUser.member_email)&" +
            "member_address=\(newUser.member_address)&"
        WebAPI.shared.request(urlString: url, parameters: parameter) { isSuccess, data, error in
            if isSuccess {
                self.loadUser(id: user.member_id, pw: user.member_pwd)
            }
            completion(isSuccess)
        }
    }
    
}

