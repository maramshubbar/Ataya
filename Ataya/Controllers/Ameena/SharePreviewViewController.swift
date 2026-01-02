import UIKit

final class SharePreviewViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var chartContainerView: UIView!

    @IBOutlet weak var messageContainerView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var shareButton: UIButton!

    var selectedSection: Int = 1   // 1 Meals, 2 Waste, 3 Env
    var selectedPeriod: Int = 0    // 0 Daily, 1 Monthly, 2 Yearly
    
    var imageToShare: UIImage?
    var shareText: String?

    private let atayaYellow = UIColor(red: 0xF7/255, green: 0xD4/255, blue: 0x4C/255, alpha: 1)
    private let cardBeige = UIColor(red: 0xF6/255, green: 0xF2/255, blue: 0xD8/255, alpha: 1)

    private var currentChartView: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Impact Dashboard"
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .systemBackground

        styleUI()
        applyContent()
        renderChart() // ✅ الجديد: يرسم الشارت داخل الكونتينر
    }

    private func styleUI() {
        // Title label
        titleLabel.textAlignment = .center
        titleLabel.textColor = .label
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        titleLabel.numberOfLines = 1
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.85

        // Chart container (Host)
        chartContainerView.backgroundColor = UIColor.systemGray6
        chartContainerView.layer.cornerRadius = 12
        chartContainerView.clipsToBounds = true

        // Message card
        messageContainerView.backgroundColor = cardBeige
        messageContainerView.layer.cornerRadius = 18
        messageContainerView.layer.borderWidth = 1
        messageContainerView.layer.borderColor = UIColor.systemGray4.cgColor
        messageContainerView.clipsToBounds = true

        // Message text
        messageLabel.textColor = .label
        messageLabel.numberOfLines = 0
        messageLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        messageLabel.lineBreakMode = .byWordWrapping

        // Share button
        shareButton.setTitle("Share Impact", for: .normal)
        shareButton.backgroundColor = atayaYellow
        shareButton.setTitleColor(.black, for: .normal)
        shareButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        shareButton.layer.cornerRadius = 14
        shareButton.clipsToBounds = true
    }

    private func applyContent() {
        switch selectedSection {
        case 1:
            titleLabel.text = "Meals Provided"
            messageLabel.text = mealsMessage(period: selectedPeriod)
        case 2:
            titleLabel.text = "Food Waste Prevented"
            messageLabel.text = wasteMessage(period: selectedPeriod)
        default:
            titleLabel.text = "Environmental Equivalent"
            messageLabel.text = envMessage(period: selectedPeriod)
        }
    }

    // MARK: - Messages
    private func mealsMessage(period: Int) -> String {
        return """
        You have shared 145 meals with people in need — a beautiful contribution that brought real change to your community.
        Your impact peaked in July with 42 meals, showing amazing generosity during that month.

        Every meal you donated helped reduce hunger and spread kindness.
        """
    }

    private func wasteMessage(period: Int) -> String {
        return """
        Your consistent donations helped prevent food waste and support sustainability.
        Your strongest period showed steady giving that made a meaningful difference.

        Small actions add up to big environmental change.
        """
    }

    private func envMessage(period: Int) -> String {
        return """
        Your donations didn’t just help people — they helped the environment too.
        Your impact contributed to a greener community and reduced environmental strain.

        Thank you for making a difference.
        """
    }

    // MARK: - Chart Rendering (✅ أهم تعديل)
    private func renderChart() {
        // احذف اللي قبل
        currentChartView?.removeFromSuperview()
        currentChartView = nil

        // اختار نوع الشارت حسب السيكشن
        let chartView: UIView

        if selectedSection == 1 {
            // Bar chart
            let v = ImpactBarChartView()
            v.values = valuesFor(section: selectedSection, period: selectedPeriod)
            chartView = v
        } else if selectedSection == 2 {
            // Line chart
            let v = ImpactLineChartView()
            v.values = valuesFor(section: selectedSection, period: selectedPeriod)
            chartView = v
        } else {
            // Pie chart
            let v = ImpactPieChartView()
            v.values = valuesFor(section: selectedSection, period: selectedPeriod)
            chartView = v
        }

        chartView.translatesAutoresizingMaskIntoConstraints = false
        chartView.backgroundColor = .clear

        chartContainerView.addSubview(chartView)

        NSLayoutConstraint.activate([
            chartView.topAnchor.constraint(equalTo: chartContainerView.topAnchor),
            chartView.leadingAnchor.constraint(equalTo: chartContainerView.leadingAnchor),
            chartView.trailingAnchor.constraint(equalTo: chartContainerView.trailingAnchor),
            chartView.bottomAnchor.constraint(equalTo: chartContainerView.bottomAnchor)
        ])

        currentChartView = chartView

        // مهم لرسم الشارت
        chartView.setNeedsDisplay()
        chartView.layoutIfNeeded()
    }

    private func valuesFor(section: Int, period: Int) -> [CGFloat] {
        // داتا مؤقتة لين Firebase
        switch (section, period) {
        case (1, 0): return [1, 2, 1, 3, 2, 4, 2]
        case (1, 1): return [4, 23, 24, 12, 15, 40, 45, 39, 31, 30, 35, 28]
        case (1, 2): return [80, 95, 110, 120, 140, 160, 155, 170, 165, 180, 190, 210]

        case (2, 0): return [2, 3, 2, 4, 3, 5, 4]
        case (2, 1): return [10, 14, 12, 18, 16, 22, 20, 25, 21, 27, 24, 30]
        case (2, 2): return [20, 25, 28, 30, 35, 38, 40, 42, 45, 48, 50, 55]

        case (3, 0): return [55, 25, 20]
        case (3, 1): return [60, 22, 18]
        default:     return [65, 20, 15]
        }
    }

    // MARK: - Share (✅ نخليه “صورة”)
    @IBAction func shareTapped(_ sender: UIButton) {

        // 1) جهّز صورة للشير (مثل mock)
        // إذا ما عندج imageToShare، خليه يسوي Screenshot للصفحة
        let img = imageToShare ?? view.snapshotImage()

        // 2) النص اختياري (تقدرين تلغينه إذا تبين بس صورة)
        let text = (shareText?.isEmpty == false)
        ? shareText!
        : "\(titleLabel.text ?? "")\n\n\(messageLabel.text ?? "")"

        // إذا تبين الشير “صورة فقط” مثل Figma:
        let items: [Any] = [img]  // <- صورة فقط
        // وإذا تبينه صورة + نص:
        // let items: [Any] = [text, img]

        let vc = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(vc, animated: true)
    }
}

// MARK: - Snapshot Helper
private extension UIView {
    func snapshotImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { _ in
            drawHierarchy(in: bounds, afterScreenUpdates: true)
        }
    }
}
