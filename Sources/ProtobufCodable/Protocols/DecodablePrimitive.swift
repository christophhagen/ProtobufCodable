import Foundation

/**
 A protocol adopted by primitive types for decoding.
 */
protocol DecodablePrimitive: WireTypeProvider {

    /**
     Decode a value from the data.
     - Note: All provided data can be used
     - Throws: Errors of type ``CorruptDataError``
     */
    init(data: Data) throws

    static var zero: Self { get }
}

extension DecodablePrimitive {

    init(elements: [DataField]?) throws {
        guard let (type, data) = elements?.last else {
            self = Self.zero
            return
        }
        guard type == Self.wireType else {
            throw CorruptedDataError.init(invalidType: type, for: "\(Self.self)")
        }
        try self.init(data: data)
    }
}
