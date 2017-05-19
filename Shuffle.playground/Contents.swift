import Foundation

/// Provides never-ending shuffled random indexes. When an index is returned it is put in a discard pile, which turns back to the deck when the deck is empty. The available indexes are continuous without gaps, starting with 0.
class Shuffler {
    typealias Index = Int
    var deck = [Index]()
    var discard = [Index]()
    var total: Int { return deck.count + discard.count }
    var ratioDiscarded: Float { if total == 0 { return 0 } else { return Float(discard.count)/Float(total) } }
    var lastValueOfLastDeck: Index = 0
    
    
    
    /// The next shuffled, random indexes.
    /// - parameters:
    ///     - count: The number of indexes returned (there is no limit).
    /// - returns: An array of index's
    
    func next(count: Int) -> [Index] {
        let emptiesDeck = count == deck.count
        var nextIndexes = [Index]()
        var deckIndexes = [Index]()
        
        if count == 0 || total == 0 {
            return nextIndexes
        } else if count <= deck.count {
            for i in 0..<count {
                let random = Index(arc4random_uniform(UInt32(deck.count - i)))
                if discard.count == 0 && i == 0 && total > 2 && deck[random] == lastValueOfLastDeck {// prevents matching last of the old deck with first of the new
                    if random + 1 < deck.count {
                        deckIndexes.append(random + 1)
                    } else {
                        deckIndexes.append(random - 1)
                    }
                } else {
                    deckIndexes.append(random)
                }
            }
            
            for index in deckIndexes {
                nextIndexes.append(deck.remove(at: index))
            }
            discard += nextIndexes
        } else if count > deck.count {
            let numToEmpty = deck.count
            return next(count: numToEmpty) + next(count: count - numToEmpty)
        }
        
        if emptiesDeck {
            swap(&deck, &discard)
            lastValueOfLastDeck = deck.last ?? 0
        }
        return nextIndexes
    }
    
    /// Adds to the total number of indexes available.
    /// - parameters:
    ///     - numOfIndexes: How many indexes to add.
    func add(numOfIndexes num: Int) {
        if num == 0 { return }
        if num < 0 { remove(numOfIndexes: -num) }
        
        let putInDiscard = Int(Float(num) * ratioDiscarded)
        discard += stride(from: total, to: total + putInDiscard, by: 1)
        let putInDeck = num - putInDiscard
        deck += stride(from: total, to: total + putInDeck, by: 1)
    }
    
    /// Removes from the total number of indexes available
    /// - parameters:
    ///     - numOfIndexes: How many indexes to remove.
    func remove(numOfIndexes num: Int) {
        if num == 0 { return }
        if num < 0 { add(numOfIndexes: -num) }
        let num = num <= total ? num : total
        
        let toRemove = stride(from: total - num, to: total, by: 1)
        for remove in toRemove {
            if let index = deck.index(of: remove) {
                deck.remove(at: index)
            }else if let index = discard.index(of: remove) {
                discard.remove(at: index)
            }
        }
    }
    
    /// Set the total number of indexes available.
    /// - parameters:
    ///     - numOfIndexes: How many total indexes
    func setTotal(numOfIndexes num: Int) {
        if num <= 0 {
            deck.removeAll()
            discard.removeAll()
        } else if num > total {
            add(numOfIndexes: num - total)
        } else if num < total {
            remove(numOfIndexes: total - num)
        }
    }
}

let shuffler = Shuffler()
print("init\ndeck: \(shuffler.deck), discard: \(shuffler.discard)")

shuffler.add(numOfIndexes: 5)
print("add 5\ndeck: \(shuffler.deck), discard: \(shuffler.discard)")

shuffler.setTotal(numOfIndexes: 3)
print("set total 3\ndeck: \(shuffler.deck), discard: \(shuffler.discard)")

shuffler.remove(numOfIndexes: 10)
print("remove 10\ndeck: \(shuffler.deck), discard: \(shuffler.discard)")

shuffler.add(numOfIndexes: 8)
print("add 8\ndeck: \(shuffler.deck), discard: \(shuffler.discard)")

let next = shuffler.next(count: 55)
print("next 55\n\(next)")