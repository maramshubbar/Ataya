//
//  ReportCardCell.swift
//  Ataya
//
//  Created by Maram on 18/12/2025.
//
//
import UIKit

final class ReportCardCell: UITableViewCell {

    static let reuseId = "ReportCardCell"

    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var cardView: UIView!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var badgeView: UIView!
    @IBOutlet weak var badgeLabel: UILabel!

    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var reporterLabel: UILabel!
    @IBOutlet weak var ngoLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    @IBOutlet weak var btnViewDetails: UIButton!

    var onViewDetailsTapped: (() -> Void)?

    // ✅ نخفي "صف" اللوكيشن كامل (الأيقونة + النص)
    private weak var locationRowStack: UIStackView?
    private weak var ngoRowStack: UIStackView?

    override func awakeFromNib() {
        super.awakeFromNib()
        styleUI()

        locationRowStack = findNearestHorizontalRowStack(containing: locationLabel)
        ngoRowStack = findNearestHorizontalRowStack(containing: ngoLabel)
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        // رجّعيهم ظاهرين افتراضياً
        locationRowStack?.isHidden = false
        ngoRowStack?.isHidden = false

        locationLabel.isHidden = false
        ngoLabel.isHidden = false
    }

    private func styleUI() {
        cardView.layer.cornerRadius = 8
        cardView.clipsToBounds = true

        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1).cgColor

        shadowView.layer.shadowOpacity = 0
        shadowView.layer.shadowRadius = 0
        shadowView.layer.shadowOffset = .zero
        shadowView.layer.shadowColor = UIColor.clear.cgColor

        badgeView.layer.cornerRadius = 8
        badgeView.clipsToBounds = true

        btnViewDetails.layer.cornerRadius = 4.6
        btnViewDetails.clipsToBounds = true
        btnViewDetails.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
    }

    @IBAction func viewDetailsTapped(_ sender: UIButton) {
        onViewDetailsTapped?()
    }

    // ✅ يلقط أقرب stack أفقي يمثل "row" ويحتوي الليبل (حتى لو الليبل داخل View داخل الـstack)
    private func findNearestHorizontalRowStack(containing view: UIView) -> UIStackView? {
        var current: UIView? = view
        while let c = current {
            if let stack = c as? UIStackView, stack.axis == .horizontal {
                let match = stack.arrangedSubviews.contains { arranged in
                    arranged === view || view.isDescendant(of: arranged)
                }
                if match { return stack }
            }
            current = c.superview
        }
        return nil
    }

    func configure(title: String,
                   location: String,
                   reporter: String,
                   ngo: String,
                   date: String,
                   status: String) {

        titleLabel.text = title
        reporterLabel.text = reporter
        dateLabel.text = date

        let loc = location.trimmingCharacters(in: .whitespacesAndNewlines)
        let ngoText = ngo.trimmingCharacters(in: .whitespacesAndNewlines)

        locationLabel.text = loc
        ngoLabel.text = ngoText

        let hideLocation = loc.isEmpty
        let hideNgo = ngoText.isEmpty

        // ✅ أهم سطرين: نخفي الصف كامل (يختفي pin + النص)
        if let row = locationRowStack {
            row.isHidden = hideLocation
        } else {
            // fallback: لو ما لقينا stack (نخفي الليبل نفسه على الأقل)
            locationLabel.isHidden = hideLocation
            // ونخفي أي UIImageView قريبة بنفس السوبرفيو (عشان pin ما يطلع بروحه)
            hideNearestImageView(around: locationLabel, hide: hideLocation)
        }

        if let row = ngoRowStack {
            row.isHidden = hideNgo
        } else {
            ngoLabel.isHidden = hideNgo
        }

        badgeLabel.text = status
        if status.lowercased() == "resolved" {
            badgeView.backgroundColor = UIColor(red: 213/255, green: 244/255, blue: 214/255, alpha: 1)
        } else {
            badgeView.backgroundColor = UIColor(red: 255/255, green: 244/255, blue: 191/255, alpha: 1)
        }
    }

    // ✅ fallback قوي: يخفي أقرب UIImageView حوالين الليبل (pin)
    private func hideNearestImageView(around label: UILabel, hide: Bool) {
        // جرّبي نفس السوبرفيو
        if let siblings = label.superview?.subviews {
            for v in siblings {
                if let img = v as? UIImageView {
                    img.isHidden = hide
                    return
                }
                // لو الأيقونة داخل View
                if let img = v.subviews.first(where: { $0 is UIImageView }) as? UIImageView {
                    img.isHidden = hide
                    return
                }
            }
        }
        // جرّبي سوبرفيو أعلى
        if let parent = label.superview?.superview {
            for v in parent.subviews {
                if let img = v as? UIImageView {
                    img.isHidden = hide
                    return
                }
                if let img = v.subviews.first(where: { $0 is UIImageView }) as? UIImageView {
                    img.isHidden = hide
                    return
                }
            }
        }
    }
}
