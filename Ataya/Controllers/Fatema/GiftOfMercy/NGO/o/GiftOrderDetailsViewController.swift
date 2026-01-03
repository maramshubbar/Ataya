//import UIKit
//import Foundation
//import MessageUI
//import FirebaseFirestore
//
//final class GiftOrderDetailsViewController: UIViewController, MFMailComposeViewControllerDelegate {
//
//    // ✅ callback (optional)
//    var onStatusUpdated: ((String, NGOGiftOrderStatus) -> Void)?
//
//    private var order: NGOGiftOrder
//
//    // UI
//    private let scrollView = UIScrollView()
//    private let contentStack = UIStackView()
//
//    private let titleLabel = UILabel()
//    private let dateLabel = UILabel()
//    private let statusBadge = UILabel()
//
//    private let recipientTitleLabel = UILabel()
//    private let recipientNameLabel = UILabel()
//    private let recipientEmailLabel = UILabel()
//
//    private let messageTitleLabel = UILabel()
//    private let messageLabel = UILabel()
//
//    private let cardTitleLabel = UILabel()
//    private let cardIdLabel = UILabel()
//
//    private let sendEmailButton = UIButton(type: .system)
//    private let markSentButton = UIButton(type: .system)
//
//    private let spinner = UIActivityIndicatorView(style: .medium)
//
//    // Theme
//    private let brandYellow = UIColor(red: 247/255, green: 212/255, blue: 76/255, alpha: 1)
//
//    private static let df: DateFormatter = {
//        let f = DateFormatter()
//        f.dateStyle = .medium
//        f.timeStyle = .short
//        return f
//    }()
//
//    // Firestore
//    private let db = Firestore.firestore()
//
//    init(order: NGOGiftOrder) {
//        self.order = order
//        super.init(nibName: nil, bundle: nil)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("Use init(order:) instead.")
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupNav()
//        setupUI()
//        bind()
//    }
//
//    private func setupNav() {
//        view.backgroundColor = .systemBackground
//        title = "Order Details"
//        navigationItem.largeTitleDisplayMode = .never
//    }
//
//    private func setupUI() {
//        // Scroll
//        scrollView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(scrollView)
//
//        contentStack.axis = .vertical
//        contentStack.spacing = 14
//        contentStack.translatesAutoresizingMaskIntoConstraints = false
//        scrollView.addSubview(contentStack)
//
//        NSLayoutConstraint.activate([
//            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//
//            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
//            contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
//            contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16),
//            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24)
//        ])
//
//        // Header card
//        let (headerCard, headerStack) = makeCard(title: "Summary")
//
//        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
//        titleLabel.numberOfLines = 0
//
//        dateLabel.font = .systemFont(ofSize: 14)
//        dateLabel.textColor = .secondaryLabel
//
//        statusBadge.font = .systemFont(ofSize: 13, weight: .semibold)
//        statusBadge.textAlignment = .center
//        statusBadge.textColor = .black
//        statusBadge.layer.cornerRadius = 16
//        statusBadge.clipsToBounds = true
//        statusBadge.translatesAutoresizingMaskIntoConstraints = false
//        statusBadge.heightAnchor.constraint(equalToConstant: 32).isActive = true
//        statusBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 110).isActive = true
//
//        let topRow = UIStackView(arrangedSubviews: [titleLabel, statusBadge])
//        topRow.axis = .horizontal
//        topRow.alignment = .center
//        topRow.spacing = 10
//
//        headerStack.addArrangedSubview(topRow)
//        headerStack.addArrangedSubview(dateLabel)
//        contentStack.addArrangedSubview(headerCard)
//
//        // Recipient card
//        let (recCard, recStack) = makeCard(title: "Send certificate to")
//        recipientTitleLabel.text = "Recipient"
//        recipientTitleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
//
//        recipientNameLabel.font = .systemFont(ofSize: 15)
//        recipientEmailLabel.font = .systemFont(ofSize: 14)
//        recipientEmailLabel.textColor = .secondaryLabel
//
//        recStack.addArrangedSubview(recipientTitleLabel)
//        recStack.addArrangedSubview(recipientNameLabel)
//        recStack.addArrangedSubview(recipientEmailLabel)
//        contentStack.addArrangedSubview(recCard)
//
//        // Message card
//        let (msgCard, msgStack) = makeCard(title: "Personal message")
//        messageTitleLabel.text = "Message"
//        messageTitleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
//
//        messageLabel.font = .systemFont(ofSize: 14)
//        messageLabel.textColor = .secondaryLabel
//        messageLabel.numberOfLines = 0
//
//        msgStack.addArrangedSubview(messageTitleLabel)
//        msgStack.addArrangedSubview(messageLabel)
//        contentStack.addArrangedSubview(msgCard)
//
//        // Card design card
//        let (cardInfoCard, cardInfoStack) = makeCard(title: "Card design")
//        cardTitleLabel.text = "Card ID"
//        cardTitleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
//
//        cardIdLabel.font = .systemFont(ofSize: 14)
//        cardIdLabel.textColor = .secondaryLabel
//        cardIdLabel.numberOfLines = 0
//
//        cardInfoStack.addArrangedSubview(cardTitleLabel)
//        cardInfoStack.addArrangedSubview(cardIdLabel)
//        contentStack.addArrangedSubview(cardInfoCard)
//
//        // Buttons
//        sendEmailButton.setTitle("Send Certificate Email", for: .normal)
//        sendEmailButton.setTitleColor(.black, for: .normal)
//        sendEmailButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
//        sendEmailButton.backgroundColor = brandYellow
//        sendEmailButton.layer.cornerRadius = 12
//        sendEmailButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
//        sendEmailButton.addTarget(self, action: #selector(sendEmailTapped), for: .touchUpInside)
//
//        markSentButton.setTitle("Mark as Sent", for: .normal)
//        markSentButton.setTitleColor(.white, for: .normal)
//        markSentButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
//        markSentButton.backgroundColor = .systemGreen
//        markSentButton.layer.cornerRadius = 12
//        markSentButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
//        markSentButton.addTarget(self, action: #selector(markSentTapped), for: .touchUpInside)
//
//        // Spinner on send button
//        spinner.hidesWhenStopped = true
//        spinner.translatesAutoresizingMaskIntoConstraints = false
//        sendEmailButton.addSubview(spinner)
//        NSLayoutConstraint.activate([
//            spinner.centerYAnchor.constraint(equalTo: sendEmailButton.centerYAnchor),
//            spinner.trailingAnchor.constraint(equalTo: sendEmailButton.trailingAnchor, constant: -16)
//        ])
//
//        contentStack.addArrangedSubview(sendEmailButton)
//        contentStack.addArrangedSubview(markSentButton)
//    }
//
//    private func makeCard(title: String) -> (UIView, UIStackView) {
//        let card = UIView()
//        card.backgroundColor = .secondarySystemGroupedBackground
//        card.layer.cornerRadius = 16
//
//        let t = UILabel()
//        t.text = title
//        t.font = .systemFont(ofSize: 15, weight: .semibold)
//
//        let inner = UIStackView()
//        inner.axis = .vertical
//        inner.spacing = 8
//        inner.translatesAutoresizingMaskIntoConstraints = false
//
//        let container = UIStackView(arrangedSubviews: [t, inner])
//        container.axis = .vertical
//        container.spacing = 10
//        container.translatesAutoresizingMaskIntoConstraints = false
//
//        card.addSubview(container)
//
//        NSLayoutConstraint.activate([
//            container.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
//            container.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
//            container.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
//            container.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12)
//        ])
//
//        return (card, inner)
//    }
//
//    private func bind() {
//        titleLabel.text = "Order ID: \(order.id)"
//        dateLabel.text = "Date: " + Self.df.string(from: order.createdAt)
//
//        recipientNameLabel.text = order.recipientName
//        recipientEmailLabel.text = order.recipientEmail
//
//        let msg = order.personalMessage.trimmingCharacters(in: .whitespacesAndNewlines)
//        messageLabel.text = msg.isEmpty ? "No message." : msg
//
//        cardIdLabel.text = order.cardId.isEmpty ? "—" : order.cardId
//
//        applyStatus(order.status)
//
//        // ✅ show only when NOT sent
//        let isSent = (order.status == .sent)
//        markSentButton.isHidden = isSent
//        sendEmailButton.isHidden = isSent
//    }
//
//    // ✅ UI shows only: Processing / Sent
//    private func applyStatus(_ status: NGOGiftOrderStatus) {
//        let isSent = (status == .sent)
//        statusBadge.text = isSent ? "Sent" : "Processing"
//        statusBadge.backgroundColor = isSent
//            ? UIColor.systemGreen.withAlphaComponent(0.25)
//            : brandYellow.withAlphaComponent(0.35)
//    }
//
//    private func setLoading(_ loading: Bool) {
//        sendEmailButton.isEnabled = !loading
//        markSentButton.isEnabled = !loading
//        loading ? spinner.startAnimating() : spinner.stopAnimating()
//        sendEmailButton.alpha = loading ? 0.85 : 1.0
//    }
//
//    // MARK: - Actions
//
//    @objc private func markSentTapped() {
//        let ac = UIAlertController(
//            title: "Mark as Sent?",
//            message: "This will change the order status to Sent.",
//            preferredStyle: .alert
//        )
//        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//        ac.addAction(UIAlertAction(title: "Mark as Sent", style: .default) { [weak self] _ in
//            guard let self else { return }
//            self.setLoading(true)
//
//            self.updateOrderStatusSent(orderId: self.order.id) { [weak self] (err: Error?) in
//                DispatchQueue.main.async(execute: {
//                    guard let self else { return }
//                    self.setLoading(false)
//
//                    if let err {
//                        self.alert("Update error", err.localizedDescription)
//                        return
//                    }
//
//                    self.order = NGOGiftOrder(
//                        id: self.order.id,
//                        ngoId: self.order.ngoId,
//                        donorId: self.order.donorId,
//                        recipientName: self.order.recipientName,
//                        recipientEmail: self.order.recipientEmail,
//                        personalMessage: self.order.personalMessage,
//                        cardId: self.order.cardId,
//                        status: .sent,
//                        createdAt: self.order.createdAt
//                    )
//
//                    self.onStatusUpdated?(self.order.id, .sent)
//                    self.bind()
//                })
//            }
//        })
//
//        present(ac, animated: true)
//    }
//
//    @objc private func sendEmailTapped() {
//        guard MFMailComposeViewController.canSendMail() else {
//            alert("Mail not available", "Mail is not configured on this device/simulator.")
//            return
//        }
//
//        setLoading(true)
//
//        fetchCardImageURL(cardId: order.cardId) { [weak self] result in
//            guard let self else { return }
//
//            switch result {
//            case .failure(let err):
//                DispatchQueue.main.async(execute: {
//                    self.setLoading(false)
//                    self.alert("Card error", err.localizedDescription)
//                })
//
//            case .success(let url):
//                self.downloadImage(urlString: url) { imgResult in
//                    switch imgResult {
//                    case .failure(let err):
//                        DispatchQueue.main.async(execute: {
//                            self.setLoading(false)
//                            self.alert("Image error", err.localizedDescription)
//                        })
//
//                    case .success(let baseImg):
//                        let finalImg = self.drawNameOnCertificate(base: baseImg, name: self.order.recipientName)
//
//                        DispatchQueue.main.async(execute: {
//                            self.setLoading(false)
//
//                            let mail = MFMailComposeViewController()
//                            mail.mailComposeDelegate = self
//                            mail.setToRecipients([self.order.recipientEmail])
//                            mail.setSubject("Gift of Mercy Certificate ✅")
//                            mail.setMessageBody(
//                                "Hi \(self.order.recipientName),\n\nPlease find your certificate attached.\n\nRegards,\nAtaya",
//                                isHTML: false
//                            )
//
//                            if let data = finalImg.pngData() {
//                                mail.addAttachmentData(data, mimeType: "image/png", fileName: "certificate.png")
//                            }
//
//                            self.present(mail, animated: true)
//                        })
//                    }
//                }
//            }
//        }
//    }
//
//    // MARK: - Firestore helpers
//
//    private func fetchCardImageURL(cardId: String, completion: @escaping (Result<String, Error>) -> Void) {
//        guard !cardId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
//            completion(.failure(NSError(domain: "Card", code: 0, userInfo: [NSLocalizedDescriptionKey: "Missing cardId"])))
//            return
//        }
//
//        // ✅ change collection name if yours is different
//        db.collection("cardDesigns").document(cardId).getDocument { snap, err in
//            if let err { completion(.failure(err)); return }
//            guard
//                let data = snap?.data(),
//                let url = data["imageURL"] as? String,
//                !url.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
//            else {
//                completion(.failure(NSError(domain: "Card", code: 0, userInfo: [NSLocalizedDescriptionKey: "imageURL not found in cardDesigns/\(cardId)"])))
//                return
//            }
//            completion(.success(url))
//        }
//    }
//
//    private func updateOrderStatusSent(orderId: String, completion: @escaping (Error?) -> Void) {
//        // ✅ change collection name if yours is different
//        db.collection("gift_orders").document(orderId).setData([
//            "status": NGOGiftOrderStatus.sent.rawValue,
//            "updatedAt": FieldValue.serverTimestamp()
//        ], merge: true, completion: completion)
//    }
//
//    // MARK: - Certificate name drawing
//
//    private func drawNameOnCertificate(base: UIImage, name: String) -> UIImage {
//        let format = UIGraphicsImageRendererFormat()
//        format.scale = base.scale
//
//        let renderer = UIGraphicsImageRenderer(size: base.size, format: format)
//        return renderer.image { _ in
//            base.draw(in: CGRect(origin: .zero, size: base.size))
//
//            let font = UIFont.systemFont(ofSize: base.size.width * 0.035, weight: .semibold)
//            let attrs: [NSAttributedString.Key: Any] = [
//                .font: font,
//                .foregroundColor: UIColor.black
//            ]
//
//            // ✅ مكان الاسم على السطر (عدّلي y إذا تبينه أعلى/أوطى)
//            let x = base.size.width * 0.36
//            let y = base.size.height * 0.855
//            let w = base.size.width * 0.56
//            let h = base.size.height * 0.04
//
//            (name as NSString).draw(in: CGRect(x: x, y: y, width: w, height: h), withAttributes: attrs)
//        }
//    }
//
//    private func downloadImage(urlString: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
//        guard let url = URL(string: urlString) else {
//            completion(.failure(NSError(domain: "URL", code: 0, userInfo: [NSLocalizedDescriptionKey: "Bad imageURL"])))
//            return
//        }
//
//        URLSession.shared.dataTask(with: url) { data, _, err in
//            if let err { completion(.failure(err)); return }
//            guard let data, let img = UIImage(data: data) else {
//                completion(.failure(NSError(domain: "IMG", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to decode image"])))
//                return
//            }
//            completion(.success(img))
//        }.resume()
//    }
//
//    // MARK: - Mail delegate
//
//    func mailComposeController(_ controller: MFMailComposeViewController,
//                               didFinishWith result: MFMailComposeResult,
//                               error: Error?) {
//        controller.dismiss(animated: true)
//
//        guard result == .sent else { return }
//
//        setLoading(true)
//
//        updateOrderStatusSent(orderId: order.id) { [weak self] err in
//            DispatchQueue.main.async(execute: {
//                guard let self = self else { return }
//                self.setLoading(false)
//
//                if let err = err {
//                    self.alert("Update error", err.localizedDescription)
//                    return
//                }
//
//                self.order = NGOGiftOrder(
//                    id: self.order.id,
//                    ngoId: self.order.ngoId,
//                    donorId: self.order.donorId,
//                    recipientName: self.order.recipientName,
//                    recipientEmail: self.order.recipientEmail,
//                    personalMessage: self.order.personalMessage,
//                    cardId: self.order.cardId,
//                    status: .sent,
//                    createdAt: self.order.createdAt
//                )
//
//                self.onStatusUpdated?(self.order.id, .sent)
//                self.bind()
//            })
//        }
//    }
//
//    // MARK: - Alerts
//
//    private func alert(_ title: String, _ msg: String) {
//        let ac = UIAlertController(title: title, message: msg, preferredStyle: .alert)
//        ac.addAction(UIAlertAction(title: "OK", style: .default))
//        present(ac, animated: true)
//    }
//}
