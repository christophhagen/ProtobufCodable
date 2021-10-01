import Foundation

/**
 A wrapper for integer values which ensures that values are encoded in binary format using a fixed width.

 Use the property wrapped within a `Codable` definition to enforce fixed-width encoding for a property:
 ```swift
 struct MyStruct: Codable {

     /// Always encoded as 4 bytes
     @FixedWidth var largeInteger: Int32
 }
 ```

 By default, the `FixedWidth` property wrapper is supported for all integers (signed and unsigned), except for `Int8` and `UInt8` types.

 - SeeAlso: [Laguage Guide (proto3): Scalar value types](https://developers.google.com/protocol-buffers/docs/proto3#scalar)
 */
@propertyWrapper
public struct FixedWidth<WrappedValue> where WrappedValue: FixedWidthCompatible {

    /// The value wrapped in the fixed-width container
    public var wrappedValue: WrappedValue

    /**
     Wrap an integer value in a fixed-width container
     - Parameter wrappedValue: The integer to wrap
     */
    public init(wrappedValue: WrappedValue) {
        self.wrappedValue = wrappedValue
    }
}

extension FixedWidth: Equatable where WrappedValue: Equatable {

}

extension FixedWidth: BinaryEncodable where WrappedValue: BinaryEncodable, WrappedValue: HostIndependentRepresentable {

    /**
     Encode the wrapped value to binary data compatible with the protobuf encoding.
     - Returns: The binary data in host-independent format.
     */
    func binaryData() -> Data {
        wrappedValue.hostIndependentBinaryData
    }

    var isDefaultValue: Bool {
        wrappedValue.isDefaultValue
    }
}

extension FixedWidth: WireTypeProvider {

    /// The wire type of the wrapped value.
    public static var wireType: WireType {
        WrappedValue.fixedLengthWireType
    }
}

extension FixedWidth: ByteDecodable where WrappedValue: BinaryDecodable, WrappedValue: HostIndependentRepresentable {

}

extension FixedWidth: BinaryDecodable where WrappedValue: BinaryDecodable, WrappedValue: HostIndependentRepresentable {

    /// The wrapped value is equal to the default value for the type.
    static var defaultValue: Self {
        .init(wrappedValue: .defaultValue)
    }

    init(from byteProvider: DecodingDataProvider) throws {
        let wrappedValue = try WrappedValue(binaryData: byteProvider)
        self.init(wrappedValue: wrappedValue)
    }

}

extension FixedWidth: Encodable where WrappedValue: Encodable {

    /**
     Encode the wrapped value transparently to the given encoder.
     - Parameter encoder: The encoder to use for encoding.
     - Throws: Errors from the decoder when attempting to encode a value in a single value container.
     */
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self)
    }
}

extension FixedWidth: Decodable where WrappedValue: Decodable {
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

extension FixedWidth where WrappedValue: AdditiveArithmetic {

    /**
     The zero value.

     Zero is the identity element for addition. For any value, `x + .zero == x` and `.zero + x == x`.
     */
    static var zero: Self {
        .init(wrappedValue: .zero)
    }
}

extension FixedWidth where WrappedValue: FixedWidthInteger {

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
