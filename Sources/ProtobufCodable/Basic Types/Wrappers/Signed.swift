import Foundation

/**
 A wrapper for integer values which ensures that values are encoded in binary format using a zig-zag encoding.
 This encoding is more efficient for small negative values than standard variable-length encoding.
 
 Use the property wrapped within a `Codable` definition to enforce zig-zag encoding for a property:
 ```
 struct MyStruct: Codable {
 
     /// Efficiently encodes small negative numbers
     @SignedValue var signedInteger: Int32
 }
 */
@propertyWrapper
public struct SignedValue<T>: BinaryEncodable where T: BinaryEncodable, T: SignedInteger {
    
    // MARK: Property wrapper
    
    /// The value wrapped in the container
    public var wrappedValue: T
    
    /**
     Wrap a signed integer value in a container
     - Parameter wrappedValue: The integer to wrap
     */
    public init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }
    
    // MARK: BinaryPrimitiveEncodable
    
    /// The wrapped value is equal to the default value for the type.
    public var isDefaultValue: Bool {
        wrappedValue.isDefaultValue
    }
    
    /**
     Encode the wrapped value to binary data compatible with the protobuf encoding.
     - Returns: The binary data in host-independent format.
     */
    public func binaryData() -> Data {
        Int64(wrappedValue).zigZagEncoding
    }
    
    /// The wire type of the wrapped value.
    public var wireType: WireType {
        wrappedValue.wireType
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
        self.init(wrappedValue: try container.decode(T.self))
    }
}
