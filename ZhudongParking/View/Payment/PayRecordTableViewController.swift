//
//  PayRecordTableViewController.swift
//  ZhudongParking
//
//  Created by 陳Mike on 2022/7/19.
//

import UIKit
protocol PayRecordTableViewControllerDelegate: AnyObject {
    func detailAction(_ viewController: PayRecordTableViewController, record: PayRecord)
}

class PayRecordTableViewController: UITableViewController {

    weak var delegate: PayRecordTableViewControllerDelegate?
    var recordList = [PayRecord](){
        didSet{
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchRecord()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PayRecordTableViewCell", for: indexPath) as! PayRecordTableViewCell
        cell.delegate = self
        cell.record = recordList[indexPath.row]
        return cell
    }
    
    func fetchRecord(){
        guard let user = UserService.shared.user else{return}
        let url = API_URL + URL_BILLLISTE
        let parameters: [String:Any] = ["member_id":user.member_id, "member_pwd":user.member_pwd]
        WebAPI.shared.request(urlStr: url, parameters: parameters) { isSuccess, data, error in
            guard isSuccess, let data = data, let results = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] else{return}
            print(results)
            var list = [PayRecord]()
            for result in results {
                list.append(PayRecord(from: result))
            }
            self.recordList = list
        }
    }
    
    
}
extension PayRecordTableViewController: PayRecordTableViewCellDelegate {
    func detailAction(_ cell: PayRecordTableViewCell, record: PayRecord) {
        delegate?.detailAction(self, record: record)
    }
}

protocol PayRecordTableViewCellDelegate: AnyObject {
    func detailAction(_ cell: PayRecordTableViewCell, record: PayRecord)
}
class PayRecordTableViewCell: UITableViewCell {
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var payNoLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var payMoneyLabel: UILabel!
    @IBOutlet weak var payStatusLabel: UILabel!
    @IBOutlet weak var detailButton: UIButton!
    
    @IBAction func detailAction(){
        guard let record = record else{return}
        delegate?.detailAction(self, record: record)
    }
    
    weak var delegate: PayRecordTableViewCellDelegate?
    var record: PayRecord? {
        didSet{
            setRecord()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        borderView.layer.borderWidth = 0.5
        borderView.layer.cornerRadius = 5
        setRecord()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        setRecord()
    }
    
    func setRecord(){
        payNoLabel?.text = record?.bill_no
        timeLabel?.text = record?.bill_updated_at
        payMoneyLabel?.text = record?.bill_pay
        payStatusLabel?.text = record?.pay_status
    }
}
