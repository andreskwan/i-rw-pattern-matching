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
        return lhs.corners == rhs.corners
    }
}
