//
//  Theme.swift
//  ZhudongParking
//
//  Created by 陳Mike on 2022/7/15.
//

import UIKit

typealias Completion = (_ success: Bool, _ response: AnyObject?) -> Void
typealias Handler = () -> Void

enum ReturnCode {
    static let RETURN_SUCCESS = (101, "取得成功")
    static let MALL_RETURN_SUCCESS = ("0x0200", "SUCCESS")
}

class Alert {

    class func comfirmBeforeLogout(title: String?, msg: String, vc: UIViewController, handler: @escaping Handler) {

        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)

        let confirm = UIAlertAction(title: "登出", style: .destructive) { (_) in
            handler()
        }
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)

        alert.addAction(confirm)
        alert.addAction(cancel)
        vc.present(alert, animated: true, completion: nil)
    }

    class func showConfirm(title: String?, msg: String, vc: UIViewController, handler: @escaping Handler) {

        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)

        let confirm = UIAlertAction(title: "確定", style: .default) { (_) in
            handler()
        }

        let cancel = UIAlertAction(title: "取消", style: .cancel) { (_) in

        }

        alert.addAction(confirm)
        alert.addAction(cancel)
        vc.present(alert, animated: true, completion: nil)
    }

    class func showLogout(title: String?, msg: String?, vc: UIViewController, handler: @escaping Handler) {

        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)

        let logout = UIAlertAction(title: "登出", style: .destructive) { (_) in
            handler()
        }

        let cancel = UIAlertAction(title: "取消", style: .cancel) { (_) in

        }

        alert.addAction(logout)
        alert.addAction(cancel)
        vc.present(alert, animated: true, completion: nil)
    }

    class func showMessage(title: String?, msg: String, vc: UIViewController, handler: Handler? = nil) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)

        let done = UIAlertAction(title: "確定", style: .default) { (_) in
            if handler != nil {
                handler!()
            }
        }
        alert.addAction(done)
        DispatchQueue.main.async {
            vc.present(alert, animated: true, completion: nil)
        }
    }

    class func showSecurityAlert(title: String?, msg: String, vc: UIViewController, handler: Handler? = nil) {

        let blurEffect = UIBlurEffect(style: .light)
        let blurVisualEffectView = UIVisualEffectView(effect: blurEffect)
        blurVisualEffectView.frame = vc.view.bounds

        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)

        let done = UIAlertAction(title: "確定", style: .default) { (_) in
            blurVisualEffectView.removeFromSuperview()
            if handler != nil {
                handler!()
            }
        }
        alert.addAction(done)

        vc.view.addSubview(blurVisualEffectView)
        vc.present(alert, animated: true, completion: nil)

    }

    class func accountDeletionAlert(title: String?, msg: String, vc: UIViewController, handler: Handler? = nil) {

        let blurEffect = UIBlurEffect(style: .light)
        let blurVisualEffectView = UIVisualEffectView(effect: blurEffect)
        blurVisualEffectView.frame = vc.view.bounds

        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let done = UIAlertAction(title: "確定", style: .destructive) { (_) in
            blurVisualEffectView.removeFromSuperview()
            if handler != nil {
                handler!()
            }
        }
        let cancel = UIAlertAction(title: "取消", style: .cancel) { (_) in
            blurVisualEffectView.removeFromSuperview()
        }
        alert.addAction(done)
        alert.addAction(cancel)

        vc.view.addSubview(blurVisualEffectView)
        vc.present(alert, animated: true, completion: nil)
    }
}

class Theme {
    static let blueColor = UIColor(red: 190/255, green: 212/255, blue: 225/255, alpha: 1)
    
}
