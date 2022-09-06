//
//  ForgotPasswordViewController.swift
//  ZhudongParking
//
//  Created by 陳Mike on 2022/7/15.
//

import UIKit
protocol ForgotPasswordViewControllerDelegate: AnyObject {
    func getVerifyAction(_ viewController: ForgotPasswordViewController, phone: String)
    func verifyAction(_ viewController: ForgotPasswordViewController, newUser: User, verifyCode: String)
}

class ForgotPasswordViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var verifyTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmpwTextField: UITextField!
    @IBOutlet weak var getVerifyButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    
    @IBAction func getVerifyAction(_ sender: UIButton) {
        view.endEditing(true)
        let predicate = NSPredicate(format: "SELF MATCHES %@", "^09[0-9]{8}$")
        guard let phone = phoneTextField.text, predicate.evaluate(with: phone) else{
            let alert = UIAlertController.simpleOKAlert(title: "電話格式錯誤", message: "", buttonTitle: "確認", action: nil)
            present(alert, animated: true, completion: nil)
            return}
        phoneNumber = phone
        delegate?.getVerifyAction(self, phone: phone)
        getVerifyButton.setTitle("Waiting..", for: .disabled)
        getVerifyButton.isEnabled = false
        countDount = 120
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(setCountdown), userInfo: nil, repeats: true)
    }
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
    @IBAction func submitAction(_ sender: Any) {
        view.endEditing(true)
        guard let code = verifyTextField.text, let pwd = passwordTextField.text, let confirmPwd = confirmpwTextField.text, let phone = phoneTextField.text else {return}
        phoneNumber = phone
        guard phoneNumber != "", pwd != "", confirmPwd == pwd else {
            let alert = UIAlertController.simpleOKAlert(title: "欄位不能空白", message: "", buttonTitle: "確認", action: nil)
            present(alert, animated: true, completion: nil)
            return}
        let user = User()
        user.member_id = phoneNumber
        user.member_pwd = pwd
        delegate?.verifyAction(self, newUser: user, verifyCode: code)
    }
    
    weak var delegate: ForgotPasswordViewControllerDelegate?
    weak var timer: Timer?
    var countDount = 0
    var phoneNumber = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyBoard()
        setBtnView()
        phoneTextField.delegate = self
        verifyTextField.delegate = self
        passwordTextField.delegate = self
        confirmpwTextField.delegate = self
        setBorderView()
    }
    
    func setBorderView(){
        borderView.layer.borderWidth = 0.5
        borderView.layer.borderColor = UIColor.lightGray.cgColor
        borderView.layer.cornerRadius = 10
        phoneTextField.setBottomBorder()
        verifyTextField.setBottomBorder()
        passwordTextField.setBottomBorder()
        confirmpwTextField.setBottomBorder()
    }

    func hideKeyBoard(){
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(cancelFocus))
        tapGes.cancelsTouchesInView = false
        self.scrollView.addGestureRecognizer(tapGes)
    }
    @objc func cancelFocus(){
        self.view.endEditing(true)
    }
    func setBtnView(){
        //外框線
        sendButton.layer.borderWidth = 1
        getVerifyButton.layer.borderWidth = 1
        //systemBlue
        sendButton.layer.borderColor = UIColor(red: 78/255, green: 171/255, blue: 173/255, alpha: 0.7).cgColor
        sendButton.layer.cornerRadius = 5
        sendButton.backgroundColor = Theme.blueColor
        getVerifyButton.layer.borderColor = UIColor(red: 78/255, green: 171/255, blue: 173/255, alpha: 0.7).cgColor
        getVerifyButton.layer.cornerRadius = 5
        getVerifyButton.backgroundColor = Theme.blueColor
    }
    @objc func setCountdown(){
        if countDount < 1 {
            getVerifyButton.isEnabled = true
            timer?.invalidate()
        }else{
            getVerifyButton.setTitle("\(String(format: "%02d", countDount/60))：\(String(format: "%02d", countDount%60))", for: .disabled)
            countDount -= 1
        }
    }
    
}

extension ForgotPasswordViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
