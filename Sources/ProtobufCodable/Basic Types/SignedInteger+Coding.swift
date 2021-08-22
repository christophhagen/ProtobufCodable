import Foundation

extension Int8: BinaryPrimitiveEncodable, FixedLengthWireType {
    
    public var fixedLengthWireType: WireType { .length8 }
}

extension Int16: BinaryPrimitiveEncodable, FixedLengthWireType {
    
    public var fixedLengthWireType: WireType { .length16 }
}

extension Int32: BinaryPrimitiveEncodable, FixedLengthWireType {
    
    public var fixedLengthWireType: WireType { .length32 }
}

extension Int64: BinaryPrimitiveEncodable, FixedLengthWireType {
    
    public var fixedLengthWireType: WireType { .length64 }
}



extension SignedInteger {
    
    public func binaryData() -> Data {
        variableLengthEncoding
    }
    
    public var wireType: WireType {
        .varint
    }
    
    /**
     Encode a 64 bit signed integer using variable-length encoding.
     
     The sign of the value is extracted and appended as an additional bit.
     Positive signed values are thus encoded as `UInt(value) * 2`, and negative values as `UInt(abs(value) * 2 + 1`
     
     - Parameter value: The value to encode.
     - Returns: The value encoded as binary data (1 to 9 byte)
     */
    var zigZagEncoding: Data {
        guard self < 0 else {
            return (UInt64(self.magnitude) << 1).variableLengthEncoding
        }
        return ((UInt64(-1 - self) << 1) + 1).variableLengthEncoding
    }
    
    
    /**
     Encode the value using variable-length encoding.
     
     The first bit in each byte is used to indicate that another byte will follow it.
     So values from 0 to 2^7 - 1 (i.e. 127) will be encoded in a single byte.
     In general, `n` bytes are needed to encode values from ` 2^(n-1) ` to ` 2^n - 1 `
     The maximum encodable value ` 2^64 - 1 ` is encoded as 9 byte.
     
     - Returns: The value encoded as binary data (1 to 9 byte)
     */
    var variableLengthEncoding: Data {
        UInt64(bitPattern: Int64(self)).variableLengthEncoding
    }
}
