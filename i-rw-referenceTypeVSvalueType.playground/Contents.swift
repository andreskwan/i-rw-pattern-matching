//: Playground - noun: a place where people can play

import UIKit


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
