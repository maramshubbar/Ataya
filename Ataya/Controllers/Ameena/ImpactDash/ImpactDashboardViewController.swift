//
//  ImpactDashboardViewController.swift
//  Ataya
//
//  Created by Zahraa Ahmed on 03/01/2026.
//
import UIKit
import FirebaseFirestore
import FirebaseAuth

final class ImpactDashboardViewController: UIViewController {

    // MARK: - Outlets (Summary Cards)
    @IBOutlet weak var mealsCardView: UIView!
    @IBOutlet weak var wasteCardView: UIView!
    @IBOutlet weak var envCardView: UIView!

    // MARK: - Outlets (Value Labels)
    @IBOutlet weak var mealsValueLabel: UILabel!
    @IBOutlet weak var wasteValueLabel: UILabel!
    @IBOutlet weak var envValueLabel: UILabel!

    // MARK: - Firestore
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    // MARK: - Config (Adjust if your status names differ)
    private let completedStatus = "completed"

    // MARK: - Impact Factors (Adjust later if needed)
    private let kgPerMeal: Double = 0.5      // Assumption: 1 meal = 0.5 kg
    private let co2ePerKgFood: Double = 2.5  // Assumption: 1 kg food saved = 2.5 kg CO2e

    // MARK: - Data (Loaded from Firebase)
    private var donations: [ImpactDonation] = []

    override func viewDidLoad() {
        super.viewDidLoad()
            setupUI()
            attachDonationsListener()
    }

    deinit {
        // Stop listening when controller is deallocated
        listener?.remove()
    }

    // MARK: - UI Styling
    private func setupUI() {
        styleCard(mealsCardView)
        styleCard(wasteCardView)
        styleCard(envCardView)

        // Default placeholders until Firebase loads
        mealsValueLabel.text = "--"
        wasteValueLabel.text = "--"
        envValueLabel.text = "--"
    }

    private func styleCard(_ v: UIView) {
        v.layer.cornerRadius = 14
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor.systemGray5.cgColor
        v.layer.masksToBounds = true
    }

    // MARK: - Firebase: Listen to donations for current user
    private func attachDonationsListener() {
        guard let donorId = Auth.auth().currentUser?.uid else {
            // If user is not logged in, show zeros
            applyImpactToUI(meals: 0, wasteKg: 0, co2Kg: 0)
            return
        }

        // Listen for real-time updates from donations collection
        listener = db.collection("donations")
            .whereField("donorId", isEqualTo: donorId)
            .addSnapshotListener { [weak self] snap, error in
                guard let self = self else { return }

                if let error = error {
                    print("Firestore error:", error.localizedDescription)
                    self.applyImpactToUI(meals: 0, wasteKg: 0, co2Kg: 0)
                    return
                }

                let docs = snap?.documents ?? []
                self.donations = docs.compactMap { ImpactDonation(doc: $0) }

                // Recalculate impact whenever data changes
                self.updateImpactNumbers()
            }
    }

    // MARK: - Impact Calculations
    private func updateImpactNumbers() {

        // 1) Completed only
        let completed = donations.filter { $0.status.lowercased() == completedStatus }

        // 2) Convert all quantities into KG (supports multiple units)
        let totalKg = completed.reduce(0.0) { partial, d in
            partial + UnitConverter.toKg(value: d.quantityValue, unitRaw: d.quantityUnit)
        }

        // 3) Meals provided
        let meals = Int((totalKg / kgPerMeal).rounded(.down))

        // 4) Environmental equivalent (CO2e avoided)
        let co2Kg = totalKg * co2ePerKgFood

        // 5) Update UI
        applyImpactToUI(meals: meals, wasteKg: totalKg, co2Kg: co2Kg)
    }

    private func applyImpactToUI(meals: Int, wasteKg: Double, co2Kg: Double) {
        mealsValueLabel.text = "\(meals)"
        wasteValueLabel.text = String(format: "%.1f kg", wasteKg)
        envValueLabel.text = String(format: "%.1f kg CO₂e", co2Kg)
    }

    // MARK: - Navigation
    @IBAction func viewDetailsTapped(_ sender: UIButton) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "ImpactDetailsViewController")
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - Donation Model (Matches your Firestore fields)
struct ImpactDonation {
    let id: String
    let donorId: String
    let status: String
    let category: String
    let quantityValue: Double
    let quantityUnit: String
    let createdAt: Date

    init?(doc: QueryDocumentSnapshot) {
        let data = doc.data()

        guard
            let donorId = data["donorId"] as? String,
            let status = data["status"] as? String,
            let category = data["category"] as? String,
            let quantityUnit = data["quantityUnit"] as? String,
            let createdAtTS = data["createdAt"] as? Timestamp
        else { return nil }

        // quantityValue could be Int or Double
        let qAny = data["quantityValue"]
        let q: Double
        if let d = qAny as? Double { q = d }
        else if let i = qAny as? Int { q = Double(i) }
        else { return nil }

        self.id = (data["id"] as? String) ?? doc.documentID
        self.donorId = donorId
        self.status = status
        self.category = category
        self.quantityValue = q
        self.quantityUnit = quantityUnit
        self.createdAt = createdAtTS.dateValue()
    }
}

// MARK: - Unit Converter (supports future units)
enum QuantityUnit: String {
    case kg, g, item, pack, tray, box, liter
}

struct UnitConverter {

    // Estimates (adjust to match your project assumptions)
    static let kgPerItem: Double = 0.5
    static let kgPerPack: Double = 0.4
    static let kgPerTray: Double = 1.2
    static let kgPerBox: Double  = 3.0
    static let kgPerLiter: Double = 1.0

    static func toKg(value: Double, unitRaw: String) -> Double {
        let unit = QuantityUnit(rawValue: unitRaw.lowercased()) ?? .kg

        switch unit {
        case .kg:    return value
        case .g:     return value / 1000.0
        case .item:  return value * kgPerItem
        case .pack:  return value * kgPerPack
        case .tray:  return value * kgPerTray
        case .box:   return value * kgPerBox
        case .liter: return value * kgPerLiter
        }
    }
}

