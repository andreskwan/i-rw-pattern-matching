import UIKit
import PlaygroundSupport

let drawingArea = CGRect(x: 0.0, y: 0.0, width: 375.0, height: 667.0)

/// `CoreGraphicsDiagramView` is a `UIView` that draws itself by calling a
/// user-supplied function to generate paths in a `CGContext`, then strokes
/// the context's current path, creating lines in a pleasing shade of blue.
class CoreGraphicsDiagramView : UIView {
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()!
        context.saveGState()
        draw(context)
        let red = CGFloat(0.222)
        let green = CGFloat(0.617)
        let blue = CGFloat(0.976)
        let lightBlue = UIColor(red: red, green: green, blue: blue, alpha: 1.0).cgColor
        context.setStrokeColor(lightBlue)
        context.setLineWidth(3)
        context.strokePath()
        context.restoreGState()
    }
    
    var draw: (CGContext)->() = { _ in () }
}

/// Shows a `UIView` in the current playground that draws itself by invoking
/// `draw` on a `CGContext`, then stroking the context's current path in a
/// pleasing light blue.
public func showCoreGraphicsDiagram(_ title: String, draw: @escaping (CGContext)->()) {
    let diagramView = CoreGraphicsDiagramView(frame: drawingArea)
    diagramView.draw = draw
    diagramView.setNeedsDisplay()
    PlaygroundPage.current.liveView = diagramView
}

