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
    var width = 300
    var height = 200
    
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

struct SVGDocument {
    var drawables: [Drawable] = []
    
    //Getters - Computed property
    //- Creates an SVGContext and returns the htmlString from the context.
    var htmlString: String {
        let context = SVGContext()
        context.width = 300
        context.height = 200
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

let circle = Circle()
print("circle diameter: \(circle.diameter)")
print("circle area: \(circle.area)")
print("circle perimeter: \(circle.perimeter)")

let rectangle = Rectangle()

//Function - Protocol - func adopting ClosedShape protocol
func totalPerimeter(shapes: [ClosedShape]) -> Double {
    //it uses reduce to calculate the sum of perimeters.
    return shapes.reduce(0) { $0 + $1.perimeter }
}
totalPerimeter(shapes: [circle, rectangle])

///////////////////////////////////////////////////////
//Drawing the SVG
///////////////////////////////////////////////////////
var document = SVGDocument()

document.append(rectangle)
document.append(circle)

let htmlString = document.htmlString
print(htmlString)

let view = WKWebView(frame: CGRect(x: 0, y: 0, width: 300, height: 200))
view.loadHTMLString(htmlString, baseURL: nil)
PlaygroundPage.current.liveView = view



////////////////////////////////////////////////////////////////////////
//Reference(shared) vs Value types(unique, non-shared)
//https://www.raywenderlich.com/112027/reference-value-types-in-swift-part-1
//Goal - understand when should I prefer one over the other. 
////////////////////////////////////////////////////////////////////////


//Reference type - let
class Dog {
    var wasFed = false
}

let dog = Dog()
let puppy = Dog()

//Error - reference is constant, can't be changed
//dog = puppy

//Value types - Int to understand value types 
let a = 42
let b = a

//Error - value can't be mutated
//b += 1

let c = 85
//Error - can copy another value, similar to Reference when trying to assign another obj
//b = c

////////////////////////////////////
//which to use and when
////////////////////////////////////
//Classes - Cocoa APIS require NSObject for compatibility with Objective-C

////////////////////////////////////
//Value types - When to Use them. 
//1 - Comparing
//-instance data with == makes sense


struct Point: CustomStringConvertible {
    var x: Float
    var y: Float
    
    var description: String {
        return "{x: \(x), y: \(y)}"
    }
}

//Data - same internal values
//Hardware - different memory location
let point1 = Point(x: 2, y: 3)
let point2 = Point(x: 2, y: 3)

//let hola = "hola"
//NSLog("%p", hola.core._baseAddress)

//print("\(unsafeAddressOf(point1 as AnyObject))")
//Value Types - Protocol - Conform The Equatable protocol
//- good practice for all value types
//- one function that must be implemented globally in order to compare two instances
// == operator 

extension Point: Equatable {
    static func ==(lhs: Point, rhs: Point) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
}

print(point1 == point2)

////////////////////////////////////
//2 - Copies should have independent state
//What would happen if you altered the centerpoint of one of the shapes?

struct Shape {
    var center: Point
}

let initialPoint = Point(x: 0, y: 0)
var circle2 = Shape(center: initialPoint)
var square  = Shape(center: initialPoint)

circle2.center.x = 10
//Each Shape needs its own copy of a Point so you can maintain their state independent of each other.
//Could you imagine the chaos of all shapes sharing the same copy of a center Point? :]
print(circle2.center)
print(square.center)

////////////////////////////////////
//3 - The data will be used in code across multiple threads
//Will multiple threads access this data?
//If threads can uniquely own the data, using value types makes the whole point moot since each owner of the data holds a unique copy rather than a shared reference.



////////////////////////////////////////////////////////////////////////
//Reference types - When to Use them.
////////////////////////////////////////////////////////////////////////

////////////////////////////////////
//1 Comparing instance identity with === makes sense
//Analogy $20 bill exchange vs Magna Carta exchange for falsification 
//not the value/data but identity 


////////////////////////////////////
//2 Synchronize - You want ot create a shared, mutable state
class Account {
    var balance = 0.0
}

class Client {
    let account: Account
    init(_ account: Account) {
        self.account = account
    }
}
let account = Account()

let person1 = Client(account)
let person2 = Client(account)

person2.account.balance += 100.0

person1.account.balance    // 100
person2.account.balance    // 100

////////////////////////////////////////////////////////////////////////
//part 2/2 
////////////////////////////////////////////////////////////////////////
//Mixing Value and reference types

//Complications related to this mixing
//Common - References containing value types

//Person - Class
//-identify - 2 case - uniqueness matters
//-address - structured will be stored - 1 equality matters

//Struct - Value type
struct Address {
    //String is also a value type
    var streetAddress: String
    var city: String
    var state: String
    var postalCode: String
}

//class Address {
//    //String is also a value type
//    var streetAddress: String
//    var city: String
//    var state: String
//    var postalCode: String
//    
//    init(streetAddress: String, city: String, state: String, postalCode: String) {
//        self.streetAddress = streetAddress
//        self.city = city
//        self.state = state
//        self.postalCode = postalCode
//    }
//}

class Person {          // Reference type
    var name: String      // Value type
    var address: Address  // Value type
    
    init(name: String, address: Address) {
        self.name = name
        self.address = address
    }
}

// 1
let kingsLanding = Address(streetAddress: "1 King Way", city: "Kings Landing", state: "Westeros", postalCode: "12345")
let madKing = Person(name: "Aerys", address: kingsLanding)
let kingSlayer = Person(name: "Jaime", address: kingsLanding)

// 2 - chagen this property should only affect this instance.
kingSlayer.address.streetAddress = "1 King Way Apt. 1"

// 3 - uniqueness
madKing.address.streetAddress  // 1 King Way
kingSlayer.address.streetAddress // 1 King Way Apt. 1

struct Bill {
    let amount: Float
    let billedTo: Person
}


////////////////////////////////////
//Nested Types - Struct with parameters of reference type
////////////////////////////////////
struct House {
    var thermostat = Thermostat()
    var oven = Oven()
}

class Temperature {
    var fahrenheit = Double()
    var celsius : Double {
        return (self.fahrenheit - 32) * 5.0/9.0
    }
}

struct Thermostat {
    var temperature = Temperature()
}

struct Oven {
    var temperature = Temperature()
}

var home = House()
var temp = Temperature()
temp.fahrenheit = 75
home.thermostat.temperature = temp
temp.fahrenheit = 425
home.oven.temperature = temp

home.thermostat.temperature.fahrenheit
home.oven.temperature.fahrenheit

home.thermostat.temperature.celsius
home.oven.temperature.celsius


//David6p2

let array = [1,2,3,4,5]
let suma = {(x:Int, y:Int) in return (x + y)}
let sum = array.reduce(0,suma)
print(sum)

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

diagram.draw(renderer: TestRenderer())

//Rewrite render to use CoreGraphics 22:47

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


