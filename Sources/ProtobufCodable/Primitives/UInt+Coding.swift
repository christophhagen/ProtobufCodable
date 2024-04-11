import Foundation

extension UInt: EncodablePrimitive {
    
    var protoTypeName: String {
        "uint64"
    }

    /// The value encoded using variable-length encoding
    var encodedData: Data {
        variableLengthEncoded
    }
}

extension UInt: DecodablePrimitive {

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

extension UInt: VariableLengthEncodable {
    
    public var variableLengthEncoded: Data {
        UInt64(self).variableLengthEncoded
    }
}

extension UInt: VariableLengthDecodable {

    /**
     Create an integer from variable-length encoded data.
     - Parameter data: The data to decode.
     - Throws: ``CorruptedDataError``
     */
    public init(fromVarint data: Data) throws {
        let raw = try UInt64(fromVarint: data)
        guard let value = UInt(exactly: raw) else {
            throw CorruptedDataError(outOfRange: raw, forType: "UInt")
        }
        self = value
    }
}

// - MARK: Fixed-size encoding

extension UInt: FixedSizeEncodable {
    
    public static var fixedDataType: WireType {
        .i64
    }
    
    public var fixedProtoTypeName: String {
        "fixed64"
    }

    /// The value encoded as fixed-size data
    public var fixedSizeEncoded: Data {
        UInt64(self).fixedSizeEncoded
    }
}

extension UInt: FixedSizeDecodable {

    /**
     Decode a value from fixed-size data.
     - Parameter data: The data to decode.
     - Throws: ``CorruptedDataError``
     */
    public init(fromFixedSize data: Data) throws {
        let intValue = try UInt64(fromFixedSize: data)
        guard let value = UInt(exactly: intValue) else {
            throw CorruptedDataError(outOfRange: intValue, forType: "UInt")
        }
        self = value
    }
}

// - MARK: Packable

extension UInt: Packable {

}

// MARK: - ProtobufMapKey

extension UInt: ProtobufMapKey {

}
