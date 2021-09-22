import Foundation

/**
 A wrapper for integer values which ensures that values are encoded in binary format using a fixed width.
 
 Use the property wrapped within a `Codable` definition to enforce fixed-width encoding for a property:
 ```
 struct MyStruct: Codable {
 
     /// Always encoded as 4 bytes
     @FixedWidth var largeInteger: Int32
 }
 ```
 */
@propertyWrapper
public struct FixedLength<WrappedValue>: BinaryCodable, Equatable where
    WrappedValue: FixedWidthInteger,
    WrappedValue: BinaryCodable,
    WrappedValue: FixedLengthWireType,
    WrappedValue: HostIndependentRepresentable {
    
    // MARK: Property wrapper
    
    /// The value wrapped in the fixed-width container
    public var wrappedValue: WrappedValue
    
    /**
     Wrap an integer value in a fixed-width container
     - Parameter wrappedValue: The integer to wrap
     */
    public init(wrappedValue: WrappedValue) {
        self.wrappedValue = wrappedValue
    }
    
    // MARK: BinaryEncodable
    
    /// The wrapped value is equal to the default value for the type.
    public static var defaultValue: Self {
        .init(wrappedValue: .defaultValue)
    }
    
    /**
     Encode the wrapped value to binary data compatible with the protobuf encoding.
     - Returns: The binary data in host-independent format.
     */
    public func binaryData() -> Data {
        wrappedValue.hostIndependentBinaryData
    }
    
    // MARK: WireTypeProvider
    
    /// The wire type of the wrapped value.
    public static var wireType: WireType {
        WrappedValue.fixedLengthWireType
    }
    
    // MARK: BinaryDecodable
    
    public init(from byteProvider: DecodingDataProvider) throws {
        let wrappedValue = try WrappedValue(binaryData: byteProvider)
        self.init(wrappedValue: wrappedValue)
    }
    
    // MARK: Codable

    /**
     Encode the wrapped value transparently to the given encoder.
     - Parameter encoder: The encoder to use for encoding.
     - Throws: Errors from the decoder when attempting to encode a value in a single value container.
     */
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self)
    }

    /**
     Decode a wrapped value from a decoder.
     - Parameter decoder: The decoder to use for decoding.
     - Throws: Errors from the decoder when reading a single value container or decoding the wrapped value from it.
     */
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self = try container.decode(Self.self)
    }
}

extension FixedLength where WrappedValue: AdditiveArithmetic {

    /**
     The zero value.

     Zero is the identity element for addition. For any value, `x + .zero == x` and `.zero + x == x`.

     */
    static var zero: Self {
        .init(wrappedValue: .zero)
    }
}

extension FixedLength where WrappedValue: FixedWidthInteger {

    /// The maximum representable integer in this type.
    ///
    /// For unsigned integer types, this value is `(2 ** bitWidth) - 1`, where
    /// `**` is exponentiation. For signed integer types, this value is
    /// `(2 ** (bitWidth - 1)) - 1`.
    static var max: Self {
        .init(wrappedValue: .max)
    }

    /// The minimum representable integer in this type.
    ///
    /// For unsigned integer types, this value is always `0`. For signed integer
    /// types, this value is `-(2 ** (bitWidth - 1))`, where `**` is
    /// exponentiation.
    static var min: Self {
        .init(wrappedValue: .min)
    }
}
