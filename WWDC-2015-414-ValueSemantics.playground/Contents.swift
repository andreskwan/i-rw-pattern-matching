/*
 WWDC 2015 - session 414 - Value semantics/type in practics
 */
import UIKit

struct Circle {
    var center: CGPoint
    var radius: Double
    
    init(_ center: CGPoint, _ radius: Double) {
        self.center = center
        self.radius = radius
    }
}

extension Circle: Equatable {
    static func ==(lhs: Circle, rhs: Circle) -> Bool {
        return lhs.center == rhs.center && lhs.radius == rhs.radius
    }
}

struct Polygon {
    var corners: [CGPoint] = []
}

extension Polygon: Equatable {
    static func ==(lhs: Polygon, rhs: Polygon) -> Bool {
        //this should compare each element of the array 
        //so I should see lenght of the arrays to compare 
        //and then compare each element
        //return lhs.corners.lenght == 0 || lhs.corners.lenght
        //I'm taking advantage of colections == 
        //and value types
        //array with value types is a value type 
        //so, compare is easy.
        return lhs.corners == rhs.corners
    }
}

protocol Drawable {
    func draw()
}

//Namespace
enum Math{
    static let π: CGFloat = CGFloat.pi
}

extension Circle: Drawable {
    func draw() {
        //why in the example app it seems that the context is not needed to draw a circle?
        guard let context = UIGraphicsGetCurrentContext() else {
            //does it should throw an error if there is no context?
            return
        }
        
        let startAngle: CGFloat = 0.0
        let endAngle: CGFloat = 2 * Math.π
        
        context.addArc(center: center, radius: CGFloat(radius), startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
    }
}

extension Polygon: Drawable {
    func draw() {
        guard let context = UIGraphicsGetCurrentContext() else {
            //does it should throw an error if there is no context?
            return
        }
        
        context.move(to: corners.last!)
        
        for point in corners {
            context.addLine(to: point)
        }
        
        context.closePath()
        context.strokePath()
    }
}

let polygon = Polygon()
let circle = Circle(CGPoint(x: 0, y:0) , 10)

let diagramArray: [Drawable] = [polygon, circle]
