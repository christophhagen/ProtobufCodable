import Foundation

final class SingleValueEncodingNode: SingleValueEncodingContainer {
    
    let codingPath: [CodingKey]
    
    var data: Data?
    
    private var encodedTypeInfo: String?

    var encodesNil: Bool {
        data == nil
    }
    
    init(codingPath: [CodingKey]) {
        self.codingPath = codingPath
    }
    
    func encodeNil() throws {
        self.data = nil
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
        //self.data = try primitive.binaryData()
        self.data = try primitive.binaryDataIncludingLengthIfNeeded()
        self.encodedTypeInfo = "\(type(of: primitive)): \(primitive)"
    }
    
    func encode<T>(_ value: T) throws where T: Encodable {
        switch value {
        case let primitive as BinaryEncodable:
            try encodePrimitive(primitive)
        default:
            #warning("Encode complex types in SingleValueContainer")
            fatalError()
        }
    }
}

extension SingleValueEncodingNode: EncodedDataProvider {
    
    func getEncodedData() throws -> Data {
        data ?? .empty
    }

    func encodedObjects() throws -> [Data] {
        guard let d = data else {
            return []
        }
        return [d]
    }
}

extension SingleValueEncodingNode: CustomStringConvertible {
    
    var description: String {
        encodedTypeInfo ?? "\(type(of: self))"
    }
}
