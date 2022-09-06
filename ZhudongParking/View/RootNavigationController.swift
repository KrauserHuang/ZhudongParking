//
//  RootNavigationController.swift
//  ZhudongParking
//
//  Created by 陳Mike on 2022/7/15.
//

import UIKit

class RootNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let controller = TopPageViewController()
        controller.setNavigationTitle("竹東停車幫幫忙")
        controller.delegate = self
        viewControllers = [controller]
        
        let memberBtn = UIBarButtonItem(image: UIImage(named: "member")?.imageResized(to: CGSize(width: 35, height: 35)), style: .plain, target: self, action: #selector(memberAction))
        memberBtn.tintColor = .black
        controller.navigationItem.rightBarButtonItem = memberBtn
        if #available(iOS 15, *) {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = Theme.blueColor
            appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
    }
    
    @objc func memberAction(){
        if UserService.shared.user == nil {
            let controller = LogInFlowViewController()
            controller.setNavigationTitle("竹東停車幫幫忙")
            controller.delegate = self
            let navi = UINavigationController(rootViewController: controller)
            navi.modalPresentationStyle = .overFullScreen
            present(navi, animated: false)
        }else{
            let controller = MemberCenterFlowViewController()
            controller.setNavigationTitle("竹東停車幫幫忙")
            controller.delegate = self
            let navi = UINavigationController(rootViewController: controller)
            navi.modalPresentationStyle = .overFullScreen
            present(navi, animated: false)
        }
    }
    
    
}
extension RootNavigationController: LogInFlowViewControllerDelegate {
    func loginAction(_ viewController: LogInFlowViewController) {
        let controller = MemberCenterFlowViewController()
        controller.setNavigationTitle("竹東停車幫幫忙")
        controller.delegate = self
        let navi = UINavigationController(rootViewController: controller)
        navi.modalPresentationStyle = .overFullScreen
        dismiss(animated: false) {
            self.present(navi, animated: false)
        }
    }
    func adminLoginAction(_ viewController: LogInFlowViewController) {
        let vc = AdminMainPageViewController()
        vc.setNavigationTitle("店長核銷")
        vc.delegate = self
        let navi = UINavigationController(rootViewController: vc)
        navi.modalPresentationStyle = .overFullScreen
        dismiss(animated: false) {
            self.present(navi, animated: false)
        }
    }
}
extension RootNavigationController: MemberCenterFlowViewControllerDelegate {
    func logoutAction(_ viewController: MemberCenterFlowViewController) {
        UserService.shared.logout()
        let controller = LogInFlowViewController()
        controller.setNavigationTitle("竹東停車幫幫忙")
        controller.delegate = self
        let navi = UINavigationController(rootViewController: controller)
        navi.modalPresentationStyle = .overFullScreen
        dismiss(animated: false) {
            self.present(navi, animated: false)
        }
    }
}

extension RootNavigationController: TopPageViewControllerDelegate {
    func payAction(_ viewController: TopPageViewController) {
        guard let user = UserService.shared.user else{
            let alert = UIAlertController.simpleOKAlert(title: "", message: "請先登入會員", buttonTitle: "確認", action: nil)
            present(alert, animated: true)
            return}
        RootWindow?.loadingAction()
        let url = API_URL + URL_PLATENUMBERE
        let parameters: [String:Any] = ["member_id":user.member_id, "member_pwd":user.member_pwd]
        WebAPI.shared.request(urlStr: url, parameters: parameters) { isSuccess, data, error in
            RootWindow?.finishLoading()
            guard isSuccess, let data = data, let results = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] else{return}
            var list = [String]()
            for result in results {
                let plateNo = result["plateNo"] as? String ?? ""
                list.append(plateNo)
            }
            let controller = PaymentFlowViewController()
            controller.setNavigationTitle("竹東停車幫幫忙")
            controller.records = list
            let navi = UINavigationController(rootViewController: controller)
            navi.modalPresentationStyle = .overFullScreen
            self.present(navi, animated: false)
        }
    }
    func parkingAction(_ viewController: TopPageViewController) {
        let controller = UIStoryboard(name: "ParkingInfoTableViewController", bundle: nil).instantiateViewController(withIdentifier: "ParkingInfoTableViewController") as! ParkingInfoTableViewController
        controller.setNavigationTitle("竹東停車幫幫忙")
        
        pushViewController(controller, animated: true)
    }
}
// MARK: - 店長核銷(第一頁)
extension RootNavigationController: AdminMainPageViewControllerDelegate {
    func didTappedScanButton(_ viewController: AdminMainPageViewController) {
        let vc = QRScanViewController()
        vc.delegate = self
        vc.modalPresentationStyle = .overFullScreen
        viewController.present(vc, animated: true, completion: nil)
    }
    
    func didTappedLogout(_ viewController: AdminMainPageViewController) {
//        viewController.dismiss(animated: true, completion: nil)
        UserService.shared.logout()
        let controller = LogInFlowViewController()
        controller.setNavigationTitle("竹東停車幫幫忙")
        controller.delegate = self
        let navi = UINavigationController(rootViewController: controller)
        navi.modalPresentationStyle = .overFullScreen
        dismiss(animated: false) {
            self.present(navi, animated: false)
        }
    }
}
//店長核銷(第二頁)
extension RootNavigationController: QRScanViewControllerDelegate {
    func didFinishedScan(_ viewController: QRScanViewController, content: String) {
        print(self, #function)
        print("content:\(content)")
        let couponContent = "ZhudongParking://?" + content
        let components = URLComponents(string: couponContent)
        
        guard let id = components?.searchValue(for: "m_id"),
              let couponNo = components?.searchValue(for: "coupon_no"),
              let user = UserService.shared.user else {
            viewController.captureSession.startRunning()
            return
        }
        AdminService.shared.applyCoupon(id: user.member_id,
                                        pwd: user.member_pwd,
                                        no: couponNo) { success, response in

            guard success else {
                let errorMsg = response as! String
                Alert.showMessage(title: "", msg: errorMsg, vc: self) {
                    viewController.captureSession.startRunning()
                }
                return
            }

            let successMsg = response as! String
            Alert.showMessage(title: "", msg: successMsg, vc: self) {
                viewController.captureSession.startRunning()
                viewController.dismiss(animated: true)
            }
        }
    }
    
    func didTappedDismissButton(_ viewController: QRScanViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
}
