import Foundation

extension UInt64: EncodablePrimitive {

    var protoTypeName: String {
        "uint64"
    }
    
    /// The value encoded using variable-length encoding
    var encodedData: Data {
        variableLengthEncoded
    }
}

extension UInt64: DecodablePrimitive {

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

extension UInt64: VariableLengthEncodable {

    /**
     Encode a 64 bit unsigned integer using variable-length encoding.

     The first bit in each byte is used to indicate that another byte will follow it.
     So values from 0 to 2^7 - 1 (i.e. 127) will be encoded in a single byte.
     The maximum encodable value `2^64 - 1` is encoded as 10 byte.

     - Parameter value: The value to encode.
     - Returns: The value encoded as binary data (1 to 10 byte)
     */
    public var variableLengthEncoded: Data {
        var result = Data()
        var value = self
        while true {
            // Extract 7 bit from value
            let nextByte = UInt8(value & 0x7F)
            value = value >> 7
            guard value > 0 else {
                result.append(nextByte)
                return result
            }
            // Set 8th bit to indicate another byte
            result.append(nextByte | 0x80)
        }
    }
}

extension UInt64: VariableLengthDecodable {

    /**
     Create an integer from variable-length encoded data.
     - Parameter data: The data to decode.
     - Throws: ``CorruptedDataError``
     */
    public init(fromVarint data: Data) throws {
        var currentIndex = data.startIndex
        
        func nextByte() throws -> UInt64 {
            guard currentIndex < data.endIndex else {
                throw CorruptedDataError(prematureEndofDataDecoding: "variable length integer")
            }
            defer { currentIndex += 1}
            return UInt64(data[currentIndex])
        }
        
        func ensureDataIsAtEnd() throws {
            guard currentIndex == data.endIndex else {
                throw CorruptedDataError(unusedBytes: data.endIndex - currentIndex, during: "variable length integer decoding")
            }
        }
        
        let startByte = try nextByte()
        guard startByte & 0x80 > 0 else {
            try ensureDataIsAtEnd()
            self = startByte
            return
        }

        var result = startByte & 0x7F
        // There are always 7 usable bits per byte, for 8 bytes
        for byteIndex in 1...8 {
            let nextByte = try nextByte()
            // Insert the last 7 bit of the byte at the end
            result += UInt64(nextByte & 0x7F) << (byteIndex*7)
            // Check if an additional byte is coming
            guard nextByte & 0x80 > 0 else {
                try ensureDataIsAtEnd()
                self = result
                return
            }
        }

        // If we're here, the 9th byte had the MSB set
        let nextByte = try nextByte()
        switch nextByte {
        case 0:
            break
        case 1:
            result += 1 << 63
        default:
            // Only 0x01 and 0x00 are valid for the 10th byte, or the UInt64 would overflow
            throw CorruptedDataError.init(outOfRange: "\(result) + \(nextByte) << 63", forType: "UInt64")
        }
        try ensureDataIsAtEnd()
        self = result
    }
}

// - MARK: Fixed-size encoding

extension UInt64: FixedSizeEncodable {
    
    public static var fixedDataType: WireType {
        .i64
    }
    
    public var fixedProtoTypeName: String {
        "fixed64"
    }
    
    /// The value encoded as fixed-size data
    public var fixedSizeEncoded: Data {
        Data(underlying: littleEndian)
    }
}

extension UInt64: FixedSizeDecodable {

    /**
     Decode a value from fixed-size data.
     - Parameter data: The data to decode.
     - Throws: ``CorruptedDataError``
     */
    public init(fromFixedSize data: Data) throws {
        guard data.count == MemoryLayout<UInt64>.size else {
            throw CorruptedDataError(invalidSize: data.count, for: "UInt64")
        }
        self.init(littleEndian: data.interpreted())
    }
}

// MARK: - Packable

extension UInt64: Packable {

}

// MARK: - ProtobufMapKey

extension UInt64: ProtobufMapKey {

}


