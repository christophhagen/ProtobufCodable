import Foundation

/**
 A wrapper for integer values which ensures that values are encoded in binary format using a zig-zag encoding.
 This encoding is more efficient for small negative values than standard variable-length encoding.
 */
@propertyWrapper
public struct SignedValue<T>: BinaryPrimitiveEncodable where T: BinaryPrimitiveEncodable, T: SignedInteger {
    
    // MARK: Property wrapper
    
    public var wrappedValue: T
    
    public init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }
    
    // MARK: BinaryPrimitiveEncodable
    
    public var isDefaultValue: Bool {
        wrappedValue.isDefaultValue
    }
    
    public func binaryData() -> Data {
        Int64(wrappedValue).zigZagEncoding
    }
    
    public var wireType: WireType {
        wrappedValue.wireType
    }
    
    // MARK: Codable

    enum CodingKeys: Int, CodingKey {
        case wrappedValue = 1
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.init(wrappedValue: try container.decode(T.self))
    }
}
