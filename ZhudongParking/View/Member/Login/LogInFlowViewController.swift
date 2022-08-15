//
//  LogInFlowViewController.swift
//  ZhudongParking
//
//  Created by 陳Mike on 2022/7/15.
//

import UIKit
protocol LogInFlowViewControllerDelegate: AnyObject {
    func loginAction(_ viewController: LogInFlowViewController)
}

class LogInFlowViewController: UIViewController {
    
    var initFlag = true
    var delegate: LogInFlowViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
        let controller = LogInViewController()
        controller.delegate = self
        controller.setNavigationTitle("註冊/登入")
        pushViewController(controller, animated: true)
    }
    
    func pushViewController(_ viewController: UIViewController, animated: Bool) {
        navigationController?.pushViewController(viewController, animated: animated)
    }
    
}

extension LogInFlowViewController: LogInViewControllerDelegate {
    func loginAction(_ viewController: LogInViewController) {
        delegate?.loginAction(self)
    }
    func signupAction(_ viewController: LogInViewController) {
        let controller = SignUpViewController()
        controller.setNavigationTitle("註冊")
        controller.delegate = self
        pushViewController(controller, animated: true)
    }
    func forgotAction(_ viewController: LogInViewController) {
        let controller = ForgotPasswordViewController()
        controller.setNavigationTitle("忘記密碼")
        controller.delegate = self
        pushViewController(controller, animated: true)
    }
}

extension LogInFlowViewController: SignUpViewControllerDelegate {
    func signupAction(_ viewController: SignUpViewController, newUser: User) {
        navigationController?.popToRootViewController(animated: true)
    }
    func ruleAction(_ viewController: SignUpViewController) {
        let controller = RuleTextViewController()
        controller.setNavigationTitle("使用者條款")
        controller.type = .UserRule
        pushViewController(controller, animated: true)
    }
}

extension LogInFlowViewController: ForgotPasswordViewControllerDelegate {
    func getVerifyAction(_ viewController: ForgotPasswordViewController, phone: String) {
        
    }
    func verifyAction(_ viewController: ForgotPasswordViewController, newUser: User, verifyCode: String) {
        
    }
}
