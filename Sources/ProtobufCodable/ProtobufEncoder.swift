import Foundation

public struct ProtobufEncoder {
    
    static let omitDefaultKey: CodingUserInfoKey = .init(rawValue: "omitDefaults")!
    
    /**
     Prevent default values (like `zero`) from being written to binary data.
     
     Omitting defaults is default protobuf behaviour to reduce the binary size.
     - Warning: If you specify `true` when encoding objects with optional values,
     any default value will be decoded as `nil`.
     */
    var omitDefaultValues: Bool
    
    public init(omitDefaultValues: Bool = false) {
        self.omitDefaultValues = omitDefaultValues
    }
    
    public func encode(_ value: Encodable) throws -> Data {
        let encoder = TopLevelEncodingContainer(codingPath: [], userInfo: [:])
        try value.encode(to: encoder)
        return try encoder.getEncodedData()
    }
    
    public func encodeOld(_ value: Encodable) throws -> Data {
        let userInfo: [CodingUserInfoKey : Any] = [ProtobufEncoder.omitDefaultKey : omitDefaultValues]
        let encoder = EncodingNode(userInfo: userInfo)
        try value.encode(to: encoder)
        return encoder.getEncodedData()
    }
}
