import Foundation

extension UInt32: EncodablePrimitive {

    var protoTypeName: String {
        "uint32"
    }
    
    /// The value encoded using variable-length encoding
    var encodedData: Data {
        variableLengthEncoded
    }
}

extension UInt32: DecodablePrimitive {

    static var wireType: WireType {
        .varInt
    }
    
    /**
     Create an integer from variable-length encoded data.
     - Parameter data: The data to decode.
     - Throws: ``CorruptedDataError``
     */
    init(data: Data) throws {
        try self.init(fromVarint: data)
    }
}

// - MARK: Variable-length encoding

extension UInt32: VariableLengthEncodable {

    /// The value encoded using variable-length encoding
    public var variableLengthEncoded: Data {
        UInt64(self).variableLengthEncoded
    }

}

extension UInt32: VariableLengthDecodable {

    /**
     Create an integer from variable-length encoded data.
     - Parameter data: The data to decode.
     - Throws: ``CorruptedDataError``
     */
    public init(fromVarint data: Data) throws {
        let raw = try UInt64(fromVarint: data)
        guard let value = UInt32(exactly: raw) else {
            throw CorruptedDataError(outOfRange: raw, forType: "UInt32")
        }
        self = value
    }
}

// - MARK: Fixed-size encoding

extension UInt32: FixedSizeEncodable {
    
    public static var fixedDataType: WireType {
        .i32
    }
    
    public var fixedProtoTypeName: String {
        "fixed32"
    }

    /// The value encoded as fixed-size data
    public var fixedSizeEncoded: Data {
        Data(underlying: littleEndian)
    }
}

extension UInt32: FixedSizeDecodable {

    /**
     Decode a value from fixed-size data.
     - Parameter data: The data to decode.
     - Throws: ``CorruptedDataError``
     */
    public init(fromFixedSize data: Data) throws {
        guard data.count == MemoryLayout<UInt32>.size else {
            throw CorruptedDataError(invalidSize: data.count, for: "UInt32")
        }
        self.init(littleEndian: data.interpreted())
    }
}

// MARK: - Packable

extension UInt32: Packable {

}

// MARK: - ProtobufMapKey

extension UInt32: ProtobufMapKey {

}

