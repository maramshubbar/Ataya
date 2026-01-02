import UIKit

final class MyAddressListViewController: UIViewController {

    @IBOutlet weak var buttonContainer: UIView!
    @IBOutlet weak var myAddressButton: UIButton!
    @IBOutlet weak var ngoButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    var draft: DraftDonation?

    private enum Choice { case myAddress, ngo }
    private var selectedChoice: Choice?

    private let grayBorder    = UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1) // #999999
    private let selectedBorder = UIColor(red: 254/255, green: 196/255, blue: 0/255,   alpha: 1) // #FEC400
    private let selectedBG     = UIColor(red: 255/255, green: 251/255, blue: 231/255, alpha: 1) // #FFFBE7


    private let pickupSB = UIStoryboard(name: "Pickup", bundle: nil)

    override func viewDidLoad() {
        super.viewDidLoad()

        if draft == nil { draft = DraftSession.current }
            DraftSession.current = draft

            if draft == nil {
                setNextEnabled(false)
              
                return
        }

        setupOptionButton(myAddressButton)
        setupOptionButton(ngoButton)

        myAddressButton.addTarget(self, action: #selector(myAddressTapped), for: .touchUpInside)
        ngoButton.addTarget(self, action: #selector(ngoTapped), for: .touchUpInside)

        nextButton.removeTarget(nil, action: nil, for: .allEvents)
        nextButton.addTarget(self, action: #selector(nextTappedProgrammatic), for: .touchUpInside)

        applyDefaultStyle(myAddressButton)
        applyDefaultStyle(ngoButton)
        setNextEnabled(false)
    }

    private func setupOptionButton(_ button: UIButton) {
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.contentHorizontalAlignment = .center

        button.layer.cornerRadius = 4
        button.clipsToBounds = true

        button.backgroundColor = .white
        button.layer.borderWidth = 1
        button.layer.borderColor = grayBorder.cgColor

        button.addTarget(self, action: #selector(pressDown(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(pressUp(_:)), for: [.touchUpInside, .touchCancel, .touchDragExit])
    }

    @objc private func myAddressTapped() { select(.myAddress) }
    @objc private func ngoTapped() { select(.ngo) }

    private func select(_ choice: Choice) {
        selectedChoice = choice

        applyDefaultStyle(myAddressButton)
        applyDefaultStyle(ngoButton)

        switch choice {
        case .myAddress: applySelectedStyle(myAddressButton)
        case .ngo: applySelectedStyle(ngoButton)
        }

        setNextEnabled(true)
    }

    private func applyDefaultStyle(_ button: UIButton) {
        button.backgroundColor = .white
        button.layer.borderWidth = 1
        button.layer.borderColor = grayBorder.cgColor
    }

    private func applySelectedStyle(_ button: UIButton) {
        button.backgroundColor = selectedBG
        button.layer.borderWidth = 2
        button.layer.borderColor = selectedBorder.cgColor
    }

    private func setNextEnabled(_ enabled: Bool) {
        nextButton.isEnabled = enabled
        nextButton.alpha = enabled ? 1.0 : 0.5
    }

    @objc private func nextTappedProgrammatic() {

        guard let choice = selectedChoice else {
            showAlert(title: "Choose an option", message: "Select My Address or NGO first.")
            return
        }

        guard let draftObj = draft else {
            showAlert(title: "Missing draft", message: "Draft not found. Please go back and try again.")
            return
        }

        switch choice {

        case .ngo:
            draftObj.pickupMethod = "ngo"
            draftObj.pickupAddress = nil

            setNextEnabled(false)

            // ✅ Upload (if needed) ثم Save ثم Popup
            uploadThenSave(draftObj) { [weak self] error in
                guard let self else { return }
                self.setNextEnabled(true)

                if let error {
                    self.showAlert(title: "Save failed", message: error.localizedDescription)
                    return
                }

                self.presentThankYouPopup()
            }

        case .myAddress:
            draftObj.pickupMethod = "myAddress"

            guard let vc = pickupSB.instantiateViewController(withIdentifier: "MyAddressListTableViewController") as? MyAddressListTableViewController else {
                showAlert(title: "Storyboard Error", message: "In Pickup.storyboard set Storyboard ID = MyAddressListTableViewController")
                return
            }

            vc.draft = draftObj
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    // MARK: - ✅ Upload then Save
    private func uploadThenSave(_ draft: DraftDonation, completion: @escaping (Error?) -> Void) {

        // إذا عنده صور محلية بس ما عنده روابط كلاودينري -> ارفع أول
        if !draft.images.isEmpty && draft.photoURLs.isEmpty {

            CloudinaryUploader.shared.uploadImages(draft.images, folder: "donations") { res in
                switch res {
                case .success(let items):
                    let urls = items.map { $0.secureUrl }
                    let ids  = items.map { $0.publicId }
                    draft.applyCloudinaryUploads(urls: urls, publicIds: ids, replace: true)

                    DonationDraftSaver.shared.saveAfterPickup(draft: draft) { err in
                        completion(err)
                    }

                case .failure(let err):
                    completion(err)
                }
            }
            return
        }

        
        DonationDraftSaver.shared.saveAfterPickup(draft: draft) { err in
            completion(err)
        }
    }

    private func presentThankYouPopup() {
        guard let popup = pickupSB.instantiateViewController(withIdentifier: "PopupConfirmPickupViewController") as? PopupConfirmPickupViewController else {
            showAlert(title: "Storyboard Error", message: "In Pickup.storyboard set Storyboard ID = PopupConfirmPickupViewController")
            return
        }

        popup.modalPresentationStyle = .overFullScreen
        popup.modalTransitionStyle = .crossDissolve
        present(popup, animated: true)
    }

    @objc private func pressDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.10) {
            sender.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
            sender.alpha = 0.92
        }
    }

    @objc private func pressUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.10) {
            sender.transform = .identity
            sender.alpha = 1.0
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
}
