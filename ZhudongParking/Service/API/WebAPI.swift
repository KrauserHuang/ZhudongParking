//
//  WebAPI.swift
//
//  Created by 陳昱宏 on 2021/2/4.
//

import Foundation
import UIKit.UIImage
import CryptoKit

class WebAPI: NSObject {
//    singleton
    static let shared = WebAPI()
    private override init(){}
    let HttpSecretToken = ""
    
    /**
     parameters = [參數1名稱:參數1內容,參數2名稱:參數2內容,...]
     */
    func request(urlStr: String, parameters: [String: Any], method: String = "POST", useMd5: Bool = false, completion: @escaping(_ status: Bool, _ data: Data?, _ error: Error?)->()) {
        var paraStr = ""
        for parameter in parameters {
            if paraStr != "" {
                paraStr += "&"
            }
            paraStr += "\(parameter.key)=\(parameter.value)"
        }
        self.request(urlString: urlStr, parameters: paraStr, method: method, useMd5: useMd5, completion: completion)
    }
    
    /**
     Request function support parameters with UIImage use PNG or JPG
     */
    func requestUploadImageBase64(urlString: String, parameters: [String: Any], usePng: Bool, completion: @escaping(_ status: Bool, _ data: Data?, _ error: Error?)->()) {
        var paraStr = ""
        for parameter in parameters {
            if paraStr != "" {
                paraStr += "&"
            }
            if usePng, let image = parameter.value as? UIImage, let valueData = image.pngData() {
                paraStr += "\(parameter.key)=\(valueData.base64EncodedString())"
            }else if let image = parameter.value as? UIImage, let valueData = image.jpegData(compressionQuality: 0.8) {
                paraStr += "\(parameter.key)=\(valueData.base64EncodedString())"
            }else{
                paraStr += "\(parameter.key)=\(parameter.value)"
            }
        }
        self.request(urlString: urlString, parameters: paraStr, completion: completion)
    }
    
    /**
    parameters = "參數1名稱=參數1內容&參數2名稱=參數2內容..."
     */
    func request(urlString: String, parameters: String, method: String = "POST", useMd5: Bool = false, completion: @escaping(_ status: Bool, _ data: Data?, _ error: Error?)->()){
        var urlStr = urlString
        if method == "GET", parameters != "" {
            urlStr += "?" + parameters
        }
        guard let url = URL(string: urlStr) else {
            print("rulError:\(urlString)")
            DispatchQueue.main.async {
                completion(false, nil, nil)
            }
            return
        }
        var request = URLRequest(url: url)
//        預設為GET，POST需再設定
        if method == "POST" {
            request.httpMethod = "POST"
            request.httpBody = parameters.data(using: .utf8)
        }
        if useMd5 {
            if #available(iOS 13.0, *) {
                let dateformat = DateFormatter()
                dateformat.dateFormat = "yyyyMMdd"
                let headString = HttpSecretToken + dateformat.string(from: Date())
                let md5 = Insecure.MD5.hash(data: headString.data(using: .utf8)!)
                let md5Str = md5.map({ String(format: "%02hhx", $0) }).joined()
                request.addValue(md5Str, forHTTPHeaderField: "Authorization")
            }
        }
        
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: nil)
        session.dataTask(with: request) { data, response, error in
            if let err = error as NSError?, err.domain == NSURLErrorDomain {
                print("url:\(url)")
                print("errorCode:\(err.code)")
                print("description:\(err.localizedDescription)")
                DispatchQueue.main.async {
                    completion(false, data, error)
                }
                session.invalidateAndCancel()
                return
            }
            guard error == nil else{
                print("url:\(url)")
                print("error:\(error)")
                DispatchQueue.main.async {
                    completion(false, data, error)
                }
                session.invalidateAndCancel()
                return
            }
//            確認網路回傳狀態是否成功
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                print("url:\(url)")
                print("responseError:\(String(describing: (response as? HTTPURLResponse)?.statusCode))")
                DispatchQueue.main.async {
                    completion(false, data, error)
                }
                session.invalidateAndCancel()
                return
            }
//            確認回傳JSON的status是不是false
            if let data = data, let results = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any], results["status"] as? String == "false" {
                print("url:\(url)")
                print("errorData:\(String(describing: data))")
                print(results)
                DispatchQueue.main.async {
                    completion(false, data, error)
                }
                session.invalidateAndCancel()
                return
            }
            DispatchQueue.main.async {
                completion(true, data, error)
            }
            session.invalidateAndCancel()
        }.resume()
    }
    
    func requestImage(urlString: String, completion: @escaping((UIImage)->())) {
        guard let picUrl = URL(string: urlString) else{
            print("url:\(urlString)")
            print("urlError\(urlString)")
            return
        }
        let session = URLSession(configuration: .default)
        session.dataTask(with: picUrl) { data, URLResponse, error in
            if let error = error {
                print("url:\(urlString)")
                print(error.localizedDescription)
            }
            guard let data = data, let image = UIImage(data: data) else{
                print("url:\(urlString)")
                print("dataError")
                return
            }
            DispatchQueue.main.async {
                completion(image)
            }
        }.resume()
    }
    
    func requestWithBearer(urlString: String, parameters: String, method: String = "POST", bearerStr: String, completion: @escaping(_ status: Bool, _ data: Data?, _ error: Error?)->()){
        var urlStr = urlString
        if method == "GET", parameters != "" {
            urlStr += "?" + parameters
        }
        guard let url = URL(string: urlStr) else {
            print("rulError:\(urlString)")
            DispatchQueue.main.async {
                completion(false, nil, nil)
            }
            return
        }
        var request = URLRequest(url: url)
//        預設為GET，POST需再設定
        if method == "POST" {
            request.httpMethod = "POST"
            request.httpBody = parameters.data(using: .utf8)
        }
        request.addValue("Bearer " + bearerStr, forHTTPHeaderField: "Authorization")
        
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: nil)
        session.dataTask(with: request) { data, response, error in
            if let err = error as NSError?, err.domain == NSURLErrorDomain {
                print("url:\(url)")
                print("errorCode:\(err.code)")
                print("description:\(err.localizedDescription)")
                DispatchQueue.main.async {
                    completion(false, data, error)
                }
                session.invalidateAndCancel()
                return
            }
            guard error == nil else{
                print("url:\(url)")
                print("error:\(error)")
                DispatchQueue.main.async {
                    completion(false, data, error)
                }
                session.invalidateAndCancel()
                return
            }
//            確認網路回傳狀態是否成功
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                print("url:\(url)")
                print("responseError:\(String(describing: (response as? HTTPURLResponse)?.statusCode))")
                DispatchQueue.main.async {
                    completion(false, data, error)
                }
                session.invalidateAndCancel()
                return
            }
//            確認回傳JSON的status是不是false
            if let data = data, let results = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any], results["status"] as? String == "false" {
                print("url:\(url)")
                print("errorData:\(String(describing: data))")
                print(results)
                DispatchQueue.main.async {
                    completion(false, data, error)
                }
                session.invalidateAndCancel()
                return
            }
            DispatchQueue.main.async {
                completion(true, data, error)
            }
            session.invalidateAndCancel()
        }.resume()
    }
    
    
    /**
    parameters = [ 參數名稱: 參數內容 ]
    */
    func requestAndUploadImage(urlString: String, parameters: [String: Any], completion: @escaping(_ status: Bool, _ data: Data?, _ error: Error?)->()) {
        guard let url = URL(string: urlString) else{return}
        let postData = createMultipartData(with: parameters)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        let session = URLSession(configuration: .default)
        session.uploadTask(with: request, from: postData) { data, response, error in
            if let err = error as NSError?, err.domain == NSURLErrorDomain {
                print("url:\(url)")
                print("errorCode:\(err.code)")
                print("description:\(err.localizedDescription)")
                completion(false, data, error)
                session.invalidateAndCancel()
                return
            }
            guard error == nil else{
                print("error:\(error)")
                completion(false, data, error)
                session.invalidateAndCancel()
                return
            }
//            確認網路回傳狀態是否成功
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                print("responseError:\(String(describing: (response as? HTTPURLResponse)?.statusCode))")
                completion(false, data, error)
                session.invalidateAndCancel()
                return
            }
//            確認回傳JSON的status是不是false
            if let data = data, let results = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any], results["status"] as? String == "false" {
                print("errorData:\(String(describing: data))")
                print(results)
                completion(false, data, error)
                session.invalidateAndCancel()
                return
            }
            completion(true, data, error)
            session.invalidateAndCancel()
        }.resume()
    }
    private let boundary = "--Boundary-\(UUID().uuidString)"
    private func createMultipartData(with parameters: [String: Any]) -> Data {
        var returnData = Data()
        for parameter in parameters {
            let paraKey = parameter.key
            returnData.append("--\(boundary)\r\n".data(using: .utf8)!)
            returnData.append("Content-Disposition: form-data; name=\(paraKey)".data(using: .utf8)!)
            
            if let paraValue = parameter.value as? String {
                returnData.append("\r\n\r\n\(paraValue)\r\n".data(using: .utf8)!)
            }else if let paraValue = parameter.value as? UIImage {
                let imageData = paraValue.pngData()!
                let fileName = UUID().uuidString
                returnData.append("; filename=\"\(fileName).png\"\r\n".data(using: .utf8)!)
                returnData.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
                returnData.append(imageData)
                returnData.append("\r\n".data(using: .utf8)!)
            }
        }
        returnData.append("--\(boundary)--\r\n".data(using: .utf8)!)
        return returnData
    }
    
    func downloadFile(remoteURL url: URL, localURL fileUrl: URL, completion: (()->())?) {
        let request = URLRequest(url: url)
        let session = URLSession(configuration: .default)
        session.dataTask(with: request) { data, response, error in
            guard let data = data else{
                print(error)
                session.invalidateAndCancel()
                return}
            print(data)
            do {
                try data.write(to: fileUrl, options: .atomic)
            }catch{
                print(error)
            }
            session.invalidateAndCancel()
            completion?()
        }.resume()
    }
}

extension WebAPI: URLSessionDelegate {
//    比對SSL憑證
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard let serverTrust = challenge.protectionSpace.serverTrust, let cer = SecTrustGetCertificateAtIndex(serverTrust, 0), let cerPath = Bundle.main.path(forResource: "tripspot", ofType: "der"), let localCer = try? Data(contentsOf: URL(fileURLWithPath: cerPath)) else{
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        let policies = NSMutableArray()
        policies.add(SecPolicyCreateSSL(true, challenge.protectionSpace.host as CFString))
        SecTrustSetPolicies(serverTrust, policies)
        
        var result: SecTrustResultType = .invalid
        SecTrustEvaluate(serverTrust, &result)
        let isServerTrusted = (result == .unspecified || result == .proceed)
        
        let remoteCerficateData = SecCertificateCopyData(cer) as Data
        
        if isServerTrusted && remoteCerficateData == localCer {
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
        }else{
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
}
