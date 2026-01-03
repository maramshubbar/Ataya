import UIKit

final class RecurringHistoryCell: UITableViewCell {

    // Card container
    @IBOutlet weak var cardView: UIView!
    
    // Labels
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!

    // Status badge
    @IBOutlet weak var statusLabel: UILabel!
    
    // Buttons
    
    @IBOutlet weak var resumeButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    
    var onEdit: (() -> Void)?
    var onResume: (() -> Void)?
    var onPause: (() -> Void)?
    
    enum DonationStatus {
        case confirmed
        case paused
    }

    private let yellow = UIColor(red: 0xF7/255.0, green: 0xD4/255.0, blue: 0x4C/255.0, alpha: 1.0)

    override func awakeFromNib() {
        super.awakeFromNib()

        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        applyStyles()

        // ✅ Handle taps in code (NO storyboard action connections)
        editButton.addTarget(self, action: #selector(editPressed), for: .touchUpInside)
        resumeButton.addTarget(self, action: #selector(resumePressed), for: .touchUpInside)
        pauseButton.addTarget(self, action: #selector(pausePressed), for: .touchUpInside)
    }

    private func applyStyles() {
        cardView.layer.cornerRadius = 8
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = UIColor.systemGray4.cgColor
        cardView.layer.masksToBounds = true
        cardView.backgroundColor = .white

        statusLabel.layer.cornerRadius = 8
        statusLabel.layer.masksToBounds = true
        statusLabel.textColor = .black

        [editButton, resumeButton, pauseButton].forEach {
            $0?.layer.cornerRadius = 4
            $0?.layer.masksToBounds = true
        }

        editButton.backgroundColor = .clear
        editButton.layer.borderWidth = 1
        editButton.layer.borderColor = yellow.cgColor
        editButton.setTitleColor(yellow, for: .normal)

        resumeButton.backgroundColor = yellow
        pauseButton.backgroundColor = yellow
        resumeButton.setTitleColor(.black, for: .normal)
        pauseButton.setTitleColor(.black, for: .normal)
    }

    func configure(title: String, category: String, date: String, status: String) {

        titleLabel.text = title
        categoryLabel.text = category
        dateLabel.text = date

        statusLabel.text = "  \(status)  "
        statusLabel.layer.cornerRadius = 8
        statusLabel.clipsToBounds = true

        switch status.lowercased() {
        case "confirmed":
            statusLabel.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.25)
            statusLabel.textColor = .black

        case "paused":
            statusLabel.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.35)
            statusLabel.textColor = .black

        case "resumed":
            statusLabel.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.30)
            statusLabel.textColor = .black

        default:
            statusLabel.backgroundColor = UIColor.systemGray5
            statusLabel.textColor = .black
        }
    }

    @objc private func editPressed() { onEdit?() }
    @objc private func resumePressed() { onResume?() }
    @objc private func pausePressed() { onPause?() }

}
