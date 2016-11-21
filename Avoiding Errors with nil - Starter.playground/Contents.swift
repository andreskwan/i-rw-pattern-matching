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

// ----------------------------------------------------------------------------
// Playground that includes Witches.
//
// These magical beings may be created and may cast spells on each other 
// & their familiars (i.e. cats, bats, toads).
// ----------------------------------------------------------------------------

//Protocol - Provide a visual representation
//of each object that can be printed to the console.
protocol Avatar {
  var avatar: String { get }
}


// ----------------------------------------------------------------------------
// Example One - Avoiding Swift errors using nil (failable initializers)
// ----------------------------------------------------------------------------
//Enum - magic words that represent a spell
//- String is the (custom type)/(backing store)
//- list of known things
enum MagicWords: String {
  case abracadbra = "abracadabra"
  case alakazam = "alakazam"
  case hocusPocus = "hocus pocus"
  case prestoChango = "presto chango"
}

//Struct - model spell 
//- Why not a protocol for spells?
struct Spell {
  var magicWords: MagicWords = .abracadbra
}

extension Spell {
    //Enum - why not use the Enum as parameter to avoid errors?
    //Factory Method
    //- this is an initializer
    //- tries to create an spell using a String that represents a MagicWord
  static func create(withMagicWords words: String) -> Spell? {
    //Optional binding
    if let incantation = MagicWords(rawValue: words) {
      var spell = Spell()
      spell.magicWords = incantation
      return spell
    }
    else {
      return nil
    }
  }
    //Failable Initializer replacing the factory method
    //this initializer is optional
    init?(words: String) {
        if let incantation = MagicWords(rawValue: words) {
            self.magicWords = incantation
        } else {
            return nil
        }
    }
}

let first = Spell.create(withMagicWords: "abracadabra")
let second = Spell.create(withMagicWords: "ascendio")

let third = Spell(words: "abracadabra")
let fourth = Spell(words: "ascendio")
let fifth = Spell()
print(fifth)


    
