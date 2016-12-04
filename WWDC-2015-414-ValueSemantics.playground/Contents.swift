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
