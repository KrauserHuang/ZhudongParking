//
//  CouponAlert.swift
//  ZhudongParking
//
//  Created by Tai Chin Huang on 2022/8/24.
//

import UIKit
import SnapKit

class CouponAlert {
    
    struct Constant {
        static let backgroundAlphaTo: CGFloat = 0.6 //動畫要到達的
        
    }
    
    private let titleLabel = String()
    
    private let backgroundView: UIView = { //建立底層背景
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0 //alpha要從初始0~0.6(動畫結束)
        return view
    }()
    
    private let alertView: UIView = { //建立alertView實體
       let view = UIView()
        view.backgroundColor = .white
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 12
        return view
    }()
    
    private var myTargetView: UIView?
    private var couponName: String?
    
    func showAlert(title: String = "會員註冊禮",
                   couponName: String,
                   couponImage: String,
                   couponEndDate: String,
                   buttonTitle: String = "請至會員中心-優惠券查看",
                   on viewController: UIViewController) { //呈現整個CouponAlert
        guard let targetView = viewController.view else { return }
        
        myTargetView = targetView
        
        backgroundView.frame = targetView.bounds //放入CouponAlert背景
        targetView.addSubview(backgroundView)
        
        alertView.frame = CGRect(x: 50,
                                 y: -300,
                                 width: targetView.frame.size.width - 100,
                                 height: 350)
        targetView.addSubview(alertView)
        
        let titleLabel = UILabel(frame: CGRect(x: 0, //標題
                                               y: 0,
                                               width: alertView.frame.size.width,
                                               height: 50))
        titleLabel.text = title
        titleLabel.textAlignment = .center
        alertView.addSubview(titleLabel)
        
        let couponNameLabel = UILabel(frame: CGRect(x: 0, //coupon名稱
                                                    y: titleLabel.frame.size.height,
                                                    width: alertView.frame.size.width,
                                                    height: 50))
        self.couponName = couponName
        couponNameLabel.text = couponName
        couponNameLabel.textAlignment = .center
        couponNameLabel.numberOfLines = 0
        alertView.addSubview(couponNameLabel)
        
        let couponImageView = UIImageView(frame: CGRect(x: (alertView.frame.size.width - 150) / 2, //coupon圖片
                                                        y: titleLabel.frame.size.height + couponNameLabel.frame.size.height,
                                                        width: 150,
                                                        height: 150))
//    width: alertView.frame.size.width - 100,
//    height: alertView.frame.size.width - 100))
        couponImageView.image = UIImage(named: couponImage)
        couponImageView.contentMode = .scaleAspectFit
        
        alertView.addSubview(couponImageView)
        
        let couponEndDateLabel = UILabel(frame: CGRect(x: 0, //coupon兌換期限
                                                       y: titleLabel.frame.size.height + couponNameLabel.frame.size.height + couponImageView.frame.size.height,
                                                       width: alertView.frame.size.width,
                                                       height: 50))
        couponEndDateLabel.text = couponEndDate
        couponEndDateLabel.textAlignment = .center
        couponEndDateLabel.numberOfLines = 0
        alertView.addSubview(couponEndDateLabel)
        
        let button = UIButton(frame: CGRect(x: 0, //結束button
                                            y: alertView.frame.size.height - 50,
                                            width: alertView.frame.size.width,
                                            height: 50))
        button.setTitle(buttonTitle, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.addTarget(self,
                         action: #selector(dismissAlert),
                         for: .touchUpInside)
        alertView.addSubview(button)
        
        UIView.animate(withDuration: 0.25) {
            self.backgroundView.alpha = Constant.backgroundAlphaTo
        } completion: { done in
            if done {
                UIView.animate(withDuration: 0.25) {
                    self.alertView.center = targetView.center
                }
            }
        }
    }
    
    @objc func dismissAlert() { //收掉整個CouponAlert
        guard let targetView = myTargetView else { return }
        
        UIView.animate(withDuration: 0.25) {
            self.alertView.frame = CGRect(x: 50,
                                          y: targetView.frame.size.height,
                                          width: targetView.frame.size.width - 100,
                                          height: 350)
        } completion: { done in
            if done {
                UIView.animate(withDuration: 0.25) {
                    self.backgroundView.alpha = 0
                } completion: { done in
                    if done {
                        self.alertView.removeFromSuperview()
                        self.backgroundView.removeFromSuperview()
                    }
                }
            }
        }
    }
}
