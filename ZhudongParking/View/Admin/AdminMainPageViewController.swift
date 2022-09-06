//
//  AdminMainPageViewController.swift
//  ZhudongParking
//
//  Created by Tai Chin Huang on 2022/8/17.
//

import UIKit

protocol AdminMainPageViewControllerDelegate: AnyObject {
    func didTappedScanButton(_ viewController: AdminMainPageViewController)
    func didTappedLogout(_ viewController: AdminMainPageViewController)
}

class AdminMainPageViewController: UIViewController {
    
    weak var delegate: AdminMainPageViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func qrScanButtonTapped(_ sender: UIButton) {
        delegate?.didTappedScanButton(self)
    }
    @IBAction func logoutButtonTapped(_ sender: UIButton) {
        delegate?.didTappedLogout(self)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
