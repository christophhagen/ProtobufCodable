import Foundation

extension Sequence {
    
    func sum(_ converting: (Element) -> Int) -> Int {
        reduce(0) { $0 + converting($1) }
    }
    
    func count(isIncluded: (Element) -> Bool) -> Int {
        var count = 0
        for element in self {
            if isIncluded(element) {
                count += 1
            }
        }
        return count
    }
}
