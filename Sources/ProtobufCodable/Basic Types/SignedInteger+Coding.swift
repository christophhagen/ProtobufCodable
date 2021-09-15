import Foundation

// MARK: BinaryEncodable

extension Int8: BinaryCodable {
    
    public func binaryData() -> Data {
        UInt8(bitPattern: self).binaryData()
    }
    
    public init(from byteProvider: DecodingDataProvider) throws {
        self = Int8(bitPattern: try byteProvider.getNextByte())
    }
}

extension Int16: BinaryCodable { }

extension Int32: BinaryCodable { }

extension Int64: BinaryCodable { }

extension Int: BinaryCodable { }

// MARK: FixedLengthWireType

extension Int8: FixedLengthWireType {
    
    public var fixedLengthWireType: WireType { .length8 }
}

extension Int16: FixedLengthWireType {
    
    public var fixedLengthWireType: WireType { .length16 }
}

extension Int32: FixedLengthWireType {
    
    public var fixedLengthWireType: WireType { .length32 }
}

extension Int64: FixedLengthWireType {
    
    public var fixedLengthWireType: WireType { .length64 }
}

// MARK: HostIndependentRepresentable

extension Int8: HostIndependentRepresentable {
    
    public var hostIndependentRepresentation: Int8 {
        self
    }
    
    public init(fromHostIndependentRepresentation value: Int8) {
        self = value
    }
}

extension Int16: HostIndependentRepresentable {
    
    public var hostIndependentRepresentation: UInt16 {
        CFSwapInt16HostToLittle(.init(bitPattern: self))
    }
    
    public init(fromHostIndependentRepresentation value: UInt16) {
        self.init(bitPattern: CFSwapInt16LittleToHost(value))
    }
}

extension Int32: HostIndependentRepresentable {
    
    public var hostIndependentRepresentation: UInt32 {
        CFSwapInt32HostToLittle(.init(bitPattern: self))
    }
    
    public init(fromHostIndependentRepresentation value: UInt32) {
        self.init(bitPattern: CFSwapInt32LittleToHost(value))
    }
}

extension Int64: HostIndependentRepresentable {
    
    public var hostIndependentRepresentation: UInt64 {
        CFSwapInt64HostToLittle(.init(bitPattern: self))
    }
    
    public init(fromHostIndependentRepresentation value: UInt64) {
        self.init(bitPattern: CFSwapInt64LittleToHost(value))
    }
}

// Note: `Int` does not conform to `FixedLengthWireType`,
// because it may have different width on different systems

// MARK: Common signed functions

extension SignedInteger {
    
    /**
     Encodes the integer into binary data, using variable length encoding.
     - Returns: The binary data of the converted value.
     */
    public func binaryData() -> Data {
        variableLengthEncoding
    }
    
    /// The wire type of the integer (`varint`)
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
     The maximum encodable value ` 2^64 - 1 ` is encoded as 10 byte.
     
     - Returns: The value encoded as binary data (1 to 10 byte)
     */
    var variableLengthEncoding: Data {
        UInt64(bitPattern: Int64(self)).variableLengthEncoding
    }
    
    public init(from byteProvider: DecodingDataProvider) throws {
        let value = try Int64.from(byteProvider)
        guard let result = Self.init(exactly: value) else {
            throw ProtobufDecodingError.variableLengthEncodedValueOutOfRange
        }
        self = result
    }
    
    init(zigZagEncodedFrom byteProvider: DecodingDataProvider) throws {
        let value = try Int64.zigZagEncoded(from: byteProvider)
        guard let result = Self.init(exactly: value) else {
            throw ProtobufDecodingError.variableLengthEncodedValueOutOfRange
        }
        self = result
    }
}

extension Int64 {
    
    /**
     Decode a 64 bit signed integer using variable-length encoding.
     
     Decodes an unsigned integer, where the last bit indicates the sign, and the absolute value is half of the decoded value
     - Parameter byteProvider: A closure providing the next byte in the data.
     - Throws: `BinaryDecodingError.unexpectedEndOfData`
     - Returns: The decoded signed integer.
     */
    static func zigZagEncoded(from byteProvider: DecodingDataProvider) throws -> Int64 {
        let result = try UInt64.from(byteProvider)
        // Check the last bit to get sign
        guard result & 1 > 0 else {
            // Divide by two to get absolute value of positive values
            return Int64(result >> 1)
        }
        // Divide by 2 and subtract one to get absolute value of negative values.
        return -Int64(result >> 1) - 1
    }
    
    /**
     Decode a 64 bit signed integer using variable-length encoding.
     
     Decodes an unsigned integer, where the last bit indicates the sign, and the absolute value is half of the decoded value
     - Parameter byteProvider: A closure providing the next byte in the data.
     - Throws: `BinaryDecodingError.unexpectedEndOfData`
     - Returns: The decoded signed integer.
     */
    static func from(_ byteProvider: DecodingDataProvider) throws -> Int64 {
        Int64(bitPattern: try UInt64.from(byteProvider))
    }
}
