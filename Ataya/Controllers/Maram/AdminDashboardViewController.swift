//
//  AdminDashboard1ViewController.swift
//  Ataya
//
//  Created by Maram on 17/12/2025.
/*
import UIKit

final class AdminDashboardViewController: UIViewController {
    
    // MARK: - Outlets (Cards)
    @IBOutlet private weak var cardRegisteredUsers: UIView!
    @IBOutlet private weak var cardTotalDonations: UIView!
    @IBOutlet private weak var cardFlaggedReports: UIView!
    @IBOutlet private weak var cardVerifiedCollectors: UIView!
    
    @IBOutlet weak var donationOverviewCard: UIView!
    
    @IBOutlet weak var auditLogCard: UIView!
    // MARK: - Outlets (Buttons)
    //@IBOutlet private weak var btnDonationOverview: UIButton!
    // @IBOutlet private weak var btnAuditLog: UIButton!   // إذا عندج زر ثاني، فعّليه
    let activities = [
        "New donation request received from Al Noor Charity with a large quantity of packaged food items that require verification.",
        "Collector Ahmed Hassan has been verified successfully after completing all required safety and identity checks.",
        "A donation was flagged due to missing expiration date information and is pending admin review.",
        "System update completed successfully without any issues reported by users."
    ]
    
    
    @IBOutlet weak var tblRecentActivity: UITableView!
    
    private let cardCornerRadius: CGFloat = 16

    override func viewDidLoad() {
        super.viewDidLoad()
      
        
        tblRecentActivity.dataSource = self
        tblRecentActivity.delegate = self
        tblRecentActivity.isScrollEnabled = false
        tblRecentActivity.rowHeight = UITableView.automaticDimension
        tblRecentActivity.estimatedRowHeight = 90


       
        
        styleCard(donationOverviewCard)
            styleCard(auditLogCard)
        


        
        // 1) Cards style (corner + shadow)
        let cards: [UIView] = [
            cardRegisteredUsers,
            cardTotalDonations,
            cardFlaggedReports,
            cardVerifiedCollectors
        ]
        cards.forEach { $0.applyCardShadow(cornerRadius: cardCornerRadius) }
                 
    }
    
    
    private func styleCard(_ v: UIView) {
        v.layer.cornerRadius = 8
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor(red: 247/255, green: 212/255, blue: 76/255, alpha: 1).cgColor
        v.layer.masksToBounds = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // لازم تتحدث بعد layout عشان bounds صحيح
        let cards: [UIView] = [
            cardRegisteredUsers,
            cardTotalDonations,
            cardFlaggedReports,
            cardVerifiedCollectors
        ]
        cards.forEach { $0.updateShadowPath(cornerRadius: cardCornerRadius) }
    }
    
    
    
}
// MARK: - Card Shadow Helpers
private extension UIView {

    func applyCardShadow(cornerRadius: CGFloat) {
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = false

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.10
        layer.shadowRadius = 10
        layer.shadowOffset = CGSize(width: 0, height: 4)

        // نخليه هنا، وبنحدثه بعدين في viewDidLayoutSubviews
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
    }

    func updateShadowPath(cornerRadius: CGFloat) {
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
    }
}
// MARK: - Image Resize
/*private extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }*/

extension AdminDashboardViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activities.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "cellActivity", for: indexPath)

        let lbl = cell.viewWithTag(2) as? UILabel   // أو outlet إذا سويتي
        lbl?.text = activities[indexPath.row]
        cell.selectionStyle = .none

        return cell
    }
}

*/
import UIKit

final class AdminDashboardViewController: UIViewController {

    // MARK: - Outlets (Cards)
    @IBOutlet private weak var cardRegisteredUsers: UIView!
    @IBOutlet private weak var cardTotalDonations: UIView!
    @IBOutlet private weak var cardFlaggedReports: UIView!
    @IBOutlet private weak var cardVerifiedCollectors: UIView!

    // Quick Links Views
    @IBOutlet weak var donationOverviewCard: UIView!
    @IBOutlet weak var auditLogCard: UIView!

    // Recent Activity Table
    @IBOutlet weak var tblRecentActivity: UITableView!
    @IBOutlet weak var tblRecentActivityHeight: NSLayoutConstraint!   // ✅ اربطيها على Height constraint للجدول
    
    @IBAction func donationOverviewTapped(_ sender: Any) {
        performSegue(withIdentifier: "sgDonationOverview", sender: self)
    }


    private let cardCornerRadius: CGFloat = 16

    // Test data (long text)
    private let activities = [
        "New donation request received from Al Noor Charity with a large quantity of packaged food items that require verification.",
        "Collector Ahmed Hassan has been verified successfully after completing all required safety and identity checks.",
        "A donation was flagged due to missing expiration date information and is pending admin review.",
        "System update completed successfully without any issues reported by users."
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        donationOverviewCard.isUserInteractionEnabled = true
        auditLogCard.isUserInteractionEnabled = true

        donationOverviewCard.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(openDonationOverview))
        )

        auditLogCard.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(openAuditLog))
        )


        // Table setup
        tblRecentActivity.dataSource = self
        tblRecentActivity.delegate = self
        tblRecentActivity.isScrollEnabled = false

        // ✅ خلي ارتفاع الـ cells يتمدد حسب النص
        tblRecentActivity.rowHeight = UITableView.automaticDimension
        tblRecentActivity.estimatedRowHeight = 120

        // Quick links border
        styleCard(donationOverviewCard)
        styleCard(auditLogCard)

        // Cards shadow
        let cards: [UIView] = [
            cardRegisteredUsers,
            cardTotalDonations,
            cardFlaggedReports,
            cardVerifiedCollectors
        ]
        cards.forEach { $0.applyCardShadow(cornerRadius: cardCornerRadius) }
    }
    
    
    @objc private func openDonationOverview() {
        performSegue(withIdentifier: "sgDonationOverview", sender: self)
    }

    @objc private func openAuditLog() {
        performSegue(withIdentifier: "sgAuditLog", sender: self)
    }


    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Update shadow paths after layout
        let cards: [UIView] = [
            cardRegisteredUsers,
            cardTotalDonations,
            cardFlaggedReports,
            cardVerifiedCollectors
        ]
        cards.forEach { $0.updateShadowPath(cornerRadius: cardCornerRadius) }

        // ✅ أهم جزء: خليه يحسب ارتفاع الجدول ويكبره داخل الـ ScrollView
        updateRecentActivityTableHeight()
    }

    private func updateRecentActivityTableHeight() {
        // لازم يتأكد إن الـ layout جاهز
        tblRecentActivity.layoutIfNeeded()
        tblRecentActivityHeight.constant = tblRecentActivity.contentSize.height
    }

    private func styleCard(_ v: UIView) {
        v.layer.cornerRadius = 12
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor(red: 247/255, green: 212/255, blue: 76/255, alpha: 1).cgColor // #F7D44C
        v.layer.masksToBounds = true
        v.backgroundColor = .white
    }
}

// MARK: - Card Shadow Helpers
private extension UIView {

    func applyCardShadow(cornerRadius: CGFloat) {
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = false

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.09
        layer.shadowRadius = 2
        layer.shadowOffset = CGSize(width: 0, height: 4)

        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
    }

    func updateShadowPath(cornerRadius: CGFloat) {
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
    }
}

// MARK: - Table DataSource / Delegate
extension AdminDashboardViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activities.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "cellActivity", for: indexPath)

        // IMPORTANT: تأكدي lblActivityText Tag = 2 في Storyboard
        let lbl = cell.viewWithTag(2) as? UILabel
        lbl?.text = activities[indexPath.row]
        lbl?.numberOfLines = 0

        cell.selectionStyle = .none
        return cell
    }
}
