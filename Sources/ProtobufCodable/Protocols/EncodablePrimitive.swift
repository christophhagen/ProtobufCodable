import Foundation

/**
 A protocol adopted by all base types (Int, Data, String, ...) to provide the encoded data.
 */
protocol EncodablePrimitive: EncodableContainer, WireTypeProvider {

    /// The name of the protobuf type mirrored by this Swift type
    var protoTypeName: String { get }

    /**
     The raw data of the encoded base type value.
     - Note: No length information must be included
     */
    var encodedData: Data { get }

    static var zero: Self { get }

    var isZero: Bool { get }

}

extension EncodablePrimitive {

    /**
     Encode the value only if it is not the default value
     */
    func encode(forKey key: Int) -> Data {
        guard !isZero else {
            // Default values are not encoded in keyed containers
            return .empty
        }
        return encodeAlways(forKey: key)
    }

    /**
     Encode the value with the key, even if it is a default value.

     - Note: This function is needed for unkeyed containers that are not packed.
     */
    public func encodeAlways(forKey key: Int) -> Data {
        let tag = wireType.encoded(with: key)
        let data = encodedData
        guard wireType == .len else {
            return tag + data
        }
        return tag + data.count.variableLengthEncoded + data
    }

    func encodeForUnkeyedContainer() -> Data {
        let data = encodedData
        guard wireType == .len else {
            return data
        }
        return data.count.variableLengthEncoded + data
    }
}

extension EncodablePrimitive where Self: Equatable {

    var isZero: Bool {
        self == Self.zero
    }
}
