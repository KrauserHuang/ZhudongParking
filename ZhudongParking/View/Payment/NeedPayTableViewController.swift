//
//  NeedPayTableViewController.swift
//  ZhudongParking
//
//  Created by 陳Mike on 2022/7/18.
//

import UIKit
protocol NeedPayTableViewControllerDelegate: AnyObject {
    func payAction(_ viewController: NeedPayTableViewController, bill: BillRecord)
}
class NeedPayTableViewController: UITableViewController {
    
    @IBOutlet weak var plateNoLabel: UILabel!
    @IBOutlet weak var payButton: UIButton!
    @IBAction func payAction(_ sender: Any) {
        var selected: BillRecord?
        for model in payList {
            if model.isSelect {
                selected = model
            }
        }
        guard let model = selected else{return}
        delegate?.payAction(self, bill: model)
    }
    
    weak var delegate: NeedPayTableViewControllerDelegate?
    var plateNo = ""
    var payList = [BillRecord]() {
        didSet{
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        payButton.backgroundColor = Theme.blueColor
        plateNoLabel.text = plateNo
        fetchBill()
    }
    
    func fetchBill(){
        RootWindow?.loadingAction()
        let url = API_URL + URL_SEARCHPLATENOE
        let parameters: [String:Any] = ["plate_number":plateNo]
        WebAPI.shared.request(urlStr: url, parameters: parameters, method: "GET") { isSuccess, data, error in
            RootWindow?.finishLoading()
            guard isSuccess, let data = data, let results = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any], let items = results["items"] as? [[String:Any]] else{return}
            print(items)
            var list = [BillRecord]()
            for item in items {
                list.append(BillRecord(from: item))
            }
            self.payList = list
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return payList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NeedPayTableViewCell", for: indexPath) as! NeedPayTableViewCell
        cell.record = payList[indexPath.row]
        cell.delegate = self
        return cell
    }
    
}
extension NeedPayTableViewController: NeedPayTableViewCellDelegate {
    func checkAction(_ cell: NeedPayTableViewCell, model: BillRecord) {
        for cell in tableView.visibleCells {
            let cell = cell as? NeedPayTableViewCell
            cell?.deselectAction()
        }
        for model in payList {
            model.isSelect = false
        }
        model.isSelect = true
        cell.setRecordView()
    }
}


protocol NeedPayTableViewCellDelegate: AnyObject {
    func checkAction(_ cell: NeedPayTableViewCell, model: BillRecord)
}
class NeedPayTableViewCell: UITableViewCell {
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var payNoLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var payMoneyLabel: UILabel!
    @IBOutlet weak var payStatusLabel: UILabel!
    
    @IBAction func checkAction(){
        guard let record = record else{return}
        record.isSelect.toggle()
        if isChecked {
            delegate?.checkAction(self, model: record)
        }else{
            checkButton.isSelected = isChecked
        }
    }
    
    weak var delegate: NeedPayTableViewCellDelegate?
    var isChecked: Bool {
        return record?.isSelect == true
    }
    var record: BillRecord? {
        didSet{
            setRecordView()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        checkButton.setImage(UIImage(named: "check_icon_2"), for: .normal)
        checkButton.setImage(UIImage(named: "check_icon"), for: .selected)
        borderView.layer.borderWidth = 0.5
        borderView.layer.cornerRadius = 5
        setRecordView()
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        
        checkButton.isSelected = isChecked
    }
    
    func setRecordView(){
        payNoLabel?.text = record?.serial
        timeLabel?.text = record?.date
        payMoneyLabel?.text = record?.amount
        checkButton.isSelected = isChecked
    }
    
    func deselectAction(){
        record?.isSelect = false
        checkButton.isSelected = isChecked
    }
    
}
