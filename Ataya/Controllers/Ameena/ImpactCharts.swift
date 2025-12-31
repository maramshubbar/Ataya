import UIKit

// =======================================================
// MARK: - Bar Chart View (Simple Custom Draw)
// =======================================================
// Draws vertical bars based on `values`.
// Use it as a placeholder chart for the demo.
// Assign the view class in storyboard: ImpactBarChartView
final class ImpactBarChartView: UIView {

    // Values to plot (e.g., 12 months)
    var values: [CGFloat] = [] {
        didSet { setNeedsDisplay() }
    }

    // Bar fill color
    var barColor: UIColor = UIColor(
        red: 0xF7/255, green: 0xD4/255, blue: 0x4C/255, alpha: 0.65
    )

    // Optional: inner padding so bars don't touch edges
    var contentInset: UIEdgeInsets = .init(top: 10, left: 12, bottom: 10, right: 12)

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext(), !values.isEmpty else { return }

        // Define drawable area
        let drawRect = rect.inset(by: contentInset)
        guard drawRect.width > 0, drawRect.height > 0 else { return }

        // Avoid division by zero
        let maxValue = max(values.max() ?? 1, 1)

        // Bar sizing
        let barCount = values.count
        let totalSlots = barCount * 2 // bar + spacing
        let barWidth = drawRect.width / CGFloat(totalSlots)
        let spacing = barWidth

        ctx.setFillColor(barColor.cgColor)

        for (i, v) in values.enumerated() {
            let x = drawRect.minX + CGFloat(i) * (barWidth + spacing) + spacing
            let height = drawRect.height * (v / maxValue)
            let y = drawRect.maxY - height

            let barRect = CGRect(x: x, y: y, width: barWidth, height: height)
            let path = UIBezierPath(roundedRect: barRect, cornerRadius: 6)

            ctx.addPath(path.cgPath)
            ctx.fillPath()
        }
    }
}


// =======================================================
// MARK: - Line Chart View (Simple Custom Draw)
// =======================================================
// Draws a polyline connecting points based on `values`.
// Assign the view class in storyboard: ImpactLineChartView
final class ImpactLineChartView: UIView {

    // Values to plot (e.g., 12 months)
    var values: [CGFloat] = [] {
        didSet { setNeedsDisplay() }
    }

    // Line color
    var lineColor: UIColor = UIColor(
        red: 0xF7/255, green: 0xD4/255, blue: 0x4C/255, alpha: 0.85
    )

    // Line width
    var lineWidth: CGFloat = 3

    // Optional: inner padding so line doesn't touch edges
    var contentInset: UIEdgeInsets = .init(top: 12, left: 12, bottom: 12, right: 12)

    override func draw(_ rect: CGRect) {
        guard values.count > 1 else { return }

        let drawRect = rect.inset(by: contentInset)
        guard drawRect.width > 0, drawRect.height > 0 else { return }

        // Avoid division by zero
        let maxValue = max(values.max() ?? 1, 1)

        let stepX = drawRect.width / CGFloat(values.count - 1)
        let path = UIBezierPath()

        for (i, v) in values.enumerated() {
            let x = drawRect.minX + CGFloat(i) * stepX
            let y = drawRect.maxY - (drawRect.height * (v / maxValue))
            let point = CGPoint(x: x, y: y)

            if i == 0 { path.move(to: point) }
            else { path.addLine(to: point) }
        }

        lineColor.setStroke()
        path.lineWidth = lineWidth
        path.lineJoinStyle = .round
        path.lineCapStyle = .round
        path.stroke()
    }
}


// =======================================================
// MARK: - Pie Chart View (Simple Custom Draw)
// =======================================================
// Draws pie slices based on `values`.
// Assign the view class in storyboard: ImpactPieChartView
final class ImpactPieChartView: UIView {

    // Values to plot (e.g., top 3 categories)
    var values: [CGFloat] = [] {
        didSet { setNeedsDisplay() }
    }

    // Optional labels (not drawn; useful if you want to show a legend later)
    var labels: [String] = []

    // Slice colors (reused cyclically if there are more slices than colors)
    var colors: [UIColor] = [
        UIColor(red: 0xF7/255, green: 0xD4/255, blue: 0x4C/255, alpha: 0.85),
        UIColor(red: 0xF7/255, green: 0xD4/255, blue: 0x4C/255, alpha: 0.55),
        UIColor(red: 0xF7/255, green: 0xD4/255, blue: 0x4C/255, alpha: 0.35)
    ]

    // Optional: inner padding
    var contentInset: UIEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext(), !values.isEmpty else { return }

        // Calculate total; if total is 0, nothing to draw
        let total = values.reduce(0, +)
        guard total > 0 else { return }

        let drawRect = rect.inset(by: contentInset)
        guard drawRect.width > 0, drawRect.height > 0 else { return }

        let center = CGPoint(x: drawRect.midX, y: drawRect.midY)
        let radius = min(drawRect.width, drawRect.height) / 2

        // Start at top (-90 degrees)
        var startAngle: CGFloat = -.pi / 2

        for (i, v) in values.enumerated() {
            let fraction = v / total
            let endAngle = startAngle + 2 * .pi * fraction

            ctx.setFillColor(colors[i % colors.count].cgColor)
            ctx.move(to: center)
            ctx.addArc(center: center,
                       radius: radius,
                       startAngle: startAngle,
                       endAngle: endAngle,
                       clockwise: false)
            ctx.closePath()
            ctx.fillPath()

            startAngle = endAngle
        }
    }
}
