import UIKit

final class ImpactBarChartView: UIView {

    // Data used to draw the chart
    var months: [String] = []
    var values: [CGFloat] = []

    // Chart scale
    var yMax: CGFloat = 50
    var yStep: CGFloat = 10

    // Colors
    private let axisTextColor = UIColor.black.withAlphaComponent(0.55)
    private let gridColor = UIColor.black.withAlphaComponent(0.06)
    private let barColor = UIColor(red: 0xF9/255, green: 0xDE/255, blue: 0xB3/255, alpha: 1)

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        guard months.count == values.count, !months.isEmpty else { return }
        guard let context = UIGraphicsGetCurrentContext() else { return }

        // Layout spacing
        let leftPadding: CGFloat = 34
        let bottomPadding: CGFloat = 22
        let topPadding: CGFloat = 8
        let rightPadding: CGFloat = 6

        let plotArea = CGRect(
            x: leftPadding,
            y: topPadding,
            width: rect.width - leftPadding - rightPadding,
            height: rect.height - topPadding - bottomPadding
        )

        let labelFont = UIFont.systemFont(ofSize: 10)
        let steps = Int(yMax / yStep)

        // Horizontal grid lines and Y-axis labels
        for i in 0...steps {
            let value = CGFloat(i) * yStep
            let ratio = value / yMax
            let y = plotArea.maxY - (ratio * plotArea.height)

            context.setStrokeColor(gridColor.cgColor)
            context.setLineWidth(1)
            context.move(to: CGPoint(x: plotArea.minX, y: y))
            context.addLine(to: CGPoint(x: plotArea.maxX, y: y))
            context.strokePath()

            let text = "\(Int(value))" as NSString
            let size = text.size(withAttributes: [.font: labelFont])
            let rect = CGRect(x: 0, y: y - size.height / 2, width: leftPadding - 6, height: size.height)
            text.draw(in: rect, withAttributes: [.font: labelFont, .foregroundColor: axisTextColor])
        }

        // Bars and month labels
        let count = values.count
        let gap: CGFloat = 6
        let barWidth = max(6, (plotArea.width - gap * CGFloat(count - 1)) / CGFloat(count))

        for index in 0..<count {
            let value = min(max(values[index], 0), yMax)
            let height = (value / yMax) * plotArea.height
            let x = plotArea.minX + CGFloat(index) * (barWidth + gap)
            let y = plotArea.maxY - height

            let barRect = CGRect(x: x, y: y, width: barWidth, height: height)
            barColor.setFill()
            UIBezierPath(roundedRect: barRect, cornerRadius: 4).fill()

            let month = months[index] as NSString
            let size = month.size(withAttributes: [.font: labelFont])
            let mx = x + (barWidth - size.width) / 2
            let my = plotArea.maxY + 6
            month.draw(at: CGPoint(x: mx, y: my),
                       withAttributes: [.font: labelFont, .foregroundColor: axisTextColor])
        }
    }
}


