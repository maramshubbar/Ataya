import UIKit

class DiscoverNGOViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!   
    
    var ngos: [NGO] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register the XIB for your custom cell
        tableView.register(UINib(nibName: "NGOCellTableViewCell", bundle: nil),
                           forCellReuseIdentifier: "NGOCellTableViewCell")
        
        tableView.dataSource = self
        tableView.delegate = self
        
        ngos = loadDummyNGOs()
    }
    
    func loadDummyNGOs() -> [NGO] {
        return [
            NGO(name: "NextGen Giving", category: "Educational & Children Support",
                email: "info@brighthands.org", location: "Manama, Bahrain", rating: 4.5),
            NGO(name: "GlobalReach", category: "Community Support & Donations",
                email: "contact@globalreach.org", location: "Doha, Qatar", rating: 5.0),
            NGO(name: "BrightImpact", category: "Community Support & Donations",
                email: "support@BrightImpact.org", location: "Riyadh, Saudi Arabia", rating: 5.0),
            NGO(name: "PillarSupport", category: "Refugee & Poverty Assistance",
                email: "info@pillarSupport.org", location: "Amman, Jordan", rating: 4.9)
        ]
    }
    
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ngos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NGOCellTableViewCell", for: indexPath) as? NGOCellTableViewCell else {
            return UITableViewCell()
        }
        let ngo = ngos[indexPath.row]
        cell.configure(with: ngo)
        return cell
    }
}
