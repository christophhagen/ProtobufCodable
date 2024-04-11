import Foundation

extension Int64: EncodablePrimitive {

    var protoTypeName: String {
        "int64"
    }
    
    /// The value encoded using variable-length encoding
    var encodedData: Data { variableLengthEncoded }
}

extension Int64: DecodablePrimitive {

    static var wireType: WireType {
        .varInt
    }
    
    /**
     Decode an integer from variable-length encoded data.
     - Parameter data: The data of the variable-length encoded value.
     - Throws: ``CorruptedDataError``
     */
    init(data: Data) throws {
        try self.init(fromVarint: data)
    }
}

// - MARK: Variable-length encoding

extension Int64: VariableLengthEncodable {

    /// The value encoded using variable length encoding
    public var variableLengthEncoded: Data {
        UInt64(bitPattern: self).encodedData
    }

}

extension Int64: VariableLengthDecodable {

    /**
     Create an integer from variable-length encoded data.
     - Parameter data: The data to decode.
     - Throws: ``CorruptedDataError``
     */
    public init(fromVarint data: Data) throws {
        let value = try UInt64(fromVarint: data)
        self = Int64(bitPattern: value)
    }
}

// - MARK: Zig-zag encoding

extension Int64: SignedEncodable {
    
    public var signedProtoTypeName: String {
        "sfixed64"
    }

    /// The integer encoded using zig-zag encoding
    public var signedEncoded: Data {
        guard self < 0 else {
            return (UInt64(self.magnitude) << 1).variableLengthEncoded
        }
        return ((UInt64(-1 - self) << 1) + 1).variableLengthEncoded
    }
}

extension Int64: SignedDecodable {
    
    /**
     Decode an integer from zig-zag encoded data.
     - Parameter data: The data of the zig-zag encoded value.
     - Throws: ``CorruptedDataError``
     */
    public init(fromSigned data: Data) throws {
        let unsigned = try UInt64(fromVarint: data)

        // Check the last bit to get sign
        if unsigned & 1 > 0 {
            // Divide by 2 and subtract one to get absolute value of negative values.
            self = -Int64(unsigned >> 1) - 1
        } else {
            // Divide by two to get absolute value of positive values
            self = Int64(unsigned >> 1)
        }
    }
}

// - MARK: Fixed-size encoding

extension Int64: FixedSizeEncodable {
    
    public static var fixedDataType: WireType {
        .i64
    }
    
    public var fixedProtoTypeName: String {
        "sfixed64"
    }

    /// The value encoded as fixed-size data
    public var fixedSizeEncoded: Data {
        let value = UInt64(bitPattern: littleEndian)
        return Data.init(underlying: value)
    }
}

extension Int64: FixedSizeDecodable {

    /**
     Decode a value from fixed-size data.
     - Parameter data: The data to decode.
     - Throws: ``CorruptedDataError``
     */
    public init(fromFixedSize data: Data) throws {
        guard data.count == MemoryLayout<UInt64>.size else {
            throw CorruptedDataError(invalidSize: data.count, for: "Int64")
        }
        let value = UInt64(littleEndian: data.interpreted())
        self.init(bitPattern: value)
    }
}

// - MARK: Packable

extension Int64: Packable {

}

// MARK: - ProtobufMapKey

extension Int64: ProtobufMapKey {

}
