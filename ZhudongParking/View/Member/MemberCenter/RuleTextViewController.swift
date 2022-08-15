//
//  RuleTextViewController.swift
//  ZhudongParking
//
//  Created by 陳Mike on 2022/7/15.
//

import UIKit

class RuleTextViewController: UIViewController {
    @IBOutlet weak var textLabel: UILabel!

    var type: RuleTextType = .Undifine
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        switch type {
        case .UserRule:
            textLabel.text = "收費方式:\n\n路邊收費停車場費率標準如下:\n1.未逾5分鐘免予收費。\n\n2.逾5分鐘，未逾半小時，新臺幣（以下同）十元；\n\n3.逾半小時，其超過之部分，每半小時十元。\n\n4.未滿半小時者，以半小時計。\n\n5.停車逾5分鐘始開始計費，停車費用之計算追溯該5分鐘。\n\n6.民眾以現場自動收費機繳費完畢者，應給予車輛10分鐘緩衝時間駛離，倘逾10分鐘仍未駛離者，方得再重新開立停車單，停車費用之計算亦追溯該10分鐘緩衝時間。"
        case .QandA:
            textLabel.text = "Q1:如何加入會員\n請點選主頁右上角人頭icon，點選註冊，輸入姓名電話等資訊即刻進行註冊\n\nQ2:忘記密碼怎麼辦\n於註冊/登入頁面點選忘記密碼，輸入手機號碼與新密碼即可完成新密碼設定\n\nQ3:忘記會員帳號怎麼辦\n會員帳號即為手機號碼\n\nQ4:該如何修改個人資料與密碼\n會員資料頁面下方即有修改個人資料選項，點選即可進行會員資料與密碼修改"
        case .Undifine:
            textLabel.text = ""
        }
    }
    
    enum RuleTextType {
    case UserRule, QandA, Undifine
    }
}
