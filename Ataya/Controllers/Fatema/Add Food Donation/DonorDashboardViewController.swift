//
//  DonorDashboardViewController.swift
//  Ataya
//
//  Created by Fatema Maitham on 19/12/2025.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

struct DashboardCampaign {
    let imageName: String
    let imageUrl: String?
    let tag: String
    let title: String
    let createdAt: Date?
}

final class DonorDashboardViewController: UIViewController,
    UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,
    UITableViewDataSource, UITableViewDelegate {

    private let donateStoryboardName = "DonorDashboard"
    private let donateStoryboardID   = "DonateViewController"

    private let addStoryboardName    = "Add"
    private let addFoodStoryboardID  = "AddFoodDonationViewController"

    private let advocacyStoryboardName = "DonorDashboard"
    private let advocacyStoryboardID   = "AdvocacyViewController"
    
    private let recurringStoryboardName = "Recurring"              // عدّليه إذا اسم الستوريبورد غير
    private let recurringStoryboardID   = "RecurringViewController" // عدّليه لِـStoryboard ID الحقيقي

    // Firestore
    private let db = Firestore.firestore()
    private var campaignsListener: ListenerRegistration?
    private var ongoingListener: ListenerRegistration?

    private var campaigns: [DashboardCampaign] = []
    private var ongoing: [OngoingDonationItem] = []

    // Outlets (لا تمسحينهم)
    @IBOutlet weak var recurringStackView: UIStackView!
    @IBOutlet weak var discoverStackView: UIStackView!
    @IBOutlet weak var historyStackView: UIStackView!

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var quickToolsTitleLabel: UILabel!
    @IBOutlet weak var ongoingDonationTitleLabel: UILabel!

    @IBOutlet weak var campaignsCollectionView: UICollectionView!
    
    private let historyStoryboardName = "DonationHist" // عدليها لو اسم الستوريبورد غير
    private let historyStoryboardID   = "DonationHistoryViewController" // لازم نفس Storyboard ID بالضبط

    override func viewDidLoad() {
        super.viewDidLoad()
        setupQuickToolsTaps()


        // Collection
        campaignsCollectionView.dataSource = self
        campaignsCollectionView.delegate = self
        campaignsCollectionView.backgroundColor = .clear
        campaignsCollectionView.showsHorizontalScrollIndicator = false
        campaignsCollectionView.register(
            UINib(nibName: "CampaignCellDashboard", bundle: nil),
            forCellWithReuseIdentifier: CampaignCellDashboard.reuseId
        )

        if let layout = campaignsCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 24
            layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            layout.estimatedItemSize = .zero
        }

        // Table
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.isScrollEnabled = false
        tableView.register(
            UINib(nibName: "OngoingDonationCell", bundle: nil),
            forCellReuseIdentifier: OngoingDonationCell.reuseId
        )
        tableView.rowHeight = 120
        tableView.contentInset = .zero
        tableView.scrollIndicatorInsets = .zero

        updateTableHeight()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startFirestore()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopFirestore()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTableHeight()
        let tabH = tabBarController?.tabBar.frame.height ?? 0
        scrollView.contentInset.bottom = tabH + 24
        scrollView.verticalScrollIndicatorInsets.bottom = tabH + 24

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollView.setContentOffset(.zero, animated: false)
    }

    // ✅ اربطي زر الـ + / Donate Button بهذي الـIBAction
    @IBAction func openDonateSheetTapped(_ sender: Any) {
        openDonateSheet()
    }

    private func openDonateSheet() {
        let sb = UIStoryboard(name: donateStoryboardName, bundle: .main)

        guard let donateVC = sb.instantiateViewController(withIdentifier: donateStoryboardID) as? DonateViewController else {
            assertionFailure("❌ \(donateStoryboardName).storyboard does NOT contain ID '\(donateStoryboardID)'")
            return
        }

        let nav = UINavigationController(rootViewController: donateVC)
        nav.modalPresentationStyle = .pageSheet

        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 24
        }

        donateVC.onSelect = { [weak self] option in
            guard let self else { return }
            switch option {
            case .food:
                self.pushVC(storyboardName: self.addStoryboardName, storyboardID: self.addFoodStoryboardID)
            case .advocacy:
                self.pushVC(storyboardName: self.advocacyStoryboardName, storyboardID: self.advocacyStoryboardID)
            default:
                self.showNotReady("This page is not added yet")
            }
        }

        present(nav, animated: true)
    }
    
    private func setupQuickToolsTaps() {
        // لازم عشان الستاك يستقبل لمس
        recurringStackView.isUserInteractionEnabled = true
        discoverStackView.isUserInteractionEnabled = true
        historyStackView.isUserInteractionEnabled = true

        let recurringTap = UITapGestureRecognizer(target: self, action: #selector(recurringTapped))
        recurringStackView.addGestureRecognizer(recurringTap)

        let discoverTap = UITapGestureRecognizer(target: self, action: #selector(discoverTapped))
        discoverStackView.addGestureRecognizer(discoverTap)

        let historyTap = UITapGestureRecognizer(target: self, action: #selector(historyTapped))
        historyStackView.addGestureRecognizer(historyTap)
    }

    @objc private func recurringTapped() {
        pushVC(storyboardName: recurringStoryboardName, storyboardID: recurringStoryboardID)
    }

    @objc private func discoverTapped() {
        // إذا عندج صفحة Discover NGOs
        // pushVC(storyboardName: "DiscoverNGO", storyboardID: "DiscoverNGOViewController")
    }

    @objc private func historyTapped() {
        // إذا عندج Donation History
        // pushVC(storyboardName: "DonHist", storyboardID: "DonationHistoryViewController")
    }


    private func showNotReady(_ msg: String) {
        let alert = UIAlertController(title: "Not ready", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func pushVC(storyboardName: String, storyboardID: String) {
        let sb = UIStoryboard(name: storyboardName, bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: storyboardID)
        vc.hidesBottomBarWhenPushed = true

        if let nav = self.navigationController {
            nav.pushViewController(vc, animated: true)
        } else if let nav = self.tabBarController?.selectedViewController as? UINavigationController {
            nav.pushViewController(vc, animated: true)
        } else {
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
    }
    
    private func setupQuickToolTaps() {
        // مهم: StackView أحيانًا ما تستقبل لمس إذا عناصرها بس labels/images
        recurringStackView.isUserInteractionEnabled = true
        discoverStackView.isUserInteractionEnabled = true
        historyStackView.isUserInteractionEnabled = true

        recurringStackView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(openRecurring))
        )

        discoverStackView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(openDiscoverNGOs))
        )

        historyStackView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(openDonationHistory))
        )
    }

    @objc private func openDonationHistory() {
        pushVC(storyboardName: historyStoryboardName, storyboardID: historyStoryboardID)
    }

    @objc private func openRecurring() {
        // عدليهم حسب صفحتكم (إذا عندكم ستوريبورد/ID حق recurring)
        showNotReady("Recurring Donation page not linked yet")
    }

    @objc private func openDiscoverNGOs() {
        // عدليهم حسب صفحتكم (إذا عندكم ستوريبورد/ID حق discover)
        showNotReady("Discover NGOs page not linked yet")
    }


    // MARK: - Firestore (بدون Index requirements)
    private func startFirestore() {
        listenCampaignsNoIndex()
        listenOngoingNoIndex()
    }

    private func stopFirestore() {
        campaignsListener?.remove()
        ongoingListener?.remove()
        campaignsListener = nil
        ongoingListener = nil
    }

//    private func listenCampaignsNoIndex() {
//        campaignsListener?.remove()
//
//        campaignsListener = db.collection("campaigns")
//            .limit(to: 20)
//            .addSnapshotListener { [weak self] snap, err in
//                guard let self else { return }
//                if let err { print("❌ campaigns error:", err); return }
//
//                let docs = snap?.documents ?? []
//                var items: [DashboardCampaign] = docs.map { d in
//                    let data = d.data()
//                    let title = (data["title"] as? String) ?? (data["name"] as? String) ?? "Untitled"
//                    let tag = (data["category"] as? String) ?? (data["tag"] as? String) ?? "General"
//                    let imageUrl = (data["imageUrl"] as? String) ?? (data["image"] as? String)
//                    let imageName = (data["imageName"] as? String) ?? "campaign1"
//                    let createdAt = (data["createdAt"] as? Timestamp)?.dateValue()
//                    return DashboardCampaign(imageName: imageName, imageUrl: imageUrl, tag: tag, title: title, createdAt: createdAt)
//                }
//
//                items.sort { ($0.createdAt ?? .distantPast) > ($1.createdAt ?? .distantPast) }
//                self.campaigns = items
//
//                DispatchQueue.main.async {
//                    self.campaignsCollectionView.reloadData()
//                }
//            }
//    }
    
    
    private func listenCampaignsNoIndex() {
        campaignsListener?.remove()

        campaignsListener = db.collection("campaigns")
            .limit(to: 50)
            .addSnapshotListener { [weak self] snap, err in
                guard let self else { return }
                if let err { print("❌ campaigns error:", err); return }

                let docs = snap?.documents ?? []
                var items: [DashboardCampaign] = []

                for d in docs {
                    let data = d.data()

                    // ✅ أهم سطر: الهوم يعرض بس اللي showOnHome = true
                    let showOnHome = (data["showOnHome"] as? Bool) ?? false
                    guard showOnHome else { continue }

                    let title = (data["title"] as? String) ?? (data["name"] as? String) ?? "Untitled"
                    let tag = (data["category"] as? String) ?? (data["tag"] as? String) ?? "General"
                    let imageUrl = (data["imageUrl"] as? String) ?? (data["image"] as? String)
                    let imageName = (data["imageName"] as? String) ?? "campaign1"
                    let createdAt = (data["createdAt"] as? Timestamp)?.dateValue()

                    items.append(
                        DashboardCampaign(
                            imageName: imageName,
                            imageUrl: imageUrl,
                            tag: tag,
                            title: title,
                            createdAt: createdAt
                        )
                    )
                }

                items.sort { ($0.createdAt ?? .distantPast) > ($1.createdAt ?? .distantPast) }
                self.campaigns = items

                DispatchQueue.main.async {
                    self.campaignsCollectionView.reloadData()
                }
            }
    }


    private func listenOngoingNoIndex() {
        ongoingListener?.remove()

        guard let uid = Auth.auth().currentUser?.uid, !uid.isEmpty else {
            ongoing = []
            tableView.reloadData()
            updateTableHeight()
            return
        }

        ongoingListener = db.collection("donations")
            .whereField("donorId", isEqualTo: uid)
            .limit(to: 20)
            .addSnapshotListener { [weak self] snap, err in
                guard let self else { return }
                if let err { print("❌ ongoing error:", err); return }

                let docs = snap?.documents ?? []
                var items: [OngoingDonationItem] = docs.map { d in
                    let data = d.data()
                    return OngoingDonationItem.fromFirestore(docId: d.documentID, data: data)
                }


                
                items.sort(by: { (a: OngoingDonationItem, b: OngoingDonationItem) -> Bool in
                    (a.updatedAt ?? .distantPast) > (b.updatedAt ?? .distantPast)
                })
                self.ongoing = items

                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.updateTableHeight()
                }
            }
    }

    // MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        ongoing.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: OngoingDonationCell.reuseId, for: indexPath) as! OngoingDonationCell
        cell.configure(with: ongoing[indexPath.row])
        return cell
    }

    // MARK: - CollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        campaigns.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CampaignCellDashboard.reuseId, for: indexPath) as! CampaignCellDashboard
        cell.configure(with: campaigns[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width - 35
        return CGSize(width: width, height: collectionView.bounds.height)
    }

    private func updateTableHeight() {
        tableView.layoutIfNeeded()
        tableHeightConstraint.constant = tableView.contentSize.height
    }
}
