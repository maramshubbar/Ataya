//
//  DonationStatusViewController.swift
//  DonationStatus
//
//  Created by Ruqaya Habib on 25/12/2025.
//

import UIKit

final class DonationStatusViewController: UIViewController {

    
 
    @IBOutlet weak var donationIdLabel: UILabel!
    @IBOutlet weak var lastUpdatedLabel: UILabel!
    
    @IBOutlet weak var trackingContainerView: UIView!
    
    @IBOutlet weak var detailsCardView: UIView!
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var expectedDeliveryLabel: UILabel!
    @IBOutlet weak var addressValueLabel: UILabel!
    @IBOutlet weak var notesValueLabel: UILabel!
    
    
    @IBOutlet weak var ngoContact: UIView!
    @IBOutlet weak var ngoImage: UIImageView!
    @IBOutlet weak var ngoName: UILabel!
    @IBOutlet weak var ngoContactLabel: UILabel!
    @IBOutlet weak var ngoPhoneNumber: UILabel!
    
    
    @IBOutlet weak var supportButton: UIButton!
    
    private let atayaYellow = UIColor(red: 0xF7/255, green: 0xD4/255, blue: 0x4C/255, alpha: 1)
    private let lightGray = UIColor(white: 0.85, alpha: 1)

    private let steps = [
        "Pending",
        "Accepted",
        "In Transit",
        "Collected",
        "Delivered"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        title = "Donation Status"
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .systemBackground

        styleLikeFigma()
        fillDummyData()
        buildTrackingLikeFigma(activeIndex: 2)
        
    }
    
    override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            ngoImage.layer.cornerRadius = ngoImage.bounds.height / 2
            ngoImage.clipsToBounds = true
        }

        private func styleLikeFigma() {
            
            // Big card
            detailsCardView.backgroundColor = .white
            detailsCardView.layer.cornerRadius = 5
            detailsCardView.layer.borderWidth = 1
            detailsCardView.layer.borderColor = lightGray.cgColor

            // NGO card
            ngoContact.backgroundColor = .white
            ngoContact.layer.cornerRadius = 5
            ngoContact.layer.borderWidth = 1
            ngoContact.layer.borderColor = lightGray.cgColor

            ngoImage.contentMode = .scaleAspectFill
            ngoImage.backgroundColor = UIColor(white: 0.95, alpha: 1)

            ngoName.font = .systemFont(ofSize: 15, weight: .semibold)
            ngoContactLabel.font = .systemFont(ofSize: 12)
            ngoContactLabel.textColor = .gray
            ngoPhoneNumber.font = .systemFont(ofSize: 13)
            ngoPhoneNumber.textColor = .darkGray

            addressValueLabel.numberOfLines = 0
            notesValueLabel.numberOfLines = 0

            // Button
            supportButton.setTitle("Raise a Support Ticket", for: .normal)
            supportButton.setTitleColor(.black, for: .normal)
            supportButton.backgroundColor = atayaYellow
            supportButton.layer.cornerRadius = 8
        }


        // MARK: - Dummy Data
        private func fillDummyData() {
            donationIdLabel.text = "Donation ID: DON-290"
            lastUpdatedLabel.text = "Last Updated: Nov 15, 2025 at 10:30AM"

            itemLabel.text = "Item: Bananas"
            expectedDeliveryLabel.text = "Expected Delivery: Nov 29, 2025"

            addressValueLabel.text = """
            Address:
            House 191, Road 2125, Block 321
            Manama, Kingdom of Bahrain
            """

            notesValueLabel.text = """
            My Notes:
            Look for the house with the blue
            gate, near Nasser pharmacy
            """

            ngoName.text = "Hoppal"
            ngoContactLabel.text = "Contact NGO"
            ngoPhoneNumber.text = "+973 1778 2234"
            ngoImage.image = UIImage(systemName: "leaf.fill")
        }

        // MARK: - Tracking (1:1 Figma)
        private func buildTrackingLikeFigma(activeIndex: Int) {

            trackingContainerView.subviews.forEach { $0.removeFromSuperview() }

            let wrapper = UIStackView()
            wrapper.axis = .vertical
            wrapper.spacing = 10
            wrapper.translatesAutoresizingMaskIntoConstraints = false
            trackingContainerView.addSubview(wrapper)

            NSLayoutConstraint.activate([
                wrapper.topAnchor.constraint(equalTo: trackingContainerView.topAnchor, constant: 12),
                wrapper.bottomAnchor.constraint(equalTo: trackingContainerView.bottomAnchor, constant: -12),
                wrapper.leadingAnchor.constraint(equalTo: trackingContainerView.leadingAnchor, constant: 12),
                wrapper.trailingAnchor.constraint(equalTo: trackingContainerView.trailingAnchor, constant: -12)
            ])

            // ---------- Dots Row ----------
            let dotsRow = UIView()
            dotsRow.translatesAutoresizingMaskIntoConstraints = false
            wrapper.addArrangedSubview(dotsRow)
            dotsRow.heightAnchor.constraint(equalToConstant: 16).isActive = true

            // Equal columns guides
            let guides = UIStackView()
            guides.axis = .horizontal
            guides.distribution = .fillEqually
            guides.translatesAutoresizingMaskIntoConstraints = false
            dotsRow.addSubview(guides)

            NSLayoutConstraint.activate([
                guides.topAnchor.constraint(equalTo: dotsRow.topAnchor),
                guides.bottomAnchor.constraint(equalTo: dotsRow.bottomAnchor),
                guides.leadingAnchor.constraint(equalTo: dotsRow.leadingAnchor),
                guides.trailingAnchor.constraint(equalTo: dotsRow.trailingAnchor)
            ])

            var centers: [NSLayoutXAxisAnchor] = []

            for _ in steps {
                let g = UIView()
                guides.addArrangedSubview(g)
                centers.append(g.centerXAnchor)
            }

            // Base line
            let baseLine = UIView()
            baseLine.backgroundColor = lightGray
            baseLine.translatesAutoresizingMaskIntoConstraints = false
            dotsRow.addSubview(baseLine)

            NSLayoutConstraint.activate([
                baseLine.heightAnchor.constraint(equalToConstant: 2),
                baseLine.centerYAnchor.constraint(equalTo: dotsRow.centerYAnchor),
                baseLine.leadingAnchor.constraint(equalTo: dotsRow.leadingAnchor),
                baseLine.trailingAnchor.constraint(equalTo: dotsRow.trailingAnchor)
            ])

            // Progress line
            let progressLine = UIView()
            progressLine.backgroundColor = atayaYellow
            progressLine.translatesAutoresizingMaskIntoConstraints = false
            dotsRow.addSubview(progressLine)

            NSLayoutConstraint.activate([
                progressLine.heightAnchor.constraint(equalToConstant: 2),
                progressLine.centerYAnchor.constraint(equalTo: dotsRow.centerYAnchor),
                progressLine.leadingAnchor.constraint(equalTo: dotsRow.leadingAnchor),
                progressLine.trailingAnchor.constraint(equalTo: centers[activeIndex])
            ])

            // Dots
            for i in 0..<steps.count {
                let dot = UIView()
                dot.translatesAutoresizingMaskIntoConstraints = false
                dot.layer.cornerRadius = 7
                dot.backgroundColor = (i <= activeIndex) ? atayaYellow : lightGray
                dotsRow.addSubview(dot)

                NSLayoutConstraint.activate([
                    dot.widthAnchor.constraint(equalToConstant: 14),
                    dot.heightAnchor.constraint(equalToConstant: 14),
                    dot.centerYAnchor.constraint(equalTo: dotsRow.centerYAnchor),
                    dot.centerXAnchor.constraint(equalTo: centers[i])
                ])
            }

            // ---------- Labels Row ----------
            let labelsRow = UIStackView()
            labelsRow.axis = .horizontal
            labelsRow.distribution = .fillEqually
            labelsRow.translatesAutoresizingMaskIntoConstraints = false
            wrapper.addArrangedSubview(labelsRow)

            for (i, title) in steps.enumerated() {
                let lbl = UILabel()
                lbl.text = title
                lbl.textAlignment = .center
                lbl.numberOfLines = 2
                lbl.font = .systemFont(ofSize: 11, weight: i == activeIndex ? .semibold : .regular)
                lbl.textColor = i <= activeIndex ? .black : UIColor(white: 0.65, alpha: 1)
                labelsRow.addArrangedSubview(lbl)
            }
        }
    
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
