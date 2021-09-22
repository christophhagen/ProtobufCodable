import Foundation

final class SingleValueEncodingNode: SingleValueEncodingContainer {
    
    let codingPath: [CodingKey]
    
    var object: EncodedDataWrapper?
    
    private var encodedTypeInfo: String?

    var encodesNil: Bool {
        object == nil
    }
    
    init(codingPath: [CodingKey]) {
        self.codingPath = codingPath
    }
    
    func encodeNil() throws {
        self.object = nil
        self.encodedTypeInfo = "nil"
    }
    
    private func encodePrimitive(_ primitive: BinaryEncodable) throws {
        #warning("Should values be ommitted sometimes?")
//        if primitive.isDefaultValue && omitDefaultValues {
//            self.data = .empty
//            return
//        }
        self.object = try primitive.encoded()
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

    func encodedObjects() throws -> [EncodedDataWrapper] {
        guard let object = object else {
            return []
        }
        return [object]
    }
}

extension SingleValueEncodingNode: CustomStringConvertible {
    
    var description: String {
        encodedTypeInfo ?? "\(type(of: self))"
    }
}
