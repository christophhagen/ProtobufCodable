import Foundation

extension Int: EncodablePrimitive {
    
    var protoTypeName: String {
        "int64"
    }

    /// The integer encoded using variable-length encoding
    var encodedData: Data {
        variableLengthEncoded
    }
}

extension Int: DecodablePrimitive {

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

extension Int: VariableLengthEncodable {

    /// The value encoded using variable length encoding
    public var variableLengthEncoded: Data {
        Int64(self).variableLengthEncoded
    }
}

extension Int: VariableLengthDecodable {

    /**
     Create an integer from variable-length encoded data.
     - Parameter data: The data to decode.
     - Throws: ``CorruptedDataError``
     */
    public init(fromVarint data: Data) throws {
        let intValue = try Int64(fromVarint: data)
        guard let value = Int(exactly: intValue) else {
            throw CorruptedDataError(outOfRange: intValue, forType: "Int")
        }
        self = value
    }
}

// - MARK: Zig-zag encoding

extension Int: SignedEncodable {
    
    /// The protobuf type equivalent to the signed size type
    public var signedProtoTypeName: String {
        "sint64"
    }

    /// The integer encoded using zig-zag encoding
    public var signedEncoded: Data {
        Int64(self).signedEncoded
    }
}

extension Int: SignedDecodable {

    /**
     Decode an integer from zig-zag encoded data.
     - Parameter data: The data of the zig-zag encoded value.
     - Throws: ``CorruptedDataError``
     */
    public init(fromSigned data: Data) throws {
        let raw = try Int64(data: data)
        guard let value = Int(exactly: raw) else {
            throw CorruptedDataError(outOfRange: raw, forType: "Int")
        }
        self = value
    }
}

// - MARK: Fixed-size encoding

extension Int: FixedSizeEncodable {
    
    public static var fixedDataType: WireType {
        .i64
    }
    
    public var fixedProtoTypeName: String {
        "sfixed64"
    }

    /// The value encoded as fixed-size data
    public var fixedSizeEncoded: Data {
        Int64(self).fixedSizeEncoded
    }
}

extension Int: FixedSizeDecodable {

    /**
     Decode a value from fixed-size data.
     - Parameter data: The data to decode.
     - Throws: ``CorruptedDataError``
     */
    public init(fromFixedSize data: Data) throws {
        let signed = try Int64(fromFixedSize: data)
        guard let value = Int(exactly: signed) else {
            throw CorruptedDataError(outOfRange: signed, forType: "Int")
        }
        self = value
    }
}

// MARK: - Packable

extension Int: Packable {

}

// MARK: - ProtobufMapKey

extension Int: ProtobufMapKey {

}
