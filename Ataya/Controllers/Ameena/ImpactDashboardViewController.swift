import UIKit

final class ImpactDashboardViewController: UIViewController {
    
    // MARK: - Outlets (cards)
    @IBOutlet weak var mealsCardView: UIView!
    @IBOutlet weak var wasteCardView: UIView!
    @IBOutlet weak var envCardView: UIView!
    
    // MARK: - Outlets (value labels)
    @IBOutlet weak var mealsValueLabel: UILabel!
    @IBOutlet weak var wasteValueLabel: UILabel!
    @IBOutlet weak var envValueLabel: UILabel!
    
    
    // MARK: - Dummy data (replace later with Firebase/DB)
    private var donations: [Donation] = [
        Donation(amountKg: 3.0, status: "Completed"),
        Donation(amountKg: 1.5, status: "Completed"),
        Donation(amountKg: 2.0, status: "Pending"),
        Donation(amountKg: 4.0, status: "Completed")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateImpactNumbers()
    }
    
    private func setupUI() {
        styleCard(mealsCardView)
        styleCard(wasteCardView)
        styleCard(envCardView)
    }
    
    private func styleCard(_ v: UIView) {
        v.layer.cornerRadius = 14
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor.systemGray5.cgColor
        v.layer.masksToBounds = true
    }
    
    private func updateImpactNumbers() {
        
        // 1) Donations done (Completed only)
        let completed = donations.filter { $0.status.lowercased() == "completed" }
        
        // 2) Food waste prevented = total kg rescued
        let wastePreventedKg = completed.reduce(0.0) { $0 + $1.amountKg }
        
        // 3) Meals provided (اختيار بسيط): 1 meal = 0.5 kg
        let kgPerMeal = 0.5
        let meals = Int((wastePreventedKg / kgPerMeal).rounded(.down))
        
        // 4) Environmental equivalent: CO2e avoided (تقريبي)
        let co2ePerKgFood = 2.5
        let co2eAvoidedKg = wastePreventedKg * co2ePerKgFood
        
        // UI
        mealsValueLabel.text = "\(meals)"
        wasteValueLabel.text = String(format: "%.1f kg", wastePreventedKg)
        envValueLabel.text = String(format: "%.1f kg CO₂e", co2eAvoidedKg)
    }
    
    @IBAction func viewDetailsTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "showImpactDetails", sender: nil)
    }
}


// MARK: - Model
struct Donation {
    let amountKg: Double
    let status: String
}
