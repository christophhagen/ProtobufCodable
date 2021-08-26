import Foundation

// MARK: BinaryEncodable

extension UInt8: BinaryEncodable {
    
    public func binaryData() -> Data {
        [self].data
    }
}

extension UInt16: BinaryEncodable { }

extension UInt32: BinaryEncodable { }

extension UInt64: BinaryEncodable { }

extension UInt: BinaryEncodable { }

// MARK: FixedLengthWireType

extension UInt8: FixedLengthWireType {
    
    public var fixedLengthWireType: WireType { .length8 }
}

extension UInt16: FixedLengthWireType {
    
    public var fixedLengthWireType: WireType { .length16 }
}

extension UInt32: FixedLengthWireType {
    
    public var fixedLengthWireType: WireType { .length32 }
}

extension UInt64: FixedLengthWireType {
    
    public var fixedLengthWireType: WireType { .length64 }
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
