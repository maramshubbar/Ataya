//
//  ImpactSummaryViewController.swift
//  Ataya
//
//  Created by Ameena Khamis on 22/12/2025.
//

import UIKit

final class ImpactSummaryViewController: UIViewController {
    
    //storyboard outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var shareImpactButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var descriptionCard: UIView!
    @IBOutlet weak var chart: ImpactBarChartView!
    
    // Chart data
    private let months = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]
    private let values: [CGFloat] = [4,23,24,12,14,15,40,44,39,31,30,35]

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Impact Dashboard"
        navigationItem.largeTitleDisplayMode = .never

        setupText()
        styleDescriptionCard()
        styleShareButton()
        setupChart()
    }

    private func setupText() {
        // Title shown above the chart
        titleLabel.text = "Meals Provided"
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textAlignment = .center

        // Description text inside the card
        descriptionLabel.text = "Together, we're fighting hunger and reducing food waste."
        descriptionLabel.numberOfLines = 0
        descriptionLabel.font = .systemFont(ofSize: 17, weight: .medium)
        descriptionLabel.textColor = UIColor.black.withAlphaComponent(0.75)
    }

    private func styleDescriptionCard() {
        // Card background and border
        descriptionCard.backgroundColor = UIColor(
            red: 0xFF/255,
            green: 0xF7/255,
            blue: 0xE0/255,
            alpha: 1
        )
        descriptionCard.layer.cornerRadius = 16
        descriptionCard.layer.borderWidth = 1
        descriptionCard.layer.borderColor = UIColor.black.withAlphaComponent(0.12).cgColor
    }

    private func styleShareButton() {
        // Main action button styling
        shareImpactButton.setTitle("Share Impact", for: .normal)
        shareImpactButton.setTitleColor(.black, for: .normal)
        shareImpactButton.backgroundColor = UIColor(
            red: 0xF7/255,
            green: 0xD4/255,
            blue: 0x4C/255,
            alpha: 1
        )
        shareImpactButton.layer.cornerRadius = 8
        
        // Button font
            shareImpactButton.titleLabel?.font = UIFont.systemFont(
                ofSize: 18,
                weight: .semibold
            )
    }

    private func setupChart() {
        // Chart configuration
        chart.backgroundColor = .clear
        chart.months = months
        chart.values = values
        chart.yMax = 50
        chart.yStep = 10
        chart.setNeedsDisplay()
    }

    @IBAction func shareImpactTapped(_ sender: UIButton) {
// Hide button before taking the screenshot
        shareImpactButton.isHidden = true
        let image = view.asImage()
        shareImpactButton.isHidden = false

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(
            withIdentifier: "SharePreviewViewController"
        ) as! SharePreviewViewController

        vc.imageToShare = image
        vc.shareText = "I helped provide 82 meals this month! 💛"

        navigationController?.pushViewController(vc, animated: true)
    }
}

extension UIView {
    // Used to capture the current view as an image
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { _ in
            drawHierarchy(in: bounds, afterScreenUpdates: true)
        }
    }
}

