import Foundation

extension CodingKey {

    /**
     Compare two coding keys for equality.

     Keys are first compared by their integer value, if it exists.
     If either one has no integer key, then the string values are compared.
     - Parameter other: The key to compare.
     */
    func isEqual(to other: CodingKey) -> Bool {
        if let ownInt = intValue, let otherInt = other.intValue {
            return ownInt == otherInt
        }
        return stringValue == other.stringValue
    }

    /**
     Create a coding key from another coding key.
     - Parameter key: The key to convert.
     */
    init?(key: CodingKey) {
        guard let int = key.intValue else {
            self.init(stringValue: key.stringValue)
            return
        }
        self.init(intValue: int)
    }

    /**
     The nil data coding key.

     The nil key is used to encode information about optional values within keyed containers.
     */
    var correspondingNilKey: GenericCodingKey {
        .init(convertingToNilKey: self)
    }
}
