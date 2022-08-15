//
//  InputRecordTableViewController.swift
//  ZhudongParking
//
//  Created by 陳Mike on 2022/7/18.
//

import UIKit
protocol InputRecordTableViewControllerDelegate: AnyObject {
    func otherAction(_ viewController: InputRecordTableViewController)
    func queryAction(_ viewController: InputRecordTableViewController, plateNo: String)
}

class InputRecordTableViewController: UITableViewController {
    
    @IBOutlet weak var otherPlateButton: UIButton!
    @IBAction func otherPlateAction(_ sender: Any) {
        delegate?.otherAction(self)
    }
    
    var records = [String]()
    weak var delegate: InputRecordTableViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        otherPlateButton.backgroundColor = Theme.blueColor
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return records.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InputRecordTableViewCell", for: indexPath) as! InputRecordTableViewCell
        cell.plateNo = records[indexPath.row]
        cell.delegate = self
        return cell
    }
    
}
extension InputRecordTableViewController: InputRecordTableViewCellDelegate {
    func queryAction(_ cell: InputRecordTableViewCell, plateNo: String) {
        delegate?.queryAction(self, plateNo: plateNo)
    }
}


protocol InputRecordTableViewCellDelegate: AnyObject {
    func queryAction(_ cell: InputRecordTableViewCell, plateNo: String)
}
class InputRecordTableViewCell: UITableViewCell {
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var plateNoLabel: UILabel!
    @IBOutlet weak var queryButton: UIButton!
    @IBAction func queryAction(_ sender: Any) {
        delegate?.queryAction(self, plateNo: plateNo)
    }
    
    weak var delegate: InputRecordTableViewCellDelegate?
    var plateNo = ""{
        didSet{
            plateNoLabel?.text = plateNo
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        queryButton.backgroundColor = Theme.blueColor
        plateNoLabel.text = plateNo
        borderView.layer.borderWidth = 0.5
    }
}
