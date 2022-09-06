//
//  LogInViewController.swift
//  ZhudongParking
//
//  Created by 陳Mike on 2022/7/15.
//

import UIKit
//會員中心_會員登入
protocol LogInViewControllerDelegate: AnyObject {
//    登入
    func loginAction(_ viewController: LogInViewController)
    //店長登入
    func adminLoginAction(_ viewController: LogInViewController)
//    註冊
    func signupAction(_ viewController: LogInViewController)
//    忘記密碼
    func forgotAction(_ viewController: LogInViewController)
//    會員條款
//    func userAction(_ viewController: LogInViewController)
//    隱私權條款
//    func privateAction(_ viewController: LogInViewController)
}
class LogInViewController: UIViewController {
    @IBOutlet weak var accountTextField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var forgotButton: UIButton!
    @IBOutlet weak var autoButton: UIButton!
    
    @IBAction func loginAction(_ sender: UIButton){
        self.view.endEditing(true)
        if (accountTextField.text == "" || passwordField.text == "") {
            let alert = UIAlertController.simpleOKAlert(title: "欄位不能空白", message: "", buttonTitle: "確認", action: nil)
            present(alert, animated: true, completion: nil)
            return
        }
//        let predicate = NSPredicate(format: "SELF MATCHES %@", "^09[0-9]{8}$")
//        guard predicate.evaluate(with: accountTextField.text) else {
//            let alert = UIAlertController.simpleOKAlert(title: "帳號格式錯誤", message: "", buttonTitle: "確認", action: nil)
//            present(alert, animated: true, completion: nil)
//            return}
        UserService.shared.autoLogin = autoButton.isSelected
        UserService.shared.logIn(account: accountTextField.text!, password: passwordField.text!) { isSuccess, message in
            if isSuccess {
                print(self, #function, "message:\(message)")
                if message.hasPrefix("Store") {
                    //代表是店長帳號登入成功
                    self.delegate?.adminLoginAction(self)
                } else {
                    self.delegate?.loginAction(self)
                }
            }else{
                let alert = UIAlertController.simpleOKAlert(title: "登入錯誤", message: message, buttonTitle: "確認", action: nil)
                self.present(alert, animated: true)
            }
        }
    }
    @IBAction func signupAction(_ sender: UIButton){
        delegate?.signupAction(self)
    }
    @IBAction func forgotAction(_ sender: UIButton){
        delegate?.forgotAction(self)
    }
    @IBAction func autoAction(_ sender: UIButton) {
        sender.isSelected.toggle()
    }
    
    weak var delegate: LogInViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setButtonUnderline(forgotButton)
        setAllRadius()
        setAllTextField()
        loginButton.backgroundColor = Theme.blueColor
        signupButton.setTitleColor(Theme.blueColor, for: .normal)
    }
    
    func setButtonUnderline(_ button: UIButton){
//        設定底線
        let font = UIFont(name: "Arial", size: 16)!
        let attributes = [NSMutableAttributedString.Key.font: font, NSMutableAttributedString.Key.foregroundColor: UIColor.black, NSMutableAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue] as [NSAttributedString.Key : Any]
        let string = NSMutableAttributedString(string: button.titleLabel?.text ?? "", attributes: attributes)
        button.setAttributedTitle(string, for: [])
    }
    func setAllRadius(){
        setRadius(accountTextField)
        setRadius(passwordField)
        setRadius(loginButton)
        setRadius(signupButton)
    }
    func setRadius(_ view: UIView){
        view.layer.cornerRadius = 5
        view.layer.borderWidth = 1
        if view.isKind(of: UIButton.self) {
            view.layer.borderColor = Theme.blueColor.cgColor
        }else{
            view.layer.borderColor = UIColor.lightGray.cgColor
        }
    }
    func setAllTextField(){
        setTextField(accountTextField)
        setTextField(passwordField)
        setAccessoryView(accountTextField)
    }
    func setTextField(_ textField: UITextField) {
        let insetView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField.frame.height))
        textField.leftView = insetView
        textField.leftViewMode = .always
        textField.delegate = self
    }
    func setAccessoryView(_ textField: UITextField) {
        let next = UIBarButtonItem(title: "下一格", style: .plain, target: self, action: #selector(nextText))
        let done = UIBarButtonItem(title: "完成", style: .done, target: self, action: #selector(doneText))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let tool = UIToolbar()
        tool.items = [done, flexSpace, next]
        tool.sizeToFit()
        textField.inputAccessoryView = tool
    }
    @objc func nextText(){
        passwordField.becomeFirstResponder()
    }
    @objc func doneText(){
        accountTextField.resignFirstResponder()
    }

}

extension LogInViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
