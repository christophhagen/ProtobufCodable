import Foundation

/**
 A wrapper for integer values which ensures that values are encoded in binary format using a fixed width.
 */
@propertyWrapper
public struct FixedLength<T>: BinaryPrimitiveEncodable, Codable where T: FixedWidthInteger, T: BinaryPrimitiveEncodable, T: FixedLengthWireType {
    
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
        toData(wrappedValue)
    }
    
    public var wireType: WireType {
        wrappedValue.fixedLengthWireType
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
