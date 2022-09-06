//
//  SignUpViewController.swift
//  ZhudongParking
//
//  Created by 陳Mike on 2022/7/15.
//

import UIKit
protocol SignUpViewControllerDelegate: AnyObject {
    func signupAction(_ viewController: SignUpViewController, newUser: User)
    func ruleAction(_ viewController: SignUpViewController)
}
class SignUpViewController: UIViewController {
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmpwTextField: UITextField!
    @IBOutlet weak var ruleButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var agreeButton: UIButton!
    @IBAction func visibleAction(_ sender: UIButton) {
        var textField: UITextField
        if sender.tag == 1 {
            textField = passwordTextField
        }else{
            textField = confirmpwTextField
        }
        if textField.isSecureTextEntry {
            sender.setImage(UIImage(named: "iconInvisible"), for: .normal)
        }else{
            sender.setImage(UIImage(named: "iconVisible"), for: .normal)
        }
        textField.isSecureTextEntry.toggle()
    }
    @IBAction func agreeAction(_ sender: UIButton) {
        sender.isSelected.toggle()
    }
    @IBAction func signupAction(_ sender: Any) {
        //欄位都不可留白
        if(nameTextField.text == "" || emailTextField.text == "" || phoneTextField.text == "" || passwordTextField.text == "" || !agreeButton.isSelected){
            let alert = UIAlertController.simpleOKAlert(title: "", message: "欄位不可空白", buttonTitle: "確認", action: nil)
            present(alert, animated: true, completion: nil)
            return
        }
        //驗證email
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}")
        guard emailPredicate.evaluate(with: emailTextField.text) else {
            let alert = UIAlertController.simpleOKAlert(title: "", message: "信箱格式錯誤，請重新輸入", buttonTitle: "確認", action: nil)
            present(alert, animated: true, completion: nil)
            return}
        //手機號碼驗證
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", "^09[0-9]{8}$")
        guard phonePredicate.evaluate(with: phoneTextField.text) else{
            let alert = UIAlertController.simpleOKAlert(title: "", message: "請確認是否輸入正確之手機號碼", buttonTitle: "確認", action: nil)
            present(alert, animated: true, completion: nil)
            return}
        //密碼驗證 6-12位英數字混合
        guard passwordTextField.text == confirmpwTextField.text else{
            let alert = UIAlertController.simpleOKAlert(title: "密碼與驗證不相符", message: "請確認密碼", buttonTitle: "確認", action: nil)
            present(alert, animated: true, completion: nil)
            return}
        let pwdPredicate = NSPredicate(format: "SELF MATCHES %@ ", "^[A-Za-z0-9]{6,12}$")
        guard pwdPredicate.evaluate(with: passwordTextField.text) else {
            let alert = UIAlertController.simpleOKAlert(title: "密碼格式錯誤", message: "請輸入6-12碼英數字混合", buttonTitle: "確認", action: nil)
            present(alert, animated: true, completion: nil)
            return}
        let user = User()
        user.member_id = phoneTextField.text ?? ""
        user.member_pwd = passwordTextField.text ?? ""
        user.member_name = nameTextField.text ?? ""
        user.member_email = emailTextField.text ?? ""
        
        UserService.shared.signUp(user) { isSuccess, message in
            if isSuccess {
                // TODO: 沒解完
//                self.couponAlert.showAlert(couponName: "哪來的coupon名稱",
//                                           couponImage: "哪來的coupon照片",
//                                           couponEndDate: "哪來的coupon期限",
//                                           on: self)
                Alert.showMessage(title: "獲得註冊優惠券", msg: "請至會員中心-優惠券查看", vc: self) {
                    self.delegate?.signupAction(self, newUser: user)
                }
            }else{
                let alert = UIAlertController.simpleOKAlert(title: "註冊錯誤", message: message, buttonTitle: "確認", action: nil)
                self.present(alert, animated: true)
            }
        }
    }
    
    @IBAction func rulsAction(_ sender: Any) {
        delegate?.ruleAction(self)
    }
    
    weak var delegate: SignUpViewControllerDelegate?
    private let couponAlert = CouponAlert()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBtnView()
        hideKeyBoard()
        nameTextField.delegate = self
        emailTextField.delegate = self
        phoneTextField.delegate = self
        passwordTextField.delegate = self
        setBorderView()
        agreeButton.setImage(UIImage(named: "check_icon_2"), for: .normal)
        agreeButton.setImage(UIImage(named: "check_icon"), for: .selected)
        
    }
    
    func setBorderView(){
        borderView.layer.borderWidth = 0.5
        borderView.layer.borderColor = UIColor.lightGray.cgColor
        borderView.layer.cornerRadius = 10
        nameTextField.setBottomBorder()
        emailTextField.setBottomBorder()
        phoneTextField.setBottomBorder()
        passwordTextField.setBottomBorder()
    }
    
    func hideKeyBoard(){
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(cancelFocus))
        tapGes.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGes)
    }
    
    @objc func cancelFocus(){
        self.view.endEditing(true)
    }
    
    func setBtnView(){
        //外框線
        signupButton.layer.borderWidth = 1
        //systemBlue
        signupButton.layer.borderColor = UIColor(red: 78/255, green: 171/255, blue: 173/255, alpha: 0.7).cgColor
        signupButton.layer.cornerRadius = 5
        signupButton.setTitleColor(Theme.blueColor, for: .normal)
        //加上下底線
        let attr: [NSAttributedString.Key: Any] = [.underlineStyle: NSUnderlineStyle.single.rawValue]
        let attrString = NSMutableAttributedString(string: "會員使用條款", attributes: attr)
        ruleButton.setAttributedTitle(attrString, for: .normal)
    }
    
    @objc func dismissAlert() {
        couponAlert.dismissAlert()
    }
}

extension SignUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
