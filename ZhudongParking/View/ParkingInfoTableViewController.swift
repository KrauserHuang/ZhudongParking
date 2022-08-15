//
//  ParkingInfoTableViewController.swift
//  ZhudongParking
//
//  Created by 陳Mike on 2022/7/18.
//

import UIKit

class ParkingInfoTableViewController: UITableViewController {
    
    var capList = [Int:String]()
    var spaceList = [Int:String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        fetchSpace()
    }
    
    func fetchSpace(){
        let url = API_URL + URL_PARKINGSPACESE
        WebAPI.shared.request(urlStr: url, parameters: [:]) { _, data, error in
            guard let data = data, let results = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any], let result = results["data"] as? [[String:Any]] else{return}
            var space = 0
            for result in result {
                if result["parked"] as? String == "Y" {
                    space += 1
                }
            }
            self.spaceList.updateValue("\(space)", forKey: 0)
            self.capList.updateValue("\(result.count)", forKey: 0)
            self.tableView.reloadData()
        }
        
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ParkingInfoTableViewCell", for: indexPath) as! ParkingInfoTableViewCell
        cell.capacity = capList[indexPath.row] ?? "--"
        cell.space = spaceList[indexPath.row] ?? "--"
        return cell
    }
    
}

class ParkingInfoTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var capacityLabel: UILabel!
    @IBOutlet weak var borderView: UIView!
    
    @IBAction func naviAction(_ sender: Any) {
        let latitude = 24.73704328258781
        let longitude = 121.092230017034
        let schemeStr = "comgooglemaps://?saddr=&daddr=\(latitude),\(longitude)&directionsmode=driving"
        let urlStr = "https://www.google.com.tw/maps/dir/?api=1&destination=\(latitude),\(longitude)&travelmode=driving"
        if let url = URL(string: schemeStr), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }else if let url = URL(string: urlStr){
            UIApplication.shared.open(url)
        }
    }
    
    var capacity = "--"
    var space = "--" {
        didSet{
            capacityLabel.text = "\(space)/\(capacity)"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        borderView.layer.borderWidth = 0.5
        borderView.layer.cornerRadius = 5
    }
    
    
}
