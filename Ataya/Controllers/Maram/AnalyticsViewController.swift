//
//  AnalyticsViewController.swift
//  Ataya
//
//  Created by Maram on 02/12/2025.
//

import UIKit

final class AnalyticsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tblCountries: UITableView!
    
    @IBOutlet weak var tblList: UITableView!
    
    @IBOutlet weak var segListFilter: UISegmentedControl!
    
    
    enum RowType: String { case donor = "Donor", ngo = "NGO" }
    
    struct ListRow {
        let name: String
        let location: String
        let type: RowType
    }
    
    private let data: [(name: String, amount: String, percent: Int)] = [
        ("Bahrain", "BD 120", 42),
        ("Saudi Arabia", "BD 80", 28),
        ("Kuwait", "BD 40", 15),
        ("UAE", "BD 25", 10),
        ("Oman", "BD 10", 5)
    ]
    
    
    private let dotColors: [UIColor] = [
        UIColor(red: 102/255, green: 167/255, blue: 255/255, alpha: 1), // #66a7ff
        UIColor(red: 111/255, green: 201/255, blue: 168/255, alpha: 1), // #6fc9a8
        UIColor(red: 255/255, green: 169/255, blue: 97/255,  alpha: 1), // #ffa961
        UIColor(red: 221/255, green: 203/255, blue: 242/255, alpha: 1)  // #ddcbf2
    ]
    
    
    private var rows: [ListRow] = []
    private var allRows: [ListRow] = [
        .init(name: "Ahmed Ali",     location: "Manama",   type: .donor),
        .init(name: "Hope Kitchen",  location: "Muharraq", type: .ngo),
        .init(name: "Fatema",        location: "Riffa",    type: .donor),
        .init(name: "Bahrain NGO",   location: "Isa Town", type: .ngo),
        .init(name: "Maryam",        location: "Sitra",    type: .donor)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblCountries.dataSource = self
        tblCountries.delegate = self
        
        tblCountries.isScrollEnabled = false
        tblCountries.rowHeight = 44
        tblCountries.separatorStyle = .none
        tblCountries.backgroundColor = .clear
        
        tblCountries.reloadData()
        
        
        rows = allRows
        
        tblList.dataSource = self
        tblList.delegate = self
        
        // لأن الجدول داخل ScrollView
        tblList.isScrollEnabled = false
        tblList.rowHeight = 64
        tblList.separatorStyle = .none
        tblList.backgroundColor = .clear
        
        // Segmented (All / Donors / NGOs)
        segListFilter.selectedSegmentIndex = 0
        segListFilter.addTarget(self, action: #selector(filterChanged), for: .valueChanged)
        
        tblList.reloadData()
    }
    
    
    
    @objc private func filterChanged() {
        switch segListFilter.selectedSegmentIndex {
        case 1: rows = allRows.filter { $0.type == .donor }
        case 2: rows = allRows.filter { $0.type == .ngo }
        default: rows = allRows
        }
        tblList.reloadData()
    }
    
    /*func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     return data.count
     }
     
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: "CountryCell", for: indexPath)
     
     let amtLbl = cell.contentView.viewWithTag(4) as? UILabel
     amtLbl?.text = "BD 12.5"  // مؤقت للتجربة
     
     let item = data[indexPath.row]
     
     let dot = cell.contentView.viewWithTag(1) as? UIView
     let nameLbl = cell.contentView.viewWithTag(2) as? UILabel
     let pctLbl = cell.contentView.viewWithTag(3) as? UILabel
     
     amtLbl?.text = item.amount
     
     dot?.backgroundColor = dotColors[indexPath.row % dotColors.count]
     dot?.layer.cornerRadius = 10
     dot?.layer.masksToBounds = true
     
     nameLbl?.text = item.name
     pctLbl?.text = "\(item.percent)%"
     
     cell.selectionStyle = .none
     cell.backgroundColor = .clear
     return cell
     }*/
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tblCountries { return data.count }
        if tableView == tblList { return rows.count }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // ✅ جدول الدول
        if tableView == tblCountries {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CountryCell", for: indexPath)
            let item = data[indexPath.row]
            
            let dot = cell.contentView.viewWithTag(1) as? UIView
            let nameLbl = cell.contentView.viewWithTag(2) as? UILabel
            let pctLbl  = cell.contentView.viewWithTag(3) as? UILabel
            let amtLbl  = cell.contentView.viewWithTag(4) as? UILabel
            
            nameLbl?.text = item.name
            amtLbl?.text  = item.amount
            pctLbl?.text  = "\(item.percent)%"
            
            dot?.backgroundColor = dotColors[indexPath.row % dotColors.count]
            dot?.layer.cornerRadius = 10
            dot?.layer.masksToBounds = true
            
            cell.selectionStyle = .none
            cell.backgroundColor = .clear
            return cell
        }
        
        
        // ✅ جدول القائمة (All/Donors/NGOs)
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath)
        let item = rows[indexPath.row]
        
        let img = cell.contentView.viewWithTag(10) as? UIImageView
        img?.image = UIImage(named: "ic_report_center") // جرّبيها مؤقت
        
        let lblName = cell.contentView.viewWithTag(1) as? UILabel
        let lblLocation = cell.contentView.viewWithTag(2) as? UILabel
        let lblType = cell.contentView.viewWithTag(3) as? UILabel
        
        lblName?.text = item.name
        lblLocation?.text = item.location
        lblType?.text = item.type.rawValue
        
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        return cell
    }
}
    
