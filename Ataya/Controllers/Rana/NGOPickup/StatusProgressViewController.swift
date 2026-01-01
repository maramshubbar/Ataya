//
//  StatusProgressViewController.swift
//  Ataya
//
//  Created by BP-36-224-09 on 29/12/2025.
//
import UIKit

final class StatusProgressView: UIView {

    enum Step { case pending, accepted, completed }

    private let activeYellow = UIColor.hex("#FEC400")
    private let inactiveGray = UIColor.hex("#E0E0E0")
    private let labelGray   = UIColor.hex("#8A8A8A")

    private let lineBase = CAShapeLayer()
    private let lineFill = CAShapeLayer()
    private var dots: [CAShapeLayer] = []

    private let pendingLabel = UILabel()
    private let acceptedLabel = UILabel()
    private let completedLabel = UILabel()

    // Tunables (these are what make it “Figma clean”)
    private let horizontalPadding: CGFloat = 22   // makes line shorter so it doesn’t touch border
    private let topPadding: CGFloat = 12
    private let labelGap: CGFloat = 14

    private let dotSize: CGFloat = 18
    private let lineThickness: CGFloat = 3

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    override var intrinsicContentSize: CGSize {
        // Important: gives room so labels don’t feel “stuck” to the line
        CGSize(width: UIView.noIntrinsicMetric, height: 74)
    }

    private func commonInit() {
        backgroundColor = .clear
        isOpaque = false
        clipsToBounds = false

        lineBase.strokeColor = inactiveGray.cgColor
        lineBase.lineWidth = lineThickness
        lineBase.lineCap = .round
        layer.addSublayer(lineBase)

        lineFill.strokeColor = activeYellow.cgColor
        lineFill.lineWidth = lineThickness
        lineFill.lineCap = .round
        lineFill.strokeEnd = 0
        layer.addSublayer(lineFill)

        for _ in 0..<3 {
            let d = CAShapeLayer()
            d.fillColor = inactiveGray.cgColor
            layer.addSublayer(d)
            dots.append(d)
        }

        setupStepLabel(pendingLabel, text: "Pending")
        setupStepLabel(acceptedLabel, text: "Accepted")
        setupStepLabel(completedLabel, text: "Completed")
    }

    private func setupStepLabel(_ label: UILabel, text: String) {
        label.text = text
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = labelGray
        label.textAlignment = .center
        label.numberOfLines = 1
        label.backgroundColor = .clear
        addSubview(label)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        redraw()
        layoutStepLabels()
    }

    private func redraw() {
        let w = bounds.width
        let h = bounds.height
        guard w > 0, h > 0 else { return }

        // ✅ line + dots Y (top area, with padding)
        let y = topPadding + dotSize / 2

        // ✅ shorter line (padding from left/right)
        let x1 = horizontalPadding
        let x3 = w - horizontalPadding
        let x2 = (x1 + x3) / 2

        let pts = [
            CGPoint(x: x1, y: y),
            CGPoint(x: x2, y: y),
            CGPoint(x: x3, y: y)
        ]

        let path = UIBezierPath()
        path.move(to: pts[0])
        path.addLine(to: pts[2])

        lineBase.path = path.cgPath
        lineFill.path = path.cgPath
        lineFill.strokeStart = 0

        for (i, d) in dots.enumerated() {
            let rect = CGRect(
                x: pts[i].x - dotSize/2,
                y: pts[i].y - dotSize/2,
                width: dotSize,
                height: dotSize
            )
            d.path = UIBezierPath(ovalIn: rect).cgPath
        }
    }

    private func layoutStepLabels() {
        let w = bounds.width
        let yLine = topPadding + dotSize / 2
        let labelY = yLine + dotSize/2 + labelGap

        let x1 = horizontalPadding
        let x3 = w - horizontalPadding
        let x2 = (x1 + x3) / 2

        let centersX = [x1, x2, x3]
        let labels = [pendingLabel, acceptedLabel, completedLabel]

        for (i, lbl) in labels.enumerated() {
            lbl.frame = CGRect(x: 0, y: 0, width: 90, height: 16)
            lbl.center = CGPoint(x: centersX[i], y: labelY)
        }
    }

    func set(step: Step, animated: Bool = true) {
        let strokeEnd: CGFloat
        let fills: [UIColor]

        switch step {
        case .pending:
            strokeEnd = 0.0
            fills = [activeYellow, inactiveGray, inactiveGray]
        case .accepted:
            strokeEnd = 0.5
            fills = [activeYellow, activeYellow, inactiveGray]
        case .completed:
            strokeEnd = 1.0
            fills = [activeYellow, activeYellow, activeYellow]
        }

        if animated {
            let anim = CABasicAnimation(keyPath: "strokeEnd")
            anim.fromValue = lineFill.presentation()?.strokeEnd ?? lineFill.strokeEnd
            anim.toValue = strokeEnd
            anim.duration = 0.25
            anim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            lineFill.strokeEnd = strokeEnd
            lineFill.add(anim, forKey: "strokeEndAnim")
        } else {
            lineFill.strokeEnd = strokeEnd
        }

        for (i, d) in dots.enumerated() {
            let newColor = fills[i].cgColor
            if animated {
                let a = CABasicAnimation(keyPath: "fillColor")
                a.fromValue = d.presentation()?.fillColor ?? d.fillColor
                a.toValue = newColor
                a.duration = 0.25
                a.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                d.fillColor = newColor
                d.add(a, forKey: "fillColorAnim")
            } else {
                d.fillColor = newColor
            }
        }
    }
}
