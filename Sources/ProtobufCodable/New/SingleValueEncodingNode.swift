import Foundation

final class SingleValueEncodingNode: SingleValueEncodingContainer {
    
    var codingPath: [CodingKey]
    
    var data: Data?
    
    private var encodedTypeInfo: String?
    
    init(codingPath: [CodingKey]) {
        self.codingPath = codingPath
    }
    
    func encodeNil() throws {
        guard data == nil else {
            throw ProtobufEncodingError.multipleValuesEncodedInSingleValueContainer
        }
        self.data = .empty
        self.encodedTypeInfo = "nil"
    }
    
    private func encodePrimitive(_ primitive: BinaryEncodable) throws {
        #warning("Should values be ommitted sometimes?")
//        if primitive.isDefaultValue && omitDefaultValues {
//            self.data = .empty
//            return
//        }
//        let data = try primitive.binaryData()
//        if primitive.wireType == .lengthDelimited {
//            // Prepend the length for primitive types like `String` and `Data`
//            self.data = data.count.variableLengthEncoding + data
//        } else {
//            self.data = data
//        }
        self.data = try primitive.binaryData()
        self.encodedTypeInfo = "\(type(of: primitive)): \(primitive)"
    }
    
    func encode<T>(_ value: T) throws where T: Encodable {
        guard data == nil else {
            throw ProtobufEncodingError.multipleValuesEncodedInSingleValueContainer
        }
        switch value {
        case let primitive as BinaryEncodable:
            try encodePrimitive(primitive)
        default:
            #warning("Encode complex types in SingleValueContainer")
            throw ProtobufEncodingError.notImplemented
        }
    }
}

extension SingleValueEncodingNode: EncodedDataProvider {
    
    func getEncodedData() throws -> Data {
        data ?? .empty
    }
}

extension SingleValueEncodingNode: CustomStringConvertible {
    
    var description: String {
        encodedTypeInfo ?? "\(type(of: self))"
    }
}
