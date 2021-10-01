import Foundation

// MARK: BinaryEncodable

extension Int8: BinaryCodable {

    /**
     Convert the integer value to binary data.

     The value is cast to an unsigned byte and returned, occupying exactly one byte.
     - Returns: The binary data of the integer value
     */
    func binaryData() -> Data {
        UInt8(bitPattern: self).binaryData()
    }

    /**
     Decode a signed integer from a data provider.

     Reads a single byte from the container and casts it to a signed value.
     - Throws: `ProtobufDecodingError.missingData`, if no more bytes are available.
     */
    init(from byteProvider: DecodingDataProvider) throws {
        self = Int8(bitPattern: try byteProvider.getNextByte())
    }
}

extension Int16: BinaryCodable { }

extension Int32: BinaryCodable { }

extension Int64: BinaryCodable { }

extension Int: BinaryCodable { }

// MARK: SignedValueCompatible

extension Int16: SignedValueCompatible { }

extension Int32: SignedValueCompatible { }

extension Int64: SignedValueCompatible { }

extension Int: SignedValueCompatible { }

// MARK: WireTypeProvider

extension Int8: WireTypeProvider {
    // Int8 does not conform to `FixedLengthWireType`, because
    // it's only needed for the `FixedWidth` property wrapper,
    // which has no effect on Int8
}

// MARK: FixedLengthWireType

extension Int16: FixedWidthCompatible {

    /**
     The wire type of the value when encoding it using a fixed length of two bytes.
     - Note: `Int16` values are not compatible with the protobuf definition, neither using fixed- or variable-length encoding.
     */
    public static var fixedLengthWireType: WireType { .length16 }
}

extension Int32: FixedWidthCompatible {

    /**
     The wire type of the value when encoding it using a fixed length of four bytes.
     - Note: `Int32` values are compatible with the protobuf definition, either using fixed-, signed- or variable-length encoding.
     */
    public static var fixedLengthWireType: WireType { .length32 }
}

extension Int64: FixedWidthCompatible {

    /**
     The wire type of the value when encoding it using a fixed length of eight bytes.
     - Note: `Int64` values are compatible with the protobuf definition, either using fixed-, signed- or variable-length encoding.
     */
    public static var fixedLengthWireType: WireType { .length64 }
}

// MARK: HostIndependentRepresentable

extension Int8: HostIndependentRepresentable {

    /**
     The host-independent representation of the value.

     For `Int8`, the host-independent representation is unchanged.
     */
    var hostIndependentRepresentation: Int8 {
        self
    }

    /**
     Create a value from its host-independent representation.

     For `Int8`, the host-independent representation is the same.
     */
    init(fromHostIndependentRepresentation value: Int8) {
        self = value
    }
}

extension Int16: HostIndependentRepresentable {

    /**
     Convert the value to a host-independent (little endian) format.
     */
    var hostIndependentRepresentation: UInt16 {
        CFSwapInt16HostToLittle(.init(bitPattern: self))
    }

    /**
     Create an `Int16` value from its host-independent (little endian) representation.
     - Parameter value: The host-independent representation
     */
    init(fromHostIndependentRepresentation value: UInt16) {
        self.init(bitPattern: CFSwapInt16LittleToHost(value))
    }
}

extension Int32: HostIndependentRepresentable {

    /**
     Convert the value to a host-independent (little endian) format.
     */
    var hostIndependentRepresentation: UInt32 {
        CFSwapInt32HostToLittle(.init(bitPattern: self))
    }

    /**
     Create an `Int32` value from its host-independent (little endian) representation.
     - Parameter value: The host-independent representation
     */
    init(fromHostIndependentRepresentation value: UInt32) {
        self.init(bitPattern: CFSwapInt32LittleToHost(value))
    }
}

extension Int64: HostIndependentRepresentable {

    /**
     Convert the value to a host-independent (little endian) format.
     */
    var hostIndependentRepresentation: UInt64 {
        CFSwapInt64HostToLittle(.init(bitPattern: self))
    }

    /**
     Create an `Int64` value from its host-independent (little endian) representation.
     - Parameter value: The host-independent representation
     */
    init(fromHostIndependentRepresentation value: UInt64) {
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
    func binaryData() -> Data {
        variableLengthEncoding
    }
}

extension SignedInteger {
    
    /// The wire type of the integer (`varint`)
    public static var wireType: WireType {
        .varint
    }
}

extension SignedInteger {

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

    /**
     Decode a signed integer from a data provider using variable-length encoding.

     - Parameter byteProvider: A closure providing the next byte in the data.
     - Throws: `ProtobufDecodingError` of type `invalidVarintEncoding`, `variableLengthEncodedValueOutOfRange` or `ProtobufDecodingError.missingData`
     - Returns: The decoded signed integer.
     */
    init(from byteProvider: DecodingDataProvider) throws {
        let value = try Int64.from(byteProvider)
        guard let result = Self.init(exactly: value) else {
            throw ProtobufDecodingError.variableLengthEncodedValueOutOfRange
        }
        self = result
    }

    /**
     Decode a signed integer using variable-length encoding and based on zig-zag storage of signed values.

     Decodes an unsigned integer, where the last bit indicates the sign, and the absolute value is half of the decoded value
     - Parameter byteProvider: A closure providing the next byte in the data.
     - Throws: `ProtobufDecodingError` of type `invalidVarintEncoding`, `variableLengthEncodedValueOutOfRange` or `ProtobufDecodingError.missingData`
     - Returns: The decoded signed integer.
     */
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
     
     Decodes an unsigned integer, where the last bit indicates the sign, and the absolute value is half of the decoded value of the remaining bits.
     - Parameter byteProvider: A closure providing the next byte in the data.
     - Throws: `ProtobufDecodingError.invalidVarintEncoding` or
     `ProtobufDecodingError.missingData`
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
     - Throws: `ProtobufDecodingError.invalidVarintEncoding` or
     `ProtobufDecodingError.missingData`
     - Returns: The decoded signed integer.
     */
    static func from(_ byteProvider: DecodingDataProvider) throws -> Int64 {
        Int64(bitPattern: try UInt64.from(byteProvider))
    }
}
