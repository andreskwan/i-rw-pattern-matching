/**
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

/*
 Goal: Understand Pattern Matching in Swift
 it enables to design rules that match values against each other. 
 
 The tutorial covers the following patterns:
 Tuple pattern
 Type-casting patterns
 Wildcard pattern
 Optional pattern
 Enumeration case pattern
 Expression pattern
 */

import Foundation

//Generate random days for the schedule
func random_uniform(value: Int) -> Int {
  return Int(arc4random_uniform(UInt32(value)))
}

typealias JSONObject = [String: AnyObject]
let file = Bundle.main.path(forResource:"tutorials", ofType: "json")!
let url = URL(fileURLWithPath: file)
let data = try! Data(contentsOf: url)
let json = try! JSONSerialization.jsonObject(with: data) as! [JSONObject]
print(json)

enum Day: Int {
    case monday, tuesday, wednesday, thursday, friday, saturday, sunday
}

class Tutorial {
    
    //always a title
    let title: String
    //optional for unschedule tutorials
    var day: Day?
    
    init(title: String, day: Day? = nil) {
        self.title = title
        self.day = day
    }
}

var tutorials: [Tutorial] = []

//convert the array of dictionaries/objs in JSON format into an array of Tutorial objs
//user maps to transform the array of ditionaries to an array of tutorials
//how to do this with for
for jsonObject in json {
    var title = ""
    var scheduleDay: Day? = nil
    
    for (key,value) in jsonObject {
        
    }
    guard let title = jsonObject["title"] as? String else {
        print("no title")
        break
    }
    print(title)
    tutorials.append(Tutorial(title: title, day: jsonObject["day"] as Day))
}

