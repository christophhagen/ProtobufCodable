import Foundation

class ObjectEncoder: CodingPathNode {

    var objects = [EncodedDataProvider]()

    @discardableResult
    func addObject<T>(_ block: () throws -> T) rethrows -> T where T: EncodedDataProvider {
        let object = try block()
        objects.append(object)
        return object
    }
}
