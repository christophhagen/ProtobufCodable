import Foundation

// MARK: BinaryEncodable

extension UInt8: BinaryCodable {
    
    public func binaryData() -> Data {
        [self].data
    }
    
    public init(from byteProvider: DecodingDataProvider) throws {
        self = try byteProvider.getNextByte()
    }
}

extension UInt16: BinaryCodable { }

extension UInt32: BinaryCodable { }

extension UInt64: BinaryCodable { }

extension UInt: BinaryCodable { }

// MARK: FixedLengthWireType

extension UInt8: FixedLengthWireType {
    
    public static var fixedLengthWireType: WireType { .length8 }
}

extension UInt16: FixedLengthWireType {
    
    public static var fixedLengthWireType: WireType { .length16 }
}

extension UInt32: FixedLengthWireType {
    
    public static var fixedLengthWireType: WireType { .length32 }
}

extension UInt64: FixedLengthWireType {
    
    public static var fixedLengthWireType: WireType { .length64 }
}

// Note: `UInt` does not conform to `FixedLengthWireType`,
// because it may have different width on different systems

// MARK: HostIndependentRepresentable

extension UInt8: HostIndependentRepresentable {
    
    public var hostIndependentRepresentation: UInt8 {
        self
    }
    
    public init(fromHostIndependentRepresentation value: UInt8) {
        self = value
    }
}

extension UInt16: HostIndependentRepresentable {
    
    public var hostIndependentRepresentation: UInt16 {
        CFSwapInt16HostToLittle(self)
    }
    
    public init(fromHostIndependentRepresentation value: UInt16) {
        self = CFSwapInt16LittleToHost(value)
    }
}

extension UInt32: HostIndependentRepresentable {
    
    public var hostIndependentRepresentation: UInt32 {
        CFSwapInt32HostToLittle(self)
    }
    
    public init(fromHostIndependentRepresentation value: UInt32) {
        self = CFSwapInt32LittleToHost(value)
    }
}

extension UInt64: HostIndependentRepresentable {
    
    public var hostIndependentRepresentation: UInt64 {
        CFSwapInt64HostToLittle(self)
    }
    
    public init(fromHostIndependentRepresentation value: UInt64) {
        self = CFSwapInt64LittleToHost(value)
    }
}

// MARK: Common unsigned functions

extension UnsignedInteger {
    
    /**
     Encodes the integer into binary data, using variable length encoding.
     - Returns: The binary data of the converted value.
     */
    public func binaryData() -> Data {
        variableLengthEncoding
    }
    
    /// The wire type of the integer (`varint`)
    public static var wireType: WireType {
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
    
    /**
     Decode an unsigned integer using variable length encoding.
     
     The first bit of each byte indicates if another byte follows.
     The remaining 7 bit are the first 7 bit of the number.
     - Throws: `BinaryDecodingError.missingData`
     - Returns: The decoded unsigned integer.
     */
    public init(from byteProvider: DecodingDataProvider) throws {
        let value = try UInt64.from(byteProvider)
        guard let result = Self.init(exactly: value) else {
            throw ProtobufDecodingError.variableLengthEncodedValueOutOfRange
        }
        self = result
    }
}

extension UInt64 {
    
    static func from(_ byteProvider: DecodingDataProvider) throws -> UInt64 {
        var result: UInt64 = 0
        
        // There are always usable 7 bits per byte, for 9 bytes
        for shift in stride(from: 0, through: 56, by: 7) {
            let nextByte = UInt64(try byteProvider.getNextByte())
            // Insert the last 7 bit of the byte at the end
            result += UInt64(nextByte & 0x7F) << shift
            // Check if an additional byte is coming
            guard nextByte & 0x80 > 0 else {
                return result
            }
        }
        // If we're here, the 9th byte had the MSB set
        let nextByte = UInt64(try byteProvider.getNextByte())
        // Only 0x01 and 0x00 are valid for the 10th byte, or the UInt64 would overflow
        guard nextByte & ~1 == 0 else {
            throw ProtobufDecodingError.invalidVarintEncoding
        }
        result += UInt64(nextByte & 0x7F) << 63
        return result
    }
}
