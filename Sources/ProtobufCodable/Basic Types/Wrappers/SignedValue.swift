import Foundation

/// A signed integer which can be forced to use zig-zag encoding.
public protocol SignedValueCompatible: SignedInteger {

}

/**
 A wrapper for integer values which ensures that values are encoded in binary format using a zig-zag encoding.
 This encoding is more efficient for small negative values than standard variable-length encoding.
 
 Use the property wrapped within a `Codable` definition to enforce zig-zag encoding for a property:
 ```swift
 struct MyStruct: Codable {
 
     /// Efficiently encodes small negative numbers
     @SignedValue var signedInteger: Int32
 }
 ```

 By default, the `SignedValue` property wrapper is supported for all signed integers (`Int8`, `Int16`, `Int32`, `Int64`, and `Int`)
 
 - SeeAlso: [Laguage Guide (proto3): Scalar value types](https://developers.google.com/protocol-buffers/docs/proto3#scalar)
 */
@propertyWrapper
public struct SignedValue<WrappedValue> where WrappedValue: SignedValueCompatible {
    
    /// The value wrapped in the container
    public var wrappedValue: WrappedValue
    
    /**
     Wrap a signed integer value in a container
     - Parameter wrappedValue: The integer to wrap
     */
    public init(wrappedValue: WrappedValue) {
        self.wrappedValue = wrappedValue
    }
}

extension SignedValue: WireTypeProvider where WrappedValue: WireTypeProvider {

    /// The wire type of the wrapped value.
    public static var wireType: WireType {
        WrappedValue.wireType
    }
}

extension SignedValue: BinaryEncodable where WrappedValue: BinaryEncodable, WrappedValue: SignedInteger {
    
    var isDefaultValue: Bool {
        wrappedValue.isDefaultValue
    }

    /**
     Encode the wrapped value to binary data compatible with the protobuf encoding.
     - Returns: The binary data in host-independent format.
     */
    func binaryData() -> Data {
        Int64(wrappedValue).zigZagEncoding
    }
}

extension SignedValue: Equatable where WrappedValue: Equatable {

}

extension SignedValue: ByteDecodable where WrappedValue: BinaryDecodable {

}

extension SignedValue: BinaryDecodable where WrappedValue: BinaryDecodable {

    /// The wrapped value is equal to the default value for the type.
    static var defaultValue: Self {
        .init(wrappedValue: .defaultValue)
    }

    init(from byteProvider: DecodingDataProvider) throws {
        let wrappedValue = try WrappedValue(zigZagEncodedFrom: byteProvider)
        self.init(wrappedValue: wrappedValue)
    }
}

    // MARK: Codable
extension SignedValue: Encodable where WrappedValue: Encodable {

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

extension SignedValue: Decodable where WrappedValue: Decodable {
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

extension SignedValue where WrappedValue: AdditiveArithmetic {

    /**
     The zero value.

     Zero is the identity element for addition. For any value, `x + .zero == x` and `.zero + x == x`.

     */
    static var zero: Self {
        .init(wrappedValue: .zero)
    }
}

extension SignedValue where WrappedValue: FixedWidthInteger {

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
