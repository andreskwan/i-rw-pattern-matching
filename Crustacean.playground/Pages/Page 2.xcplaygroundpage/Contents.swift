//: # Crustacean II
//:
//: Protocol-Oriented Programming with Value Types
//:
//: This page does everything the [previous one](@previous) does, but also
//: demonstrates some more sophisticated techniques that would make the first
//: page harder to grasp.
import UIKit
import CoreGraphics
let twoPi = CGFloat(M_PI * 2)

//: A protocol for types that respond to primitive graphics commands.  We
//: start with the basics:
protocol Renderer {
    /// Moves the pen to `position` without drawing anything.
    func moveTo(position: CGPoint)
    
    /// Draws a line from the pen's current position to `position`, updating
    /// the pen position.
    func lineTo(position: CGPoint)
    
    /// Draws the fragment of the circle centered at `c` having the given
    /// `radius`, that lies between `startAngle` and `endAngle`, measured in
    /// radians.
    func arcAt(center: CGPoint, radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat)
    
    /// Draws a complete circle with the given center and radius.
    ///
    /// Note: a default implementation of `circleAt` is provided by a
    /// protocol extension, so conforming types need not supply their own.
    func circleAt(center: CGPoint, radius: CGFloat)
}

//: A `Renderer` that prints to the console.
//:
//: Printing the drawing commands comes in handy for debugging; you
//: can't always see everything by looking at graphics.  For an
//: example, see the "nested diagram" section below.
struct TestRenderer : Renderer {
    func moveTo(position p: CGPoint) { print("moveTo(\(p.x), \(p.y))") }
    
    func lineTo(position p: CGPoint) { print("lineTo(\(p.x), \(p.y))") }
    
    func arcAt(center: CGPoint, radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat) {
        print("arcAt(\(center), radius: \(radius)," + " startAngle: \(startAngle), endAngle: \(endAngle))")
    }
}

//: An element of a `Diagram`.  Concrete examples follow.
protocol Drawable {
    /// Issues drawing commands to `renderer` to represent `self`.
    func draw(renderer: Renderer)
    func isEqualTo(other: Drawable) -> Bool
}

//: Basic `Drawable`s
struct Polygon : Drawable {
    func draw(renderer: Renderer) {
        renderer.moveTo(position: corners.last!)
        for p in corners { renderer.lineTo(position: p) }
    }
    var corners: [CGPoint] = []
}

struct Circle : Drawable {
    func draw(renderer: Renderer) {
        renderer.arcAt(center: center, radius: radius, startAngle: 0.0, endAngle: twoPi)
    }
    var center: CGPoint
    var radius: CGFloat
}

//: Now a `Diagram`, which contains a heterogeneous array of `Drawable`s
/// A group of `Drawable`s
struct Diagram : Drawable {
    func draw(renderer: Renderer) {
        for f in elements {
            f.draw(renderer: renderer)
        }
    }
    mutating func add(other: Drawable) {
        elements.append(other)
    }
    var elements: [Drawable] = []
}

//: Extend `CGContext` to make it a `RendererType`.  This kind of “post-hoc
//: conformance” would not be possible if `RendererType` were a base class
//: rather than a protocol.
extension CGContext : Renderer {
    func moveTo(position: CGPoint) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.move(to: position)
    }
    func lineTo(position: CGPoint) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.addLine(to: position)
    }
    func arcAt(center: CGPoint, radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat) {
        let path = CGMutablePath()
        path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        self.addPath(path)
    }
}

// A bubble is made of an outer circle and an inner highlight
struct Bubble : Drawable {
    func draw(renderer r: Renderer) {
        r.circleAt(center: center, radius: radius)
        r.circleAt(center: highlightCenter, radius: highlightRadius)
    }
    
    var center: CGPoint
    var radius: CGFloat
    var highlightCenter: CGPoint {
        return CGPoint(x: center.x + 0.2 * radius, y: center.y - 0.4 * radius)
    }
    var highlightRadius: CGFloat {
        return radius * 0.33
    }
}

//: ## Putting a `Diagram` inside itself
//:
//: If `Diagram`s had reference semantics, we could easily cause an infinite
//: recursion in drawing just by inserting a `Diagram` into its own array of
//: `Drawable`s.  However, value semantics make this operation entirely
//: benign.
//:
//: To ensure that the result can be observed visually, we need to alter the
//: inserted diagram somehow; otherwise, all the elements would line up
//: exactly with existing ones.  This is a nice demonstration of generic
//: adapters in action.
//:
//:
//: We start by creating a `Drawable` wrapper that applies scaling to
//: some underlying `Drawable` instance; then we can wrap it around
//: the diagram.

/// A `Renderer` that passes drawing commands through to some `base`
/// renderer, after applying uniform scaling to all distances.
struct ScaledRenderer : Renderer {
    let base: Renderer
    let scale: CGFloat
    
    func moveTo(position p: CGPoint) {
        base.moveTo(position: CGPoint(x: p.x * scale, y: p.y * scale))
    }
    
    func lineTo(position p: CGPoint) {
        base.lineTo(position: CGPoint(x: p.x * scale, y: p.y * scale))
    }
    
    func arcAt(center: CGPoint, radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat) {
        let scaledCenter = CGPoint(x: center.x * scale, y: center.y * scale)
        base.arcAt(center: scaledCenter, radius: radius * scale, startAngle: startAngle, endAngle: endAngle
        )
    }
}

/// A `Drawable` that scales an instance of `Base`
struct Scaled<Base: Drawable> : Drawable {
    var scale: CGFloat
    var subject: Base
    
    func draw(renderer: Renderer) {
        subject.draw(renderer: ScaledRenderer(base: renderer, scale: scale))
    }
}


//: Methods provided for all types conforming to `RendererType`.  Of
//: `circleAt` and `rectangleAt`, only the first is a protocol
//: requirement, which allows us to demonstrate the difference in
//: dispatching.
extension Renderer {
    // types conforming to `Renderer` can provide a more-specific
    // `circleAt` that will always be used in lieu of this one.
    func circleAt(center: CGPoint, radius: CGFloat) {
        arcAt(center: center, radius: radius, startAngle: 0.0, endAngle: twoPi)
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
}

extension TestRenderer {
    func circleAt(center: CGPoint, radius: CGFloat) {
        print("circleAt(\(center), \(radius))")
    }
    
    func rectangleAt(r: CGRect) {
        print("rectangleAt(\(r))")
    }
}

extension CGContext {
    func rectangleAt(r: CGRect) {
        let context = UIGraphicsGetCurrentContext()!
        context.addRect(r)
    }
}

struct Rectangle : Drawable {
    func draw(renderer r: Renderer) {
        r.rectangleAt(r: bounds)
    }
    var bounds: CGRect
}

//: ## `Equatable` support
//:
//: Value types should always be `Equatable`.  Mostly this is just rote
//: comparison of the corresponding sub-parts of the left-and right-hand
//: arguments, but things get interesting below where handle heterogeneous
//: comparison.
extension Polygon : Equatable {}
func == (lhs: Polygon, rhs: Polygon) -> Bool {
    return lhs.corners == rhs.corners
}

extension Circle : Equatable {}
func == (lhs: Circle, rhs: Circle) -> Bool {
    return lhs.center == rhs.center && lhs.radius == rhs.radius
}

extension Rectangle : Equatable {}
func == (lhs: Rectangle, rhs: Rectangle) -> Bool {
    return lhs.bounds == rhs.bounds
}

extension Bubble : Equatable {}
func == (lhs: Bubble, rhs: Bubble) -> Bool {
    return lhs.center == rhs.center && lhs.radius == rhs.radius
}

//: ### Heterogeneous Equality
//:
//: Both `Scaled` and `Diagram` contain other `Drawable`s whose concrete
//: type can vary dynamically, so we need some way to compare two
//: `Drawable` instances whose dynamic types do not match.  That explains
//: the presence of the `isEqualTo` requirement in `Drawable`.
//:
//: Asking every `Drawable` to support a heterogeneous binary operation
//: imposes quite a burden—one that is usually solved by adding a `Self`
//: requirement to the protocol.  However, equality is a special case,
//: because there's usually a meaningful result when the types don't match:
//: the instances can be assumed to be not-equal.  We extend `Equatable`
//: (which supports *homogeneous* equality comparison) to provide an
//: `isEqualTo` for `Drawable` that returns `false` when the types don't
//: match.
extension Equatable where Self : Drawable {
    func isEqualTo(other: Drawable) -> Bool {
        guard let o = other as? Self else { return false }
        return self == o
    }
}

//: With that, we use `isEqualTo()` to implement `Equatable` conformance for
//: `Scale` and `Diagram`.
extension Scaled : Equatable {}
func == <T>(lhs: Scaled<T>, rhs: Scaled<T>) -> Bool {
    return lhs.scale == rhs.scale && lhs.subject.isEqualTo(other: rhs.subject)
}

extension Diagram : Equatable {}
func == (lhs: Diagram, rhs: Diagram) -> Bool {
    return lhs.elements.count == rhs.elements.count
        && !zip(lhs.elements, rhs.elements).contains { !$0.isEqualTo(other: $1) }
}

//: Building a diagram out of other `Drawable`s
/// Returns a regular `n`-sided polygon with corners on a circle
/// having the given `center` and `radius`
func regularPolygon(n: Int, center: CGPoint, radius r: CGFloat) -> Polygon {
    let angles = (0..<n).map { twoPi / CGFloat(n) * CGFloat($0) }
    return Polygon(corners: angles.map {
        CGPoint(x: center.x + sin($0) * r, y: center.y + cos($0) * r)
    })
}

/// Returns a diagram in the center of the given frame containing an
/// equilateral triangle inscribed in a circle.
func sampleDiagram(frame: CGRect) -> Diagram {
    var sample = Diagram()
    let r = min(frame.width, frame.height) / 4
    let center = CGPoint(x: frame.midX, y: frame.midY)
    
    var circle = Circle(center: center, radius: r)
    sample.add(other: circle)
    sample.add(other: regularPolygon(n: 3, center: center, radius: r))
    
    let s = CGRect(x: center.x - r/3, y: center.y, width: r/6, height: r/6)
    sample.add(other: Rectangle(bounds: s))
    
    // adjust the circle
    circle.center.y += circle.radius * 2.5
    
    // append the circle again
    sample.add(other: circle)
    return sample
}

let drawingArea = CGRect(x: 0.0, y: 0.0, width: 375.0, height: 667.0)

// Create a simple diagram
var sample = sampleDiagram(frame: drawingArea)

// Nest the diagram inside itself, demonstrating that each diagram
// variable is a logically independent value.  If they weren't, we'd
// end up in an infinite drawing recursion.
let nestDiagram = true
if nestDiagram {
    sample.add(other: Scaled(scale: 0.3, subject: sample))
    // do it twice if you want to get fancy
    // sample.add(Scaled(scale: 0.5, subject: sample))
}

// Also add a Bubble
let addBubble = true
if addBubble {
    let radius = drawingArea.width / 10
    let margin = radius * 1.2
    let center = CGPoint(x: drawingArea.maxX - margin, y: drawingArea.minY + margin)
    sample.add(other: Bubble(center: center, radius: radius))
}

// Dump the diagram to the console. Use View>Debug Area>Show Debug
// Area (shift-cmd-Y) to observe the output.

TestRenderer().rectangleAt(r: drawingArea)
print("--- \"rectangleAt\" appears above this line but not below ---")
// Note: the fact that "rectangleAt" doesn't appear below, but
// "circleAt" does, serves as a demonstration of how dispatching through
// protocols works: methods in protocol extensions that don't match a
// requirement (such as rectangleAt) are dispatched statically.
sample.draw(renderer: TestRenderer())

// Also show it in the view. To see the result, View>Assistant
// Editor>Show Assistant Editor (opt-cmd-Return).
showCoreGraphicsDiagram("Diagram") { sample.draw(renderer: $0) }
