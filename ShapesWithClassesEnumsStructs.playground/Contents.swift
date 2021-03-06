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


///////////////////////////////////////////////////////
//Enums
///////////////////////////////////////////////////////
//amazing for well known list of things that we want to represent 
//no so good for things that could be extended or changed in time.
//Why? Because new enum cases cannot be added later in an extension.

//Enum - Namespaces/Scope
//- A namespace in Swift is a named region of a program
//Named types(Classes, Enums, Structs)
//- can act as a namespace to keep things organized and minimize complexity
//ColorName is only ever used in the context of a CSSColor.
//hide ColorName within a CSSColor model

extension CSSColor {
    //CSS colors
    // Enum String as a RawRepresentable
    enum ColorName: String {
        case black, silver, gray, white, maroon, red, purple, fuchsia, green, lime, olive, yellow, navy, blue, teal, aqua
    }
}

//Enum - Associated Values
enum CSSColor {
    case named(ColorName)
    case rgb(UInt8, UInt8, UInt8)
}

//Enum - Namespaces in action
//- A namespace in Swift is a named region of a program
//As such they provide virtual grouping within our code where things outside of the namespace cannot access things inside of the namespace without first mentioning the namespaces itself.
CSSColor.ColorName.black

//Enum - Protocols
extension CSSColor: CustomStringConvertible {
//Protocol implementation
//You’re required to implement a getter for a description string property.
    var description: String {
        switch self {
        case .named(let colorName):
            return colorName.rawValue
        case .rgb(let red, let green, let blue):
            return String(format: "#%02X%02X%02X", red, green, blue)
        }
    }
}
let fill = CSSColor.named(.fuchsia)
let fillRGB = CSSColor.rgb(100, 100, 100)

//print(fillRGB)

//Enum - Custom initializer 
//for grayscale values.
extension CSSColor {
    init(gray: UInt8) {
        self = .rgb(gray, gray, gray)
    }
}

let color3 = CSSColor(gray: 0xaa)
//print(color3)


//Enums can be set up as pure namespaces that users can’t accidentally instantiate.
//Since the Math enum contains no cases, and it’s illegal to add new cases in an extension,
// it can never be instantiated.
// never be able to accidentally misuse Math as a variable or parameter.
// By declaring phi as a static constant, you don’t need to instantiate one.
enum Math {
    static let phi = 1.6180339887498948482 // golden mean
}

Math.phi


///////////////////////////////////////////////////////
//Structs - Protocol Oriented Programming - Composition DP
///////////////////////////////////////////////////////
// Is about creating new extensible(customizable) models

//when creating a new model, first design the interface using a protocol

//Goal - allow users to create their own custom shpes within the SVG

//Protocol - I want my shapes to be drawable
protocol Drawable {
    //defines what it means to be Drawable
    //no drawing technology is specified 
    //so I could implement it in terms of anything!
    //SVG, HTML5 canvas, CoreGraphics, OpenGL, Metal, etc.
    func draw(with context: DrawingContext)
}

//Protocol - I need a context to draw my shapes
protocol DrawingContext {
    //Knows how to draw pure geometric types(graphycal primitives)
    func draw(circle: Circle)
    func draw(rectangle: Rectangle)
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
    func draw(with context: DrawingContext) {
        //defer the draw work to the DrawingContext
        context.draw(circle: self)
    }
}

struct Rectangle : Drawable {
    var strokeWidth = 5
    var strokeColor = CSSColor.named(.teal)
    var fillColor = CSSColor.named(.aqua)
    var origin = (x: 75.0, y: 50.0)
    var size = (width: 100.0, height: 100.0)
    
    func draw(with context: DrawingContext) {
        //defer the draw work to the DrawingContext
        context.draw(rectangle: self)
    }
}

//Class - Adopting the DrawingContext protocol
final class SVGContext : DrawingContext {
    
    private var commands: [String] = []
    
    //Context size
    var width = 0
    var height = 0
    
    // 1 conform to the DrawingContext protocol
    func draw(circle: Circle) {
        commands.append("<circle cx='\(circle.center.x)' cy='\(circle.center.y)\' r='\(circle.radius)' stroke='\(circle.strokeColor)' fill='\(circle.fillColor)' stroke-width='\(circle.strokeWidth)'  />")
    }
    
    // 2 conform to the DrawingContext protocol
    func draw(rectangle: Rectangle) {
        commands.append("<rect x='\(rectangle.origin.x)' y='\(rectangle.origin.y)' width='\(rectangle.size.width)' height='\(rectangle.size.height)' stroke='\(rectangle.strokeColor)' fill='\(rectangle.fillColor)' stroke-width='\(rectangle.strokeWidth)' />")
    }
    
    //Getter
    var svgString: String {
        var output = "<svg width='\(width)' height='\(height)'>" +
                        "<rect width='\(width)' height='\(height)' style=\"fill:rgb(25,25,25)\"/>"
        for command in commands {
            print(command)
            output += command
        }
        output += "</svg>"
        return output
    }
    
    //Getter
    var htmlString: String {
        //        http://www.w3schools.com/html/html5_svg.asp
        //        http://www.w3schools.com/html/tryit.asp?filename=tryhtml_svg_rect
        return "<!DOCTYPE html>" +
                    "<head>" +
                        "<style>body { background-color: #555555; }</style>" +
                    "</head>" +
                    "<html>" +
                        "<body>" + svgString + "</body>" +
                    "</html>"
    }
}

struct SVGDocument {
    var drawables: [Drawable] = []
    
    //Getters - Computed property
    //- Creates an SVGContext and returns the htmlString from the context.
    var htmlString: String {
        let context = SVGContext()
        context.width = 960
        context.height = 500
        for drawable in drawables {
            drawable.draw(with: context)
        }
        return context.htmlString
    }
    
    mutating func append(_ drawable: Drawable) {
        drawables.append(drawable)
    }
}

///////////////////////////////////////////////////////
//Classes
///////////////////////////////////////////////////////
//let me define 
//- base classes
//- derived classes

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

//Classes/Structs - Retroactive Modeling and Type Constraining
//retroactive modeling. 
//- It lets you extend behavior of a model type even if you don’t have the source code for it.

//Goal - create a protocol for clased shapes

extension Rectangle {
    var area: Double {
        return size.width * size.height
    }
    var perimeter: Double {
        return 2 * (size.width + size.height)
    }
}

//Protocols - formalizing closed shape related methods into a protocol
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

var circle = Circle()
//print("circle diameter: \(circle.diameter)")
//print("circle area: \(circle.area)")
//print("circle perimeter: \(circle.perimeter)")

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
var document = SVGDocument()

document.append(rectangle)
document.append(circle)

let htmlString = document.htmlString
//print(htmlString)

//let view = WKWebView(frame: CGRect(x: 0, y: 0, width: 300, height: 200))
//view.loadHTMLString(htmlString, baseURL: nil)
//PlaygroundPage.current.liveView = view


////////////////////////////////////////////////////////////////////////
//WWDC 2015 408
////////////////////////////////////////////////////////////////////////
protocol Renderer {
    func moveTo(position p: CGPoint)
    
    func lineTo(position p: CGPoint)
    
    func arcAt(center: CGPoint, radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat)
}

struct TestRenderer : Renderer {
    func moveTo(position p: CGPoint) { print("moveTo(\(p.x), \(p.y)")}
    
    func lineTo(position p: CGPoint) { print("lineTo(\(p.x), \(p.y)")}
    
    func arcAt(center: CGPoint, radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat) {
    print("arcAt(\(center), radius: \(radius), startAngle: \(startAngle), endAngle: \(endAngle)")
    }
}

//Protocol - Extension - Can't add function declaration to a protocol!!!
//should add implementation
//of a method
//So I create a new protocol
protocol DrawableCrusty {
    func draw(renderer: Renderer)
}

//Struc - Protocol - implementation - Adopting a Protocol 
//value type
struct Polygon : DrawableCrusty {
    //value type
    var corners: [CGPoint] = []
    
    func draw(renderer: Renderer) {
        renderer.moveTo(position: corners.last!)
        for point in corners {
            renderer.lineTo(position: point)
        }
    }
}

//Struct - Protocol - Extension
extension Circle : DrawableCrusty {
    func draw(renderer: Renderer) {
        renderer.arcAt(center: CGPoint(x: center.x, y: center.y),
                       radius: CGFloat(radius),
                       startAngle: 0.0,
                       endAngle: 2 *  CGFloat.pi )
    }
}

//Struct - value type
struct Diagram : DrawableCrusty {
    var elements: [DrawableCrusty] = []
    
    func draw(renderer: Renderer) {
        for f in elements {
            f.draw(renderer: renderer)
        }
    }
    
    mutating func add(other: DrawableCrusty) {
        elements.append(other)
    }
}

//Struct - extension - initializer
extension Circle {
    init(center point: (Double, Double), radius length: Double) {
        self.center = point
        self.radius = length
    }
}

var circle408 = Circle(center: (187.5, 333.5), radius: 93.75)
var triangle = Polygon(corners: [CGPoint(x: 187.5, y: 427.25),
                                 CGPoint(x: 268.69, y: 286.625),
                                 CGPoint(x: 106.31, y: 286.625)])

var diagram = Diagram(elements: [circle408, triangle])

//why does it works? bacause value type.
var insideDiagram = diagram
diagram.add(other: insideDiagram)
diagram.draw(renderer: TestRenderer())

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

let drawingArea = CGRect(x: 100.0, y: 0.0, width: 375.0, height: 667.0)

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

//https://github.com/alskipp/Swift-Diagram-Playgrounds/tree/master - helps me to solve the drawing with CG issue. 
/// Shows a `UIView` in the current playground that draws itself by invoking
/// `draw` on a `CGContext`, then stroking the context's current path in a
/// pleasing light blue.
//public func showCoreGraphicsDiagram(_ title: String, draw: @escaping (CGContext)->()) {
//    let diagramView = CoreGraphicsDiagramView(frame: drawingArea)
//    diagramView.draw = draw
//    diagramView.setNeedsDisplay()
//    PlaygroundPage.current.liveView = diagramView
//}


//http://stackoverflow.com/questions/37097448/playground-xcode-swift-wkwebview-scripting-failed-to-obtain-sandbox-extensi
let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: 375, height: 200))
//webView.isOpaque = true
webView.loadHTMLString(htmlString, baseURL: nil)
//webView.backgroundColor = UIColor.red
//this backgroundColor did not appear because the html takes precedence 
//PlaygroundPage.current.liveView = view

let diagramView = CoreGraphicsDiagramView(frame: drawingArea)
diagramView.draw = { diagram.draw(renderer: $0) }
diagramView.addSubview(webView)
diagramView.setNeedsDisplay()
PlaygroundPage.current.liveView = diagramView
//showCoreGraphicsDiagram("Diagram") { diagram.draw(renderer: $0) }


