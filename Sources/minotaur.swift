import LogicKit

let zero = Value (0)

func succ (_ of: Term) -> Map {
    return ["succ": of]
}

func toNat (_ n : Int) -> Term {
    var result : Term = zero
    for _ in 1...n {
        result = succ (result)
    }
    return result
}

struct Position : Equatable, CustomStringConvertible {
    let x : Int
    let y : Int

    var description: String {
        return "\(self.x):\(self.y)"
    }

    static func ==(lhs: Position, rhs: Position) -> Bool {
      return lhs.x == rhs.x && lhs.y == rhs.y
    }

}


// rooms are numbered:
// x:1,y:1 ... x:n,y:1
// ...             ...
// x:1,y:m ... x:n,y:m
func room (_ x: Int, _ y: Int) -> Term {
  return Value (Position (x: x, y: y))
}

func doors (from: Term, to: Term) -> Goal {
    return   (from === room(2,1) && to === room(1,1)) ||
             (from === room(1,2) && to === room(1,1)) ||
             (from === room(1,2) && to === room(2,2)) ||
             (from === room(3,2) && to === room(3,3)) ||
             (from === room(4,2) && to === room(4,3)) ||
             (from === room(4,2) && to === room(4,1)) ||
             (from === room(1,4) && to === room(1,3)) ||
             (from === room(2,4) && to === room(2,3)) ||
             (from === room(3,4) && to === room(2,4)) ||
             (from === room(1,3) && to === room(1,2)) ||
             (from === room(2,3) && to === room(1,3)) ||
             (from === room(2,2) && to === room(3,2)) ||
             (from === room(3,1) && to === room(2,1)) ||
             (from === room(4,1) && to === room(3,1)) ||
             (from === room(3,2) && to === room(4,2)) ||
             (from === room(2,3) && to === room(2,2)) ||
             (from === room(3,4) && to === room(3,3)) ||
             (from === room(4,4) && to === room(3,4))
}

func entrance (location: Term) -> Goal {
    return  (location === room(1,4)) ||
            (location === room(4,4))
}

func exit (location: Term) -> Goal {
    return  (location === room(1,1)) ||
            (location === room(4,3))
}

func minotaur (location: Term) -> Goal {
    return (location === room(3,2))
}

func path (from: Term,to: Term,through: Term) -> Goal {
  return
        //cas 1: les chambres sont à coté et donc le trough est vide et on doit juste faire le test doors
        ((doors(from: from, to: to)) && (through === List.empty)) ||
        // cas 2 : on mets toutes les portes entre les 2 chambres dans la liste et on teste s'il y a unt porte de from a to qui est 1ere dans la liste
        (delayed (fresh { x in fresh { y in
          ((through === List.cons(x, y)) && (doors(from: from, to: x))
            && (path(from: x, to: to, through: y))) }}))
}


//Pour créer la fonction battery, on doit créer une autre fonction, dont le role sera de soustraire un nb du level pour le 1er cas

func batt(through: Term, level: Term) -> Goal {
  return  (through === List.empty) ||
          delayed (fresh { x in fresh { y in fresh { z in fresh { a in
            (through === List.cons(x, y)) &&
            (level ≡ succ(z)) &&
            (z === succ(a)) &&
            (batt(through:y, level: z))

          }}}})
}

func battery (through: Term, level: Term) -> Goal {
    return delayed (fresh { x in (level === succ(x)) &&
    batt(through: through, level: x)})
}

//The next function tell us if there is a minotaur in our path
func dangerMinotaur (_ path: Term) -> Goal {
  return
    delayed ( fresh {
      x in fresh {
        y in
          (path === List.cons(y, x)) &&
          (minotaur(location : y) ||
          dangerMinotaur(x))
      }
    }
  )
}
func winning (through: Term, level: Term) -> Goal {
  return
    battery(through : through, level : level) &&
    dangerMinotaur(through) &&
    fresh {
      x in fresh {
                  y in
                  (entrance(location : x) &&
                  exit(location : y) &&
                  path(from : x, to : y, through : through))}}

}
