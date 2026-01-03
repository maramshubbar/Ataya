import UIKit

final class DonorTabBarController: UITabBarController, UITabBarControllerDelegate, UIAdaptivePresentationControllerDelegate {

    private let centerButton = UIButton(type: .custom)
    private var centerButtonConstraints: [NSLayoutConstraint] = []

    private var isShowingDonateSheet = false
    private weak var donateNavController: UINavigationController?

    override func viewDidLoad() {
        super.viewDidLoad()

        definesPresentationContext = true
        delegate = self

        if #available(iOS 18.0, *), UIDevice.current.userInterfaceIdiom == .pad {
            traitOverrides.horizontalSizeClass = .compact
        }

        setupTabLook()
        setupTabIconSizes()
        setupCenterButton()
    }

    private func setupTabLook() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.shadowColor = .clear

        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) { tabBar.scrollEdgeAppearance = appearance }

        tabBar.isTranslucent = false
        tabBar.tintColor = UIColor(red: 0.96, green: 0.84, blue: 0.36, alpha: 1.0)
        tabBar.unselectedItemTintColor = UIColor.systemGray2
    }

    private func setupTabIconSizes() {
        guard let items = tabBar.items, items.count >= 5 else { return }
        let size = CGSize(width: 30, height: 30)

        items[0].image = UIImage(named: "housefillgrey")?.resized(to: size).withRenderingMode(.alwaysTemplate)
        items[0].selectedImage = UIImage(named: "housefillgrey")?.resized(to: size).withRenderingMode(.alwaysTemplate)

        items[1].image = UIImage(named: "earthglobegrey")?.resized(to: size).withRenderingMode(.alwaysTemplate)
        items[1].selectedImage = UIImage(named: "earthglobegrey")?.resized(to: size).withRenderingMode(.alwaysTemplate)

        // center dummy
        items[2].image = UIImage(named: "tab_empty")?.withRenderingMode(.alwaysOriginal)
        items[2].selectedImage = UIImage(named: "tab_empty")?.withRenderingMode(.alwaysOriginal)

        items[3].image = UIImage(named: "prizegrey")?.resized(to: size).withRenderingMode(.alwaysTemplate)
        items[3].selectedImage = UIImage(named: "prizegrey")?.resized(to: size).withRenderingMode(.alwaysTemplate)

        items[4].image = UIImage(named: "usergrey")?.resized(to: size).withRenderingMode(.alwaysTemplate)
        items[4].selectedImage = UIImage(named: "usergrey")?.resized(to: size).withRenderingMode(.alwaysTemplate)
    }

    private func setupCenterButton() {
        centerButton.setBackgroundImage(UIImage(named: "hex_report_bg"), for: .normal)
        centerButton.setImage(UIImage(named: "ic_donate_center"), for: .normal)
        centerButton.addTarget(self, action: #selector(centerTapped), for: .touchUpInside)

        if centerButton.superview == nil {
            tabBar.addSubview(centerButton)
        }
        tabBar.bringSubviewToFront(centerButton)

        centerButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.deactivate(centerButtonConstraints)
        centerButtonConstraints = [
            centerButton.centerXAnchor.constraint(equalTo: tabBar.centerXAnchor),
            centerButton.centerYAnchor.constraint(equalTo: tabBar.topAnchor, constant: -7),
            centerButton.widthAnchor.constraint(equalToConstant: 90),
            centerButton.heightAnchor.constraint(equalTo: centerButton.widthAnchor)
        ]
        NSLayoutConstraint.activate(centerButtonConstraints)
    }

    // MARK: - Intercept center tab
    func tabBarController(_ tabBarController: UITabBarController,
                          shouldSelect viewController: UIViewController) -> Bool {
        if let idx = viewControllers?.firstIndex(of: viewController), idx == 2 {
            presentDonateSheet()
            return false
        }
        return true
    }

    @objc private func centerTapped() {
        presentDonateSheet()
    }

    // MARK: - Apple Sheet
    private func presentDonateSheet() {
        guard !isShowingDonateSheet else { return }
        isShowingDonateSheet = true

        let sb = UIStoryboard(name: "DonorDashboard", bundle: nil)
        guard let donateVC = sb.instantiateViewController(withIdentifier: "DonateViewController") as? DonateViewController else {
            assertionFailure("DonateViewController Storyboard ID not found")
            isShowingDonateSheet = false
            return
        }

        let nav = UINavigationController(rootViewController: donateVC)
        nav.modalPresentationStyle = .pageSheet
        nav.presentationController?.delegate = self
        donateNavController = nav

        if let sheet = nav.sheetPresentationController {
            if let sheet = nav.sheetPresentationController {
                sheet.prefersGrabberVisible = true
                sheet.preferredCornerRadius = 28
                sheet.largestUndimmedDetentIdentifier = nil

                if #available(iOS 16.0, *) {
                    let midID = UISheetPresentationController.Detent.Identifier("donateMedium")

                    sheet.detents = [
                        .custom(identifier: midID) { ctx in
                            min(800, ctx.maximumDetentValue * 0.85)
                        },
                        .large()
                    ]

                    sheet.selectedDetentIdentifier = midID
                    sheet.prefersScrollingExpandsWhenScrolledToEdge = true

                    sheet.prefersEdgeAttachedInCompactHeight = true
                    sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
                } else {
                    sheet.detents = [.medium(), .large()]
                    sheet.selectedDetentIdentifier = .medium
                    sheet.prefersScrollingExpandsWhenScrolledToEdge = true
                }
            }

            sheet.largestUndimmedDetentIdentifier = nil
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false

            if #available(iOS 16.0, *) {
                sheet.prefersEdgeAttachedInCompactHeight = true
                sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
            }
        }

        donateVC.onClose = { [weak self] in
            self?.isShowingDonateSheet = false
            self?.donateNavController = nil
        }

        donateVC.onSelect = { [weak self] option in
            guard let self else { return }
            nav.dismiss(animated: true) {
                self.isShowingDonateSheet = false
                self.donateNavController = nil
                self.openDonate(option)
            }
        }

        present(nav, animated: true)
    }

    // ✅ هذا اللي كان يعطي warning عندج — لازم @objc
    @objc func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        isShowingDonateSheet = false
        donateNavController = nil
    }

    // MARK: - Navigate after choosing
    private func openDonate(_ option: DonateOption) {
        let sb = UIStoryboard(name: "Main", bundle: nil)

        let base = selectedViewController
        let nav = (base as? UINavigationController) ?? base?.navigationController

        switch option {
        case .food:
            nav?.pushViewController(sb.instantiateViewController(withIdentifier: "UploadPhotosViewController"), animated: true)

        case .basket:
            nav?.pushViewController(sb.instantiateViewController(withIdentifier: "BasketStartViewController"), animated: true)

        case .funds:
            nav?.pushViewController(sb.instantiateViewController(withIdentifier: "FundsStartViewController"), animated: true)

        case .campaigns:
            nav?.pushViewController(sb.instantiateViewController(withIdentifier: "CampaignsViewController"), animated: true)

        case .advocacy:
            nav?.pushViewController(sb.instantiateViewController(withIdentifier: "AdvocateForGazaViewController"), animated: true)

        case .giftOfMercy:
            nav?.pushViewController(sb.instantiateViewController(withIdentifier: "GiftViewController"), animated: true)
        }
    }
}

