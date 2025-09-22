import SwiftUI
import UIKit

public struct GridBackground: View {
    private let lineColor = Color.white.opacity(0.07)
    private let boldLineColor = Color.white.opacity(0.07)
    private let minorSquaresPerInch: CGFloat = 5
    private var spacing: CGFloat { GridBackground.pointsPerInch() / minorSquaresPerInch }
    private let boldEvery: Int = 4

    public init() {}

    public var body: some View {
        GeometryReader { geo in
            Canvas { context, size in
                let cols = Int(ceil(size.width / spacing))
                let rows = Int(ceil(size.height / spacing))

                for c in 0...cols {
                    let x = CGFloat(c) * spacing
                    var path = Path()
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: size.height))
                    let color = (c % boldEvery == 0) ? boldLineColor : lineColor
                    context.stroke(path, with: .color(color), lineWidth: 0.5)
                }

                for r in 0...rows {
                    let y = CGFloat(r) * spacing
                    var path = Path()
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: size.width, y: y))
                    let color = (r % boldEvery == 0) ? boldLineColor : lineColor
                    context.stroke(path, with: .color(color), lineWidth: 0.5)
                }
            }
            .blendMode(.screen)
            .background(Color.black)
        }
    }

    private static func pointsPerInch() -> CGFloat {
        switch UIDevice.current.userInterfaceIdiom {
        case .pad: return 132
        case .phone: return 160
        default: return 160
        }
    }
}

#Preview {
    GridBackground()
        .preferredColorScheme(.dark)
}
