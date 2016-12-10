/*
 Tutorial Goal - Getting to know Enums, Structs & Classes
 https://www.raywenderlich.com/119881/enums-structs-and-classes-in-swift
 Example goal - Create framework for SVG
 render a svg file*/

import Foundation
import WebKit
import PlaygroundSupport
import UIKit
import CoreGraphics

let twoPi = CGFloat(M_PI * 2)

///////////////////////////////////////////////////////
//Structs - Protocol Oriented Programming - Composition DP
///////////////////////////////////////////////////////
// Is about creating new extensible(customizable) models

//when creating a new model, first design the interface using a protocol

//Goal - allow users to create their own custom shpes within the SVG

protocol Renderer {
    func moveTo(position p: CGPoint)
    
    func lineTo(position p: CGPoint)
    
    func arcAt(center: CGPoint, radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat)
    
    /// Draws a complete circle with the given center and radius.
    ///
    /// Note: a default implementation of `circleAt` is provided by a
    /// protocol extension, so conforming types need not supply their own.
    func circleAt(center: CGPoint, radius: CGFloat)
    func draw(circle: Circle)
    func draw(rectangle: Rectangle)
}

extension Renderer {
    func arcAt(center: CGPoint, radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat) { }
    
    func lineTo(position p: CGPoint) { }
    
    func moveTo(position p: CGPoint) { }
    
    // types conforming to `Renderer` can provide a more-specific
    // `circleAt` that will always be used in lieu of this one.
    func circleAt(center: CGPoint, radius: CGFloat) {
        arcAt(center: center, radius: radius, startAngle: 0.0, endAngle: twoPi)
    }
    
    func circleAt(center: (x: Float, y: Float), radius: Float) {
//        arcAt(center: center, radius: radius, startAngle: 0.0, endAngle: twoPi)
    }
    // `rectangleAt` is not a protocol requirement, so it is
    // dispatched statically.  In a context where the concrete type
    // conforming to `Renderer` is not known at compile-time, this
    // `rectangleAt` will be used in lieu of any implementation
    // provided by the conforming type.
    func rectangleAt(r: CGRect) {
        moveTo(position: CGPoint(x: r.minX, y: r.minY))
        lineTo(position: CGPoint(x: r.minX, y: r.maxY))
        lineTo(position: CGPoint(x: r.maxX, y: r.maxY))
        lineTo(position: CGPoint(x: r.maxX, y: r.minY))
        lineTo(position: CGPoint(x: r.minX, y: r.minY))
    }
    
    func draw(circle: Circle) {
        circleAt(center: CGPoint(x: CGFloat(circle.center.x),y: CGFloat(circle.center.y)),
                 radius: CGFloat(circle.radius))
    }
    
    func draw(rectangle: Rectangle) { }
}

struct TestRenderer : Renderer {
    func moveTo(position p: CGPoint) { print("moveTo(\(p.x), \(p.y)")}
    
    func lineTo(position p: CGPoint) { print("lineTo(\(p.x), \(p.y)")}
    
    func arcAt(center: CGPoint, radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat) {
        print("arcAt(\(center), radius: \(radius), startAngle: \(startAngle), endAngle: \(endAngle)")
    }
}

extension TestRenderer {
    func circleAt(center: CGPoint, radius: CGFloat) {
        print("circleAt(\(center), \(radius))")
    }
    
    func rectangleAt(r: CGRect) {
        print("rectangleAt(\(r))")
    }
}

//SVG - testing
extension TestRenderer {
    func draw(circle: Circle) {
        print("draw(circle: Circle) circle.center: \(circle.center), circle.radius: \(circle.radius)")
    }
    func draw(rectangle: Rectangle) {
        print("draw(rectangle: Rectangle) rectangle.size: \(rectangle.size), rectangle.area: \(rectangle.area)")
    }
}

//Protocol - I want my shapes to be drawable
//defines what it means to be Drawable
//no drawing technology is specified
//so I could implement it in terms of anything!
//SVG, HTML5 canvas, CoreGraphics, OpenGL, Metal, etc.
protocol Drawable {
    var drawables: [Drawable] {set get}
    func draw(renderer: Renderer)
    mutating func append(drawable: Drawable)
}

extension Drawable {
    var drawables: [Drawable] {
        get {
            return drawables
        }
        set {
            drawables = newValue
        }
    }
    mutating func append(drawable: Drawable) {
        drawables.append(drawable)
    }
}

//Struc - Adopting a Protocol - implementation
struct Circle : Drawable {
    //Struct - to group together stored properties
    var strokeWidth = 5
    var strokeColor = CSSColor.named(.red)
    var fillColor = CSSColor.named(.yellow)
    var center = (x: 125.0, y: 100.0)
    var radius = 50.0
    
    // Implementing the Drawable protocol.
    func draw(renderer: Renderer) {
        renderer.draw(circle: self)
    }
}

//Structs/Classes - computed properties
//implementing a computed property based on the radius
extension Circle {
    var diameter: Double {
        get {
            return radius * 2
        }
        set {
            radius = newValue / 2
        }
    }
    
    //Struct - Mutation
    //is ok if this function wants to mutate the struct.
    //change stored properties on the struct
    mutating func shift(x: Double, y: Double) {
        center.x += x
        center.y += y
    }
}

//Struct - extension - initializer
extension Circle {
    init(center point: (Double, Double), radius length: Double) {
        self.center = point
        self.radius = length
    }
}

//Struc - Protocol - implementation - Adopting a Protocol
//value type
struct Polygon : Drawable {
    //value type
    var corners: [CGPoint] = []
    
    func draw(renderer: Renderer) {
        renderer.moveTo(position: corners.last!)
        for point in corners {
            renderer.lineTo(position: point)
        }
    }
}

struct Rectangle : Drawable {
    var strokeWidth = 5
    var strokeColor = CSSColor.named(.teal)
    var fillColor = CSSColor.named(.aqua)
    var origin = (x: 75.0, y: 50.0)
    var size = (width: 100.0, height: 100.0)
    
    func draw(renderer: Renderer) {
        renderer.draw(rectangle: self)
    }
}

extension Rectangle {
    var bounds: CGRect {
        return CGRect(x: origin.x, y: origin.y , width: size.width , height: size.height)
    }
}

//C.S - Retroactive Modeling and Type Constraining
//- It lets you extend behavior of a model type even if you don’t have the source code for it.
extension Rectangle {
    var area: Double {
        return size.width * size.height
    }
    var perimeter: Double {
        return 2 * (size.width + size.height)
    }
}

//P - formalizing closed shape related methods into a protocol
//Goal - create a protocol for clased shapes
protocol ClosedShape {
    var area: Double { get }
    var perimeter: Double { get }
}

extension Circle: ClosedShape {
    // Example of getter-only computed properties
    var area: Double {
        return Double(radius) * Double(radius) * Double.pi
    }
    
    var perimeter: Double {
        return 2 * Double(radius) * Double.pi
    }
}

//C.S - Protocol - retroactively adopting the protocol
extension Rectangle: ClosedShape {}


//C - Adopting the Renderer protocol
final class SVGRenderer : Renderer {

    private var commands: [String] = []
    
    //Context size
    var width = 0
    var height = 0
    
    // 1 conform to the Renderer protocol
    func draw(circle: Circle) {
        commands.append("<circle cx='\(circle.center.x)' cy='\(circle.center.y)\' r='\(circle.radius)' stroke='\(circle.strokeColor)' fill='\(circle.fillColor)' stroke-width='\(circle.strokeWidth)'  />")
    }
    
    // 2 conform to the Renderer protocol
    func draw(rectangle: Rectangle) {
        commands.append("<rect x='\(rectangle.origin.x)' y='\(rectangle.origin.y)' width='\(rectangle.size.width)' height='\(rectangle.size.height)' stroke='\(rectangle.strokeColor)' fill='\(rectangle.fillColor)' stroke-width='\(rectangle.strokeWidth)' />")
    }
    
    //Getter
    var svgString: String {
        var output = "<svg width='\(width)' height='\(height)'>" +
        "<rect width='\(width)' height='\(height)' style=\"fill:rgb(25,25,25)\"/>"
        for command in commands {
            output += command
        }
        output += "</svg>"
        return output
    }
    
    //Getter
    var htmlFinalDoc: String {
        return "<!DOCTYPE html>" +
            "<head>" +
            "<style>body { background-color: #555555; }</style>" +
            "</head>" +
            "<html>" +
            "<body>" + svgString + "</body>" +
        "</html>"
    }
}

struct SVGDiagram : Drawable {
    var drawables: [Drawable] = []
    
    //Getters - Computed property
    //- Instantiate an SVGRenderer and returns the htmlString from the context.
    var htmlString: String {
        let svgRenderer = SVGRenderer()
        svgRenderer.width = 960
        svgRenderer.height = 500
        for drawable in drawables {
            drawable.draw(renderer: svgRenderer)
        }
        return svgRenderer.htmlFinalDoc
    }
    
    //this function is needed if I what to draw with a specific renderer
    //TestRenderer - use it to test it 
    //SVGRenderer - to
    func draw(renderer: Renderer) {
        for f in drawables {
            f.draw(renderer: renderer)
        }
    }
}


var circle = Circle()

var rectangle = Rectangle()

//Function - Protocol - func adopting ClosedShape protocol
func totalPerimeter(shapes: [ClosedShape]) -> Double {
    //it uses reduce to calculate the sum of perimeters.
    return shapes.reduce(0) { $0 + $1.perimeter }
}

//---------------------------------------------------------------------------------
let radius: Double = 93.75
let rectangleSize = (width: 800.0 , height: radius * 4)

circle.radius = radius
circle.center = (x: 187.5, y: 100)
rectangle.size = rectangleSize
totalPerimeter(shapes: [circle, rectangle])
//---------------------------------------------------------------------------------

///////////////////////////////////////////////////////
//Drawing the SVG
///////////////////////////////////////////////////////
var svgDiagram = SVGDiagram()

svgDiagram.append(drawable: rectangle)
svgDiagram.append(drawable: circle)
//testing the SVGRenderer
svgDiagram.draw(renderer: TestRenderer())

let htmlString = svgDiagram.htmlString
//let svgString = document.svgString
//print(htmlString)

//Struct - value type
struct Diagram : Drawable {
    var drawables: [Drawable] = []
    
    func draw(renderer: Renderer) {
        for f in drawables {
            f.draw(renderer: renderer)
        }
    }
}

//Rewrite render to use CoreGraphics 22:47

//Retroactive Modeling
//extend CGContext to make it a Renderer
//not possible if Renderer were a base class rather that a protocol.
extension CGContext : Renderer {
    func moveTo(position p: CGPoint) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.move(to: p)
    }
    
    func lineTo(position p: CGPoint) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.addLine(to: p)
    }
    
    func arcAt(center: CGPoint, radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat) {
        let path = CGMutablePath()
        path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        self.addPath(path)
    }
}

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
//public func showCoreGraphicsDiagram(_ title: String, draw: @escaping (CGContext)->()) {
//    let diagramView = CoreGraphicsDiagramView(frame: drawingArea)
//    diagramView.draw = draw
//    diagramView.setNeedsDisplay()
//    PlaygroundPage.current.liveView = diagramView
//}

var circle408 = Circle(center: (187.5, 333.5), radius: 93.75)
var triangle = Polygon(corners: [CGPoint(x: 187.5, y: 427.25),
                                 CGPoint(x: 268.69, y: 286.625),
                                 CGPoint(x: 106.31, y: 286.625)])

var diagram = Diagram(drawables: [circle408, triangle])

//why does it works? bacause value type.
var insideDiagram = diagram
diagram.append(drawable: insideDiagram)
diagram.draw(renderer: TestRenderer())

//http://stackoverflow.com/questions/37097448/playground-xcode-swift-wkwebview-scripting-failed-to-obtain-sandbox-extensi
let svgDrawingArea = CGRect(x: 0.0, y: 0.0, width: 375.0, height: 200.0)
let webView = WKWebView(frame: svgDrawingArea)
//loadHTMLString is the renderer for SVGRenderer! 
webView.loadHTMLString(htmlString, baseURL: nil)
////webView.backgroundColor = UIColor.red
////this backgroundColor did not appear because the html takes precedence
////PlaygroundPage.current.liveView = view

let drawingArea = CGRect(x: 100.0, y: 0.0, width: 375.0, height: 667.0)
let diagramView = CoreGraphicsDiagramView(frame: drawingArea)
diagramView.draw = { diagram.draw(renderer: $0) }
diagramView.addSubview(webView)
diagramView.setNeedsDisplay()
PlaygroundPage.current.liveView = diagramView
////showCoreGraphicsDiagram("Diagram") { diagram.draw(renderer: $0) }


