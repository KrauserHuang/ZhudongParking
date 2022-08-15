//
//  InputPlateViewController.swift
//  ZhudongParking
//
//  Created by 陳Mike on 2022/7/18.
//

import UIKit
protocol InputPlateViewControllerDelegate: AnyObject {
    func nextAction(_ viewController: InputPlateViewController, plateNo: String)
}

class InputPlateViewController: UIViewController {
    @IBOutlet weak var preTextField: UITextField!
    @IBOutlet weak var sufTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    @IBAction func nextAction(_ sender: Any) {
        guard let preNo = preTextField.text, let sufNo = sufTextField.text, preNo != "", sufNo != "" else{
            let alert = UIAlertController.simpleOKAlert(title: "", message: "欄位請勿留白", buttonTitle: "確認", action: nil)
            present(alert, animated: true)
            return}
        let plateNo = preNo + "-" + sufNo
        delegate?.nextAction(self, plateNo: plateNo)
        addNewNo(plateNo)
    }
    
    weak var delegate: InputPlateViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nextButton.backgroundColor = Theme.blueColor
        preTextField.delegate = self
        sufTextField.delegate = self
    }
    
    func addNewNo(_ plateNo: String){
        guard let user = UserService.shared.user else{return}
        let url = API_URL + URL_PLATENUMBERADDE
        let parameters: [String:Any] = ["member_id":user.member_id, "member_pwd":user.member_pwd, "plate_number":plateNo]
        WebAPI.shared.request(urlStr: url, parameters: parameters) { isSuccess, data, error in
            if let data = data {
                print(String(data: data, encoding: .utf8))
            }
        }
    }
    
}

extension InputPlateViewController: UITextFieldDelegate {
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
