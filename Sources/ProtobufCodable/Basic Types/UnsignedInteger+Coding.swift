import Foundation

extension UInt8: BinaryPrimitiveEncodable, FixedLengthWireType {
    
    public func binaryData() -> Data {
        [self].data
    }
    
    public var fixedLengthWireType: WireType { .length8 }
}

extension UInt16: BinaryPrimitiveEncodable, FixedLengthWireType {
    
    public var fixedLengthWireType: WireType { .length16 }
}

extension UInt32: BinaryPrimitiveEncodable, FixedLengthWireType {
    
    public var fixedLengthWireType: WireType { .length32 }
}

extension UInt64: BinaryPrimitiveEncodable, FixedLengthWireType {
    
    public var fixedLengthWireType: WireType { .length64 }
}

extension UInt: BinaryPrimitiveEncodable {
    
    // Note: `UInt` does not conform to `FixedLengthWireType`,
    // because it may have different width on different systems
}

extension UnsignedInteger {
    
    public func binaryData() -> Data {
        variableLengthEncoding
    }
    
    public var wireType: WireType {
        .varint
    }
    
    /**
     Encode a 64 bit unsigned integer using variable-length encoding.
     
     The first bit in each byte is used to indicate that another byte will follow it.
     So values from 0 to 2^7 - 1 (i.e. 127) will be encoded in a single byte.
     In general, `n` bytes are needed to encode values from ` 2^(n-1) ` to ` 2^n - 1 `
     The maximum encodable value ` 2^64 - 1 ` is encoded as 10 byte.
     
     - Parameter value: The value to encode.
     - Returns: The value encoded as binary data (1 to 10 byte)
     */
    var variableLengthEncoding: Data {
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
