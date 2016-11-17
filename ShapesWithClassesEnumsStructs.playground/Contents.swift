/*Goal Create framework for SVG
 render a svg file*/
import Foundation

//CSS colors
// Enum String as a RawRepresentable
enum ColorName: String {
    case black, silver, gray, white, maroon, red, purple, fuchsia, green, lime, olive, yellow, navy, blue, teal, aqua
}

//Associated Values
enum CSSColor {
    case named(ColorName)
    case rgb(UInt8, UInt8, UInt8)
}

//Protocols and Methods with an Enum
extension CSSColor: CustomStringConvertible {
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

//Initializers with an Enum
//make a custom initializer for grayscale values.
extension CSSColor {
    init(gray: UInt8) {
        self = .rgb(gray, gray, gray)
    }
}

let color3 = CSSColor(gray: 0xaa)
print(color3)

//Namespaces with Enum
