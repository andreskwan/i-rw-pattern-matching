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
