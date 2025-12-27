import UIKit

// MARK: - Bar Chart
final class ImpactBarChartView: UIView {

    var values: [CGFloat] = [] {
        didSet { setNeedsDisplay() }
    }

    var barColor: UIColor = UIColor(red: 0xF7/255, green: 0xD4/255, blue: 0x4C/255, alpha: 0.65)

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext(),
              values.count > 0 else { return }

        let maxValue = max(values.max() ?? 1, 1)
        let barWidth = rect.width / CGFloat(values.count * 2)
        let spacing = barWidth

        for (i, v) in values.enumerated() {
            let x = CGFloat(i) * (barWidth + spacing) + spacing
            let h = rect.height * (v / maxValue)
            let y = rect.height - h

            let r = CGRect(x: x, y: y, width: barWidth, height: h)
            let path = UIBezierPath(roundedRect: r, cornerRadius: 6)

            ctx.setFillColor(barColor.cgColor)
            ctx.addPath(path.cgPath)
            ctx.fillPath()
        }
    }
}

// MARK: - Line Chart
final class ImpactLineChartView: UIView {

    var values: [CGFloat] = [] {
        didSet { setNeedsDisplay() }
    }

    var lineColor: UIColor = UIColor(red: 0xF7/255, green: 0xD4/255, blue: 0x4C/255, alpha: 0.8)

    override func draw(_ rect: CGRect) {
        guard values.count > 1 else { return }

        let path = UIBezierPath()
        let maxValue = max(values.max() ?? 1, 1)
        let stepX = rect.width / CGFloat(values.count - 1)

        for (i, v) in values.enumerated() {
            let x = CGFloat(i) * stepX
            let y = rect.height - (rect.height * (v / maxValue))
            let point = CGPoint(x: x, y: y)

            i == 0 ? path.move(to: point) : path.addLine(to: point)
        }

        lineColor.setStroke()
        path.lineWidth = 3
        path.lineJoinStyle = .round
        path.stroke()
    }
}

// MARK: - Pie Chart
final class ImpactPieChartView: UIView {

    var values: [CGFloat] = [] {
        didSet { setNeedsDisplay() }
    }

    var colors: [UIColor] = [
        UIColor(red: 0xF7/255, green: 0xD4/255, blue: 0x4C/255, alpha: 0.8),
        UIColor(red: 0xF7/255, green: 0xD4/255, blue: 0x4C/255, alpha: 0.5),
        UIColor(red: 0xF7/255, green: 0xD4/255, blue: 0x4C/255, alpha: 0.3)
    ]

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext(),
              values.count > 0 else { return }

        let total = values.reduce(0, +)
        var startAngle: CGFloat = -.pi / 2
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2

        for (i, v) in values.enumerated() {
            let endAngle = startAngle + 2 * .pi * (v / total)

            ctx.setFillColor(colors[i % colors.count].cgColor)
            ctx.move(to: center)
            ctx.addArc(center: center, radius: radius,
                       startAngle: startAngle,
                       endAngle: endAngle,
                       clockwise: false)
            ctx.fillPath()

            startAngle = endAngle
        }
    }
}
