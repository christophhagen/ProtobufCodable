import Foundation

extension Int32: EncodablePrimitive {

    var protoTypeName: String {
        "int32"
    }
    
    /// The integer encoded using variable-length encoding
    var encodedData: Data {
        variableLengthEncoded
    }
}

extension Int32: DecodablePrimitive {

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

extension Int32: VariableLengthEncodable {

    /// The value encoded using variable length encoding
    public var variableLengthEncoded: Data {
        UInt32(bitPattern: self).variableLengthEncoded
    }
}

extension Int32: VariableLengthDecodable {

    /**
     Create an integer from variable-length encoded data.
     - Parameter data: The data to decode.
     - Throws: ``CorruptedDataError``
     */
    public init(fromVarint data: Data) throws {
        let value = try UInt32(fromVarint: data)
        self = Int32(bitPattern: value)
    }
}

// - MARK: Zig-zag encoding

extension Int32: SignedEncodable {

    /// The protobuf type equivalent to the signed size type
    public var signedProtoTypeName: String {
        "sint32"
    }
    
    /// The integer encoded using zig-zag encoding
    public var signedEncoded: Data {
        Int64(self).signedEncoded
    }
}

extension Int32: SignedDecodable {

    /**
     Decode an integer from zig-zag encoded data.
     - Parameter data: The data of the zig-zag encoded value.
     - Throws: ``CorruptedDataError``
     */
    public init(fromSigned data: Data) throws {
        let raw = try Int64(fromSigned: data)
        guard let value = Int32(exactly: raw) else {
            throw CorruptedDataError(outOfRange: raw, forType: "Int32")
        }
        self = value
    }
}

// - MARK: Fixed-size encoding

extension Int32: FixedSizeEncodable {
    
    public static var fixedDataType: WireType {
        .i32
    }
    
    public var fixedProtoTypeName: String {
        "sfixed32"
    }

    /// The value encoded as fixed-size data
    public var fixedSizeEncoded: Data {
        let value = UInt32(bitPattern: littleEndian)
        return Data(underlying: value)
    }
}

extension Int32: FixedSizeDecodable {

    /**
     Decode a value from fixed-size data.
     - Parameter data: The data to decode.
     - Throws: ``CorruptedDataError``
     */
    public init(fromFixedSize data: Data) throws {
        guard data.count == MemoryLayout<UInt32>.size else {
            throw CorruptedDataError(invalidSize: data.count, for: "Int32")
        }
        let value = UInt32(littleEndian: data.interpreted())
        self.init(bitPattern: value)
    }
}

// MARK: - Packable

extension Int32: Packable {

}

// MARK: - ProtobufMapKey

extension Int32: ProtobufMapKey {

}
