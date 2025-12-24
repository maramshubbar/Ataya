import UIKit

final class DonorTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    private let centerButton = UIButton(type: .custom)
    private var centerButtonConstraints: [NSLayoutConstraint] = []
    
    private var isShowingDonateSheet = false
    private var lastSelectedIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        definesPresentationContext = true
        
        lastSelectedIndex = selectedIndex
        
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
        
        items[0].image = templatedImage("housefillgrey", size: size)
        items[0].selectedImage = templatedImage("housefillgrey", size: size)
        
        items[1].image = templatedImage("earthglobegrey", size: size)
        items[1].selectedImage = templatedImage("earthglobegrey", size: size)
        
        items[2].image = UIImage(named: "tab_empty")?.withRenderingMode(.alwaysOriginal)
        items[2].selectedImage = UIImage(named: "tab_empty")?.withRenderingMode(.alwaysOriginal)
        
        items[3].image = templatedImage("prizegrey", size: size)
        items[3].selectedImage = templatedImage("prizegrey", size: size)
        
        items[4].image = templatedImage("usergrey", size: size)
        items[4].selectedImage = templatedImage("usergrey", size: size)
    }
    
    private func templatedImage(_ name: String, size: CGSize) -> UIImage? {
        guard let img = UIImage(named: name) else { return nil }
        return img.resized(to: size).withRenderingMode(.alwaysTemplate)
    }
    
    private func setupCenterButton() {
        centerButton.setBackgroundImage(UIImage(named: "hex_report_bg"), for: .normal)
        centerButton.setImage(UIImage(named: "ic_donate_center"), for: .normal)
        centerButton.addTarget(self, action: #selector(centerTapped), for: .touchUpInside)
        centerButton.isExclusiveTouch = true
        
        tabBar.addSubview(centerButton)
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
    
    // ✅ خزّني آخر تاب حقيقي (غير Donate)
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if selectedIndex != 2 { lastSelectedIndex = selectedIndex }
    }
    
    func tabBarController(_ tabBarController: UITabBarController,
                          shouldSelect viewController: UIViewController) -> Bool {
        if let idx = viewControllers?.firstIndex(of: viewController), idx == 2 {
            showDonateSheetOnce()
            return false
        }
        return true
    }
    
    @objc private func centerTapped() {
        showDonateSheetOnce()
    }
    
    private func showDonateSheetOnce() {
        // ✅ رجّعي التاب للآخر واحد (عشان ما يروح للشاشة الفاضية)
        selectedIndex = lastSelectedIndex
        
        guard !isShowingDonateSheet else { return }
        guard presentedViewController == nil else { return }
        
        isShowingDonateSheet = true
        
        let sb = UIStoryboard(name: "Main", bundle: nil)
        guard let donateVC = sb.instantiateViewController(withIdentifier: "DonateViewController") as? DonateViewController else {
            isShowingDonateSheet = false
            assertionFailure("DonateViewController Storyboard ID not found")
            return
        }
        
        donateVC.onSelect = { [weak self] option in
            guard let self else { return }
            self.dismiss(animated: true) {
                self.isShowingDonateSheet = false
                self.openDonate(option)
            }
        }
        
        let nav = UINavigationController(rootViewController: donateVC)
        nav.navigationBar.prefersLargeTitles = false
        
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = .white
        navAppearance.shadowColor = UIColor.systemGray5
        nav.navigationBar.standardAppearance = navAppearance
        nav.navigationBar.scrollEdgeAppearance = navAppearance
        nav.navigationBar.compactAppearance = navAppearance
        
        let tabBarHeight = tabBar.frame.height
        let container = DonateSheetContainerViewController(content: nav, tabBarHeight: tabBarHeight)
        
        container.onDismiss = { [weak self] in
            self?.isShowingDonateSheet = false
        }
        
        container.modalPresentationStyle = .overCurrentContext
        container.modalTransitionStyle = .crossDissolve
        
        present(container, animated: true)
    }
    
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
            nav?.pushViewController(sb.instantiateViewController(withIdentifier: "GiftOfMercyViewController"), animated: true)
        }
    }
}

private extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
