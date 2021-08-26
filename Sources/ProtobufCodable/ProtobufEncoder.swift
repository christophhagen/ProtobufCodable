import Foundation

enum ProtobufEncodingError: Error {
    
    case missingIntegerCodingKey(CodingKey)
    
    case notImplemented
    
    /**
     A string value can't be represented using UTF-8 encoding.
     */
    case stringNotRepresentableInUTF8(_ failingString: String)
}

public struct ProtobufEncoder {
    
    let encoder: EncodingNode
    
    public init() {
        self.encoder = EncodingNode()
    }
    
    public func encode(_ value: Encodable) throws -> Data {
        try value.encode(to: encoder)
        //encoder.printTree()
        return encoder.getEncodedData()
    }
    
    private func encode(_ data: Data) -> Data {
        guard !data.isEmpty else {
            return .empty
        }
        return data.count.variableLengthEncoding + data
    }
}



