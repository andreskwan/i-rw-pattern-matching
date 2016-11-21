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
    
    ////////////////////////////////////////////////////////////////////////
    //    Overloading Failable initializers
    ////////////////////////////////////////////////////////////////////////
    //Failable Initializer replacing the factory method
    //this initializer is optional
    // If words are considered magical, we can create a spell
    init?(words: String) {
        //guard -  failure case is more evident
        guard let incantation = MagicWords(rawValue: words) else {
            return nil
        }
        //golden path is the path of execution, not in an else clause
        self.magicWords = incantation
    }
    
    init?(magicWords: MagicWords) {
        self.magicWords = magicWords
    }
}
extension Spell {
    //Enum - why not use the Enum as parameter to avoid errors?
    //Factory Method
    //- this is an initializer
    //- tries to create an spell using a String that represents a MagicWord
    //    static func create(withMagicWords words: String) -> Spell? {
    //        //Optional binding
    //        if let incantation = MagicWords(rawValue: words) {
    //        // this makes this Factory method obsolete 
    //        //  because the Spell() with Failable initializers will handle the creation of the object
    //          var spell = Spell()
    //          spell.magicWords = incantation
    //          return spell
    //        }
    //        else {
    //          return nil
    //        }
    //    }
}

let first = Spell(magicWords: MagicWords(rawValue: "abracadabra")!)
//failing if not a valid raw value
//let second = Spell(magicWords: MagicWords(rawValue: "ascendio")!)

let third = Spell(words: "abracadabra")
let fourth = Spell(words: "ascendio")

// ----------------------------------------------------------------------------
// Example Two - Avoiding Errors with Custom Handling - Pyramids of Doom
// ----------------------------------------------------------------------------

// Familiars

protocol Familiar: Avatar {
    var noise: String { get }
    var name: String? { get set }
    init(name: String?)
}

extension Familiar {
    func speak() {
        print(avatar, "* \(noise)s *", separator: " ", terminator: "")
    }
}


struct Cat: Familiar {
    var name: String?
    var noise  = "purr"
    var avatar = "🐱"
    
    init(name: String?) {
        self.name = name
    }
}

struct Bat: Familiar {
    var name: String?
    var noise = "screech"
    var avatar = "[bat]" // Sadly there is no bat avatar
    
    init(name: String?) {
        self.name = name
    }
    
    func speak() {
        print(avatar, "* \(noise)es *", separator: " ", terminator: "")
    }
}

struct Toad: Familiar {
    init(name: String?) {
        self.name = name
    }
    
    var name: String?
    var noise  = "croak"
    var avatar = "🐸"
}

// Magical Things

struct Hat {
    enum HatSize {
        case small
        case medium
        case large
    }
    
    enum HatColor {
        case black
    }
    
    var color: HatColor = .black
    var size: HatSize = .medium
    var isMagical = true
}


protocol Magical: Avatar {
    var name: String? { get set }
    var spells: [Spell] { get set }
    
    func turnFamiliarIntoToad() -> Toad
}

struct Witch: Magical {
    var avatar = "👩🏻"
    var name: String?
    var familiar: Familiar?
    var spells: [Spell] = []
    var hat: Hat?
    
    init(name: String?, familiar: Familiar?) {
        self.name = name
        self.familiar = familiar
        
        if let s = Spell(magicWords: .prestoChango) {
            self.spells = [s]
        }
    }
    
    init(name: String?, familiar: Familiar?, hat: Hat?) {
        self.init(name: name, familiar: familiar)
        self.hat = hat
    }
    
    func turnFamiliarIntoToad() -> Toad {
        //here I can validate if the wich has a hat and if it is magic
        guard let hat = hat else {
            //if not hat, then no magic!
            //what should I return here?
            return 
        }
        
        //what to do here?
        //do I need this guard? 
        //it makes the failure case evident
        guard hat.isMagical else {
            //what should I return here?
        }
//        if hat.isMagical { // When have you ever seen a Witch perform a spell without her magical hat on ? :]
        // Check if witch has a familiar
        guard let familiar = familiar else {
            //no familiar yet
            //nothing to be turn into a toad
            //what should I return here?
            return
        }
        // If familiar is already a toad, no magic required
        guard let _ = familiar as? Toad else {
            //familiar is a
            return toad
        }
        
        if hasSpell(ofType: .prestoChango) {
            if let name = familiar.name {
                return Toad(name: name)
            }
        }
//        }
        //no matter what always return a toad???!!!
        return Toad(name: "New Toad")  // This is an entirely new Toad.
    }
    
    func hasSpell(ofType type: MagicWords) -> Bool { // Check if witch currently has an appropriate spell in their spellbook
        let change = spells.flatMap { spell in
            spell.magicWords == type
        }
        return change.count > 0
    }
}
