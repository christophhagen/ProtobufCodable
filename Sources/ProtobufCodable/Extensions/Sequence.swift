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

extension Sequence {

    func mapAndJoin(_ closure: (Element) throws -> Data) rethrows -> Data {
        var result = Data()
        for (value) in self {
            let data = try closure(value)
            result.append(data)
        }
        return result
    }
}
