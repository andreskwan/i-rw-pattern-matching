/*Goal Create framework for SVG
 render a svg file*/
import Foundation
import WebKit
import PlaygroundSupport

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

print(fillRGB)

//Enum - Custom initializer 
//for grayscale values.
extension CSSColor {
    init(gray: UInt8) {
        self = .rgb(gray, gray, gray)
    }
}

let color3 = CSSColor(gray: 0xaa)
print(color3)

///////////////////////////////////////////////////////
//Structs
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
    var center = (x: 100.0, y: 150.0)
    var radius = 60.0
    
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
    var origin = (x: 110.0, y: 10.0)
    var size = (width: 100.0, height: 130.0)
    
    func draw(with context: DrawingContext) {
        //defer the draw work to the DrawingContext
        context.draw(rectangle: self)
    }
}

//Class - Adopting the DrawingContext protocol
final class SVGContext : DrawingContext {
    
    private var commands: [String] = []
    
    //Context size
    var width = 250
    var height = 250
    
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
        var output = "<svg width='\(width)' height='\(height)'>"
        for command in commands {
            output += command
        }
        output += "</svg>"
        return output
    }
    
    //Getter
    var htmlString: String {
        return "<!DOCTYPE html><html><body>" + svgString + "</body></html>"
    }
}

