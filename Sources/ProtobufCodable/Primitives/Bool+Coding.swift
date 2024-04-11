import Foundation

extension Bool: EncodablePrimitive {

    var protoTypeName: String {
        "bool"
    }

    static var zero: Bool {
        false
    }

    /// The boolean encoded as data
    var encodedData: Data {
        Data([self ? 1 : 0])
    }

}

extension Bool: DecodablePrimitive {

    static var wireType: WireType {
        .varInt
    }

    /**
     Decode a boolean from encoded data.
     - Parameter data: The data to decode
     - Throws: ``CorruptedDataError``
     */
    init(data: Data) throws {
        guard data.count == 1 else {
            throw CorruptedDataError(invalidSize: data.count, for: "Bool")
        }
        let byte = data[data.startIndex]
        switch byte {
        case 0:
            self = false
        case 1:
            self = true
        default:
            throw CorruptedDataError(invalidBoolByte: byte)
        }
    }
}

// - MARK: Packable

extension Bool: Packable {

}

// MARK: - ProtobufMapKey

extension Bool: ProtobufMapKey {

}
