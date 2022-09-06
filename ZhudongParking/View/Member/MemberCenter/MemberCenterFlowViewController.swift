//
//  MemberCenterFlowViewController.swift
//  ZhudongParking
//
//  Created by 陳Mike on 2022/7/15.
//

import UIKit


protocol MemberCenterFlowViewControllerDelegate: AnyObject {
    func logoutAction(_ viewController: MemberCenterFlowViewController)
}

class MemberCenterFlowViewController: UIViewController {
    var initFlag = true
    weak var delegate: MemberCenterFlowViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        navigationItem.hidesBackButton = true
        self.view.backgroundColor = .clear
        self.view.isOpaque = false
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if initFlag {
            showView()
            initFlag = false
        }else{
            dismiss(animated: false)
        }
    }
    
    func showView(){
        let controller = UIStoryboard(name: "MemberCenterTableViewController", bundle: nil).instantiateViewController(withIdentifier: "MemberCenterTableViewController") as! MemberCenterTableViewController
        controller.delegate = self
        controller.setNavigationTitle("會員中心")
        pushViewController(controller, animated: true)
    }

    func pushViewController(_ viewController: UIViewController, animated: Bool) {
        navigationController?.pushViewController(viewController, animated: animated)
    }
}

extension MemberCenterFlowViewController: MemberCenterTableViewControllerDelegate {
    func memberInfoAction(_ controller: MemberCenterTableViewController) {
        let controller = MemberInfoViewController()
        controller.setNavigationTitle("會員資料")
        controller.delegate = self
        pushViewController(controller, animated: true)
    }
    
    func couponAction(_ controller: MemberCenterTableViewController) {
        RootWindow?.loadingAction()
        guard let user = UserService.shared.user else{return}
        let url = API_URL + URL_MYCOUPONLIST
        let parameters: [String:Any] = ["member_id":user.member_id, "member_pwd":user.member_pwd]
        WebAPI.shared.request(urlStr: url, parameters: parameters) { isSuccess, data, error in
            RootWindow?.finishLoading()
            guard isSuccess, let data = data, let results = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] else{return}
            var canuseList = [Coupon]()
            var usedList = [Coupon]()
            var outOfDateList = [Coupon]()
            for result in results {
                let coupon = Coupon(from: result)
                switch coupon.checkAvailable() {
                case .Available:
                    canuseList.append(coupon)
                case .OutDate:
                    outOfDateList.append(coupon)
                case .Used:
                    usedList.append(coupon)
                default:
                    break
                }
            }
            let tabBarController = OnTopTabBarController()
            let canUseController = UIStoryboard(name: "CouponTableViewController", bundle: nil).instantiateViewController(withIdentifier: "CouponTableViewController") as! CouponTableViewController
            canUseController.tabBarItem = UITabBarItem(title: "可兌換", image: nil, tag: 0)
            canUseController.couponList = canuseList
            let usedController = UIStoryboard(name: "CouponTableViewController", bundle: nil).instantiateViewController(withIdentifier: "CouponTableViewController") as! CouponTableViewController
            usedController.tabBarItem = UITabBarItem(title: "已兌換", image: nil, tag: 0)
            usedController.couponList = usedList
            let outOfDateController = UIStoryboard(name: "CouponTableViewController", bundle: nil).instantiateViewController(withIdentifier: "CouponTableViewController") as! CouponTableViewController
            outOfDateController.tabBarItem = UITabBarItem(title: "已過期", image: nil, tag: 0)
            outOfDateController.couponList = outOfDateList
            tabBarController.edgesForExtendedLayout = []
            tabBarController.setNavigationTitle("優惠券")
            tabBarController.viewControllers = [canUseController, usedController, outOfDateController]
            self.pushViewController(tabBarController, animated: true)
        }
    }
    
    func recordAction(_ controller: MemberCenterTableViewController) {
        let controller = UIStoryboard(name: "PayRecordTableViewController", bundle: nil).instantiateViewController(withIdentifier: "PayRecordTableViewController") as! PayRecordTableViewController
        controller.setNavigationTitle("繳費紀錄")
        controller.delegate = self
        pushViewController(controller, animated: true)
    }
    
    func userRuleAction(_ controller: MemberCenterTableViewController) {
        let controller = RuleTextViewController()
        controller.setNavigationTitle("使用者條款")
        controller.type = .UserRule
        pushViewController(controller, animated: true)
    }
    
    func qnaAction(_ controller: MemberCenterTableViewController) {
        let controller = RuleTextViewController()
        controller.setNavigationTitle("常見問題")
        controller.type = .QandA
        pushViewController(controller, animated: true)
    }
    
    func logoutAction(_ controller: MemberCenterTableViewController) {
        delegate?.logoutAction(self)
    }
    
    func accountDeletionAction(_ controller: MemberCenterTableViewController) {
        Alert.showMessage(title: "注意", msg: "我們將刪除您的帳號", vc: controller) {
            self.delegate?.logoutAction(self)
        }
    }
}

extension MemberCenterFlowViewController: PayRecordTableViewControllerDelegate {
    func detailAction(_ viewController: PayRecordTableViewController, record: PayRecord) {
        let controller = PayDetailViewController()
        controller.setNavigationTitle("繳費紀錄")
        controller.orderNo = record.bill_no
        pushViewController(controller, animated: true)
    }
}

extension MemberCenterFlowViewController: MemberInfoViewControllerDelegate {
    func toModifyAction(_ viewController: MemberInfoViewController) {
        let controller = MemberInfoViewController()
        controller.setNavigationTitle("會員資料修改")
        controller.isModify = true
        controller.delegate = self
        pushViewController(controller, animated: true)
    }
    
    func modifyAction(_ viewController: MemberInfoViewController, newUser: User) {
        
        navigationController?.popViewController(animated: true)
    }
}
