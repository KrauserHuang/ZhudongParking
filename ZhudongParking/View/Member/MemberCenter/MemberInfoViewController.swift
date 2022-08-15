//
//  MemberInfoViewController.swift
//  ZhudongParking
//
//  Created by 陳Mike on 2022/7/15.
//

import UIKit
protocol MemberInfoViewControllerDelegate: AnyObject {
    func toModifyAction(_ viewController: MemberInfoViewController)
    func modifyAction(_ viewController: MemberInfoViewController, newUser: User)
}

class MemberInfoViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    @IBAction func nextAction(_ sender: Any) {
        guard isModify, let user = UserService.shared.user else{
            delegate?.toModifyAction(self)
            return}
        //驗證email
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}")
        if !emailPredicate.evaluate(with: emailTextField.text) {
            let alert = UIAlertController.simpleOKAlert(title: "", message: "信箱格式錯誤，請重新輸入", buttonTitle: "確認", action: nil)
            self.present(alert, animated: true, completion: nil)
            return
        }
        //手機號碼驗證
//        let predicate = NSPredicate(format: "SELF MATCHES %@", "^09[0-9]{8}$")
//        guard predicate.evaluate(with: phoneTextField.text) else{
//            let alert = UIAlertController.simpleOKAlert(title: "", message: "請確認是否輸入正確之手機號碼", buttonTitle: "確認", action: nil)
//            self.present(alert, animated: true, completion: nil)
//            return}
        let newUser = User()
        newUser.member_id = user.member_id
        let name = nameTextField.text ?? ""
        newUser.member_name = name == "" ? user.member_name : name
        let email = emailTextField.text ?? ""
        newUser.member_email = email == "" ? user.member_email : email
        newUser.member_address = addressTextField.text ?? ""
        
        UserService.shared.editUser(newUser) { isSuccess in
            if isSuccess {
                let alert = UIAlertController.simpleOKAlert(title: "", message: "修改成功", buttonTitle: "確認") { _ in
                    self.delegate?.modifyAction(self, newUser: newUser)
                }
                self.present(alert, animated: true)
            }else{
                self.delegate?.modifyAction(self, newUser: newUser)
            }
        }
    }
    
    var isModify = false
    weak var delegate: MemberInfoViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBtnView()
        hideKeyBoard()
        nameTextField.delegate = self
        emailTextField.delegate = self
        phoneTextField.delegate = self
        addressTextField.delegate = self
        setBorderView()
        if isModify {
            setModifyView()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setMemberData()
    }
    
    func setBorderView(){
        borderView.layer.borderWidth = 0.5
        borderView.layer.borderColor = UIColor.lightGray.cgColor
        borderView.layer.cornerRadius = 10
//        nameTextField.setBottomBorder()
//        emailTextField.setBottomBorder()
//        phoneTextField.setBottomBorder()
//        addressTextField.setBottomBorder()
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
        actionButton.layer.borderWidth = 1
        //systemBlue
//        signupButton.layer.borderColor = CGColor(red: 0, green: 122/255, blue: 255/255, alpha: 0.7)
        actionButton.layer.borderColor = UIColor(red: 78/255, green: 171/255, blue: 173/255, alpha: 0.7).cgColor
        actionButton.layer.cornerRadius = 5
    }
    
    func setModifyView(){
        actionButton.setTitle("會員資料修改", for: .normal)
        nameTextField.isHidden = false
        emailTextField.isHidden = false
        phoneTextField.isHidden = false
        phoneTextField.isEnabled = false
        addressTextField.isHidden = false
        nameLabel.isHidden = true
        emailLabel.isHidden = true
        phoneLabel.isHidden = true
        addressLabel.isHidden = true
    }
    
    func setMemberData(){
        let user = UserService.shared.user
        if isModify {
            phoneTextField.text = (user?.member_id ?? "") + "(無法修改)"
            nameTextField.text = user?.member_name
            emailTextField.text = user?.member_email
            addressTextField.text = user?.member_address
        }else{
            phoneLabel.text = user?.member_id
            nameLabel.text = user?.member_name
            emailLabel.text = user?.member_email
            addressLabel.text = user?.member_address
        }
    }
    
}

extension MemberInfoViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
