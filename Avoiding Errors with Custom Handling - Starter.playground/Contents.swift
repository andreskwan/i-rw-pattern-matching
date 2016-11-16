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

// Most objects in this tutorial need an avatar, to make things exciting.

protocol Avatar {
  var avatar: String { get }
}

enum MagicWords: String {
  case abracadbra = "abracadabra"
  case alakazam = "alakazam"
  case hocusPocus = "hocus pocus"
  case prestoChango = "presto chango"
}

struct Spell {

  var magicWords: MagicWords = .abracadbra
  
  // If words are considered magical, we can create a spell
  init?(words: String) {
    guard let incantation = MagicWords(rawValue: words) else {
      return nil
    }
    self.magicWords = incantation
  }
  
  init?(magicWords: MagicWords) {
    self.magicWords = magicWords
  }
}


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
        if let hat = hat {
            if hat.isMagical { // When have you ever seen a Witch perform a spell without her magical hat on ? :]
                if let familiar = familiar {   // Check if witch has a familiar
                    if let toad = familiar as? Toad {  // If familiar is already a toad, no magic required
                        return toad
                    } else {
                        if hasSpell(ofType: .prestoChango) {
                            if let name = familiar.name {
                                return Toad(name: name)
                            }
                        }
                    }
                }
            }
        }
        return Toad(name: "New Toad")  // This is an entirely new Toad.
    }
  
  func hasSpell(ofType type: MagicWords) -> Bool { // Check if witch currently has an appropriate spell in their spellbook
    let change = spells.flatMap { spell in
      spell.magicWords == type
    }
    return change.count > 0
  }
}
